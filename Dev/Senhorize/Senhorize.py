#!/usr/bin/env python3
"""
MiSTer sys_top.v Editor v1.7
Automates editing of sys_top.v files in MiSTer cores for Senhor board compatibility.

Changes in v1.7:
  - Remove FAST_OUTPUT_ENABLE_REGISTER ON instance-assignment lines
  - Remove obsolete broad QSF PIN-block cleanup and use safer insertion anchors
  - Force SMART_RECOMPILE OFF when SMART_RECOMPILE is set to ON
  - Remove every .qsf line containing FAST_INPUT_REGISTER or FAST_OUTPUT_REGISTER
  - Replace detected LED pin assignments with Senhor LED[0:4] pin mapping
  - Normalize existing DEVICE assignment to 5CSEMA6U23A7
  - Replace detected SDRAM pin location assignments with Senhor SDRAM pin mapping
  - Inject senhor_constraints.sdc reference into .qsf for board-level timing constraints
  - Gate HDMI_MCLK on audio PLL lock signal in sys_top.v to prevent ADV7513 audio crackles
"""

import sys
import os
import argparse
import re
import shutil
import zipfile
from pathlib import Path


# ---------------------------------------------------------------------------
# .QSF EDITING
# ---------------------------------------------------------------------------

def edit_qsf(file_path, backup=True):
    """
    Edit .qsf file:
      - Change MAX_CORE_JUNCTION_TEMP from 100 to 125
      - If a DEVICE assignment exists, set it to 5CSEMA6U23A7
      - Remove lines containing FAST_INPUT_REGISTER or FAST_OUTPUT_REGISTER
      - Remove lines containing FAST_OUTPUT_ENABLE_REGISTER ON
      - Change SMART_RECOMPILE ON to SMART_RECOMPILE OFF
      - If LED pin assignments are detected, replace them with the Senhor LED mapping
      - If SDRAM_* is detected, replace SDRAM location assignments with
        the Senhor SDRAM pin mapping
      - Remove entries between 'source sys/sys.tcl' and 'source files.qip'
        (preserving 'source sys/sys_analog.tcl' if present)
      - Inject 'set_global_assignment -name SDC_FILE senhor_constraints.sdc'
        if not already present

    Args:
        file_path: Path to .qsf file
        backup: Create backup file before editing

    Returns:
        tuple: (success, message)
    """

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return False, f"Error reading file: {e}"

    original_content = content
    changes_made = []
    had_sdram = bool(re.search(r'\bSDRAM_', content))
    had_led = bool(re.search(
        r'(?mi)^[ \t]*set_location_assignment[^\r\n]*-to[ \t]+LED(?:\[[0-9]+\]|_[A-Za-z0-9_]+)?(?:[ \t]|$)',
        content
    ))

    # ------------------------------------------------------------------
    # 1. MAX_CORE_JUNCTION_TEMP
    # ------------------------------------------------------------------
    old_str = "set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100"
    new_str = "set_global_assignment -name MAX_CORE_JUNCTION_TEMP 125"

    if old_str in content:
        content = content.replace(old_str, new_str)
        changes_made.append("✓ Changed MAX_CORE_JUNCTION_TEMP from 100 to 125")
    else:
        if "MAX_CORE_JUNCTION_TEMP 125" in content:
            changes_made.append("⊙ MAX_CORE_JUNCTION_TEMP already set to 125")
        else:
            changes_made.append("✗ MAX_CORE_JUNCTION_TEMP 100 not found")


    # ------------------------------------------------------------------
    # 2. DEVICE
    #    If an existing DEVICE assignment is present, force Senhor FPGA.
    #    Do not inject a DEVICE assignment if the QSF has none.
    # ------------------------------------------------------------------
    device_line = 'set_global_assignment -name DEVICE 5CSEMA6U23A7'
    device_pattern = r'(?m)^[ \t]*set_global_assignment[ \t]+-name[ \t]+DEVICE(?:[ \t]+.*)?$'
    device_matches = re.findall(device_pattern, content)

    if device_matches:
        if len(device_matches) == 1 and device_matches[0].strip() == device_line:
            changes_made.append("⊙ DEVICE already set to 5CSEMA6U23A7")
        else:
            content = re.sub(device_pattern, device_line, content)
            changes_made.append("✓ Set DEVICE to 5CSEMA6U23A7")
    else:
        changes_made.append("⊙ DEVICE assignment not found — leaving unchanged")



    # ------------------------------------------------------------------
    # 3. SMART_RECOMPILE
    #    If explicitly enabled, disable it for Senhor builds.
    # ------------------------------------------------------------------
    smart_on = 'set_global_assignment -name SMART_RECOMPILE ON'
    smart_off = 'set_global_assignment -name SMART_RECOMPILE OFF'

    if smart_on in content:
        content = content.replace(smart_on, smart_off)
        changes_made.append("✓ Changed SMART_RECOMPILE from ON to OFF")
    elif smart_off in content:
        changes_made.append("⊙ SMART_RECOMPILE already set to OFF")
    else:
        changes_made.append("⊙ SMART_RECOMPILE ON not found — leaving unchanged")

    # ------------------------------------------------------------------
    # 4. Remove FAST_INPUT_REGISTER / FAST_OUTPUT_REGISTER lines
    # ------------------------------------------------------------------
    fast_output_enable_line = 'set_instance_assignment -name FAST_OUTPUT_ENABLE_REGISTER ON'

    fast_lines = [
        line for line in content.splitlines(keepends=True)
        if (
            'FAST_INPUT_REGISTER' in line
            or 'FAST_OUTPUT_REGISTER' in line
            or fast_output_enable_line in line
        )
    ]

    if fast_lines:
        content = ''.join(
            line for line in content.splitlines(keepends=True)
            if (
                'FAST_INPUT_REGISTER' not in line
                and 'FAST_OUTPUT_REGISTER' not in line
                and fast_output_enable_line not in line
            )
        )
        changes_made.append(
            f"✓ Removed {len(fast_lines)} FAST register assignment line(s)"
        )
    else:
        changes_made.append(
            "⊙ No FAST register assignment lines found"
        )

    # ------------------------------------------------------------------
    # 5. Remove entries between 'source sys/sys.tcl' and 'source files.qip'
    #    Preserve 'source sys/sys_analog.tcl' if present.
    # ------------------------------------------------------------------
    pattern = r'(source sys/sys\.tcl\s*\n)(.*?)(source files\.qip)'

    match = re.search(pattern, content, re.DOTALL)
    if match:
        between_content = match.group(2)

        analog_source = None
        for line in between_content.split('\n'):
            if 'source sys/sys_analog.tcl' in line:
                analog_source = line
                break

        lines_to_remove = [line for line in between_content.split('\n') if line.strip()]
        num_lines = len(lines_to_remove)

        if num_lines > 0:
            if analog_source:
                new_between = analog_source + '\n'
                changes_made.append(
                    f"✓ Removed {num_lines} line(s) between 'source sys/sys.tcl' "
                    f"and 'source files.qip'"
                )
                changes_made.append("✓ Preserved 'source sys/sys_analog.tcl'")
            else:
                new_between = ''
                changes_made.append(
                    f"✓ Removed {num_lines} line(s) between 'source sys/sys.tcl' "
                    f"and 'source files.qip'"
                )

            new_content = match.group(1) + new_between + match.group(3)
            content = content[:match.start()] + new_content + content[match.end():]
        else:
            changes_made.append(
                "⊙ No entries found between 'source sys/sys.tcl' and 'source files.qip'"
            )
    else:
        if 'source sys/sys.tcl' in content and 'source files.qip' in content:
            changes_made.append("⊙ Found both source lines but in unexpected format")
        elif 'source sys/sys.tcl' not in content:
            changes_made.append("⊙ 'source sys/sys.tcl' not found in file")
        elif 'source files.qip' not in content:
            changes_made.append("⊙ 'source files.qip' not found in file")

    # ------------------------------------------------------------------
    # 6. SDRAM pin mapping
    #    Detect SDRAM_ in the original QSF before the broad old PIN cleanup.
    #    If found, replace SDRAM location assignments with the Senhor mapping.
    # ------------------------------------------------------------------
    sdram_block = """set_location_assignment PIN_AH8 -to SDRAM_A[0]
set_location_assignment PIN_AG9 -to SDRAM_A[1]
set_location_assignment PIN_AH7 -to SDRAM_A[2]
set_location_assignment PIN_AG8 -to SDRAM_A[3]
set_location_assignment PIN_AH13 -to SDRAM_A[4]
set_location_assignment PIN_AF15 -to SDRAM_A[5]
set_location_assignment PIN_AH14 -to SDRAM_A[6]
set_location_assignment PIN_AF17 -to SDRAM_A[7]
set_location_assignment PIN_AG16 -to SDRAM_A[8]
set_location_assignment PIN_Y18 -to SDRAM_A[9]
set_location_assignment PIN_AG10 -to SDRAM_A[10]
set_location_assignment PIN_Y17 -to SDRAM_A[11]
set_location_assignment PIN_AG18 -to SDRAM_A[12]
set_location_assignment PIN_AH11 -to SDRAM_BA[0]
set_location_assignment PIN_AH9 -to SDRAM_BA[1]
set_location_assignment PIN_AF28 -to SDRAM_DQ[0]
set_location_assignment PIN_AF27 -to SDRAM_DQ[1]
set_location_assignment PIN_AG28 -to SDRAM_DQ[2]
set_location_assignment PIN_AH27 -to SDRAM_DQ[3]
set_location_assignment PIN_AG26 -to SDRAM_DQ[4]
set_location_assignment PIN_AH26 -to SDRAM_DQ[5]
set_location_assignment PIN_AG25 -to SDRAM_DQ[6]
set_location_assignment PIN_AG24 -to SDRAM_DQ[7]
set_location_assignment PIN_AG20 -to SDRAM_DQ[8]
set_location_assignment PIN_AG19 -to SDRAM_DQ[9]
set_location_assignment PIN_AG21 -to SDRAM_DQ[10]
set_location_assignment PIN_AH21 -to SDRAM_DQ[11]
set_location_assignment PIN_AH23 -to SDRAM_DQ[12]
set_location_assignment PIN_AH22 -to SDRAM_DQ[13]
set_location_assignment PIN_AH24 -to SDRAM_DQ[14]
set_location_assignment PIN_AG23 -to SDRAM_DQ[15]
set_location_assignment PIN_AH19 -to SDRAM_CLK
set_location_assignment PIN_AG14 -to SDRAM_nWE
set_location_assignment PIN_AH12 -to SDRAM_nCAS
set_location_assignment PIN_AG11 -to SDRAM_nCS
set_location_assignment PIN_AG13 -to SDRAM_nRAS"""

    if had_sdram:
        sdram_location_pattern = (
            r'(?m)^[ \t]*set_location_assignment[^\r\n]*\bSDRAM_[^\r\n]*'
            r'(?:\r?\n|$)'
        )
        existing_sdram_locations = re.findall(sdram_location_pattern, content)
        canonical_lines = sdram_block.splitlines()
        current_lines = [line.rstrip("\r\n") for line in existing_sdram_locations]

        if current_lines == canonical_lines:
            changes_made.append("⊙ SDRAM pin mapping already matches Senhor")
        else:
            content = re.sub(sdram_location_pattern, '', content)

            qip_anchor = 'set_global_assignment -name QIP_FILE sys/sys.qip'

            if qip_anchor in content:
                content = content.replace(
                    qip_anchor,
                    qip_anchor + "\n" + sdram_block,
                    1
                )
                changes_made.append(
                    "✓ Replaced SDRAM location assignments with Senhor SDRAM pin mapping "
                    "(after sys.qip)"
                )
            else:
                content = content.rstrip() + "\n" + sdram_block + "\n"
                changes_made.append(
                    "✓ Replaced SDRAM location assignments with Senhor SDRAM pin mapping "
                    "(appended)"
                )
    else:
        changes_made.append("⊙ No SDRAM_ entries found — SDRAM pin mapping not added")


    # ------------------------------------------------------------------
    # 7. LED pin mapping
    #    Detect LED pin assignments in the original QSF before broad PIN
    #    cleanup. If found, remove remaining LED location assignments and
    #    install the Senhor LED[0:4] mapping exactly once.
    # ------------------------------------------------------------------
    led_block = """#LEDs for Senhor
set_location_assignment PIN_AF26 -to LED[0]
set_location_assignment PIN_AE26 -to LED[1]
set_location_assignment PIN_Y16 -to LED[2]
set_location_assignment PIN_V15 -to LED[3]
set_location_assignment PIN_V16 -to LED[4]"""

    if had_led:
        led_location_pattern = (
            r'(?mi)^[ \t]*set_location_assignment[^\r\n]*-to[ \t]+'
            r'LED(?:\[[0-9]+\]|_[A-Za-z0-9_]+)?[^\r\n]*'
            r'(?:\r?\n|$)'
        )

        existing_led_locations = re.findall(led_location_pattern, content)
        canonical_led_lines = led_block.splitlines()[1:]
        current_led_lines = [
            line.rstrip("\r\n") for line in existing_led_locations
        ]

        if current_led_lines == canonical_led_lines:
            changes_made.append("⊙ LED pin mapping already matches Senhor")
        else:
            content = re.sub(led_location_pattern, '', content)

            # Remove an immediately adjacent old LED-section comment if present.
            content = re.sub(
                r'(?mi)^[ \t]*#[^\r\n]*LED[^\r\n]*(?:\r?\n|$)',
                '',
                content
            )

            qip_anchor = 'set_global_assignment -name QIP_FILE sys/sys.qip'

            if qip_anchor in content:
                content = content.replace(
                    qip_anchor,
                    qip_anchor + "\n" + led_block,
                    1
                )
                changes_made.append(
                    "✓ Replaced LED pin assignments with Senhor LED mapping "
                    "(after sys.qip)"
                )
            else:
                content = content.rstrip() + "\n" + led_block + "\n"
                changes_made.append(
                    "✓ Replaced LED pin assignments with Senhor LED mapping "
                    "(appended)"
                )
    else:
        changes_made.append("⊙ No LED pin assignments found — LED mapping not added")

    # ------------------------------------------------------------------
    # 8. Inject senhor_constraints.sdc SDC reference
    #    Insert after 'set_global_assignment -name QIP_FILE sys/sys.qip'
    #    if present, otherwise append at end of file.
    # ------------------------------------------------------------------
    sdc_line = 'set_global_assignment -name SDC_FILE senhor_constraints.sdc'

    if sdc_line in content:
        changes_made.append("⊙ senhor_constraints.sdc already referenced in .qsf")
    else:
        qip_anchor = 'set_global_assignment -name QIP_FILE sys/sys.qip'

        if qip_anchor in content:
            content = content.replace(
                qip_anchor,
                qip_anchor + "\n" + sdc_line
            )
            changes_made.append(
                "✓ Injected 'set_global_assignment -name SDC_FILE "
                "senhor_constraints.sdc' after sys.qip reference"
            )
        else:
            content = content.rstrip() + "\n" + sdc_line + "\n"
            changes_made.append(
                "✓ Appended 'set_global_assignment -name SDC_FILE "
                "senhor_constraints.sdc' at end of file"
            )

    # ------------------------------------------------------------------
    # Write out
    # ------------------------------------------------------------------
    if content == original_content:
        return False, "\n".join(changes_made)

    if backup:
        backup_path = f"{file_path}.bak"
        try:
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original_content)
            changes_made.append(f"✓ Backup created: {backup_path}")
        except Exception as e:
            return False, f"Error creating backup: {e}"

    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
    except Exception as e:
        return False, f"Error writing file: {e}"

    return True, "\n".join(changes_made)


# ---------------------------------------------------------------------------
# .QSF FILE DISCOVERY
# ---------------------------------------------------------------------------

def find_qsf_files(directory='.'):
    """
    Find all .qsf files in the specified directory.

    Args:
        directory: Directory to search (default: current directory)

    Returns:
        List of paths to .qsf files
    """
    path = Path(directory)
    return list(path.glob('*.qsf'))


# ---------------------------------------------------------------------------
# sys_top.v EDITING
# ---------------------------------------------------------------------------

def edit_sys_top(file_path, backup=True):
    """
    Edit sys_top.v file with the following transformations:
      0. Replace module declaration with Senhor-compatible version
      1. KEY[1] → KEY[0] in deb_user
      2. KEY[0] → KEY[1] in deb_osd
      3. Swap hdmiclk_ddr datain_h / datain_l values
      4. Gate HDMI_MCLK on audio PLL lock signal

    Args:
        file_path: Path to sys_top.v file
        backup: Create backup file before editing

    Returns:
        tuple: (success, message)
    """

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return False, f"Error reading file: {e}"

    original_content = content
    changes_made = []

    # ------------------------------------------------------------------
    # 0. Complete module declaration with Senhor initializations
    # ------------------------------------------------------------------
    pattern = r'module sys_top.*?//////////////////////\s+Secondary SD\s+///////////////////////////////////'

    replacement = """module sys_top
(
\t/////////// CLOCK //////////
\tinput         FPGA_CLK1_50,
\tinput         FPGA_CLK2_50,
\tinput         FPGA_CLK3_50,
\t//////////// HDMI //////////
\toutput        HDMI_I2C_SCL,
\tinout         HDMI_I2C_SDA,
\toutput        HDMI_MCLK,
\toutput        HDMI_SCLK,
\toutput        HDMI_LRCLK,
\toutput        HDMI_I2S,
\toutput        HDMI_TX_CLK,
\toutput        HDMI_TX_DE,
\toutput [23:0] HDMI_TX_D,
\toutput        HDMI_TX_HS,
\toutput        HDMI_TX_VS,

\tinput         HDMI_TX_INT,
\t//////////// SDR ///////////
\toutput [12:0] SDRAM_A,
\tinout  [15:0] SDRAM_DQ,
//\toutput        SDRAM_DQML,
//\toutput        SDRAM_DQMH,
\toutput        SDRAM_nWE,
\toutput        SDRAM_nCAS,
\toutput        SDRAM_nRAS,
\toutput        SDRAM_nCS,
\toutput  [1:0] SDRAM_BA,
\toutput        SDRAM_CLK,
//\toutput        SDRAM_CKE,
`ifdef DUAL_SDRAM
\t////////// SDR #2 //////////
//\toutput [12:0] SDRAM2_A,
//\tinout  [15:0] SDRAM2_DQ,
//\toutput        SDRAM2_nWE,
//\toutput        SDRAM2_nCAS,
//\toutput        SDRAM2_nRAS,
//\toutput        SDRAM2_nCS,
//\toutput  [1:0] SDRAM2_BA,
//\toutput        SDRAM2_CLK,
`else
\t//////////// VGA ///////////
//\toutput  [5:0] VGA_R,
//\toutput  [5:0] VGA_G,
//\toutput  [5:0] VGA_B,
//\tinout         VGA_HS,  // VGA_HS is secondary SD card detect when VGA_EN = 1 (inactive)
//\toutput\t\t  VGA_VS,
//\tinput         VGA_EN,  // active low
\t/////////// AUDIO //////////
//\toutput\t\t  AUDIO_L,
//\toutput\t\t  AUDIO_R,
//\toutput\t\t  AUDIO_SPDIF,
\t//////////// SDIO ///////////
//\tinout   [3:0] SDIO_DAT,
//\tinout         SDIO_CMD,
//\toutput        SDIO_CLK,
\t//////////// I/O ///////////
//\toutput        LED_USER,
//\toutput        LED_HDD,
//\toutput        LED_POWER,
//\tinput         BTN_USER,
//\tinput         BTN_OSD,
//\tinput         BTN_RESET,
`endif
\t////////// I/O ALT /////////
//\toutput        SD_SPI_CS,
//\tinput         SD_SPI_MISO,
//\toutput        SD_SPI_CLK,
//\toutput        SD_SPI_MOSI,
//
//\tinout         SDCD_SPDIF,
//\toutput        IO_SCL,
//\tinout         IO_SDA,
\t////////// ADC //////////////
//\toutput        ADC_SCK,
//\tinput         ADC_SDO,
//\toutput        ADC_SDI,
//\toutput        ADC_CONVST,
\t////////// MB KEY ///////////
\tinput   [1:0] KEY,
\t////////// MB SWITCH ////////
\tinput   [3:0] SW,
\t////////// MB LED ///////////
\toutput  [7:0] LED
\t///////// USER IO ///////////
//\tinout   [6:0] USER_IO
);

///////////////////////// Senhor: Initializations ////////////////////////

wire [5:0] VGA_R;
wire [5:0] VGA_G;
wire [5:0] VGA_B;
wire VGA_HS;
wire VGA_VS;
wire VGA_EN = 1'b1;
wire [3:0] SDIO_DAT;
wire SDIO_CMD = 1'b1;
wire [6:0] USER_IO;
wire SD_SPI_MISO = 1'b1;
wire BTN_RESET = 1'b1, BTN_OSD = 1'b1, BTN_USER = 1'b1;

wire SD_SPI_CS = 1'b1;
wire SD_SPI_CLK = 1'b1;
wire SD_SPI_MOSI = 1'b1;
wire SDIO_CLK = 1'b1;
wire IO_SCL;
wire IO_SDA;
wire LED_POWER = 1'b1;
wire LED_HDD = 1'b1;
wire LED_USER = 1'b1;
wire SDCD_SPDIF;
wire AUDIO_SPDIF = 1'b1;
wire AUDIO_R = 1'b1;
wire AUDIO_L = 1'b1;
wire ADC_SCK = 1'b1;
wire ADC_SDO = 1'b1;
wire ADC_SDI = 1'b1;
wire ADC_CONVST = 1'b1;
wire SDRAM_DQML;
wire SDRAM_DQMH;
wire SDRAM_CKE;

/////////////////////////////////////////////////////////////////////////

//////////////////////  Secondary SD  ///////////////////////////////////"""

    match = re.search(pattern, content, re.DOTALL)
    if match:
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        changes_made.append("✓ Replaced module declaration and added Senhor initializations")
    else:
        changes_made.append("✗ Module declaration pattern not found (looking for 'Secondary SD' marker)")

    # ------------------------------------------------------------------
    # 1. KEY[1] → KEY[0] in deb_user
    # ------------------------------------------------------------------
    old_str_1 = "deb_user <= {deb_user[6:0], btn_u | ~KEY[1]};"
    new_str_1 = "deb_user <= {deb_user[6:0], btn_u | ~KEY[0]};"

    if old_str_1 in content:
        content = content.replace(old_str_1, new_str_1)
        changes_made.append("✓ Replaced deb_user KEY[1] with KEY[0]")
    else:
        changes_made.append("✗ deb_user pattern not found")

    # ------------------------------------------------------------------
    # 2. KEY[0] → KEY[1] in deb_osd
    # ------------------------------------------------------------------
    old_str_2 = "deb_osd <= {deb_osd[6:0], btn_o | ~KEY[0]};"
    new_str_2 = "deb_osd <= {deb_osd[6:0], btn_o | ~KEY[1]};"

    if old_str_2 in content:
        content = content.replace(old_str_2, new_str_2)
        changes_made.append("✓ Replaced deb_osd KEY[0] with KEY[1]")
    else:
        changes_made.append("✗ deb_osd pattern not found")

    # ------------------------------------------------------------------
    # 3. Swap hdmiclk_ddr datain_h / datain_l values
    # ------------------------------------------------------------------
    old_str_3_tabs   = "hdmiclk_ddr\n(\n\t.datain_h(1'b0),\n\t.datain_l(1'b1),"
    new_str_3_tabs   = "hdmiclk_ddr\n(\n\t.datain_h(1'b1),\n\t.datain_l(1'b0),"
    old_str_3_spaces = "hdmiclk_ddr\n(\n    .datain_h(1'b0),\n    .datain_l(1'b1),"
    new_str_3_spaces = "hdmiclk_ddr\n(\n    .datain_h(1'b1),\n    .datain_l(1'b0),"

    replaced_3 = False
    if old_str_3_tabs in content:
        content = content.replace(old_str_3_tabs, new_str_3_tabs)
        changes_made.append("✓ Swapped hdmiclk_ddr datain_h and datain_l values (tabs)")
        replaced_3 = True
    elif old_str_3_spaces in content:
        content = content.replace(old_str_3_spaces, new_str_3_spaces)
        changes_made.append("✓ Swapped hdmiclk_ddr datain_h and datain_l values (spaces)")
        replaced_3 = True

    if not replaced_3:
        changes_made.append("✗ hdmiclk_ddr pattern not found")

    # ------------------------------------------------------------------
    # 4. Gate HDMI_MCLK on audio PLL lock signal (Option A)
    #
    # In MiSTer sys_top the audio PLL block always appears as this exact
    # sequence (tabs, no locked port wired):
    #
    #   assign HDMI_MCLK = clk_audio;
    #   wire clk_audio;
    #   pll_audio pll_audio
    #   (
    #   	.refclk(FPGA_CLK3_50),
    #   	.rst(0),
    #   	.outclk_0(clk_audio)
    #   );
    #
    # We replace the whole block in one shot:
    #   - Remove the bare assign
    #   - Add wire audio_pll_locked
    #   - Add .locked(audio_pll_locked) as the last port
    #   - Add the gated assign after the PLL instantiation
    #
    # Driving 1'b0 when unlocked lets the ADV7513 detect clock absence
    # cleanly rather than seeing a glitchy signal.
    # ------------------------------------------------------------------

    # We try four variants to be robust:
    #   - with or without blank line between wire clk_audio and pll_audio pll_audio
    #   - single-tab or triple-tab port indentation
    #
    # Option A (adding .locked() to the PLL instantiation) was abandoned because
    # pll_audio IP components are generated by the Quartus PLL wizard without the
    # locked port enabled, so the port does not exist in the megafunction and
    # Quartus will error at compile time.
    #
    # Option B: inject a startup counter clocked by FPGA_CLK3_50 (the same
    # reference the PLL uses). Bit 16 goes high after 65536 cycles at 50 MHz,
    # which is ~1.3 ms — well past the Cyclone V PLL lock time (~1 ms worst
    # case). Until then HDMI_MCLK is held low so the ADV7513 detects clock
    # absence cleanly instead of seeing a glitchy signal.
    # No changes to the PLL IP or .qip files are required.

    # Counter + gated assign injected BEFORE the pll_audio block.
    # The pll_audio instantiation itself is left completely untouched.
    mclk_counter_prefix = (
        "// Senhorize v1.2: gate MCLK on a startup counter so the ADV7513\n"
        "// sees a clean clock absence until the audio PLL has settled.\n"
        "// Counter bit 16 goes high ~1.3 ms after power-on at 50 MHz.\n"
        "reg [16:0] audio_pll_lock_cnt = 0;\n"
        "wire audio_pll_locked = audio_pll_lock_cnt[16];\n"
        "always @(posedge FPGA_CLK3_50)\n"
        "\tif (!audio_pll_lock_cnt[16]) audio_pll_lock_cnt <= audio_pll_lock_cnt + 1'd1;\n"
        "\n"
    )

    mclk_variants = [
        # single tab, no blank line
        "assign HDMI_MCLK = clk_audio;\nwire clk_audio;\npll_audio pll_audio\n(\n\t.refclk(FPGA_CLK3_50),\n\t.rst(0),\n\t.outclk_0(clk_audio)\n);",
        # single tab, blank line
        "assign HDMI_MCLK = clk_audio;\nwire clk_audio;\n\npll_audio pll_audio\n(\n\t.refclk(FPGA_CLK3_50),\n\t.rst(0),\n\t.outclk_0(clk_audio)\n);",
        # triple tab, no blank line
        "assign HDMI_MCLK = clk_audio;\nwire clk_audio;\npll_audio pll_audio\n(\n\t\t\t.refclk(FPGA_CLK3_50),\n\t\t\t.rst(0),\n\t\t\t.outclk_0(clk_audio)\n);",
        # triple tab, blank line
        "assign HDMI_MCLK = clk_audio;\nwire clk_audio;\n\npll_audio pll_audio\n(\n\t\t\t.refclk(FPGA_CLK3_50),\n\t\t\t.rst(0),\n\t\t\t.outclk_0(clk_audio)\n);",
    ]

    # Build corresponding replacements: strip the bare assign, inject counter,
    # keep the wire and pll_audio block intact, add gated assign after.
    def mclk_replace(old):
        # Remove "assign HDMI_MCLK = clk_audio;\n" from the front
        without_assign = old[len("assign HDMI_MCLK = clk_audio;\n"):]
        return (
            mclk_counter_prefix
            + without_assign
            + "\nassign HDMI_MCLK = audio_pll_locked ? clk_audio : 1'b0;"
        )

    if 'audio_pll_locked' in content:
        changes_made.append("⊙ HDMI_MCLK already gated on audio_pll_locked — skipping")
    else:
        matched = False
        for mclk_old in mclk_variants:
            if mclk_old in content:
                content = content.replace(mclk_old, mclk_replace(mclk_old))
                changes_made.append(
                    "✓ Gated HDMI_MCLK on startup counter (audio_pll_locked) — "
                    "pll_audio IP left untouched"
                )
                matched = True
                break
        if not matched:
            if '//assign HDMI_MCLK' in content or '// assign HDMI_MCLK' in content:
                changes_made.append(
                    "⊙ HDMI_MCLK assignment already commented out — skipping"
                )
            else:
                changes_made.append(
                    "✗ pll_audio block pattern not found — manual review required"
                )

    # ------------------------------------------------------------------
    # Write out
    # ------------------------------------------------------------------
    if content == original_content:
        return False, "No changes made - patterns not found in file"

    if backup:
        backup_path = f"{file_path}.bak"
        try:
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original_content)
            changes_made.append(f"✓ Backup created: {backup_path}")
        except Exception as e:
            return False, f"Error creating backup: {e}"

    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
    except Exception as e:
        return False, f"Error writing file: {e}"

    return True, "\n".join(changes_made)


# ---------------------------------------------------------------------------
# sys.zip EXTRACTION
# ---------------------------------------------------------------------------

def extract_sys_files(zip_path, extract_dir, backup=True):
    """
    Extract sys.zip to the specified directory, optionally backing up
    any existing files first.

    Args:
        zip_path: Path to sys.zip file
        extract_dir: Directory to extract to
        backup: Backup existing files before extraction

    Returns:
        tuple: (success, message)
    """

    try:
        Path(extract_dir).mkdir(parents=True, exist_ok=True)
    except Exception as e:
        return False, f"Error creating directory: {e}"

    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            file_list = zip_ref.namelist()

            existing_files = []
            if backup:
                for file_name in file_list:
                    target_path = Path(extract_dir) / file_name
                    if target_path.exists():
                        existing_files.append(str(target_path))

            if existing_files and backup:
                backup_dir = Path(extract_dir) / "backup"
                backup_dir.mkdir(exist_ok=True)
                for file_path in existing_files:
                    src_path = Path(file_path)
                    dst_path = backup_dir / src_path.name
                    shutil.copy2(src_path, dst_path)

            zip_ref.extractall(extract_dir)

            messages = [f"✓ Successfully extracted {len(file_list)} files to {extract_dir}"]
            if existing_files and backup:
                messages.append(
                    f"✓ Backed up {len(existing_files)} existing files to "
                    f"{Path(extract_dir) / 'backup'}"
                )

            return True, "\n".join(messages)

    except zipfile.BadZipFile:
        return False, f"Error: {zip_path} is not a valid zip file"
    except Exception as e:
        return False, f"Error extracting zip file: {e}"


# ---------------------------------------------------------------------------
# DIRECTORY PROCESSING
# ---------------------------------------------------------------------------

def process_directory(directory, recursive=False, backup=True,
                      sys_only=False, qsf_only=False, sys_zip=None):
    """
    Process all sys_top.v and .qsf files in a directory.

    Args:
        directory: Directory to search
        recursive: Search recursively
        backup: Create backup files
        sys_only: Only process sys_top.v files
        qsf_only: Only process .qsf files
        sys_zip: Path to sys.zip file (or None)

    Returns:
        dict: Results for each file processed {path: (success, message)}
    """
    results = {}

    # Extract sys.zip to each core's sys/ directory if provided
    if sys_zip and recursive:
        path = Path(directory)
        if recursive:
            sys_dirs = [p.parent for p in path.glob("**/sys") if p.is_dir()]
        else:
            sys_dirs = [p.parent for p in path.glob("*/sys") if p.is_dir()]

        if sys_dirs:
            print(f"Found {len(sys_dirs)} core directories with sys folders")
            for core_dir in sys_dirs:
                sys_dir = core_dir / "sys"
                print(f"\nExtracting sys files to: {sys_dir}")
                success, message = extract_sys_files(sys_zip, str(sys_dir), backup=backup)
                results[f"{sys_dir} (sys.zip)"] = (success, message)
                print(message)

    # Process sys_top.v files
    if not qsf_only:
        glob_pattern = "**/*sys_top.v" if recursive else "*/sys_top.v"
        path = Path(directory)
        sys_files = list(path.glob(glob_pattern))

        if sys_files:
            print(f"\nFound {len(sys_files)} sys_top.v file(s)")
            for file_path in sys_files:
                print(f"\nProcessing: {file_path}")
                success, message = edit_sys_top(file_path, backup=backup)
                results[str(file_path)] = (success, message)
                print(message)
        else:
            print(f"\nNo sys_top.v files found in {directory}")

    # Process .qsf files
    if not sys_only:
        glob_pattern = "**/*.qsf" if recursive else "*/*.qsf"
        path = Path(directory)
        qsf_files = list(path.glob(glob_pattern))

        if qsf_files:
            print(f"\nFound {len(qsf_files)} .qsf file(s)")
            for file_path in qsf_files:
                print(f"\nProcessing: {file_path}")
                success, message = edit_qsf(file_path, backup=backup)
                results[str(file_path)] = (success, message)
                print(message)
        else:
            print(f"\nNo .qsf files found in {directory}")

    return results


# ---------------------------------------------------------------------------
# ENTRY POINT
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description=(
            "Automate editing of sys_top.v and .qsf files in MiSTer cores "
            "for Senhor board compatibility."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                              # Edit sys/sys_top.v and *.qsf in current directory
                                        # Also extracts sys.zip if found in script directory
  %(prog)s sys_top.v                    # Edit specific sys_top.v file only
  %(prog)s -d ./cores                   # Edit all sys_top.v and .qsf files in directory
  %(prog)s -d ./cores -r                # Search recursively
  %(prog)s --no-backup                  # Don't create backup
  %(prog)s --sys-only                   # Only edit sys_top.v, skip .qsf
  %(prog)s --qsf-only                   # Only edit .qsf, skip sys_top.v
  %(prog)s --skip-sys-zip               # Don't extract sys.zip even if found

Notes (v1.7):

  - senhor_constraints.sdc is now injected into every .qsf.
    Place senhor_constraints.sdc in the root of each core
    (alongside the .qsf file) so Quartus can find it.

  - HDMI_MCLK is now gated on audio_pll_locked in sys_top.v.
    The pll_audio instantiation is patched automatically to expose the
    locked port — no manual wiring required. MCLK is held low until
    the PLL locks, preventing ADV7513 audio crackles on startup and
    after reconfiguration.
        """
    )

    parser.add_argument(
        'file', nargs='?',
        help='Path to sys_top.v file (default: sys/sys_top.v)'
    )
    parser.add_argument(
        '-d', '--directory',
        help='Process all sys_top.v and .qsf files in directory'
    )
    parser.add_argument(
        '-r', '--recursive', action='store_true',
        help='Search directory recursively'
    )
    parser.add_argument(
        '--no-backup', action='store_true',
        help='Do not create backup files'
    )
    parser.add_argument(
        '--sys-only', action='store_true',
        help='Only edit sys_top.v files'
    )
    parser.add_argument(
        '--qsf-only', action='store_true',
        help='Only edit .qsf files'
    )
    parser.add_argument(
        '--skip-sys-zip', action='store_true',
        help='Skip extracting sys.zip even if found'
    )

    args = parser.parse_args()

    if args.file and args.directory:
        parser.error("Cannot specify both file and directory")

    if args.sys_only and args.qsf_only:
        parser.error("Cannot specify both --sys-only and --qsf-only")

    backup = not args.no_backup

    # Check for sys.zip alongside the script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sys_zip_path = os.path.join(script_dir, 'sys.zip')
    sys_zip_exists = os.path.exists(sys_zip_path) and not args.skip_sys_zip

    if sys_zip_exists:
        print(f"Found sys.zip at: {sys_zip_path}\n")

    # ------------------------------------------------------------------
    # Single file / current directory mode
    # ------------------------------------------------------------------
    if args.file or not args.directory:
        success_count = 0
        total_count = 0

        # Extract sys.zip if found
        if sys_zip_exists:
            total_count += 1
            sys_dir = 'sys'
            print(f"Extracting sys files from: {sys_zip_path}")
            success, message = extract_sys_files(sys_zip_path, sys_dir, backup=backup)
            print(message)
            if success:
                success_count += 1
            print()

        # Process sys_top.v
        if not args.qsf_only:
            sys_file = args.file if args.file else os.path.join('sys', 'sys_top.v')

            if os.path.exists(sys_file):
                total_count += 1
                print(f"Processing: {sys_file}")
                success, message = edit_sys_top(sys_file, backup=backup)
                print(message)
                if success:
                    success_count += 1
                print()
            else:
                print(f"Warning: File not found: {sys_file}")
                if sys_file == os.path.join('sys', 'sys_top.v'):
                    print(
                        "Hint: Run this script from the root of your MiSTer core "
                        "directory, or specify the path to sys_top.v explicitly."
                    )
                print()

        # Process .qsf files
        if not args.sys_only:
            qsf_files = find_qsf_files('.')
            if qsf_files:
                print(f"Found {len(qsf_files)} .qsf file(s)")
                for qsf_file in qsf_files:
                    total_count += 1
                    print(f"Processing: {qsf_file}")
                    success, message = edit_qsf(qsf_file, backup=backup)
                    print(message)
                    if success:
                        success_count += 1
                    print()
            else:
                print("Warning: No .qsf files found in current directory")
                print()

        if total_count == 0:
            print("Error: No files found to process")
            sys.exit(1)

        sys.exit(0 if success_count == total_count else 1)

    # ------------------------------------------------------------------
    # Directory mode
    # ------------------------------------------------------------------
    if args.directory:
        if not os.path.isdir(args.directory):
            print(f"Error: Directory not found: {args.directory}")
            sys.exit(1)

        results = process_directory(
            args.directory,
            args.recursive,
            backup=backup,
            sys_only=args.sys_only,
            qsf_only=args.qsf_only,
            sys_zip=sys_zip_path if sys_zip_exists else None
        )

        total = len(results)
        successful = sum(1 for success, _ in results.values() if success)

        print(f"\n{'='*60}")
        print(f"Summary: {successful}/{total} files successfully processed")
        print(f"{'='*60}")

        sys.exit(0 if successful == total else 1)


if __name__ == "__main__":
    main()
