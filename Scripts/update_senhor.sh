#!/bin/bash
# Update Script for Senhor FPGA

# Copyright (c) 2025 turri21 <turri21@yahoo.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

###############################################
# ASCII Art Logo
###############################################
echo -e "\e[1;36m"
cat << "EOF"                                                              
 ██████╗███████╗███╗   ██╗██╗  ██╗ ██████╗ █████╗            __           
██╔════╝██╔════╝████╗  ██║██║  ██║██╔═══██╗██╔══██╗         (  ) 
███████╗█████╗  ██╔██╗ ██║███████║██║   ██║██████╔╝          ||
╚════██║██╔══╝  ██║╚██╗██║██╔══██║██║   ██║██╔══██╗          ||
███████ ███████╗██║ ╚████║██║  ██║╚██████╔╝██║  ██║  __..___|""|_  
╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ /____________\ 
.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\____________/
EOF
echo -e "\e[0m"
echo "=================================================================="
echo "          Update Script for Senhor FPGA                           "
echo "=================================================================="
echo 

###############################################
# Configuration
###############################################
SCRIPT_NAME="update_senhor.sh"
SCRIPT_URL="https://raw.githubusercontent.com/turri21/Senhor/main/Scripts/$SCRIPT_NAME"
CURRENT_VERSION="1.0"  # Update this when you release new versions

REPO_OWNER="turri21"
REPO_NAME="Distribution_Senhor"
BASE_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main"
VERSION_FILE="version_flags.txt"

declare -A FOLDERS=(
    ["_Arcade"]="/media/fat/_Arcade"
    ["_Arcade/_ST-V"]="/media/fat/_Arcade/_ST-V"
    ["_Arcade/_ST-V/_JP Bios"]="/media/fat/_Arcade/_ST-V/_JP Bios"
    ["_Arcade/_jotego"]="/media/fat/_Arcade/_jotego"
    ["_Arcade/cores"]="/media/fat/_Arcade/cores"
    ["_Computer"]="/media/fat/_Computer"
    ["_Console"]="/media/fat/_Console"
    ["_Other"]="/media/fat/_Other"
    ["_Other/cores"]="/media/fat/_Other/cores"
    ["_Utility"]="/media/fat/_Utility"    
)

FILE_LIST_EXT="file_list.txt"
TEMP_DIR="/tmp/senhor_download"
LOG_FILE="/media/fat/scripts/senhor_download.log"
DELETE_OLD_FILES=false

mkdir -p "$TEMP_DIR"

for folder in "${!FOLDERS[@]}"; do
    mkdir -p "${FOLDERS[$folder]}"
done
touch "$LOG_FILE"

###############################################
# Functions
###############################################

log() {
    local msg="$(date "+%d-%m-%Y %H:%M:%S") - $1"
    echo "$msg" >> "$LOG_FILE"
    echo "$msg" > /dev/tty1
    echo -e "\e[1;34m$msg\e[0m"
}

check_internet() {
    log "Checking internet connection..."
    if ! ping -4 -q -c 1 -W 3 1.1.1.1 >/dev/null; then
        log "ERROR: No internet connection. Please check your network and try again."
        echo -e "\e[1;31mNo internet connection. Exiting.\e[0m"
        read -p "Press enter to exit..."
        exit 1
    fi
    log "Internet connection is available."
}

check_for_updates() {
    log "Checking for script updates..."
    
    # Download the latest version to compare
    local temp_script="$TEMP_DIR/$SCRIPT_NAME.tmp"
    if ! wget -q --tries=3 --timeout=15 "$SCRIPT_URL" -O "$temp_script"; then
        log "Failed to check for updates. Continuing with current version."
        return 1
    fi

    # Extract version from the downloaded script
    local latest_version=$(grep -m1 '^CURRENT_VERSION=' "$temp_script" | cut -d'"' -f2)
    
    if [[ "$latest_version" != "$CURRENT_VERSION" ]]; then
        log "New version available ($latest_version). Current version is $CURRENT_VERSION."
        if whiptail --title "Update Available" --yesno "A new update_senhor version ($latest_version) is available. Update now?" 8 78; then
            # Backup current script
            cp "$0" "$0old"
            
            # Replace with new version
            if mv "$temp_script" "$0" && chmod +x "$0"; then
                log "Successfully updated to version $latest_version. Please restart the script."
                exit 0
            else
                log "Update failed. Restoring backup."
                mv "$0.bak" "$0"
                return 1
            fi
        else
            log "User chose not to update."
            rm -f "$temp_script"
        fi
    else
        log "Script is up to date (v$CURRENT_VERSION)."
        rm -f "$temp_script"
    fi
}

# Enhanced version check with dates
check_version_flags() {
    local version_url="$BASE_URL/$VERSION_FILE"
    local version_file="$TEMP_DIR/$VERSION_FILE"
    
    # Clear previous flags
    declare -gA NEW_FLAGS
    declare -gA UPDATE_DATES
    
    # Download version file
    if wget -q --tries=3 --timeout=15 "$version_url" -O "$version_file"; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^# ]] && continue
            [[ -z "$key" ]] && continue
            
            # Split value into status and date
            local status=$(echo "$value" | cut -d'|' -f1)
            local date=$(echo "$value" | cut -d'|' -f2)
            
            NEW_FLAGS["$key"]="$status"
            UPDATE_DATES["$key"]="$date"
        done < "$version_file"
    else
        log "No version flags file found or couldn't download it."
    fi
}

# Enhanced display with both NEW status and date
show_update_info() {
    local item="$1"
    local info=""
    
    if [[ "${NEW_FLAGS[$item]}" == "NEW" ]]; then
        info+=" *"
    fi
    
    if [[ -n "${UPDATE_DATES[$item]}" ]]; then
        info+=" (${UPDATE_DATES[$item]})"
    fi
    
    echo -e "$info"
}

# Function to display news and wait for key press
display_news() {

    # Configuration
    NEWS_URL="https://github.com/turri21/Distribution_Senhor/raw/main/news.txt"
    TEMP_FILE="/tmp/Senhor_news.txt"

    # Download the news file
    echo "Downloading news..."
    if ! wget -q "$NEWS_URL" -O "$TEMP_FILE"; then
        echo "Failed to download news file."
        return 1
    fi

    # Check if the file has content
    if [ ! -s "$TEMP_FILE" ]; then
        echo "News file is empty."
        return 1
    fi

    # Clear screen before showing news
    # clear

    # Display header
    echo -e "\n\033[1;33m================= Senhor News ====================================\033[0m\n"

    # Process and display the news with colors
    while IFS= read -r line; do
        # Replace tags with color codes
        line="${line//\[TITLE\]/$'\033[0;36m[*] '}"
        line="${line//\[\/TITLE\]/$'\033[0m'}"
        line="${line//\[INFO\]/$'\033[0;32m[i] '}"
        line="${line//\[\/INFO\]/$'\033[0m'}"
        line="${line//\[WARNING\]/$'\033[0;31m[!] '}"
        line="${line//\[\/WARNING\]/$'\033[0m'}"
        echo -e "$line"
    done < "$TEMP_FILE"

    # Display footer
    echo -e "\n\033[1;33m==================================================================\033[0m\n"
    
    # Wait for any key press
    echo -e "\033[0;35mPress any key to continue...\033[0m"
    read -n 1 -s -r
    echo

    # Exit cleanly
    return 0
}

prompt_delete_mode() {
    if whiptail --title "Do you want to delete older versions of RBF/MGL/MRA files?" --yesno "Enable deletion of old RBF/MGL/MRA files?" 8 78; then
       DELETE_OLD_FILES=true
       echo "Old RBF/MGL/MRA files will BE deleted!"
    else
       echo "Old RBF/MGL/MRA files will NOT be deleted."
    fi
}

fetch_file_list() {
    local folder="$1"
    local file_type="$2"  # "rbf_mgl" or "mra"
    local list_file="$TEMP_DIR/${folder}_$FILE_LIST_EXT"
    local file_list_url="$BASE_URL/$folder/$FILE_LIST_EXT"

    log "Fetching file list for $folder..."

    mkdir -p "$(dirname "$list_file")"

    if ! wget -q --tries=3 --timeout=15 "$file_list_url" -O "$list_file"; then
        log "\e[31mWARNING: No file list found for $folder\e[0m"
        FILES=()
        return 1
    fi

    FILES=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line##*/}"
        line="${line//[$'\t\r\n']}"
        
        # Filter based on requested file type
        if [[ "$file_type" == "rbf_mgl" && "$line" =~ \.(rbf|mgl)$ ]]; then
            FILES+=("$line")
        elif [[ "$file_type" == "mra" && "$line" =~ \.mra$ ]]; then
            FILES+=("$line")
        fi
    done < "$list_file"

    local count=${#FILES[@]}
    if [ "$count" -eq 0 ]; then
        log "WARNING: No valid $file_type files found in $folder list"
        return 1
    fi

    log "Found $count $file_type files in $folder"
    return 0
}

delete_old_versions() {
    local folder="$1"
    local new_file="$2"
    local download_dir="${FOLDERS[$folder]}"
    local full_path_new="$download_dir/$new_file"

    # For MRA files - delete any older files with same base name
    if [[ "$new_file" == *.mra ]]; then
        local base_name="${new_file%.*}"
        # Find and log all files that will be deleted
        find "$download_dir" -maxdepth 1 -name "${base_name}*.mra" ! -name "$new_file" | while read -r existing; do
            existing_file=$(basename "$existing")
            log "\e[31mDeleting older MRA: \e[0m\e[1;33m$existing_file\e[0m"
            rm -f "$existing"
        done
        return $?
    fi
    
    # Original MGL version handling
    if [[ "$new_file" == *.mgl ]]; then
        local base_prefix=$(echo "$new_file" | cut -d'_' -f1-2)
        local new_version=$(echo "$new_file" | cut -d'_' -f3 | cut -d'.' -f1)
        
        find "$download_dir" -maxdepth 1 -name "${base_prefix}_*" | while read -r existing; do
            existing_file=$(basename "$existing")
            existing_version=$(echo "$existing_file" | cut -d'_' -f3 | cut -d'.' -f1)
            if [[ "$existing_version" < "$new_version" ]]; then
                log "\e[31mDeleting older version: \e[0m\e[1;33m$existing_file\e[0m"
                rm -f "$existing"
            fi
        done
    fi

    # Original RBF version handling
    if [[ "$new_file" == *.rbf ]]; then
        local base_prefix=$(echo "$new_file" | cut -d'_' -f1-2)
        local new_version=$(echo "$new_file" | cut -d'_' -f3 | cut -d'.' -f1)
        
        find "$download_dir" -maxdepth 1 -name "${base_prefix}_*" | while read -r existing; do
            existing_file=$(basename "$existing")
            existing_version=$(echo "$existing_file" | cut -d'_' -f3 | cut -d'.' -f1)
            if [[ "$existing_version" < "$new_version" ]]; then
                log "\e[31mDeleting older version: \e[0m\e[1;33m$existing_file\e[0m"
                rm -f "$existing"
            fi
        done
    fi
}

download_arcadealt() {
    ZIP_URL="https://github.com/turri21/Distribution_Senhor/raw/main/_Arcade/_alternatives.zip"
    DEST_DIR="/media/fat/_Arcade"
    TEMP_ZIP="/tmp/_alternatives.zip"

    echo "Deleting old _alternatives folder..."
    rm -rf "/media/fat/_Arcade/_alternatives"
    echo "Downloading Arcade mra _alternatives.zip with wget..."
    wget -O "$TEMP_ZIP" "$ZIP_URL"

    if [ $? -ne 0 ]; then
        echo "Download failed."
        exit 1
    fi

    echo "Extracting ZIP to $DEST_DIR..."
    unzip -o "$TEMP_ZIP" -d "$DEST_DIR"

    if [ $? -ne 0 ]; then
        echo "Extraction failed."
        exit 1
    fi

    echo "Cleaning up..."
    rm "$TEMP_ZIP"

    echo "Done."
}

download_file() {
    local folder="$1"
    local file="$2"
    local download_dir="${FOLDERS[$folder]}"
    local max_retries=3
    local retry_delay=2
    local local_file="$download_dir/$file"
    local temp_file="$TEMP_DIR/$file"

    # Skip if file exists and we're not in delete mode
    if [ ! "$DELETE_OLD_FILES" = true ] && [ -f "$local_file" ]; then
        log "Skipping existing file: $folder/$file"
        return 0
    fi

    # Special handling for MRA files in delete mode
    if [[ "$DELETE_OLD_FILES" = true && "$file" == *.mra && -f "$local_file" ]]; then
        # Compare file sizes instead of timestamps
        if remote_size=$(wget --spider --server-response "$BASE_URL/$folder/$file" 2>&1 | \
           grep -E '^Length:' | awk '{print $2}'); then
            local_size=$(stat -c %s "$local_file" 2>/dev/null || echo 0)
            
            if [[ "$remote_size" -eq "$local_size" ]]; then
                log "MRA file sizes match, skipping download: $folder/$file"
                return 0
            fi
        else
            log "Couldn't verify remote MRA file, proceeding with download..."
        fi
    fi

    # For RBF files, always respect the existing skip logic
    if [[ "$file" == *.rbf && -f "$local_file" ]]; then
        log "Skipping existing RBF file: $folder/$file"
        return 0
    fi

    # Download with retry logic
    for ((i=1; i<=max_retries; i++)); do
        log "Download attempt $i for $folder/$file..."
        if wget -q --tries=3 --timeout=15 "$BASE_URL/$folder/$file" -O "$temp_file"; then
            if [ -s "$temp_file" ]; then
                if $DELETE_OLD_FILES; then
                    delete_old_versions "$folder" "$file"
                fi
                mv "$temp_file" "$local_file"
                log "Successfully downloaded: \e[1;32m$folder/$file\e[0m"
                return 0
            else
                log "Attempt $i: Downloaded empty file"
                rm -f "$temp_file"
            fi
        fi
        sleep $retry_delay
    done

    log "ERROR: Failed to download after $max_retries attempts: \e[1;31m$folder/$file\e[0m"
    return 1
}

###############################################
# Arcade ROMs
###############################################
download_arcaderoms() {
    # Base target directory
    BASE_DIR="/media/fat"

    echo "Downloading..."
    wget -O "$BASE_DIR/arcade_roms_db.json.zip" "https://raw.githubusercontent.com/zakk4223/ArcadeROMsDB_MiSTer/db/arcade_roms_db.json.zip"

    if [ $? -ne 0 ]; then
        echo "Download failed."
        return 1
    fi

    echo "Extracting JSON file..."
    unzip -o "$BASE_DIR/arcade_roms_db.json.zip" -d "$BASE_DIR"

    echo "Processing JSON..."

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "This script requires 'jq'. Please install it (e.g., 'sudo apt install jq')."
        return 1
    fi

    jq -r '.files | to_entries[] | "\(.key) \(.value.url)"' "$BASE_DIR/arcade_roms_db.json" | while read -r path url; do
        # Remove leading pipe character
        relative_path="${path#|}"

        # Compute full output path
        full_path="$BASE_DIR/$relative_path"

        # Create directory if needed
        mkdir -p "$(dirname "$full_path")"

        # Download file if it doesn't exist
        if [ ! -f "$full_path" ]; then
            echo "Downloading $relative_path..."
            wget -q -O "$full_path" "$url"
        else
            echo "File $relative_path already exists. Skipping."
        fi
    done

    echo "All files processed and saved under $BASE_DIR."
}

###############################################
# BIOS files
###############################################

download_bios() {
    # Base target directory
    BASE_DIR="/media/fat"
    local JSON_ZIP="$BASE_DIR/bios_db.json.zip"
    local JSON_FILE="$BASE_DIR/bios_db.json"
    
    # Initialize success flag
    local SUCCESS=true

    echo "Downloading BIOS database..."
    if ! wget -q --show-progress -O "$JSON_ZIP" "https://raw.githubusercontent.com/ajgowans/BiosDB_MiSTer/db/bios_db.json.zip"; then
        echo "Download failed."
        return 1
    fi

    echo "Extracting JSON file..."
    if ! unzip -o "$JSON_ZIP" -d "$BASE_DIR"; then
        echo "Extraction failed."
        SUCCESS=false
    fi

    echo "Processing JSON..."

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "This script requires 'jq'. Please install it (e.g., 'sudo apt install jq')."
        SUCCESS=false
    else
        jq -r '.files | to_entries[] | "\(.key) \(.value.url)"' "$JSON_FILE" | while read -r path url; do
            # Remove leading pipe character
            relative_path="${path#|}"

            # Compute full output path
            full_path="$BASE_DIR/$relative_path"

            # Create directory if needed
            mkdir -p "$(dirname "$full_path")"

            # Download file if it doesn't exist
            if [ ! -f "$full_path" ]; then
                echo "Downloading $relative_path..."
                if ! wget -q --show-progress -O "$full_path" "$url"; then
                    echo "Failed to download $relative_path"
                    SUCCESS=false
                fi
            else
                echo "File $relative_path already exists. Skipping."
            fi
        done
    fi

    # Cleanup temporary files
    echo "Cleaning up temporary files..."
    rm -f "$JSON_ZIP" "$JSON_FILE"
    [ -f "$JSON_ZIP" ] && echo "Warning: Failed to remove $JSON_ZIP"
    [ -f "$JSON_FILE" ] && echo "Warning: Failed to remove $JSON_FILE"

    if [ "$SUCCESS" = true ]; then
        echo "BIOS files successfully processed and saved under $BASE_DIR/games/."
    else
        echo "BIOS files processed with some errors."
    fi

    return $([ "$SUCCESS" = true ] && echo 0 || echo 1)
}

###############################################
# GBA Borders
###############################################

download_gbaborders() {
    # Base target directory
    BASE_DIR="/media/fat"
    JSON_DIR="$BASE_DIR/games/GBA/Borders"
    DB_ZIP="$BASE_DIR/db.json.zip"
    JSON_FILE="$JSON_DIR/db.json"

    # Create directories if they don't exist
    mkdir -p "$JSON_DIR"

    echo "Downloading database..."
    if ! wget -O "$DB_ZIP" "https://raw.githubusercontent.com/Dinierto/MiSTer-GBA-Borders/db/db.json.zip"; then
        echo "Database download failed."
        return 1
    fi

    echo "Extracting JSON file..."
    if ! unzip -o "$DB_ZIP" -d "$JSON_DIR"; then
        echo "Extraction failed."
        rm -f "$DB_ZIP"
        return 1
    fi

    if [ ! -f "$JSON_FILE" ]; then
        echo "JSON file not found after extraction."
        rm -f "$DB_ZIP"
        return 1
    fi

    echo "Processing JSON..."

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "This script requires 'jq'. Please install it (e.g., 'sudo apt install jq')."
        rm -f "$DB_ZIP" "$JSON_FILE"
        return 1
    fi

    # Get the commit hash from base_files_url
    COMMIT_HASH=$(jq -r '.base_files_url' "$JSON_FILE" | cut -d'/' -f6)
    if [ -z "$COMMIT_HASH" ]; then
        echo "Could not determine commit hash from JSON."
        rm -f "$DB_ZIP" "$JSON_FILE"
        return 1
    fi

    # Create temporary file for counters
    COUNTER_FILE=$(mktemp)
    echo "0 0 0 0" > "$COUNTER_FILE" # TOTAL SKIPPED DOWNLOADED FAILED

    # Process files
    jq -r '.files | to_entries[] | "\(.key)\t\(.value.hash)\t\(.value.size)"' "$JSON_FILE" | while IFS=$'\t' read -r path hash size; do
        # Read current counters
        read TOTAL_FILES SKIPPED_FILES DOWNLOADED_FILES FAILED_FILES < "$COUNTER_FILE"
        TOTAL_FILES=$((TOTAL_FILES + 1))
        
        # Remove leading pipe character from path
        relative_path="${path#|}"
        filename=$(basename "$relative_path")
        
        # Compute full output path
        full_path="$BASE_DIR/$relative_path"
        
        # Create directory if needed
        mkdir -p "$(dirname "$full_path")"

        # Check if file exists and has correct hash and size
        if [ -f "$full_path" ]; then
            current_size=$(stat -c%s "$full_path" 2>/dev/null || echo 0)
            if [ "$current_size" -eq "$size" ]; then
                current_hash=$(md5sum "$full_path" | cut -d' ' -f1)
                if [ "$current_hash" = "$hash" ]; then
                    echo "[*] $filename already correct. Skipping."
                    SKIPPED_FILES=$((SKIPPED_FILES + 1))
                    echo "$TOTAL_FILES $SKIPPED_FILES $DOWNLOADED_FILES $FAILED_FILES" > "$COUNTER_FILE"
                    continue
                fi
            fi
        fi

        # Download with retry logic
        max_retries=3
        retry_count=0
        success=0
        
        while [ $retry_count -lt $max_retries ] && [ $success -eq 0 ]; do
            echo "↓ Downloading $filename (attempt $((retry_count+1)))..."
            
            # Construct proper GitHub raw content URL
            download_url="https://raw.githubusercontent.com/Dinierto/MiSTer-GBA-Borders/$COMMIT_HASH/$relative_path"
            
            if wget -q -O "$full_path.tmp" "$download_url"; then
                # Verify download
                current_size=$(stat -c%s "$full_path.tmp" 2>/dev/null || echo 0)
                if [ "$current_size" -eq "$size" ]; then
                    current_hash=$(md5sum "$full_path.tmp" | cut -d' ' -f1)
                    if [ "$current_hash" = "$hash" ]; then
                        mv "$full_path.tmp" "$full_path"
                        success=1
                        DOWNLOADED_FILES=$((DOWNLOADED_FILES + 1))
                        echo "[*] Success: $filename"
                    else
                        echo "[X] Hash mismatch: $filename"
                    fi
                else
                    echo "[X] Size mismatch: $filename (got $current_size, expected $size)"
                fi
            else
                echo "[X] Download failed: $filename"
            fi
            
            # Clean up temp file if failed
            [ -f "$full_path.tmp" ] && rm -f "$full_path.tmp"
            retry_count=$((retry_count+1))
        done

        if [ $success -eq 0 ]; then
            echo "[!] Failed to download $filename after $max_retries attempts"
            FAILED_FILES=$((FAILED_FILES + 1))
        fi

        # Update counters
        echo "$TOTAL_FILES $SKIPPED_FILES $DOWNLOADED_FILES $FAILED_FILES" > "$COUNTER_FILE"
    done

    # Read final counters
    read TOTAL_FILES SKIPPED_FILES DOWNLOADED_FILES FAILED_FILES < "$COUNTER_FILE"
    rm -f "$COUNTER_FILE"

    # Complete cleanup
    echo "Performing complete cleanup..."
    rm -f "$DB_ZIP" "$JSON_FILE"
    echo "Verified removal:"
    [ ! -f "$DB_ZIP" ] && echo " - Removed $DB_ZIP"
    [ ! -f "$JSON_FILE" ] && echo " - Removed $JSON_FILE"

    # Print summary
    echo ""
    echo "===== Download Summary ====="
    echo "Total files processed: $TOTAL_FILES"
    echo "Successfully downloaded: $DOWNLOADED_FILES"
    echo "Already up-to-date: $SKIPPED_FILES"
    echo "Failed downloads: $FAILED_FILES"
    echo ""
    echo "Borders are in: $BASE_DIR/games/GBA/Borders/"
    echo "Cleanup complete - all temporary files removed."
}

###############################################
# Wallpapers
###############################################

download_wallpapers() {
    # Base target directory
    BASE_DIR="/media/fat"
    WALLPAPER_DIR="$BASE_DIR/Wallpapers"
    TEMP_DIR=$(mktemp -d)
    
    # Repositories to process
    REPOS=(
        "RGarciaLago/Wallpaper_Collection"
        "Ranny-Snice/Ranny-Snice-Wallpapers"
    )

    # Create directory if it doesn't exist
    mkdir -p "$WALLPAPER_DIR"

    # Initialize counters
    TOTAL_FILES=0
    SKIPPED_FILES=0
    DOWNLOADED_FILES=0
    FAILED_FILES=0

    for REPO in "${REPOS[@]}"; do
        echo "Processing repository: $REPO"
        
        DB_ZIP="$TEMP_DIR/${REPO##*/}.json.zip"
        JSON_FILE="$TEMP_DIR/db.json"

        echo "Downloading database..."
        if ! wget -q -O "$DB_ZIP" "https://raw.githubusercontent.com/$REPO/db/db.json.zip"; then
            echo "Database download failed for $REPO."
            continue
        fi

        echo "Extracting JSON file..."
        if ! unzip -q -o "$DB_ZIP" -d "$TEMP_DIR"; then
            echo "Extraction failed for $REPO."
            rm -f "$DB_ZIP"
            continue
        fi

        # Look for the JSON file
        if [ ! -f "$JSON_FILE" ]; then
            echo "JSON file not found after extraction for $REPO."
            echo "Checking for alternative locations..."
            FOUND_JSON=$(find "$TEMP_DIR" -name "*.json" -type f | head -n 1)
            if [ -f "$FOUND_JSON" ]; then
                JSON_FILE="$FOUND_JSON"
                echo "Using found JSON file: $JSON_FILE"
            else
                echo "No JSON file found in the archive for $REPO."
                rm -f "$DB_ZIP"
                continue
            fi
        fi

        echo "Processing JSON..."

        # Check if jq is installed
        if ! command -v jq &> /dev/null; then
            echo "This script requires 'jq'. Please install it (e.g., 'sudo apt install jq')."
            rm -f "$DB_ZIP" "$JSON_FILE"
            return 1
        fi

        # Get the commit hash or use main as fallback
        COMMIT_HASH=$(jq -r '.base_files_url' "$JSON_FILE" | cut -d'/' -f6 2>/dev/null)
        if [ -z "$COMMIT_HASH" ] || [ "$COMMIT_HASH" = "null" ]; then
            echo "Could not determine commit hash from JSON for $REPO, using 'main' as fallback."
            COMMIT_HASH="main"
        fi

        # Process files using a temporary file to avoid subshell
        PROCESS_FILE=$(mktemp)
        jq -r '.files | to_entries[] | "\(.key)\t\(.value.hash)\t\(.value.size)"' "$JSON_FILE" > "$PROCESS_FILE"
        
        while IFS=$'\t' read -r path hash size; do
            # Skip if we didn't get valid data
            if [ -z "$path" ] || [ -z "$hash" ] || [ -z "$size" ]; then
                continue
            fi

            # Remove leading pipe character from path if present
            relative_path="${path#|}"
            filename=$(basename "$relative_path")
            
            # Skip if no filename could be determined
            if [ -z "$filename" ]; then
                continue
            fi
            
            # Compute full output path
            full_path="$WALLPAPER_DIR/$filename"

            # Check if file exists and has correct hash and size
            if [ -f "$full_path" ]; then
                current_size=$(stat -c%s "$full_path" 2>/dev/null || echo 0)
                if [ "$current_size" -eq "$size" ]; then
                    current_hash=$(md5sum "$full_path" | cut -d' ' -f1)
                    if [ "$current_hash" = "$hash" ]; then
                        echo "[*] $filename already correct. Skipping."
                        SKIPPED_FILES=$((SKIPPED_FILES + 1))
                        TOTAL_FILES=$((TOTAL_FILES + 1))
                        continue
                    fi
                fi
            fi

            # Download with retry logic
            max_retries=3
            retry_count=0
            success=0
            
            while [ $retry_count -lt $max_retries ] && [ $success -eq 0 ]; do
                echo "↓ Downloading $filename (attempt $((retry_count+1))) from $REPO..."
                
                # Construct proper GitHub raw content URL
                download_url="https://raw.githubusercontent.com/$REPO/$COMMIT_HASH/$relative_path"
                
                if wget -q -O "$full_path.tmp" "$download_url"; then
                    # Verify download
                    current_size=$(stat -c%s "$full_path.tmp" 2>/dev/null || echo 0)
                    if [ "$current_size" -eq "$size" ]; then
                        current_hash=$(md5sum "$full_path.tmp" | cut -d' ' -f1)
                        if [ "$current_hash" = "$hash" ]; then
                            mv "$full_path.tmp" "$full_path"
                            success=1
                            DOWNLOADED_FILES=$((DOWNLOADED_FILES + 1))
                            TOTAL_FILES=$((TOTAL_FILES + 1))
                            echo "[*] Success: $filename"
                        else
                            echo "[X] Hash mismatch: $filename"
                        fi
                    else
                        echo "[X] Size mismatch: $filename (got $current_size, expected $size)"
                    fi
                else
                    echo "[X] Download failed: $filename"
                fi
                
                # Clean up temp file if failed
                [ -f "$full_path.tmp" ] && rm -f "$full_path.tmp"
                retry_count=$((retry_count + 1))
            done

            if [ $success -eq 0 ]; then
                echo "[!] Failed to download $filename after $max_retries attempts"
                FAILED_FILES=$((FAILED_FILES + 1))
                TOTAL_FILES=$((TOTAL_FILES + 1))
            fi
        done < "$PROCESS_FILE"
        rm -f "$PROCESS_FILE"

        # Clean up repo files
        rm -f "$DB_ZIP" "$JSON_FILE"
    done

    # Clean up temp directory
    rm -rf "$TEMP_DIR"

    # Print summary
    echo ""
    echo "===== Download Summary ====="
    echo "Total files processed: $TOTAL_FILES"
    echo "Successfully downloaded: $DOWNLOADED_FILES"
    echo "Already up-to-date: $SKIPPED_FILES"
    echo "Failed downloads: $FAILED_FILES"
    echo ""
    echo "All wallpapers are in: $WALLPAPER_DIR/"
    echo "Cleanup complete - all temporary files removed."
}

###############################################
# Download and Extract Function
###############################################

download_and_extract() {
    local ZIP_NAME="$1"
    local ZIP_URL_FULL="$2"
    local IS_SPLIT="${3:-false}"
    local ZIP_DIR="/tmp/${ZIP_NAME}_download"
    local OUTPUT_DIR="/media/fat"
    local TEMP_LIST=$(mktemp)
    local TEMP_SAMPLE=$(mktemp)
    
    # Initialize counters
    local DOWNLOAD_SUCCESS=true
    local EXTRACT_SUCCESS=true
    local TOTAL_FILES=0
    local START_TIME=$(date +%s)
    local DOWNLOAD_SIZE=0
    local OUTPUT_SIZE=0

    mkdir -p "${ZIP_DIR}"
    cd "${ZIP_DIR}" || return 1

    local ZIP_BASE="${ZIP_NAME}.zip"
    local ZIP_Z01="${ZIP_NAME}.z01"
    local ZIP_URL_BASE=$(dirname "${ZIP_URL_FULL}")

    # Download phase
    if [ "$IS_SPLIT" = true ]; then
        echo "Downloading split archive parts..."
        echo "Downloading ${ZIP_Z01}..."
        if ! wget --show-progress -q "${ZIP_URL_BASE}/${ZIP_Z01}" -O "${ZIP_Z01}"; then
            echo "Failed to download ${ZIP_Z01}"
            DOWNLOAD_SUCCESS=false
        fi

        echo "Downloading ${ZIP_BASE}..."
        if ! wget --show-progress -q "${ZIP_URL_BASE}/${ZIP_BASE}" -O "${ZIP_BASE}"; then
            echo "Failed to download ${ZIP_BASE}"
            DOWNLOAD_SUCCESS=false
        fi

        if [ "$DOWNLOAD_SUCCESS" = true ]; then
            DOWNLOAD_SIZE=$(( $(stat -c%s "${ZIP_Z01}" 2>/dev/null || echo 0) + $(stat -c%s "${ZIP_BASE}" 2>/dev/null || echo 0) ))
            echo "Joining parts..."
            if ! zip -s 0 "${ZIP_BASE}" --out "joined_${ZIP_BASE}"; then
                echo "Failed to join split archive parts"
                EXTRACT_SUCCESS=false
            fi
        fi
    else
        echo "Downloading ${ZIP_BASE}..."
        if ! wget --show-progress -q "${ZIP_URL_BASE}/${ZIP_BASE}" -O "${ZIP_BASE}"; then
            echo "Failed to download ${ZIP_BASE}"
            DOWNLOAD_SUCCESS=false
        else
            DOWNLOAD_SIZE=$(stat -c%s "${ZIP_BASE}" 2>/dev/null || echo 0)
        fi
    fi

    # Extraction phase
    if [ "$DOWNLOAD_SUCCESS" = true ]; then
        echo "Extracting to ${OUTPUT_DIR}..."
        
        if [ "$IS_SPLIT" = true ]; then
            ZIP_TO_EXTRACT="joined_${ZIP_BASE}"
        else
            ZIP_TO_EXTRACT="${ZIP_BASE}"
        fi

        # Get list of files in the zip and save sample
        unzip -Z1 "${ZIP_TO_EXTRACT}" 2>/dev/null | grep -v '/$' > "$TEMP_LIST"
        TOTAL_FILES=$(wc -l < "$TEMP_LIST")
        head -n 5 "$TEMP_LIST" > "$TEMP_SAMPLE"

        # Extract files
        if ! unzip -o "${ZIP_TO_EXTRACT}" -d "${OUTPUT_DIR}"; then
            echo "Extraction failed"
            EXTRACT_SUCCESS=false
        else
            # Calculate size of only the extracted files
            OUTPUT_SIZE=0
            while IFS= read -r file; do
                if [[ -f "${OUTPUT_DIR}/${file}" ]]; then
                    OUTPUT_SIZE=$((OUTPUT_SIZE + $(stat -c%s "${OUTPUT_DIR}/${file}" 2>/dev/null || echo 0)))
                fi
            done < "$TEMP_LIST"
        fi
    fi

    # Calculate duration
    local END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))

    # Print summary
    echo ""
    echo "===== Operation Summary ====="
    echo "Archive: ${ZIP_NAME}"
    echo "Status: $([ "$DOWNLOAD_SUCCESS" = true ] && [ "$EXTRACT_SUCCESS" = true ] && echo "SUCCESS" || echo "FAILED")"
    echo "Download Size: $(numfmt --to=iec --format="%.2f" $DOWNLOAD_SIZE 2>/dev/null || echo "$DOWNLOAD_SIZE B")"
    
    if [ "$DOWNLOAD_SUCCESS" = true ] && [ "$EXTRACT_SUCCESS" = true ]; then
        echo "Extracted Files: ${TOTAL_FILES}"
        echo "Output Size: $(numfmt --to=iec --format="%.2f" $OUTPUT_SIZE 2>/dev/null || echo "$OUTPUT_SIZE B")"
        echo "Extracted to: ${OUTPUT_DIR}/"
        
        # Show sample files from the saved temp file
        if [ $TOTAL_FILES -gt 0 ]; then
            echo "Sample Files:"
            while IFS= read -r file; do
                echo "  - ${file}"
            done < "$TEMP_SAMPLE"
            [ $TOTAL_FILES -gt 5 ] && echo "  (... plus $((TOTAL_FILES - 5)) more files)"
        fi
    fi
    
    echo "Time Taken: ${DURATION} seconds"
    echo "============================"
    echo ""

    # Cleanup
    rm -f "$TEMP_LIST" "$TEMP_SAMPLE"
    rm -rf "$ZIP_DIR"

    if [ "$DOWNLOAD_SUCCESS" = true ] && [ "$EXTRACT_SUCCESS" = true ]; then
        return 0
    else
        return 1
    fi
}

###############################################
# Specific Download Wrappers
###############################################

download_menu() {
    local MENU_FILE="/media/fat/menu.rbf"
    local MENU_BACKUP="/media/fat/menu.rbfold"
    
    # Create backup if menu.rbf exists
    if [ -f "$MENU_FILE" ]; then
        echo "Creating backup of current menu.rbf..."
        if ! cp "$MENU_FILE" "$MENU_BACKUP"; then
            echo "Warning: Failed to create backup of menu.rbf"
        else
            echo "Backup created: $MENU_BACKUP"
        fi
    fi

    # Proceed with download and extraction
    download_and_extract "Menu" "https://github.com/turri21/Distribution_Senhor/raw/main/Menu.zip" false

    # Verify if new menu.rbf was installed
    if [ -f "$MENU_FILE" ]; then
        echo "Menu update completed successfully."
        echo "Original menu.rbf saved as menu.rbfold"
    else
        echo "Warning: No menu.rbf found after extraction!"
        
        # Restore backup if available
        if [ -f "$MENU_BACKUP" ]; then
            echo "Attempting to restore backup..."
            if cp "$MENU_BACKUP" "$MENU_FILE"; then
                echo "Backup restored successfully."
            else
                echo "Error: Failed to restore backup!"
            fi
        fi
    fi
}

download_MiSTer_binary() {
    local MiSTer_binary_FILE="/media/fat/MiSTer"
    local MiSTer_binary_BACKUP="/media/fat/MiSTerold"
    
    # Create backup if menu.rbf exists
    if [ -f "$MiSTer_binary_FILE" ]; then
        echo "Creating backup of current MiSTer binary..."
        if ! cp "$MiSTer_binary_FILE" "$MiSTer_binary_BACKUP"; then
            echo "Warning: Failed to create backup of MiSTer binary"
        else
            echo "Backup created: $MiSTer_binary_BACKUP"
        fi
    fi

    # Proceed with download and extraction
    download_and_extract "MiSTer" "https://github.com/turri21/Distribution_Senhor/raw/main/MiSTer.zip" false

    # Verify if new menu.rbf was installed
    if [ -f "$MiSTer_binary_FILE" ]; then
        echo "MiSTer binary update completed successfully."
        echo "Original MiSTer binary saved as MiSTerold"
    else
        echo "Warning: No MiSTer binary found after extraction!"
        
        # Restore backup if available
        if [ -f "$MiSTer_binary_BACKUP" ]; then
            echo "Attempting to restore backup..."
            if cp "$MiSTer_binary_BACKUP" "$MiSTer_binary_FILE"; then
                echo "Backup restored successfully."
            else
                echo "Error: Failed to restore backup!"
            fi
        fi
    fi
}

download_cheats() {
    download_and_extract "Cheats" "https://github.com/turri21/Distribution_Senhor/raw/main/Cheats.zip" true
}

download_filters() {
    download_and_extract "Filters" "https://github.com/turri21/Distribution_Senhor/raw/main/Filters.zip" false
}

download_filtersaudio() {
    download_and_extract "Filters_Audio" "https://github.com/turri21/Distribution_Senhor/raw/main/Filters_Audio.zip" false
}

download_font() {
    download_and_extract "font" "https://github.com/turri21/Distribution_Senhor/raw/main/font.zip" false
}

download_gamma() {
    download_and_extract "Gamma" "https://github.com/turri21/Distribution_Senhor/raw/main/Gamma.zip" false
}

download_presets() {
    download_and_extract "Presets" "https://github.com/turri21/Distribution_Senhor/raw/main/Presets.zip" false
}

download_scripts() {
    download_and_extract "Scripts" "https://github.com/turri21/Distribution_Senhor/raw/main/Scripts.zip" false
}

download_shadowmasks() {
    download_and_extract "Shadow_Masks" "https://github.com/turri21/Distribution_Senhor/raw/main/Shadow_Masks.zip" false
}

###############################################
# Main Process
###############################################

main() {
    check_internet
    check_for_updates
    display_news

    # Check for version flags before showing menu
    check_version_flags
    
    prompt_delete_mode

     # Menu using whiptail with update indicators
    CHOICES=$(whiptail --title "Senhor Downloader" --checklist \
        "Choose what you want to download (use space to select):" 25 74 17 \
        "RBF_MGL" "Download RBF/MGL files$(show_update_info "RBF_MGL")" ON \
        "MRA" "Download MRA files$(show_update_info "MRA")" OFF \
        "Menu" "Download Menu$(show_update_info "Menu")" OFF \
        "MiSTer_binary" "Download MiSTer bin for Senhor$(show_update_info "MiSTer_binary")" OFF \
        "Alternatives" "Download Alternative MRA files$(show_update_info "Alternatives")" OFF \
        "ArcadeROMs" "Download Arcade ROMs [SLOW]$(show_update_info "ArcadeROMs")" OFF \
        "BIOS" "Download BIOS files [SLOW]$(show_update_info "BIOS")" OFF \
        "Cheats" "Download Cheats$(show_update_info "Cheats")" OFF \
        "Filters" "Download Filters$(show_update_info "Filters")" OFF \
        "Filters_Audio" "Download Filters_Audio$(show_update_info "Filters_Audio")" OFF \
        "Fonts" "Download Fonts$(show_update_info "Fonts")" OFF \
        "Gamma" "Download Gamma$(show_update_info "Gamma")" OFF \
        "GBA_Borders" "Download GBA_Borders$(show_update_info "GBA_Borders")" OFF \
        "Presets" "Download Presets$(show_update_info "Presets")" OFF \
        "Scripts" "Download Scripts$(show_update_info "Scripts")" OFF \
        "Shadow_Masks" "Download Shadow Masks$(show_update_info "Shadow_Masks")" OFF \
        "Wallpapers" "Download Various Wallpapers$(show_update_info "Wallpapers")" OFF \
        3>&1 1>&2 2>&3)

    # User cancelled
    if [ $? -ne 0 ]; then
        echo "User cancelled. Exiting."
        exit 1
    fi

    # Flags
    run_rbf_mgl=false
    run_mra=false
    run_menu=false
    run_mister_binary=false
    run_alternatives=false
    run_roms=false
    run_bios=false
    run_cheats=false
    run_filters=false
    run_filtersaudio=false
    run_font=false
    run_gamma=false
    run_gbaborders=false
    run_presets=false
    run_scripts=false
    run_shadowmasks=false
    run_wallpapers=false

    for choice in $CHOICES; do
        case $choice in
            "\"RBF_MGL\"")
                run_rbf_mgl=true
                ;;
            "\"MRA\"")
                run_mra=true
                ;;
            "\"Menu\"")
                run_menu=true
                ;;
            "\"MiSTer_binary\"")
                run_mister_binary=true
                ;;
            "\"Alternatives\"")
                run_alternatives=true
                ;;
            "\"ArcadeROMs\"")
                run_roms=true
                ;;
            "\"BIOS\"")
                run_bios=true
                ;;
            "\"Cheats\"")
                run_cheats=true
                ;;
            "\"Filters\"")
                run_filters=true
                ;;
             "\"Filters_Audio\"")
                run_filtersaudio=true
                ;;
            "\"Fonts\"")
                run_font=true
                ;;
            "\"Gamma\"")
                run_gamma=true
                ;;
            "\"GBA_Borders\"")
                run_gbaborders=true
                ;;
            "\"Presets\"")
                run_presets=true
                ;;
            "\"Scripts\"")
                run_scripts=true
                ;;
            "\"Shadow_Masks\"")
                run_shadowmasks=true
                ;;
            "\"Wallpapers\"")
                run_wallpapers=true
                ;;
        esac
    done

    # Execute choices
    if $run_rbf_mgl; then
        log "=== Starting RBF/MGL download ==="
        local total_success=0
        local total_files=0

        for folder in "${!FOLDERS[@]}"; do
            log "Processing folder: \e[1;35m$folder\e[0m"

            if fetch_file_list "$folder" "rbf_mgl"; then
                ((total_files += ${#FILES[@]}))
            else
                continue
            fi

            for file in "${FILES[@]}"; do
                [[ -z "$file" ]] && continue
                if download_file "$folder" "$file"; then
                    ((total_success++))
                fi
            done
        done

        log "RBF/MGL complete: \e[1;32m$total_success\e[0m of \e[1;33m$total_files\e[0m files"
    fi
    
    if $run_mra; then
        log "=== Starting MRA download ==="
        local total_success=0
        local total_files=0

        for folder in "${!FOLDERS[@]}"; do
            log "Processing folder: \e[1;35m$folder\e[0m"

            if fetch_file_list "$folder" "mra"; then
                ((total_files += ${#FILES[@]}))
            else
                continue
            fi

            for file in "${FILES[@]}"; do
                [[ -z "$file" ]] && continue
                if download_file "$folder" "$file"; then
                    ((total_success++))
                fi
            done
        done

        log "MRA complete: \e[1;32m$total_success\e[0m of \e[1;33m$total_files\e[0m files"
    fi
    
    if $run_menu; then
        download_menu
    fi

    if $run_mister_binary; then
        download_MiSTer_binary
    fi

    if $run_alternatives; then
        download_arcadealt
    fi

    if $run_roms; then
        download_arcaderoms
    fi

    if $run_bios; then
        download_bios
    fi

    if $run_cheats; then
        download_cheats
    fi

    if $run_filters; then
        download_filters
    fi

    if $run_filtersaudio; then
        download_filtersaudio
    fi

    if $run_font; then
        download_font
    fi

    if $run_gamma; then
        download_gamma
    fi

    if $run_gbaborders; then
        download_gbaborders
    fi

    if $run_presets; then
        download_presets
    fi

    if $run_scripts; then
        download_scripts
    fi

    if $run_shadowmasks; then
        download_shadowmasks
    fi

    if $run_wallpapers; then
        download_wallpapers
    fi

    rm -rf "$TEMP_DIR"
    sync  # Sync to ensure all pending writes are flushed
    echo -e "\e[1;35m=================================================================\e[0m"
    echo "All operations completed successfully. Safe to power off."
    echo -e "\e[1;35m=================================================================\e[0m"
#   read -p "Press enter to continue..."
}

main
exit 0
