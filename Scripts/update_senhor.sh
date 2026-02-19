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
# Color & Style Constants
###############################################
C_RESET="\e[0m"
C_BOLD="\e[1m"
C_CYAN="\e[1;36m"
C_BLUE="\e[1;34m"
C_GREEN="\e[1;32m"
C_YELLOW="\e[1;33m"
C_MAGENTA="\e[1;35m"
C_RED="\e[1;31m"
C_DIM="\e[2m"

###############################################
# Configuration
###############################################
SCRIPT_NAME="update_senhor.sh"
CURRENT_VERSION="1.6"  # Update this when you release new versions
SCRIPT_URL="https://raw.githubusercontent.com/turri21/Senhor/main/Scripts/$SCRIPT_NAME"

REPO_OWNER="turri21"
REPO_NAME="Distribution_Senhor"
BASE_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main"
VERSION_FILE="version_flags.txt"

# --- Proxy Fail-over Configuration ---
# Set to 'true' to use the proxy if direct download fails.
USE_PROXY_ON_FAIL=true
# Your Nginx cache server address. Ex: "http://192.168.1.100:8080"
PROXY_SERVER="http://proxy.andi.com.br"
PROXY_MODE_ACTIVE=false

###############################################
# ASCII Art Logo
###############################################
clear
echo -e "${C_CYAN}"
cat << "EOF"
 ██████╗███████╗███╗   ██╗██╗  ██╗ ██████╗ ██████╗           __
██╔════╝██╔════╝████╗  ██║██║  ██║██╔═══██╗██╔══██╗         (  )
███████╗█████╗  ██╔██╗ ██║███████║██║   ██║███████║          ||
╚════██║██╔══╝  ██║╚██╗██║██╔══██║██║   ██║██╔══██║          ||
███████ ███████╗██║ ╚████║██║  ██║╚██████╔╝██║  ██║  __..___|""|_
╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ /____________\
.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\____________/
EOF
echo -e "${C_RESET}"
echo -e "${C_MAGENTA}==================================================================${C_RESET}"
echo -e "${C_BOLD}         Update Script for Senhor FPGA  --  v${CURRENT_VERSION}${C_RESET}"
echo -e "${C_MAGENTA}==================================================================${C_RESET}"
echo

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
LOG_FILE="/media/fat/Scripts/senhor_download.log"
DELETE_OLD_FILES=false

mkdir -p "$TEMP_DIR"

for folder in "${!FOLDERS[@]}"; do
    mkdir -p "${FOLDERS[$folder]}"
done
touch "$LOG_FILE"

###############################################
# Progress Bar 
###############################################
# Usage: draw_progress_bar <current> <total> <label>
SPINNER_FRAMES=('|' '/' '-' '\' '|' '/' '-' '\' '|' '/')
_SPINNER_IDX=0

# Call before a download loop to suppress log() terminal output
start_progress_bar() {
    PROGRESS_BAR_ACTIVE=true
}

# Call after a download loop to restore log() output and move past the bar line
finish_progress_bar() {
    PROGRESS_BAR_ACTIVE=false
    echo
}

draw_progress_bar() {
    local current="$1"
    local total="$2"
    local label="${3:- }"
    label="${label:0:32}"

    local bar_width=28
    local pct=0
    local filled=0

    if [[ "$total" -gt 0 ]]; then
        pct=$(( current * 100 / total ))
        filled=$(( current * bar_width / total ))
    fi

    local empty=$(( bar_width - filled ))
    local bar_fill="" bar_empty=""
    for ((i=0; i<filled; i++));  do bar_fill+="█"; done
    for ((i=0; i<empty; i++));   do bar_empty+="░"; done

    local spinner="${SPINNER_FRAMES[$_SPINNER_IDX]}"
    _SPINNER_IDX=$(( (_SPINNER_IDX + 1) % ${#SPINNER_FRAMES[@]} ))

    local bar_colour="${C_CYAN}"
    local status_colour="${C_CYAN}"
    if [[ "$current" -ge "$total" && "$total" -gt 0 ]]; then
        bar_colour="${C_GREEN}"
        status_colour="${C_GREEN}"
        spinner="+"
    fi

    local tag=""
    case "${4:-}" in
        DL)   tag="${C_GREEN}[DL]${C_RESET}" ;;
        SKIP) tag="${C_DIM}[--]${C_RESET}" ;;
        ERR)  tag="${C_RED}[!!]${C_RESET}" ;;
        *)    tag="    " ;;
    esac
    printf "\r  ${status_colour}%s${C_RESET} [${bar_colour}%s${C_DIM}%s${C_RESET}] ${C_BOLD}%3d%%${C_RESET} %s/%s  ${C_DIM}%-32s${C_RESET}  %b  " \
        "$spinner" "$bar_fill" "$bar_empty" "$pct" "$current" "$total" "$label" "$tag"
}

###############################################
# Functions
###############################################

download_wrapper() {
    local url="$1"
    local output_file="$2"
    local wget_options="-q --tries=3 --timeout=5"

    # If proxy mode is already active, go directly to the proxy.
    if [[ "$PROXY_MODE_ACTIVE" = true && "$USE_PROXY_ON_FAIL" = true && -n "$PROXY_SERVER" ]]; then
        local proxy_base_url=${PROXY_SERVER%/}
        local proxied_url="${proxy_base_url}/${url}"
        if wget $wget_options "$proxied_url" -O "$output_file" && [ -s "$output_file" ]; then
            return 0
        else
            rm -f "$output_file"
            return 1
        fi
    fi

    # Attempt 1: Direct Download
    if wget $wget_options "$url" -O "$output_file" && [ -s "$output_file" ]; then
        return 0
    fi
    
    rm -f "$output_file"

    # Attempt 2: Use Proxy (if enabled and configured)
    if [[ "$USE_PROXY_ON_FAIL" = true && -n "$PROXY_SERVER" ]]; then
        PROXY_MODE_ACTIVE=true

        local proxy_base_url=${PROXY_SERVER%/}
        local proxied_url="${proxy_base_url}/${url}"
        
        if wget $wget_options "$proxied_url" -O "$output_file" && [ -s "$output_file" ]; then
            return 0
        else
            rm -f "$output_file"
        fi
    fi
    
    return 1
}
PROGRESS_BAR_ACTIVE=false

log() {
    local timestamp="$(date "+%d-%m-%Y %H:%M:%S")"
    local msg="$1"
    local level="${2:-INFO}"
    local full_msg="[$timestamp] $msg"
    echo "$full_msg" >> "$LOG_FILE"
    # Suppress terminal output while the progress bar is on screen
    [[ "$PROGRESS_BAR_ACTIVE" == true ]] && return 0
    echo "$full_msg" > /dev/tty1 2>/dev/null || true
    case "$level" in
        ERROR)   echo -e "${C_RED}[X] $msg${C_RESET}" ;;
        WARN)    echo -e "${C_YELLOW}[!] $msg${C_RESET}" ;;
        SUCCESS) echo -e "${C_GREEN}[+] $msg${C_RESET}" ;;
        *)       echo -e "${C_BLUE}[.] $msg${C_RESET}" ;;
    esac
}

check_internet() {
    log "Checking internet connection..."
    
    local connected=false
    local timeout=5
    local endpoints=("https://1.1.1.1" "https://8.8.8.8" "https://google.com")
    
    for endpoint in "${endpoints[@]}"; do
        if command -v curl >/dev/null 2>&1; then
            if curl --connect-timeout "$timeout" --max-time "$timeout" --fail --silent --head "$endpoint" >/dev/null 2>&1; then
                connected=true; break
            fi
        elif command -v wget >/dev/null 2>&1; then
            if wget --timeout="$timeout" --tries=1 --quiet --spider "$endpoint" >/dev/null 2>&1; then
                connected=true; break
            fi
        fi
    done
    
    if [ "$connected" = false ]; then
        if ping -4 -q -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
            connected=true
        fi
    fi
    
    if [ "$connected" = true ]; then
        log "Internet connection is available." SUCCESS
    else
        log "No internet connection detected." ERROR
        echo
        echo -e "${C_YELLOW}  Troubleshooting tips:${C_RESET}"
        echo -e "  ${C_DIM}*${C_RESET} Check your WiFi/Ethernet connection"
        echo -e "  ${C_DIM}*${C_RESET} Verify DNS settings (try 8.8.8.8 or 1.1.1.1)"
        echo -e "  ${C_DIM}*${C_RESET} Check if you're behind a corporate firewall"
        echo -e "  ${C_DIM}*${C_RESET} Try accessing a website in your browser"
        echo
        read -p "  Press Enter to exit..."
        exit 1
    fi
}

check_for_updates() {
    log "Checking for script updates..."
    
    local temp_script="$TEMP_DIR/$SCRIPT_NAME.tmp"
    if ! download_wrapper "$SCRIPT_URL" "$temp_script"; then
        log "Failed to check for updates. Continuing with current version." WARN
        return 1
    fi

    local latest_version
    latest_version=$(grep -m1 '^CURRENT_VERSION=' "$temp_script" | cut -d'"' -f2)
    
    if [[ "$latest_version" != "$CURRENT_VERSION" ]]; then
        log "New version available: v$latest_version (current: v$CURRENT_VERSION)" SUCCESS
        if whiptail --title "Script Update Available" \
            --yesno "A new version of update_senhor is available!\n\nCurrent:  v${CURRENT_VERSION}\nLatest:   v${latest_version}\n\nUpdate now?" 12 60; then
            # Backup current script (fixed: was $0old, should be $0.bak)
            cp "$0" "$0.bak"
            if mv "$temp_script" "$0" && chmod +x "$0"; then
                log "Successfully updated to v$latest_version. Please restart the script." SUCCESS
                exit 0
            else
                log "Update failed. Restoring backup." ERROR
                mv "$0.bak" "$0"
                return 1
            fi
        else
        log "User chose to skip update."
            rm -f "$temp_script"
        fi
    else
        log "Script is up to date (v$CURRENT_VERSION)." SUCCESS
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
    if download_wrapper "$version_url" "$version_file"; then
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
        log "No version flags file found or couldn't download it." WARN
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
    local NEWS_URL="https://github.com/turri21/Distribution_Senhor/raw/main/news.txt"
    local TEMP_FILE="/tmp/Senhor_news.txt"

    log "Fetching latest news..."
    if ! download_wrapper "$NEWS_URL" "$TEMP_FILE"; then
        log "Could not download news file." WARN
        return 1
    fi

    if [ ! -s "$TEMP_FILE" ]; then
        log "News file is empty." WARN
        return 1
    fi

    echo
    echo -e "${C_YELLOW}==================== Senhor News =================================${C_RESET}"
    echo

    while IFS= read -r line; do
        line="${line//\[TITLE\]/$'\033[1;36m>> '}"
        line="${line//\[\/TITLE\]/$'\033[0m'}"
        line="${line//\[INFO\]/$'\033[0;32m  i '}"
        line="${line//\[\/INFO\]/$'\033[0m'}"
        line="${line//\[WARNING\]/$'\033[1;31m  ! '}"
        line="${line//\[\/WARNING\]/$'\033[0m'}"
        echo -e "$line"
    done < "$TEMP_FILE"

    echo
    echo -e "${C_YELLOW}==================================================================${C_RESET}"
    echo
    echo -e "${C_MAGENTA}  Press any key to continue...${C_RESET}"
    read -n 1 -s -r
    echo
    return 0
}

prompt_delete_mode() {
    if whiptail --title "File Cleanup Mode" \
        --yesno "Delete older versions of RBF/MGL/MRA files after downloading?\n\nThis will remove superseded core versions to save space." 10 60; then
        DELETE_OLD_FILES=true
        log "Cleanup mode enabled: old RBF/MGL/MRA files will be removed." WARN
    else
        DELETE_OLD_FILES=false
        log "Cleanup mode disabled: existing files will be kept."
    fi
}

fetch_file_list() {
    local folder="$1"
    local file_type="$2"  # "rbf_mgl" or "mra"
    local list_file="$TEMP_DIR/${folder}_$FILE_LIST_EXT"
    local file_list_url="$BASE_URL/$folder/$FILE_LIST_EXT"

    mkdir -p "$(dirname "$list_file")"

    if ! download_wrapper "$file_list_url" "$list_file" >/dev/null 2>&1; then
        FILES=()
        return 1
    fi

    FILES=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line##*/}"
        line="${line//[$'\t\r\n']}"
        
        if [[ "$file_type" == "rbf_mgl" && "$line" =~ \.(rbf|mgl)$ ]]; then
            FILES+=("$line")
        elif [[ "$file_type" == "mra" && "$line" =~ \.mra$ ]]; then
            FILES+=("$line")
        fi
    done < "$list_file"

    local count=${#FILES[@]}
    if [ "$count" -eq 0 ]; then
        return 1
    fi

    return 0
}

delete_old_versions() {
    local folder="$1"
    local new_file="$2"
    local download_dir="${FOLDERS[$folder]}"
    local full_path_new="$download_dir/$new_file"

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
    local ZIP_URL="https://github.com/turri21/Distribution_Senhor/raw/main/_Arcade/_alternatives.zip"
    local DEST_DIR="/media/fat/_Arcade"
    local TEMP_ZIP="/tmp/_alternatives.zip"

    log "Removing old _alternatives folder..."
    rm -rf "/media/fat/_Arcade/_alternatives"

    log "Downloading Arcade MRA alternatives..."
    if ! download_wrapper "$ZIP_URL" "$TEMP_ZIP"; then
        log "Download failed." ERROR
        exit 1
    fi

    log "Extracting to $DEST_DIR..."
    if ! unzip -o "$TEMP_ZIP" -d "$DEST_DIR"; then
        log "Extraction failed." ERROR
        exit 1
    fi

    rm -f "$TEMP_ZIP"
    log "Arcade alternatives installed successfully." SUCCESS
}

download_file() {
    local folder="$1"
    local file="$2"
    local download_dir="${FOLDERS[$folder]}"
    local max_retries=3
    local retry_delay=2
    local local_file="$download_dir/$file"
    local temp_file="$TEMP_DIR/$file"

    # For RBF and MGL files, always respect the existing skip logic
    if [[ ( "$file" =~ \.rbf$ || "$file" =~ \.mgl$ ) && -f "$local_file" ]]; then
        log "Skipping (exists): $folder/$file"
        return 0
    fi

    # For MRA files - always skip if exists (treat like RBF/MGL)
    if [[ "$file" =~ \.mra$ && -f "$local_file" ]]; then
        log "Skipping (exists): $folder/$file"
        return 0
    fi

    # Skip if file exists and we're not in delete mode
    if [ ! "$DELETE_OLD_FILES" = true ] && [ -f "$local_file" ]; then
        log "Skipping (exists): $folder/$file"
        return 0
    fi

    # Special handling for MGL files in delete mode - compare file sizes (MRA handled above)
    if [[ "$DELETE_OLD_FILES" = true && "$file" =~ \.mgl$ && -f "$local_file" ]]; then
        # Compare file sizes instead of timestamps
        if remote_size=$(wget --spider --server-response "$BASE_URL/$folder/$file" 2>/dev/null | \
           grep -E '^Length:' | awk '{print $2}'); then
            local_size=$(stat -c %s "$local_file" 2>/dev/null || echo 0)
            
            if [[ "$remote_size" -eq "$local_size" ]]; then
                log "Skipping (unchanged): $folder/$file"
                return 0
            fi
        else
            log "Couldn't verify remote MGL size, proceeding with download..." WARN
        fi
    fi

    # Download with retry logic
    for ((i=1; i<=max_retries; i++)); do
        log "Download attempt $i for $folder/$file..."
        if download_wrapper "$BASE_URL/$folder/$file" "$temp_file"; then
            if [ -s "$temp_file" ]; then
                if $DELETE_OLD_FILES; then
                    delete_old_versions "$folder" "$file"
                fi
                mv "$temp_file" "$local_file"
                log "Downloaded: $folder/$file" SUCCESS
                return 2
            else
                log "Attempt $i: Downloaded empty file"
                rm -f "$temp_file"
            fi
        fi
        sleep $retry_delay
    done

    log "Failed to download after $max_retries attempts: $folder/$file" ERROR
    return 1
}

###############################################
# Dependency Helpers
###############################################
require_jq() {
    if ! command -v jq &>/dev/null; then
        log "Required tool 'jq' is not installed. Install it with: apt install jq" ERROR
        return 1
    fi
    return 0
}

###############################################
# Arcade ROMs
###############################################
download_arcaderoms() {
    local BASE_DIR="/media/fat"

    require_jq || return 1

    log "Downloading Arcade ROMs database..."
    if ! download_wrapper "https://raw.githubusercontent.com/zakk4223/ArcadeROMsDB_MiSTer/db/arcade_roms_db.json.zip" "$BASE_DIR/arcade_roms_db.json.zip"; then
        log "Failed to download Arcade ROMs database." ERROR
        return 1
    fi

    log "Extracting database..."
    unzip -o "$BASE_DIR/arcade_roms_db.json.zip" -d "$BASE_DIR"

    log "Processing Arcade ROMs..."
    local total=0 downloaded=0 skipped=0 failed=0

    jq -r '.files | to_entries[] | "\(.key) \(.value.url)"' "$BASE_DIR/arcade_roms_db.json" | while read -r path url; do
        local relative_path="${path#|}"
        local full_path="$BASE_DIR/$relative_path"
        mkdir -p "$(dirname "$full_path")"
        ((total++))
        if [ ! -f "$full_path" ]; then
            if download_wrapper "$url" "$full_path"; then
                log "Downloaded: $relative_path" SUCCESS
                ((downloaded++))
            else
                log "Failed: $relative_path" ERROR
                ((failed++))
            fi
        else
            log "Skipping (exists): $relative_path"
            ((skipped++))
        fi
    done

    log "Arcade ROMs complete. Downloaded: $downloaded  Skipped: $skipped  Failed: $failed" SUCCESS
}

###############################################
# BIOS files
###############################################

download_bios() {
    local BASE_DIR="/media/fat"
    local JSON_ZIP="$BASE_DIR/bios_db.json.zip"
    local JSON_FILE="$BASE_DIR/bios_db.json"
    local SUCCESS=true

    require_jq || return 1

    log "Downloading BIOS database..."
    if ! download_wrapper "https://raw.githubusercontent.com/ajgowans/BiosDB_MiSTer/db/bios_db.json.zip" "$JSON_ZIP"; then
        log "Failed to download BIOS database." ERROR
        return 1
    fi

    log "Extracting database..."
    if ! unzip -o "$JSON_ZIP" -d "$BASE_DIR"; then
        log "Extraction failed." ERROR
        SUCCESS=false
    fi

    if [ "$SUCCESS" = true ]; then
        log "Processing BIOS files..."
        jq -r '.files | to_entries[] | "\(.key) \(.value.url)"' "$JSON_FILE" | while read -r path url; do
            local relative_path="${path#|}"
            local full_path="$BASE_DIR/$relative_path"
            mkdir -p "$(dirname "$full_path")"
            if [ ! -f "$full_path" ]; then
                if ! download_wrapper "$url" "$full_path"; then
                    log "Failed to download: $relative_path" ERROR
                    SUCCESS=false
                else
                    log "Downloaded: $relative_path" SUCCESS
                fi
            else
                log "Skipping (exists): $relative_path"
            fi
        done
    fi

    log "Cleaning up temporary files..."
    rm -f "$JSON_ZIP" "$JSON_FILE"

    if [ "$SUCCESS" = true ]; then
        log "BIOS files installed successfully under $BASE_DIR/games/" SUCCESS
    else
        log "BIOS download completed with some errors." WARN
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

    log "Downloading GBA Borders database..."
    if ! download_wrapper "https://raw.githubusercontent.com/Dinierto/MiSTer-GBA-Borders/db/db.json.zip" "$DB_ZIP"; then
        log "Database download failed." ERROR
        return 1
    fi

    log "Extracting database..."
    if ! unzip -o "$DB_ZIP" -d "$JSON_DIR"; then
        log "Extraction failed." ERROR
        rm -f "$DB_ZIP"
        return 1
    fi

    if [ ! -f "$JSON_FILE" ]; then
        log "JSON file not found after extraction." ERROR
        rm -f "$DB_ZIP"
        return 1
    fi

    log "Processing GBA Borders..."

    require_jq || { rm -f "$DB_ZIP" "$JSON_FILE"; return 1; }

    # Get the commit hash from base_files_url
    COMMIT_HASH=$(jq -r '.base_files_url' "$JSON_FILE" | cut -d'/' -f6)
    if [ -z "$COMMIT_HASH" ]; then
        log "Could not determine commit hash from JSON." ERROR
        rm -f "$DB_ZIP" "$JSON_FILE"
        return 1
    fi

    # Collect all file entries first so we know the total for the progress bar
    local GBA_DATA_FILE
    GBA_DATA_FILE=$(mktemp)
    jq -r '.files | to_entries[] | "\(.key)\t\(.value.hash)\t\(.value.size)"' "$JSON_FILE" > "$GBA_DATA_FILE"
    local TOTAL_FILES=0 SKIPPED_FILES=0 DOWNLOADED_FILES=0 FAILED_FILES=0
    local GBA_TOTAL
    GBA_TOTAL=$(wc -l < "$GBA_DATA_FILE")
    log "Found $GBA_TOTAL GBA Border file(s)."
    echo
    echo -e "${C_CYAN}  [ GBA Borders ]${C_RESET}"
    start_progress_bar
    draw_progress_bar 0 "$GBA_TOTAL" "Starting..."

    local current_idx=0
    local _tag=""
    while IFS=$'\t' read -r path hash size; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        _tag=""

        relative_path="${path#|}"
        filename=$(basename "$relative_path")
        full_path="$BASE_DIR/$relative_path"
        mkdir -p "$(dirname "$full_path")"

        if [ -f "$full_path" ]; then
            current_size=$(stat -c%s "$full_path" 2>/dev/null || echo 0)
            if [ "$current_size" -eq "$size" ]; then
                current_hash=$(md5sum "$full_path" | cut -d' ' -f1)
                if [ "$current_hash" = "$hash" ]; then
                    SKIPPED_FILES=$((SKIPPED_FILES + 1))
                    _tag="SKIP"
                    ((current_idx++))
                    draw_progress_bar "$current_idx" "$GBA_TOTAL" "$filename" "$_tag"
                    continue
                fi
            fi
        fi

        max_retries=3
        retry_count=0
        success=0
        download_url="https://raw.githubusercontent.com/Dinierto/MiSTer-GBA-Borders/$COMMIT_HASH/$relative_path"

        while [ $retry_count -lt $max_retries ] && [ $success -eq 0 ]; do
            if download_wrapper "$download_url" "$full_path.tmp"; then
                current_size=$(stat -c%s "$full_path.tmp" 2>/dev/null || echo 0)
                if [ "$current_size" -eq "$size" ]; then
                    current_hash=$(md5sum "$full_path.tmp" | cut -d' ' -f1)
                    if [ "$current_hash" = "$hash" ]; then
                        mv "$full_path.tmp" "$full_path"
                        success=1
                        DOWNLOADED_FILES=$((DOWNLOADED_FILES + 1))
                    fi
                fi
            fi
            [ -f "$full_path.tmp" ] && rm -f "$full_path.tmp"
            retry_count=$((retry_count+1))
        done

        if [ $success -eq 0 ]; then
            FAILED_FILES=$((FAILED_FILES + 1))
            _tag="ERR"
            log "Failed: $filename" ERROR
        else
            _tag="DL"
        fi
        ((current_idx++))
        draw_progress_bar "$current_idx" "$GBA_TOTAL" "$filename" "$_tag"
    done < "$GBA_DATA_FILE"
    finish_progress_bar

    rm -f "$GBA_DATA_FILE" "$DB_ZIP" "$JSON_FILE"

    echo
    echo -e "${C_CYAN}  +------------------------------+${C_RESET}"
    echo -e "${C_CYAN}  |    GBA Borders  Summary      |${C_RESET}"
    echo -e "${C_CYAN}  +------------------------------+${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Total processed : ${C_BOLD}$TOTAL_FILES${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Downloaded      : ${C_GREEN}$DOWNLOADED_FILES${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Already current : ${C_DIM}$SKIPPED_FILES${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Failed          : ${C_RED}$FAILED_FILES${C_RESET}"
    echo -e "${C_CYAN}  +------------------------------+${C_RESET}"
    echo -e "  Borders installed in: ${C_YELLOW}$BASE_DIR/games/GBA/Borders/${C_RESET}"
    echo
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
        log "Processing repository: $REPO"
        
        DB_ZIP="$TEMP_DIR/${REPO##*/}.json.zip"
        JSON_FILE="$TEMP_DIR/db.json"

        log "Downloading wallpaper database from $REPO..."
        if ! download_wrapper "https://raw.githubusercontent.com/$REPO/db/db.json.zip" "$DB_ZIP"; then
            log "Database download failed for $REPO." ERROR
            continue
        fi

        log "Extracting database..."
        if ! unzip -q -o "$DB_ZIP" -d "$TEMP_DIR"; then
            log "Extraction failed for $REPO." ERROR
            rm -f "$DB_ZIP"
            continue
        fi

        if [ ! -f "$JSON_FILE" ]; then
            log "JSON file not found after extraction for $REPO. Searching..." WARN
            FOUND_JSON=$(find "$TEMP_DIR" -name "*.json" -type f | head -n 1)
            if [ -f "$FOUND_JSON" ]; then
                JSON_FILE="$FOUND_JSON"
                log "Found JSON at: $JSON_FILE"
            else
                log "No JSON file found in the archive for $REPO." ERROR
                rm -f "$DB_ZIP"
                continue
            fi
        fi

        log "Processing wallpapers from $REPO..."

        require_jq || { rm -f "$DB_ZIP" "$JSON_FILE"; return 1; }

        COMMIT_HASH=$(jq -r '.base_files_url' "$JSON_FILE" | cut -d'/' -f6 2>/dev/null)
        if [ -z "$COMMIT_HASH" ] || [ "$COMMIT_HASH" = "null" ]; then
            log "Could not determine commit hash for $REPO - using 'main'." WARN
            COMMIT_HASH="main"
        fi

        # Dump file list to temp file for progress bar (need total count upfront)
        PROCESS_FILE=$(mktemp)
        jq -r '.files | to_entries[] | "\(.key)\t\(.value.hash)\t\(.value.size)"' "$JSON_FILE" > "$PROCESS_FILE"
        local REPO_TOTAL
        REPO_TOTAL=$(grep -c . "$PROCESS_FILE" || echo 0)
        log "Found $REPO_TOTAL wallpaper file(s) in $REPO."
        echo
        echo -e "${C_CYAN}  [ Wallpapers - $REPO ]${C_RESET}"
        start_progress_bar
        draw_progress_bar 0 "$REPO_TOTAL" "Starting..."

        local repo_idx=0
        local _tag=""
        while IFS=$'\t' read -r path hash size; do
            [ -z "$path" ] || [ -z "$hash" ] || [ -z "$size" ] && continue
            _tag=""

            relative_path="${path#|}"
            filename=$(basename "$relative_path")
            [ -z "$filename" ] && continue

            full_path="$WALLPAPER_DIR/$filename"
            TOTAL_FILES=$((TOTAL_FILES + 1))

            if [ -f "$full_path" ]; then
                current_size=$(stat -c%s "$full_path" 2>/dev/null || echo 0)
                if [ "$current_size" -eq "$size" ]; then
                    current_hash=$(md5sum "$full_path" | cut -d' ' -f1)
                    if [ "$current_hash" = "$hash" ]; then
                        SKIPPED_FILES=$((SKIPPED_FILES + 1))
                        _tag="SKIP"
                        ((repo_idx++))
                        draw_progress_bar "$repo_idx" "$REPO_TOTAL" "$filename" "$_tag"
                        continue
                    fi
                fi
            fi

            max_retries=3
            retry_count=0
            success=0
            download_url="https://raw.githubusercontent.com/$REPO/$COMMIT_HASH/$relative_path"

            while [ $retry_count -lt $max_retries ] && [ $success -eq 0 ]; do
                if download_wrapper "$download_url" "$full_path.tmp"; then
                    current_size=$(stat -c%s "$full_path.tmp" 2>/dev/null || echo 0)
                    if [ "$current_size" -eq "$size" ]; then
                        current_hash=$(md5sum "$full_path.tmp" | cut -d' ' -f1)
                        if [ "$current_hash" = "$hash" ]; then
                            mv "$full_path.tmp" "$full_path"
                            success=1
                            DOWNLOADED_FILES=$((DOWNLOADED_FILES + 1))
                        fi
                    fi
                fi
                [ -f "$full_path.tmp" ] && rm -f "$full_path.tmp"
                retry_count=$((retry_count + 1))
            done

            if [ $success -eq 0 ]; then
                FAILED_FILES=$((FAILED_FILES + 1))
                _tag="ERR"
                log "Failed: $filename" ERROR
            else
                _tag="DL"
            fi
            ((repo_idx++))
            draw_progress_bar "$repo_idx" "$REPO_TOTAL" "$filename" "$_tag"
        done < "$PROCESS_FILE"
        finish_progress_bar
        rm -f "$PROCESS_FILE" "$DB_ZIP" "$JSON_FILE"
    done

    rm -rf "$TEMP_DIR"

    echo
    echo -e "${C_CYAN}  +------------------------------+${C_RESET}"
    echo -e "${C_CYAN}  |    Wallpapers  Summary       |${C_RESET}"
    echo -e "${C_CYAN}  +------------------------------+${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Total processed : ${C_BOLD}$TOTAL_FILES${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Downloaded      : ${C_GREEN}$DOWNLOADED_FILES${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Already current : ${C_DIM}$SKIPPED_FILES${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Failed          : ${C_RED}$FAILED_FILES${C_RESET}"
    echo -e "${C_CYAN}  +------------------------------+${C_RESET}"
    echo -e "  Wallpapers installed in: ${C_YELLOW}$WALLPAPER_DIR/${C_RESET}"
    echo
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
        log "Downloading split archive: ${ZIP_Z01} + ${ZIP_BASE}..."
        if ! download_wrapper "${ZIP_URL_BASE}/${ZIP_Z01}" "${ZIP_Z01}"; then
            log "Failed to download ${ZIP_Z01}" ERROR
            DOWNLOAD_SUCCESS=false
        fi

        log "Downloading ${ZIP_BASE}..."
        if ! download_wrapper "${ZIP_URL_BASE}/${ZIP_BASE}" "${ZIP_BASE}"; then
            log "Failed to download ${ZIP_BASE}" ERROR
            DOWNLOAD_SUCCESS=false
        fi

        if [ "$DOWNLOAD_SUCCESS" = true ]; then
            DOWNLOAD_SIZE=$(( $(stat -c%s "${ZIP_Z01}" 2>/dev/null || echo 0) + $(stat -c%s "${ZIP_BASE}" 2>/dev/null || echo 0) ))
            log "Joining split archive parts..."
            if ! zip -s 0 "${ZIP_BASE}" --out "joined_${ZIP_BASE}"; then
                log "Failed to join split archive parts." ERROR
                EXTRACT_SUCCESS=false
            fi
        fi
    else
        log "Downloading ${ZIP_BASE}..."
        if ! download_wrapper "${ZIP_URL_BASE}/${ZIP_BASE}" "${ZIP_BASE}"; then
            log "Failed to download ${ZIP_BASE}." ERROR
            DOWNLOAD_SUCCESS=false
        else
            DOWNLOAD_SIZE=$(stat -c%s "${ZIP_BASE}" 2>/dev/null || echo 0)
        fi
    fi

    # Extraction phase
    if [ "$DOWNLOAD_SUCCESS" = true ]; then
        log "Extracting ${ZIP_NAME} to ${OUTPUT_DIR}..."
        
        if [ "$IS_SPLIT" = true ]; then
            ZIP_TO_EXTRACT="joined_${ZIP_BASE}"
        else
            ZIP_TO_EXTRACT="${ZIP_BASE}"
        fi

        unzip -Z1 "${ZIP_TO_EXTRACT}" 2>/dev/null | grep -v '/$' > "$TEMP_LIST"
        TOTAL_FILES=$(wc -l < "$TEMP_LIST")
        head -n 5 "$TEMP_LIST" > "$TEMP_SAMPLE"

        if ! unzip -o "${ZIP_TO_EXTRACT}" -d "${OUTPUT_DIR}"; then
            log "Extraction failed." ERROR
            EXTRACT_SUCCESS=false
        else
            OUTPUT_SIZE=0
            while IFS= read -r file; do
                if [[ -f "${OUTPUT_DIR}/${file}" ]]; then
                    OUTPUT_SIZE=$((OUTPUT_SIZE + $(stat -c%s "${OUTPUT_DIR}/${file}" 2>/dev/null || echo 0)))
                fi
            done < "$TEMP_LIST"
        fi
    fi

    local END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    local STATUS_COLOR="${C_GREEN}"
    local STATUS_TEXT="SUCCESS"
    if [ "$DOWNLOAD_SUCCESS" != true ] || [ "$EXTRACT_SUCCESS" != true ]; then
        STATUS_COLOR="${C_RED}"; STATUS_TEXT="FAILED"
    fi

    echo
    echo -e "${C_CYAN}  +---------------------------------------------+${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  ${C_BOLD}${ZIP_NAME}${C_RESET} - ${STATUS_COLOR}${STATUS_TEXT}${C_RESET}"
    echo -e "${C_CYAN}  +---------------------------------------------+${C_RESET}"
    echo -e "${C_CYAN}  |${C_RESET}  Download size : $(numfmt --to=iec --format="%.2f" $DOWNLOAD_SIZE 2>/dev/null || echo "${DOWNLOAD_SIZE} B")"
    if [ "$DOWNLOAD_SUCCESS" = true ] && [ "$EXTRACT_SUCCESS" = true ]; then
        echo -e "${C_CYAN}  |${C_RESET}  Files extracted: ${C_GREEN}${TOTAL_FILES}${C_RESET}"
        echo -e "${C_CYAN}  |${C_RESET}  Output size   : $(numfmt --to=iec --format="%.2f" $OUTPUT_SIZE 2>/dev/null || echo "${OUTPUT_SIZE} B")"
        echo -e "${C_CYAN}  |${C_RESET}  Installed in  : ${C_YELLOW}${OUTPUT_DIR}/${C_RESET}"
        if [ "$TOTAL_FILES" -gt 0 ]; then
            echo -e "${C_CYAN}  |${C_RESET}  Sample files  :"
            while IFS= read -r file; do
                echo -e "${C_CYAN}  |${C_RESET}    ${C_DIM}- ${file}${C_RESET}"
            done < "$TEMP_SAMPLE"
            [ "$TOTAL_FILES" -gt 5 ] && echo -e "${C_CYAN}  |${C_RESET}    ${C_DIM}(... and $((TOTAL_FILES - 5)) more)${C_RESET}"
        fi
    fi
    echo -e "${C_CYAN}  |${C_RESET}  Time taken    : ${DURATION}s"
    echo -e "${C_CYAN}  +---------------------------------------------+${C_RESET}"
    echo

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
    
    if [ -f "$MENU_FILE" ]; then
        log "Backing up current menu.rbf..."
        if ! cp "$MENU_FILE" "$MENU_BACKUP"; then
            log "Warning: Could not back up menu.rbf" WARN
        else
            log "Backup saved: $MENU_BACKUP" SUCCESS
        fi
    fi

    download_and_extract "Menu" "https://github.com/turri21/Distribution_Senhor/raw/main/Menu.zip" false

    if [ -f "$MENU_FILE" ]; then
        log "Menu updated successfully. Previous version saved as menu.rbfold" SUCCESS
    else
        log "Warning: menu.rbf not found after extraction!" WARN
        if [ -f "$MENU_BACKUP" ]; then
            log "Restoring backup..."
            if cp "$MENU_BACKUP" "$MENU_FILE"; then
                log "Backup restored." SUCCESS
            else
                log "Failed to restore backup!" ERROR
            fi
        fi
    fi
}

download_MiSTer_binary() {
    local MiSTer_binary_FILE="/media/fat/MiSTer"
    local MiSTer_binary_BACKUP="/media/fat/MiSTerold"
    
    if [ -f "$MiSTer_binary_FILE" ]; then
        log "Backing up current MiSTer binary..."
        if ! cp "$MiSTer_binary_FILE" "$MiSTer_binary_BACKUP"; then
            log "Warning: Could not back up MiSTer binary" WARN
        else
            log "Backup saved: $MiSTer_binary_BACKUP" SUCCESS
        fi
    fi

    download_and_extract "MiSTer" "https://github.com/turri21/Distribution_Senhor/raw/main/MiSTer.zip" false

    if [ -f "$MiSTer_binary_FILE" ]; then
        log "MiSTer binary updated successfully. Previous version saved as MiSTerold" SUCCESS
    else
        log "Warning: MiSTer binary not found after extraction!" WARN
        if [ -f "$MiSTer_binary_BACKUP" ]; then
            log "Restoring backup..."
            if cp "$MiSTer_binary_BACKUP" "$MiSTer_binary_FILE"; then
                log "Backup restored." SUCCESS
            else
                log "Failed to restore backup!" ERROR
            fi
        fi
    fi
}

download_cheats() {
    download_and_extract "Cheats" "https://github.com/turri21/Distribution_Senhor/raw/main/Cheats.zip" true
}

download_docs() {
    download_and_extract "Docs" "https://github.com/turri21/Distribution_Senhor/raw/main/Docs.zip" false
}

download_filters() {
    download_and_extract "Filters" "https://github.com/turri21/Distribution_Senhor/raw/main/Filters.zip" false
}

download_filtersaudio() {
    download_and_extract "Filters_Audio" "https://github.com/turri21/Distribution_Senhor/raw/main/Filters_Audio.zip" false
}

download_font() {
    download_and_extract "Font" "https://github.com/turri21/Distribution_Senhor/raw/main/Font.zip" false
}

download_gamma() {
    download_and_extract "Gamma" "https://github.com/turri21/Distribution_Senhor/raw/main/Gamma.zip" false
}

download_linux() {
    download_and_extract "Linux" "https://github.com/turri21/Distribution_Senhor/raw/main/Linux.zip" true
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
        "Choose what you want to download (use space to select):" 27 74 19 \
        "RBF_MGL" "Download RBF/MGL files$(show_update_info "RBF_MGL")" ON \
        "MRA" "Download MRA files$(show_update_info "MRA")" OFF \
        "Menu" "Download Menu$(show_update_info "Menu")" OFF \
        "MiSTer_binary" "Download MiSTer bin for Senhor$(show_update_info "MiSTer_binary")" OFF \
        "Linux" "Download various files for Linux$(show_update_info "Linux")" OFF \
        "Alternatives" "Download Alternative MRA files$(show_update_info "Alternatives")" OFF \
        "ArcadeROMs" "Download Arcade ROMs [SLOW]$(show_update_info "ArcadeROMs")" OFF \
        "BIOS" "Download BIOS files [SLOW]$(show_update_info "BIOS")" OFF \
        "Cheats" "Download Cheats$(show_update_info "Cheats")" OFF \
        "Docs" "Download Docs$(show_update_info "Docs")" OFF \
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

    # Clear screen after menu selection
    clear

echo -e "${C_CYAN}"
cat << "EOF"
 ██████╗███████╗███╗   ██╗██╗  ██╗ ██████╗ ██████╗           __
██╔════╝██╔════╝████╗  ██║██║  ██║██╔═══██╗██╔══██╗         (  )
███████╗█████╗  ██╔██╗ ██║███████║██║   ██║███████║          ||
╚════██║██╔══╝  ██║╚██╗██║██╔══██║██║   ██║██╔══██║          ||
███████ ███████╗██║ ╚████║██║  ██║╚██████╔╝██║  ██║  __..___|""|_
╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ /____________\
.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\____________/
             Downloading in progress...
EOF
echo -e "${C_RESET}"
echo -e "${C_BLUE}"
cat << "EOF"
██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██
░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░

EOF
echo -e "${C_RESET}"

    # Flags
    run_rbf_mgl=false
    run_mra=false
    run_menu=false
    run_mister_binary=false
    run_alternatives=false
    run_roms=false
    run_bios=false
    run_cheats=false
    run_docs=false
    run_filters=false
    run_filtersaudio=false
    run_font=false
    run_gamma=false
    run_gbaborders=false
    run_linux=false
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
            "\"Docs\"")
                run_docs=true
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
            "\"Linux\"")
                run_linux=true
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
        echo
        echo -e "${C_CYAN}  [ RBF/MGL Cores ]${C_RESET}"
        # Pass 1: collect all files across all folders
        declare -a ALL_RBF_FOLDERS ALL_RBF_FILES
        
        # Start suppression early - only show progress bar
        start_progress_bar
        draw_progress_bar 0 1 "Scanning folders..."
        
        for folder in "${!FOLDERS[@]}"; do
            if fetch_file_list "$folder" "rbf_mgl"; then
                for file in "${FILES[@]}"; do
                    [[ -z "$file" ]] && continue
                    ALL_RBF_FOLDERS+=("$folder")
                    ALL_RBF_FILES+=("$file")
                done
            fi
        done
        
        local total_files=${#ALL_RBF_FILES[@]}
        local total_success=0
        local current_file=0
        
        # Reset progress bar for actual downloads
        draw_progress_bar 0 "$total_files" "Starting..."
        
        # Pass 2: download with progress bar
        for idx in "${!ALL_RBF_FILES[@]}"; do
            local folder="${ALL_RBF_FOLDERS[$idx]}"
            local file="${ALL_RBF_FILES[$idx]}"
            download_file "$folder" "$file"
            _rc=$?
            if [[ $_rc -eq 2 ]]; then
                total_success=$((total_success + 1))
                _tag="DL"
            elif [[ $_rc -eq 1 ]]; then
                _tag="ERR"
            else
                _tag="SKIP"
            fi
            current_file=$((current_file + 1))
            draw_progress_bar "$current_file" "$total_files" "$file" "$_tag"
        done
        finish_progress_bar
        unset ALL_RBF_FOLDERS ALL_RBF_FILES
        log "RBF/MGL complete: $total_success of $total_files files downloaded." SUCCESS
    fi
    
    if $run_mra; then
        echo
        echo -e "${C_CYAN}  [ MRA Files ]${C_RESET}"
        # Pass 1: collect all files across all folders
        declare -a ALL_MRA_FOLDERS ALL_MRA_FILES
        
        start_progress_bar
        draw_progress_bar 0 1 "Scanning folders..."
        
        for folder in "${!FOLDERS[@]}"; do
            if fetch_file_list "$folder" "mra"; then
                for file in "${FILES[@]}"; do
                    [[ -z "$file" ]] && continue
                    ALL_MRA_FOLDERS+=("$folder")
                    ALL_MRA_FILES+=("$file")
                done
            fi
        done
        
        local total_files=${#ALL_MRA_FILES[@]}
        local total_success=0
        local current_file=0
        
        draw_progress_bar 0 "$total_files" "Starting..."
        
        # Pass 2: download with progress bar
        for idx in "${!ALL_MRA_FILES[@]}"; do
            local folder="${ALL_MRA_FOLDERS[$idx]}"
            local file="${ALL_MRA_FILES[$idx]}"
            download_file "$folder" "$file"
            _rc=$?
            if [[ $_rc -eq 2 ]]; then
                total_success=$((total_success + 1))
                _tag="DL"
            elif [[ $_rc -eq 1 ]]; then
                _tag="ERR"
            else
                _tag="SKIP"
            fi
            ((current_file++))
            draw_progress_bar "$current_file" "$total_files" "$file" "$_tag"
        done
        finish_progress_bar
        unset ALL_MRA_FOLDERS ALL_MRA_FILES
        log "MRA complete: $total_success of $total_files files downloaded." SUCCESS
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

    if $run_docs; then
        download_docs
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
    
    if $run_linux; then
        download_linux
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
    sync  # Flush all pending writes to disk
    echo
    echo -e "${C_MAGENTA}==================================================================${C_RESET}"
    echo -e "${C_GREEN}${C_BOLD}  *  All operations completed successfully.${C_RESET}"
    echo -e "     Safe to power off your Senhor FPGA."
    echo -e "${C_MAGENTA}==================================================================${C_RESET}"
    echo
#   read -p "Press enter to continue..."
}

main
exit 0