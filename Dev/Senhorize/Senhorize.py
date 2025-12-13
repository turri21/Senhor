#!/usr/bin/env python3
"""
MiSTer sys_top.v Editor
Automates editing of sys_top.v files in MiSTer cores
"""

import sys
import os
import argparse
import re
import shutil
import zipfile
from pathlib import Path

def edit_qsf(file_path, backup=True):
    """
    Edit .qsf file to change MAX_CORE_JUNCTION_TEMP from 100 to 125
    
    Args:
        file_path: Path to .qsf file
        backup: Create backup file before editing
    
    Returns:
        tuple: (success, message)
    """
    
    # Read the file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return False, f"Error reading file: {e}"
    
    original_content = content
    changes_made = []
    
    # Replace MAX_CORE_JUNCTION_TEMP 100 with 125
    old_str = "set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100"
    new_str = "set_global_assignment -name MAX_CORE_JUNCTION_TEMP 125"
    
    if old_str in content:
        content = content.replace(old_str, new_str)
        changes_made.append("✓ Changed MAX_CORE_JUNCTION_TEMP from 100 to 125")
    else:
        # Check if it's already 125 or a different value
        if "MAX_CORE_JUNCTION_TEMP 125" in content:
            changes_made.append("⊙ MAX_CORE_JUNCTION_TEMP already set to 125")
        else:
            changes_made.append("✗ MAX_CORE_JUNCTION_TEMP 100 not found")
    
    # Check if any changes were made
    if content == original_content:
        return False, "\n".join(changes_made)
    
    # Create backup if requested
    if backup:
        backup_path = f"{file_path}.bak"
        try:
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original_content)
            changes_made.append(f"✓ Backup created: {backup_path}")
        except Exception as e:
            return False, f"Error creating backup: {e}"
    
    # Write the modified content
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
    except Exception as e:
        return False, f"Error writing file: {e}"
    
    return True, "\n".join(changes_made)


def find_qsf_files(directory='.'):
    """
    Find all .qsf files in the specified directory
    
    Args:
        directory: Directory to search (default: current directory)
    
    Returns:
        List of paths to .qsf files
    """
    path = Path(directory)
    qsf_files = list(path.glob('*.qsf'))
    return qsf_files


def edit_sys_top(file_path, backup=True):
    """
    Edit sys_top.v file with the specified replacements
    
    Args:
        file_path: Path to sys_top.v file
        backup: Create backup file before editing
    
    Returns:
        tuple: (success, message)
    """
    
    # Read the file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return False, f"Error reading file: {e}"
    
    original_content = content
    changes_made = []
    
    # Replacement 0: Complete module declaration with Senhor initializations
    # Find everything from "module sys_top" to "Secondary SD" marker and replace it
    pattern = r'module sys_top.*?//////////////////////\s+Secondary SD\s+///////////////////////////////////'
    
    replacement = """module sys_top
(
	/////////// CLOCK //////////
	input         FPGA_CLK1_50,
	input         FPGA_CLK2_50,
	input         FPGA_CLK3_50,
	//////////// HDMI //////////
	output        HDMI_I2C_SCL,
	inout         HDMI_I2C_SDA,
	output        HDMI_MCLK,
	output        HDMI_SCLK,
	output        HDMI_LRCLK,
	output        HDMI_I2S,
	output        HDMI_TX_CLK,
	output        HDMI_TX_DE,
	output [23:0] HDMI_TX_D,
	output        HDMI_TX_HS,
	output        HDMI_TX_VS,
	
	input         HDMI_TX_INT,
	//////////// SDR ///////////
	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
//	output        SDRAM_DQML,
//	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
//	output        SDRAM_CKE,
`ifdef DUAL_SDRAM
	////////// SDR #2 //////////
//	output [12:0] SDRAM2_A,
//	inout  [15:0] SDRAM2_DQ,
//	output        SDRAM2_nWE,
//	output        SDRAM2_nCAS,
//	output        SDRAM2_nRAS,
//	output        SDRAM2_nCS,
//	output  [1:0] SDRAM2_BA,
//	output        SDRAM2_CLK,
`else
	//////////// VGA ///////////
//	output  [5:0] VGA_R,
//	output  [5:0] VGA_G,
//	output  [5:0] VGA_B,
//	inout         VGA_HS,  // VGA_HS is secondary SD card detect when VGA_EN = 1 (inactive)
//	output		  VGA_VS,
//	input         VGA_EN,  // active low
	/////////// AUDIO //////////
//	output		  AUDIO_L,
//	output		  AUDIO_R,
//	output		  AUDIO_SPDIF,
	//////////// SDIO ///////////
//	inout   [3:0] SDIO_DAT,
//	inout         SDIO_CMD,
//	output        SDIO_CLK,
	//////////// I/O ///////////
//	output        LED_USER,
//	output        LED_HDD,
//	output        LED_POWER,
//	input         BTN_USER,
//	input         BTN_OSD,
//	input         BTN_RESET,
`endif
	////////// I/O ALT /////////
//	output        SD_SPI_CS,
//	input         SD_SPI_MISO,
//	output        SD_SPI_CLK,
//	output        SD_SPI_MOSI,
//
//	inout         SDCD_SPDIF,
//	output        IO_SCL,
//	inout         IO_SDA,
	////////// ADC //////////////
//	output        ADC_SCK,
//	input         ADC_SDO,
//	output        ADC_SDI,
//	output        ADC_CONVST,
	////////// MB KEY ///////////
	input   [1:0] KEY,
	////////// MB SWITCH ////////
	input   [3:0] SW,
	////////// MB LED ///////////
	output  [7:0] LED
	///////// USER IO ///////////
//	inout   [6:0] USER_IO
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
/////////////////////////////////////////////////////////////////////////

//////////////////////  Secondary SD  ///////////////////////////////////"""
    
    match = re.search(pattern, content, re.DOTALL)
    if match:
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        changes_made.append("✓ Replaced module declaration and added Senhor initializations")
    else:
        changes_made.append("✗ Module declaration pattern not found (looking for 'Secondary SD' marker)")
    
    # Replacement 1: KEY[1] -> KEY[0] in deb_user
    old_str_1 = "deb_user <= {deb_user[6:0], btn_u | ~KEY[1]};"
    new_str_1 = "deb_user <= {deb_user[6:0], btn_u | ~KEY[0]};"
    
    if old_str_1 in content:
        content = content.replace(old_str_1, new_str_1)
        changes_made.append("✓ Replaced deb_user KEY[1] with KEY[0]")
    else:
        changes_made.append("✗ deb_user pattern not found")
    
    # Replacement 2: KEY[0] -> KEY[1] in deb_osd
    old_str_2 = "deb_osd <= {deb_osd[6:0], btn_o | ~KEY[0]};"
    new_str_2 = "deb_osd <= {deb_osd[6:0], btn_o | ~KEY[1]};"
    
    if old_str_2 in content:
        content = content.replace(old_str_2, new_str_2)
        changes_made.append("✓ Replaced deb_osd KEY[0] with KEY[1]")
    else:
        changes_made.append("✗ deb_osd pattern not found")
    
    # Replacement 3: hdmiclk_ddr values swap
    # Try with tabs (most common in Verilog files)
    old_str_3_tabs = "hdmiclk_ddr\n(\n\t.datain_h(1'b0),\n\t.datain_l(1'b1),"
    new_str_3_tabs = "hdmiclk_ddr\n(\n\t.datain_h(1'b1),\n\t.datain_l(1'b0),"
    
    # Try with spaces as alternative
    old_str_3_spaces = "hdmiclk_ddr\n(\n    .datain_h(1'b0),\n    .datain_l(1'b1),"
    new_str_3_spaces = "hdmiclk_ddr\n(\n    .datain_h(1'b1),\n    .datain_l(1'b0),"
    
    replaced_3 = False
    if old_str_3_tabs in content:
        content = content.replace(old_str_3_tabs, new_str_3_tabs)
        changes_made.append("✓ Swapped hdmiclk_ddr datain_h and datain_l values")
        replaced_3 = True
    elif old_str_3_spaces in content:
        content = content.replace(old_str_3_spaces, new_str_3_spaces)
        changes_made.append("✓ Swapped hdmiclk_ddr datain_h and datain_l values")
        replaced_3 = True
    
    if not replaced_3:
        changes_made.append("✗ hdmiclk_ddr pattern not found")
    
    # Check if any changes were made
    if content == original_content:
        return False, "No changes made - patterns not found in file"
    
    # Create backup if requested
    if backup:
        backup_path = f"{file_path}.bak"
        try:
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original_content)
            changes_made.append(f"✓ Backup created: {backup_path}")
        except Exception as e:
            return False, f"Error creating backup: {e}"
    
    # Write the modified content
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
    except Exception as e:
        return False, f"Error writing file: {e}"
    
    return True, "\n".join(changes_made)


def process_directory(directory, recursive=False, backup=True, sys_only=False, qsf_only=False, sys_zip=None):
    """
    Process all sys_top.v and .qsf files in a directory
    
    Args:
        directory: Directory to search
        recursive: Search recursively
        backup: Create backup files
        sys_only: Only process sys_top.v files
        qsf_only: Only process .qsf files
        sys_zip: Path to sys.zip file
    
    Returns:
        dict: Results for each file processed
    """
    results = {}
    
    # If processing recursively with sys.zip, extract to each core's sys directory
    if sys_zip and recursive:
        path = Path(directory)
        # Find all directories that contain a sys subdirectory
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
        pattern = "**/*sys_top.v" if recursive else "*/sys_top.v"
        path = Path(directory)
        sys_files = list(path.glob(pattern))
        
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
        if recursive:
            pattern = "**/*.qsf"
        else:
            pattern = "*/*.qsf"
        
        path = Path(directory)
        qsf_files = list(path.glob(pattern))
        
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

def extract_sys_files(zip_path, extract_dir, backup=True):
    """
    Extract sys.zip to the specified directory
    
    Args:
        zip_path: Path to sys.zip file
        extract_dir: Directory to extract to
        backup: Backup existing files before extraction
    
    Returns:
        tuple: (success, message)
    """
    
    # Create extraction directory if it doesn't exist
    try:
        Path(extract_dir).mkdir(parents=True, exist_ok=True)
    except Exception as e:
        return False, f"Error creating directory: {e}"
    
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # Get list of files in zip
            file_list = zip_ref.namelist()
            
            # Check if we should backup existing files
            existing_files = []
            if backup:
                for file_name in file_list:
                    target_path = Path(extract_dir) / file_name
                    if target_path.exists():
                        existing_files.append(str(target_path))
            
            # Backup existing files
            if existing_files and backup:
                backup_dir = Path(extract_dir) / "backup"
                backup_dir.mkdir(exist_ok=True)
                for file_path in existing_files:
                    src_path = Path(file_path)
                    dst_path = backup_dir / src_path.name
                    shutil.copy2(src_path, dst_path)
            
            # Extract all files
            zip_ref.extractall(extract_dir)
            
            # Count files extracted
            files_extracted = len(file_list)
            
            messages = [f"✓ Successfully extracted {files_extracted} files to {extract_dir}"]
            if existing_files and backup:
                messages.append(f"✓ Backed up {len(existing_files)} existing files to {backup_dir}")
            
            return True, "\n".join(messages)
            
    except zipfile.BadZipFile:
        return False, f"Error: {zip_path} is not a valid zip file"
    except Exception as e:
        return False, f"Error extracting zip file: {e}"

def main():
    parser = argparse.ArgumentParser(
        description="Automate editing of sys_top.v and .qsf files in MiSTer cores",
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
        """
    )
    
    parser.add_argument('file', nargs='?', help='Path to sys_top.v file (default: sys/sys_top.v)')
    parser.add_argument('-d', '--directory', help='Process all sys_top.v and .qsf files in directory')
    parser.add_argument('-r', '--recursive', action='store_true', 
                       help='Search directory recursively')
    parser.add_argument('--no-backup', action='store_true',
                       help='Do not create backup files')
    parser.add_argument('--sys-only', action='store_true',
                       help='Only edit sys_top.v files')
    parser.add_argument('--qsf-only', action='store_true',
                       help='Only edit .qsf files')
    parser.add_argument('--skip-sys-zip', action='store_true',
                       help='Skip extracting sys.zip even if found')
    
    args = parser.parse_args()
    
    # Validate arguments
    if args.file and args.directory:
        parser.error("Cannot specify both file and directory")
    
    if args.sys_only and args.qsf_only:
        parser.error("Cannot specify both --sys-only and --qsf-only")
    
    backup = not args.no_backup
    
    # Check for sys.zip in the same directory as the script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sys_zip_path = os.path.join(script_dir, 'sys.zip')
    sys_zip_exists = os.path.exists(sys_zip_path) and not args.skip_sys_zip
    
    if sys_zip_exists:
        print(f"Found sys.zip at: {sys_zip_path}\n")
    
    # Process single file or current directory
    if args.file or not args.directory:
        success_count = 0
        total_count = 0
        
        # Process sys.zip if found
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
            # If no file specified, try sys/sys_top.v
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
                    print("Hint: Run this script from the root of your MiSTer core directory,")
                    print("      or specify the path to sys_top.v explicitly.")
                print()
        
        # Process .qsf file
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
    
    # Process directory
    if args.directory:
        if not os.path.isdir(args.directory):
            print(f"Error: Directory not found: {args.directory}")
            sys.exit(1)
        
        results = process_directory(args.directory, args.recursive, backup=backup, 
                                    sys_only=args.sys_only, qsf_only=args.qsf_only,
                                    sys_zip=args.sys_zip)
        
        # Summary
        total = len(results)
        successful = sum(1 for success, _ in results.values() if success)
        
        print(f"\n{'='*60}")
        print(f"Summary: {successful}/{total} files successfully processed")
        print(f"{'='*60}")
        
        sys.exit(0 if successful == total else 1)


if __name__ == "__main__":
    main()