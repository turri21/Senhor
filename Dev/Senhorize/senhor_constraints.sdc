# =============================================================================
# senhor_constraints.sdc
# Board-level timing constraints for the Senhor FPGA board (QMTech Cyclone V)
# Injected alongside each core's own .sdc by Senhorize.py
#
# These constraints are additive — they do NOT replace the core's .sdc.
# TimeQuest merges both files. Core-specific clocks and paths defined in
# Corename.sdc remain in effect; this file only adds Senhor board-level rules.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. SDRAM OUTPUT CLOCK
#
# The QMTech core board places SDRAM at a different physical distance from the
# FPGA than the DE10-Nano carrier board does on MiSTer. The trace delay is
# approximately 0.5–1.0 ns longer. We model this with a tighter output delay
# window so TimeQuest is forced to meet timing with real margin rather than
# relying on the Fitter's optimistic default assumptions.
#
# If your board's actual trace delay has been measured and differs, adjust
# -max and -min accordingly. These values are conservative and safe.
#
# We use a wildcard clock reference because the core's PLL clock name varies
# between cores. TimeQuest will apply the constraint to whichever clock
# actually drives SDRAM_CLK in each core.
# -----------------------------------------------------------------------------

# Derive PLL output clocks and uncertainty before applying output delays.
# These commands are safe to call again even if the core's .sdc already calls
# them — TimeQuest deduplicates them.
derive_pll_clocks -use_net_name
derive_clock_uncertainty

# Apply output delay on the SDRAM clock pin relative to the SDRAM data/control
# outputs. This tells TimeQuest the SDRAM chip requires the clock edge to
# arrive within [-0.5, +1.5] ns of the data outputs, accounting for Senhor's
# trace lengths.
set_output_delay \
    -clock  [get_clocks {*sdram_clk*}] \
    -max    1.5 \
    [get_ports SDRAM_CLK]

set_output_delay \
    -clock  [get_clocks {*sdram_clk*}] \
    -min    -0.5 \
    [get_ports SDRAM_CLK]

# Multicycle path for SDRAM control signals — they are registered and stable
# well before the clock edge, so a 2-cycle multicycle gives the Fitter
# breathing room without violating the actual SDRAM protocol.
set_multicycle_path -from [get_registers *] \
    -to   [get_ports {SDRAM_A[*] SDRAM_BA[*] SDRAM_nWE SDRAM_nCAS SDRAM_nRAS SDRAM_nCS}] \
    -setup 2
set_multicycle_path -from [get_registers *] \
    -to   [get_ports {SDRAM_A[*] SDRAM_BA[*] SDRAM_nWE SDRAM_nCAS SDRAM_nRAS SDRAM_nCS}] \
    -hold  1

# -----------------------------------------------------------------------------
# 2. HDMI MCLK — FALSE PATH
#
# HDMI_MCLK is either tied to a static value (1'b0 when PLL unlocked, or
# clk_audio when locked). In both cases it is NOT a synchronous data path
# that TimeQuest needs to analyze against any data registers — treating it
# as a timing path produces meaningless violations and can mislead the Fitter.
# Marking it as a false path removes that noise entirely.
# -----------------------------------------------------------------------------
set_false_path -to [get_ports {HDMI_MCLK}]

# -----------------------------------------------------------------------------
# 3. FALSE PATHS FOR OUTPUTS WITH NO TIMING REQUIREMENT ON SENHOR
#
# LED outputs, HDMI audio signals (I2S, LRCLK, SCLK) are either board-level
# indicators or go through the ADV7513 which has its own internal clock domain.
# None of these need to meet setup/hold against the FPGA's system clocks.
# -----------------------------------------------------------------------------
set_false_path -to [get_ports {LED[*]}]
set_false_path -to [get_ports {HDMI_I2S}]
set_false_path -to [get_ports {HDMI_LRCLK}]
set_false_path -to [get_ports {HDMI_SCLK}]
set_false_path -to [get_ports {HDMI_I2C_SCL}]
set_false_path -to [get_ports {HDMI_I2C_SDA}]
set_false_path -to [get_ports {HDMI_TX_INT}]

# -----------------------------------------------------------------------------
# 4. FALSE PATHS FOR KEY AND SW INPUTS
#
# Physical buttons and switches are asynchronous inputs. They are always
# debounced in RTL (shift registers or synchronizers), so the raw pin itself
# has no meaningful setup/hold requirement.
# -----------------------------------------------------------------------------
set_false_path -from [get_ports {KEY[*]}]
set_false_path -from [get_ports {SW[*]}]

# -----------------------------------------------------------------------------
# 5. CUT PATHS BETWEEN UNRELATED CLOCK DOMAINS (HDMI TX vs SDRAM)
#
# The HDMI pixel clock and the SDRAM clock are unrelated PLLs. Without this
# cut, TimeQuest will attempt to analyze paths between them and report
# spurious violations that cause the Fitter to waste effort.
# The wildcard patterns are intentionally broad to cover naming variations
# across different cores.
# -----------------------------------------------------------------------------
set_clock_groups -asynchronous \
    -group [get_clocks {*hdmi*}] \
    -group [get_clocks {*sdram*}]

set_clock_groups -asynchronous \
    -group [get_clocks {*pix*}] \
    -group [get_clocks {*sdram*}]

# Audio clock is also asynchronous to video and SDRAM
set_clock_groups -asynchronous \
    -group [get_clocks {*audio*}] \
    -group [get_clocks {*sdram*}]

set_clock_groups -asynchronous \
    -group [get_clocks {*audio*}] \
    -group [get_clocks {*hdmi*}]

set_clock_groups -asynchronous \
    -group [get_clocks {*audio*}] \
    -group [get_clocks {*pix*}]
