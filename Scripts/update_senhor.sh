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

# ╔══════════════════════════════════════════════════════════════════╗
# ║                    Color & Style Constants                       ║
# ╚══════════════════════════════════════════════════════════════════╝
C_RESET="\e[0m"
C_BOLD="\e[1m"
C_ITALIC="\e[3m"
C_CYAN="\e[1;36m"
C_BLUE="\e[1;34m"
C_GREEN="\e[1;32m"
C_YELLOW="\e[1;33m"
C_MAGENTA="\e[1;35m"
C_RED="\e[1;31m"
C_DIM="\e[2m"
C_WHITE="\e[1;37m"
C_ORANGE="\e[38;5;214m"
C_PURPLE="\e[38;5;141m"

# ╔══════════════════════════════════════════════════════════════════╗
# ║                       Console Font Setup                         ║
# ╚══════════════════════════════════════════════════════════════════╝
# Load a Unicode-capable font so that box-drawing, braille spinner,
# and symbol characters render correctly on MiSTer's framebuffer console.
# The original font is restored automatically when the script exits.
_ORIG_FONT_SAVED=false

setup_console_font() {
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    local current_tty
    current_tty=$(tty 2>/dev/null || echo "pts")
    [[ "$current_tty" == *"pts"* ]] && return 0

    # Extract embedded PSF1 font (busybox-compatible, 256 glyph slots).
    # Special chars are mapped into slots 0x80-0xA9 via the unicode table,
    # but since we stay in LEGACY (non-UTF8) mode the console renders raw
    # byte values directly as glyph slot indices -- no unicode lookup needed.
    local font_file="/tmp/senhor_console.psf.gz"
    base64 -d << 'FONTEOF' > "$font_file"
H4sIAPh1mWkC/+3WWXTUVBjA8SmFUDWWUVGjVgoIBfeqWANGBPddUBRE0djBCBK1bnXUOOWJw4Mv
Hp98UZ/ddxG3oaNxG3FHdOqIW3HFumHVOvF/k5ttQI8vvs1Hf6f9cvfcm4Su0aOymUY0IhWaYRia
pmX4EZHL5SanK3R19fk/QW3NcfuLjqKsch3ZItPvqlqn6a4KMt229d6BcrncKxtonanuqOuHpgY5
f/iRqJab3Tc7F09Q0zwtHCt5NW7gbW9dUYtRiphfcWWQGVapVKmUSpYh6+mLND8KQe64QXW3FuWK
oSiK68j5txl2ucaEJwR5rVgsjiTKdZPcJWReo32w5rA/ihLl4u8C7dV8auaJBcs8XK4/Pe6aElUo
+D9h+GWiTtS/mthf/0K1Wh0oyvGzuu26NTGhIB+xLMuBNRLer35WWOwP79ewbflhD8v1Wd3L8svM
bquWyk1zKNG+6rrWrCAXI/nDyfEMTYbsf4J/Gjg/8n4MMlQ+z6CDQT5k+hGNV9rseWwnIfsf3Fqr
ro/79+914n776zPj+cnyDVVHbY3KxRoHo3JTV5WovVe5MzVft67/UhCWoSXySsWzrDCnSBOnMCq3
jER/XmmV2Lx1JXmojU4ZsjyzsujvcHOTLFdlGOFu/sOD7smnbduSvOpEz2tmk2nm/S12onLH5QCE
62tjJLsc1/fLa3G5bi81hxL3l+gV1cuO6m8p/du9Vnx/OZd68n4qSqZV8cPyjxz1gwMg6+t150Uc
Ea8iIsoHghOamF9if6JyJ5piOL/wkR7otVLzd8QJCNtnOztHxHZ0tUXlfvPE/Ujtf5CLAxDlrq3r
yX0Kzk9BUcNHqizep/J8t7LUHrHeVvnaCx7m4DchykQdrcdfysB/eulHL8xsXcjL7XX5cIuM8Hq7
LAivD6d7j/qfUhey975U/8MttVT/lGeS/VOemm+ifVgetg/HTw2amI9XF6sz6X8impqV2zb2TIx2
Z4uj684WN/5eWhavnPB9OsfsyTsFJ99jzsnEV+Ks7mNE+wLjFqLj0dLm8blbMTf+rvG9S5SLE2fy
yGeT+9WeWr+4A8n1/2vYdsY007mqbpPHl4KkPqdW4pNel9N/nJNsJ4+nEMwnNaVGNKIRjWjE/xCe
14RRaMZojIGCsWjBDtgRO0HFzmjFOGSxC3bFbhiP3bEH9oSGvbA39kEb9sUEtGMiJmEy9sMUTEUH
pmE69scBOBAH4WAcgkPRicNwOI7ADByJLhwFHTMxC0fDwDGYjWMxB3NxHI7HCTgRJ+FknIJTcRpO
xxk4E2fhbMzDfJyDc7EA5+F8LMQiXIDFuBAXYQkuxiUwcSm6kcNSXAYLl2MZluMKrICNK3EVrkYP
rsG1uA7X4wb04kbkcRNuxi1wcCsK6ENmKnsPFVmMh4Z5mI8FWIjFWAITOVhYjtW4XbSbxp7jng7P
W0u+Bk/R/yv8HsO1OyaxBxPZf/IpuIuyu8WZms75wEzoMDADHZiGsRiHe6l7H+7HA3gQD+FhPIJH
8RgexxN4MhOMvwZPYy2ewbN4Ds/jBRSxDv0o4UW8BBcvi/njVbyG11HGG1iPN/EW3sY7eBfv4X1s
wAfYiA/xESoYwMeo4hNswqf4DJ/jC3yJQWzGV/ga3+BbfIfvsQU/YAg/4if8jF/wK7biNwzjd/yB
PzGCv1AT//PF32KGcFgEFAAA
FONTEOF

    # Stay in LEGACY byte mode (do NOT send \033%G).
    # Load the font -- busybox setfont does NOT support -C, so we load it
    # directly on the current tty (which is tty1 when run from Senhor menu).
    if command -v setfont &>/dev/null && [[ -s "$font_file" ]]; then
        setfont "$font_file" 2>/dev/null && _ORIG_FONT_SAVED=false
        # Note: busybox setfont has no -O (save) or -C (target tty) flags.
        # We cannot restore the original font, but Senhor reloads its font
        # on next boot anyway.
    fi
    rm -f "$font_file"
    return 0
}

restore_console_font() {
    # busybox setfont has no save/restore -- nothing to do on physical console
    :
}

# Restore font on any exit (normal, error, or Ctrl+C)
trap restore_console_font EXIT

# ╔══════════════════════════════════════════════════════════════════╗
# ║                        Configuration                             ║
# ╚══════════════════════════════════════════════════════════════════╝
SCRIPT_NAME="update_senhor.sh"
CURRENT_VERSION="1.7"  # Update this when you release new versions
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

# ╔══════════════════════════════════════════════════════════════════╗
# ║                          Boot Splash                             ║
# ╚══════════════════════════════════════════════════════════════════╝
setup_console_font
clear
echo -e "${C_CYAN}"
cat << "EOF"                                                              
 ██████╗███████╗███╗   ██╗██╗  ██╗ ██████╗ █████╗            __           
██╔════╝██╔════╝████╗  ██║██║  ██║██╔═══██╗██╔══██╗         (  ) 
███████╗█████╗  ██╔██╗ ██║███████║██║   ██║██████╔╝          ||
╚════██║██╔══╝  ██║╚██╗██║██╔══██║██║   ██║██╔══██╗          ||
███████ ███████╗██║ ╚████║██║  ██║╚██████╔╝██║  ██║  __..___|""|_  
╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ /____________\ 
.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\____________/
EOF
echo -e "${C_RESET}"
echo -e "${C_CYAN}      [${C_RESET}  ${C_WHITE}${C_BOLD}Update Senhor Script${C_RESET}  *** ${C_YELLOW}v${CURRENT_VERSION}${C_RESET} ***  ${C_CYAN}]${C_RESET}"
echo -e "${C_DIM}      ════════════════════════════════════════${C_RESET}"
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

# Associative array: MRA filename -> expected MD5 hash (populated by fetch_file_list)
declare -gA MRA_HASHES

mkdir -p "$TEMP_DIR"

for folder in "${!FOLDERS[@]}"; do
    mkdir -p "${FOLDERS[$folder]}"
done
if [[ -f "$LOG_FILE" && $(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt $((10 * 1024 * 1024)) ]]; then
    rm -f "$LOG_FILE"
    touch "$LOG_FILE"
    echo "[$(date "+%d-%m-%Y %H:%M:%S")] Log file exceeded 10MB and was reset." >> "$LOG_FILE"
else
    touch "$LOG_FILE"
fi

# ╔══════════════════════════════════════════════════════════════════╗
# ║                        Progress Bar                              ║
# ╚══════════════════════════════════════════════════════════════════╝
# Usage: draw_progress_bar <current> <total> <label>

### Fixed Spinners Begin ###
#SPINNER_FRAMES=('|' '/' '-' '\' '|' '/' '-' '\' '|' '/')
SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
_SPINNER_IDX=0
### Fixed Spinners End ###

### Random Spinners Begin ###
#ALL_SPINNERS=(
#   '| / - \'
#    'v < ^ >'
#    '⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏'
#)

#_RANDOM_SPINNER=${ALL_SPINNERS[$RANDOM % ${#ALL_SPINNERS[@]}]}
#read -ra SPINNER_FRAMES <<< "$_RANDOM_SPINNER"
#_SPINNER_IDX=0
### Random Spinners End ###

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
        DL)   tag="${C_GREEN}[↓ DL]${C_RESET}" ;;
        EX)   tag="${C_CYAN}[◈ EX]${C_RESET}" ;;
        SKIP) tag="${C_DIM}[── ]${C_RESET}" ;;
        ERR)  tag="${C_RED}[✖ !!]${C_RESET}" ;;
        *)    tag="      " ;;
    esac
    printf "\r  ${status_colour}%s${C_RESET} [${bar_colour}%s${C_DIM}%s${C_RESET}] ${C_BOLD}%3d%%${C_RESET} %s/%s  ${C_DIM}%-32s${C_RESET}  %b  " \
        "$spinner" "$bar_fill" "$bar_empty" "$pct" "$current" "$total" "$label" "$tag"
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║                     Core Functions                               ║
# ╚══════════════════════════════════════════════════════════════════╝

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
        ERROR)   echo -e "${C_RED}  ✖  $msg${C_RESET}" ;;
        WARN)    echo -e "${C_YELLOW}  ⚠  $msg${C_RESET}" ;;
        SUCCESS) echo -e "${C_GREEN}  ✔  $msg${C_RESET}" ;;
        *)       echo -e "${C_BLUE}  ›  $msg${C_RESET}" ;;
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
echo -e "                  ████████████████████                                         "
echo -e "                  ████  ██████████████████                                     "
echo -e "                  ████████████████████████                                     "
echo -e "                  ████████████████████████                                     "
echo -e "                  ████████████████████████                                     "
echo -e "                  ████████████████████████                                     "
echo -e "                  ████████████████████████                                     "
echo -e "██                ████████████                                                 "
echo -e "██                ████████████████████                                         "
echo -e "██              ██████████████                                                 "
echo -e "████        ██████████████████                          ██                     "
echo -e "██████    ████████████████████████                    ██████                   "
echo -e "██████████████████████████████  ██                ██  ██████  ██               "
echo -e "██████████████████████████████                    ██████████████               "
echo -e "    ██████████████████████████                        ██████                   "
echo -e "      ██████████████████████                          ██████                   "
echo -e "        ██████████████████                            ██████                   "
echo -e "          ████████████████                            ██████                   " 
echo -e "███████████████████████████████████████████████████████████████████████████████"
echo -e "            ██████  ████                              ██████                   "        
echo -e "            ████      ██                                                       " 
echo -e "      ████  ██        ██                                          ████         "        
echo -e "████        ████      ████        ████                                         "            
echo -e "                                                  ██          ████      ████   "   
        echo
        echo -e "${C_RED}  ╔════════════════════════════════════════╗${C_RESET}"
        echo -e "${C_RED}  ║      ✖  No Internet Connection         ║${C_RESET}"
        echo -e "${C_RED}  ╠════════════════════════════════════════╣${C_RESET}"
        echo -e "${C_RED}  ║${C_RESET}  ${C_YELLOW}▸${C_RESET} Check your WiFi/Ethernet cable      ${C_RED}║${C_RESET}"
        echo -e "${C_RED}  ║${C_RESET}  ${C_YELLOW}▸${C_RESET} Verify DNS (try 8.8.8.8 / 1.1.1.1)  ${C_RED}║${C_RESET}"
        echo -e "${C_RED}  ║${C_RESET}  ${C_YELLOW}▸${C_RESET} Check for a corporate firewall      ${C_RED}║${C_RESET}"
        echo -e "${C_RED}  ║${C_RESET}  ${C_YELLOW}▸${C_RESET} Try loading a webpage in a browser  ${C_RED}║${C_RESET}"
        echo -e "${C_RED}  ╚════════════════════════════════════════╝${C_RESET}"
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
    echo -e "${C_WHITE}  ════════════════════════════════════════════════════════════════${C_RESET}"
    echo -e "${C_WHITE}     *  SENHOR NEWS                                               ${C_RESET}"
    echo -e "${C_WHITE}  ════════════════════════════════════════════════════════════════${C_RESET}"
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
    echo -e "${C_WHITE}  ════════════════════════════════════════════════════════════════${C_RESET}"

    # Random quote
    local QUOTES_URL="https://raw.githubusercontent.com/JamesFT/Database-Quotes-JSON/master/quotes.json"
    local QUOTES_TMP="/tmp/senhor_quotes.json"
    if download_wrapper "$QUOTES_URL" "$QUOTES_TMP" && [ -s "$QUOTES_TMP" ]; then
        # Count total quotes (one "quoteText" per quote)
        local total_quotes
        total_quotes=$(grep -c '"quoteText"' "$QUOTES_TMP" 2>/dev/null || echo 0)
        if [ "$total_quotes" -gt 0 ]; then
            # Pick a random quote index (1-based)
            local pick=$(( (RANDOM * RANDOM % total_quotes) + 1 ))
            # Extract the quoteText and quoteAuthor at that index
            local quote_text quote_author
            quote_text=$(grep '"quoteText"' "$QUOTES_TMP" | sed -n "${pick}p" | sed 's/.*"quoteText": *"\([^"]*\)".*/\1/')
            quote_author=$(grep '"quoteAuthor"' "$QUOTES_TMP" | sed -n "${pick}p" | sed 's/.*"quoteAuthor": *"\([^"]*\)".*/\1/')
            if [ -n "$quote_text" ]; then
                echo
                # Wrap at 61 chars (66 total width minus 5 char indent "  \"  ")
                local first=true
                echo "$quote_text" | fold -s -w 61 | while IFS= read -r qline; do
                    if [ "$first" = true ]; then
                        echo -e "  \"  ${C_WHITE}${qline}${C_RESET}"
                        first=false
                    else
                        echo -e "     ${C_WHITE}${qline}${C_RESET}"
                    fi
                done
                [ -n "$quote_author" ] && echo -e "     -- ${quote_author}${C_RESET}"
            fi
        fi
        rm -f "$QUOTES_TMP"
    fi

    echo
    echo -e "${C_MAGENTA}  ► Press any key to continue...${C_RESET}"
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
        line="${line//[$'\t\r\n']}"

        if [[ "$file_type" == "rbf_mgl" ]]; then
            local fname="${line##*/}"
            if [[ "$fname" =~ \.(rbf|mgl)$ ]]; then
                FILES+=("$fname")
            fi
        elif [[ "$file_type" == "mra" ]]; then
            # MRA lines format: filename.mra|md5hash|size  (or plain filename.mra)
            local fname hash
            if [[ "$line" == *"|"* ]]; then
                fname="${line%%|*}"
                fname="${fname##*/}"
                hash=$(echo "$line" | cut -d'|' -f2)
            else
                fname="${line##*/}"
                hash=""
            fi
            if [[ "$fname" =~ \.mra$ ]]; then
                FILES+=("$fname")
                # Store the expected MD5 hash for later comparison in download_file
                MRA_HASHES["$fname"]="$hash"
            fi
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

    echo
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
    echo -e "${C_CYAN}       Alternatives          ${C_RESET}"
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"

    log "Downloading Arcade MRA alternatives..."
    if ! download_wrapper "$ZIP_URL" "$TEMP_ZIP"; then
        log "Download failed." ERROR
        exit 1
    fi

    log "Extracting alternatives..."

    local TOTAL_FILES
    TOTAL_FILES=$(unzip -t "$TEMP_ZIP" 2>/dev/null | grep -c '^\s*testing:')
    [ -z "$TOTAL_FILES" ] || [ "$TOTAL_FILES" -eq 0 ] && TOTAL_FILES=1

    local unzip_exit_file="/tmp/unzip_exit_alt_$$"
    local unzip_err_file="/tmp/unzip_err_alt_$$"
    local current=0

    start_progress_bar
    draw_progress_bar 0 "$TOTAL_FILES" "Starting..." "EX"

    while IFS= read -r line; do
        case "$line" in
            *inflating:*|*extracting:*|*creating:*|*linking:*)
                current=$(( current + 1 ))
                local fname="${line##*: }"
                fname="${fname##*/}"
                fname="${fname%% *}"
                [ ${#fname} -gt 30 ] && fname="${fname:0:27}..."
                draw_progress_bar "$current" "$TOTAL_FILES" "$fname" "EX"
                ;;
            *)
                [ -n "$line" ] && echo "$line" >> "$unzip_err_file"
                ;;
        esac
    done < <(unzip -o "$TEMP_ZIP" -d "$DEST_DIR" 2>&1; echo $? > "$unzip_exit_file")

    local unzip_status=0
    [ -f "$unzip_exit_file" ] && { unzip_status=$(cat "$unzip_exit_file"); rm -f "$unzip_exit_file"; }

    draw_progress_bar "$TOTAL_FILES" "$TOTAL_FILES" "Complete" "EX"
    finish_progress_bar

    if [ "$unzip_status" -gt 1 ]; then
        [ -f "$unzip_err_file" ] && while IFS= read -r errline; do
            log "  >> $errline" ERROR
        done < "$unzip_err_file"
        rm -f "$unzip_err_file" "$TEMP_ZIP"
        exit 1
    fi

    rm -f "$unzip_err_file" "$TEMP_ZIP"
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

    # For MRA files - compare MD5 hash against file_list.txt; only skip if unchanged
    if [[ "$file" =~ \.mra$ && -f "$local_file" ]]; then
        local expected_hash="${MRA_HASHES[$file]:-}"
        if [[ -n "$expected_hash" ]]; then
            local local_hash
            local_hash=$(md5sum "$local_file" 2>/dev/null | awk '{print $1}')
            if [[ "$local_hash" == "$expected_hash" ]]; then
                log "Skipping (unchanged): $folder/$file"
                return 0
            else
                log "MRA changed (hash mismatch), updating: $folder/$file" WARN
                # If DELETE_OLD_FILES is false, warn but still replace the MRA
                # (MRAs don't stack like versioned RBFs; replacing is always safe)
                if [[ "$DELETE_OLD_FILES" != true ]]; then
                    log "Replacing updated MRA (cleanup mode off, but content changed): $folder/$file" WARN
                fi
                # Fall through to download logic below
            fi
        else
            # No hash available in file_list — fall back to skip-if-exists behaviour
            log "Skipping (exists, no hash to verify): $folder/$file"
            return 0
        fi
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

# ╔══════════════════════════════════════════════════════════════════╗
# ║                    Dependency Helpers                            ║
# ╚══════════════════════════════════════════════════════════════════╝
require_jq() {
    if ! command -v jq &>/dev/null; then
        log "Required tool 'jq' is not installed. Install it with: apt install jq" ERROR
        return 1
    fi
    return 0
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║                       Arcade ROMs                                ║
# ╚══════════════════════════════════════════════════════════════════╝
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

    # Pass 1: collect all path/url pairs into arrays so we know the total upfront
    declare -a ROM_PATHS ROM_URLS
    while IFS=' ' read -r path url; do
        ROM_PATHS+=("${path#|}")
        ROM_URLS+=("$url")
    done < <(jq -r '.files | to_entries[] | "\(.key) \(.value.url)"' "$BASE_DIR/arcade_roms_db.json")

    local total=${#ROM_PATHS[@]}
    local downloaded=0 skipped=0 failed=0 current=0

    echo
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
    echo -e "${C_CYAN}          Arcade ROMs        ${C_RESET}"
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
    start_progress_bar
    draw_progress_bar 0 "$total" "Starting..."

    # Pass 2: download with progress bar
    for idx in "${!ROM_PATHS[@]}"; do
        local relative_path="${ROM_PATHS[$idx]}"
        local url="${ROM_URLS[$idx]}"
        local full_path="$BASE_DIR/$relative_path"
        local label="${relative_path##*/}"
        mkdir -p "$(dirname "$full_path")"
        ((current++))

        if [ ! -f "$full_path" ]; then
            if download_wrapper "$url" "$full_path"; then
                log "Downloaded: $relative_path" SUCCESS
                ((downloaded++))
                draw_progress_bar "$current" "$total" "$label" "DL"
            else
                log "Failed: $relative_path" ERROR
                ((failed++))
                draw_progress_bar "$current" "$total" "$label" "ERR"
            fi
        else
            log "Skipping (exists): $relative_path"
            ((skipped++))
            draw_progress_bar "$current" "$total" "$label" "SKIP"
        fi
    done

    finish_progress_bar
    unset ROM_PATHS ROM_URLS
    log "Arcade ROMs complete. Downloaded: $downloaded  Skipped: $skipped  Failed: $failed" SUCCESS

    log "Cleaning up database files..."
    rm -f "$BASE_DIR/arcade_roms_db.json.zip" "$BASE_DIR/arcade_roms_db.json"
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║                        BIOS Files                                ║
# ╚══════════════════════════════════════════════════════════════════╝

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

# ╔══════════════════════════════════════════════════════════════════╗
# ║                       GBA Borders                                ║
# ╚══════════════════════════════════════════════════════════════════╝

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
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
    echo -e "${C_CYAN}          GBA Borders        ${C_RESET}"
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
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
    echo -e "${C_CYAN}  ╔═══════════════════════════════════════╗${C_RESET}"
    echo -e "${C_CYAN}  ║        GBA Borders Summary            ║${C_RESET}"
    echo -e "${C_CYAN}  ╠═══════════════════════════════════════╣${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Total processed  : ${C_BOLD}$TOTAL_FILES${C_RESET}               ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Downloaded  ${C_GREEN}↓${C_RESET}    : ${C_GREEN}${C_BOLD}$DOWNLOADED_FILES${C_RESET}                 ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Up to date  ${C_DIM}─${C_RESET}    : ${C_DIM}$SKIPPED_FILES${C_RESET}               ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Failed      ${C_RED}✖${C_RESET}    : ${C_RED}$FAILED_FILES${C_RESET}                 ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ╠═══════════════════════════════════════╣${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  ${C_DIM}Path:${C_RESET} ${C_YELLOW}$BASE_DIR/games/GBA/Borders/${C_RESET}  ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ╚═══════════════════════════════════════╝${C_RESET}"
    echo
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║                       Wallpapers                                 ║
# ╚══════════════════════════════════════════════════════════════════╝

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
         
        echo 
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

        echo -e "${C_CYAN}  ═════════════════════════════════════════${C_RESET}"
        echo -e "${C_CYAN}     Wallpapers · ${C_YELLOW}${REPO##*/}"
        echo -e "${C_CYAN}  ═════════════════════════════════════════${C_RESET}"
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
    echo -e "${C_CYAN}  ╔══════════════════════════════════╗${C_RESET}"
    echo -e "${C_CYAN}  ║        Wallpapers Summary        ║${C_RESET}"
    echo -e "${C_CYAN}  ╠══════════════════════════════════╣${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Total processed : ${C_BOLD}$TOTAL_FILES${C_RESET}           ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Downloaded  ${C_GREEN}↓${C_RESET}   : ${C_GREEN}${C_BOLD}$DOWNLOADED_FILES${C_RESET}             ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Up to date  ${C_DIM}─${C_RESET}   : ${C_DIM}$SKIPPED_FILES${C_RESET}           ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  Failed      ${C_RED}✖${C_RESET}   : ${C_RED}$FAILED_FILES${C_RESET}             ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ╠══════════════════════════════════╣${C_RESET}"
    echo -e "${C_CYAN}  ║${C_RESET}  ${C_DIM}Path:${C_RESET} ${C_YELLOW}$WALLPAPER_DIR/${C_RESET}    ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}  ╚══════════════════════════════════╝${C_RESET}"
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║                  Progress Bar – Zip Extraction                   ║
# ╚══════════════════════════════════════════════════════════════════╝
extract_with_progress() {
    local zip_file="$1"
    local dest_dir="$2"
    local label="${3:-Extracting}"
    
    # Get total number of files in zip
    local total_files=$(unzip -l "$zip_file" 2>/dev/null | tail -1 | awk '{print $2}')
    [ -z "$total_files" ] || [ "$total_files" -eq 0 ] && total_files=1
    
    local current=0
    start_progress_bar
    
    # Extract with quiet mode but process each file
    unzip -o "$zip_file" -d "$dest_dir" 2>/dev/null | while IFS= read -r line; do
        if [[ "$line" == extracting* ]]; then
            ((current++))
            # Extract filename from the line
            local fname=$(echo "$line" | sed 's/extracting: //' | sed 's/^[[:space:]]*//')
            fname=$(basename "$fname")
            draw_progress_bar "$current" "$total_files" "$fname" "DL"
        fi
    done
    
    finish_progress_bar
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║                   Download & Extract Function                    ║
# ╚══════════════════════════════════════════════════════════════════╝

download_and_extract() {
    local ZIP_NAME="$1"
    local ZIP_URL_FULL="$2"
    local IS_SPLIT="${3:-false}"
    local ZIP_DIR="/tmp/${ZIP_NAME}_download"
    local OUTPUT_DIR="/media/fat"
    local TEMP_LIST=$(mktemp)
    local PROGRESS_FILE="/tmp/unzip_progress_$$"
    
    local DOWNLOAD_SUCCESS=true
    local EXTRACT_SUCCESS=true
    local START_TIME=$(date +%s)
    local DOWNLOAD_SIZE=0

    mkdir -p "${ZIP_DIR}"
    cd "${ZIP_DIR}" || return 1

    local ZIP_BASE="${ZIP_NAME}.zip"
    local ZIP_Z01="${ZIP_NAME}.z01"
    local ZIP_URL_BASE=$(dirname "${ZIP_URL_FULL}")

    echo
    local _hdr_pad=$(( (27 - ${#ZIP_NAME}) / 2 ))
    printf -v _hdr_spaces '%*s' "$_hdr_pad" ''
    echo
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
    echo -e "${C_CYAN}  ${_hdr_spaces}${ZIP_NAME}${C_RESET}"
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"

    # Download phase
    if [ "$IS_SPLIT" = true ]; then
        echo -e "${C_BLUE}  Downloading part 1...${C_RESET}"
        if ! download_wrapper "${ZIP_URL_BASE}/${ZIP_Z01}" "${ZIP_Z01}"; then
            log "Failed to download ${ZIP_Z01}" ERROR
            DOWNLOAD_SUCCESS=false
        fi

        echo -e "${C_BLUE}  Downloading part 2...${C_RESET}"
        if ! download_wrapper "${ZIP_URL_BASE}/${ZIP_BASE}" "${ZIP_BASE}"; then
            log "Failed to download ${ZIP_BASE}" ERROR
            DOWNLOAD_SUCCESS=false
        fi

        if [ "$DOWNLOAD_SUCCESS" = true ]; then
            DOWNLOAD_SIZE=$(( $(stat -c%s "${ZIP_Z01}" 2>/dev/null || echo 0) + $(stat -c%s "${ZIP_BASE}" 2>/dev/null || echo 0) ))
            log "Merging split archive parts..."
            # zip writes "copying:" progress directly to /dev/tty; setsid detaches it
            # from the terminal so those messages have nowhere to go.
            if ! setsid zip -s 0 "${ZIP_BASE}" --out "joined_${ZIP_BASE}" >/dev/null 2>&1; then
                log "Failed to merge split archive parts." ERROR
                EXTRACT_SUCCESS=false
            fi
        fi
    else
        echo -e "${C_BLUE}  Downloading...${C_RESET}"
        if ! download_wrapper "${ZIP_URL_BASE}/${ZIP_BASE}" "${ZIP_BASE}"; then
            log "Failed to download ${ZIP_BASE}." ERROR
            DOWNLOAD_SUCCESS=false
        else
            DOWNLOAD_SIZE=$(stat -c%s "${ZIP_BASE}" 2>/dev/null || echo 0)
        fi
    fi

    # Extraction phase with progress bar (REAL PROGRESS - Preserves Structure)
    if [ "$DOWNLOAD_SUCCESS" = true ]; then
        echo -e "${C_BLUE}  Extracting...${C_RESET}"
        
        ZIP_TO_EXTRACT="${ZIP_BASE}"
        [ "$IS_SPLIT" = true ] && ZIP_TO_EXTRACT="joined_${ZIP_BASE}"

        # Get exact file count via test pass — counts same entries that extraction will emit
        local TOTAL_FILES
        TOTAL_FILES=$(unzip -t "${ZIP_TO_EXTRACT}" 2>/dev/null | grep -c '^\s*testing:')
        [ -z "$TOTAL_FILES" ] || [ "$TOTAL_FILES" -eq 0 ] && TOTAL_FILES=1

        start_progress_bar
        draw_progress_bar 0 "$TOTAL_FILES" "Starting..." "EX"

        # Single unzip pass — parse verbose output line-by-line to drive progress bar
        local unzip_exit_file="/tmp/unzip_exit_$$"
        local current=0
        local unzip_err_file="/tmp/unzip_err_$$"
        while IFS= read -r line; do
            case "$line" in
                *inflating:*|*extracting:*|*creating:*|*linking:*)
                    current=$(( current + 1 ))
                    local fname="${line##*: }"
                    fname="${fname##*/}"
                    fname="${fname%% *}"
                    [ ${#fname} -gt 30 ] && fname="${fname:0:27}..."
                    draw_progress_bar "$current" "$TOTAL_FILES" "$fname" "EX"
                    ;;
                *)
                    # Capture any error/warning lines to log file for diagnosis
                    [ -n "$line" ] && echo "$line" >> "$unzip_err_file"
                    ;;
            esac
        done < <(unzip -o "${ZIP_TO_EXTRACT}" -d "${OUTPUT_DIR}" 2>&1; echo $? > "$unzip_exit_file")

        # Read exit status written by the process substitution
        local unzip_status=0
        [ -f "$unzip_exit_file" ] && { unzip_status=$(cat "$unzip_exit_file"); rm -f "$unzip_exit_file"; }

        draw_progress_bar "$TOTAL_FILES" "$TOTAL_FILES" "Complete" "EX"
        finish_progress_bar

        # unzip exit 0 = success, 1 = warnings only (treat as success), 2+ = real errors
        if [ "$unzip_status" -gt 1 ]; then
            EXTRACT_SUCCESS=false
            log "Extraction failed with status $unzip_status." ERROR
            [ -f "$unzip_err_file" ] && while IFS= read -r errline; do
                log "  >> $errline" ERROR
            done < "$unzip_err_file"
        fi
        rm -f "$unzip_err_file"
        if [ "$unzip_status" -gt 1 ]; then
            EXTRACT_SUCCESS=false
            log "Extraction failed with status $unzip_status." ERROR
        fi

        rm -f "$PROGRESS_FILE" "$TEMP_LIST"
        [ "$IS_SPLIT" = true ] && rm -f "joined_${ZIP_BASE}"
    fi

    local END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    local STATUS_COLOR="${C_GREEN}"
    local STATUS_TEXT="SUCCESS"
    if [ "$DOWNLOAD_SUCCESS" != true ] || [ "$EXTRACT_SUCCESS" != true ]; then
        STATUS_COLOR="${C_RED}"; STATUS_TEXT="FAILED"
    fi

    echo
    echo -e "${C_CYAN}  -<═════════════════════════════════════════════>-${C_RESET}"
    local _banner_inner=45
    # Pin * at column 20 (0-based): prefix(4) + name + name_pad(14-len) + "  *"
    # This aligns * with the box label colons below (also at col 20).
    local _name_pad=$(( 13 - ${#ZIP_NAME} ))
    [[ $_name_pad -lt 1 ]] && _name_pad=1
    printf -v _name_spaces '%*s' "$_name_pad" ''
    # Right-align STATUS_TEXT flush with banner border
    local _banner_used=$(( 4 + ${#ZIP_NAME} + _name_pad + 5 + ${#STATUS_TEXT} ))
    local _banner_pad=$(( _banner_inner - _banner_used ))
    [[ $_banner_pad -lt 0 ]] && _banner_pad=0
    printf -v _banner_spaces '%*s' "$_banner_pad" ''
    echo -e "${C_CYAN}  ${C_RESET}  ${C_BOLD}${ZIP_NAME}${_name_spaces}${C_RESET}  ${C_DIM}*${C_RESET}  ${STATUS_COLOR}${STATUS_TEXT}${C_RESET}${_banner_spaces}${C_CYAN} ${C_RESET}"
    echo -e "${C_CYAN}  -<═════════════════════════════════════════════>-${C_RESET}"
    # Box inner width = 47 (number of ═ in top border)
    # Box label colons are padded to col 20: "  ║  " (5) + label(14) + ":" = col 20
    local _BOX_W=47
    local _size_str _files_str _path_str _time_str
    _size_str="Size          :  $(numfmt --to=iec --format="%.2f" $DOWNLOAD_SIZE 2>/dev/null || echo "${DOWNLOAD_SIZE} B")"
    _time_str="Time          :  ${DURATION}s"

    _box_line() {
        # Print one padded box row; $1 = plain text (no ANSI), $2 = styled text for display
        local _plain="$1" _styled="$2"
        local _pad=$(( _BOX_W - ${#_plain} - 2 ))  # 2 for leading "  "
        [[ $_pad -lt 0 ]] && _pad=0
        printf -v _spaces '%*s' "$_pad" ''
        echo -e "${C_CYAN}  ║${C_RESET}  ${_styled}${_spaces}${C_CYAN}║${C_RESET}"
    }

    echo
    echo -e "${C_CYAN}  ╔═══════════════════════════════════════════════╗${C_RESET}"
    _box_line "$_size_str"  "${C_DIM}Size          :${C_RESET}  $(numfmt --to=iec --format="%.2f" $DOWNLOAD_SIZE 2>/dev/null || echo "${DOWNLOAD_SIZE} B")"
    if [ "$DOWNLOAD_SUCCESS" = true ] && [ "$EXTRACT_SUCCESS" = true ]; then
        _files_str="Files         :  ${TOTAL_FILES} extracted"
        _path_str="Path          :  ${OUTPUT_DIR}/"
        _box_line "$_files_str" "${C_DIM}Files         :${C_RESET}  ${C_GREEN}${TOTAL_FILES}${C_RESET} extracted"
        _box_line "$_path_str"  "${C_DIM}Path          :${C_RESET}  ${C_YELLOW}${OUTPUT_DIR}/${C_RESET}"
    fi
    _box_line "$_time_str"  "${C_DIM}Time          :${C_RESET}  ${DURATION}s"
    echo -e "${C_CYAN}  ╚═══════════════════════════════════════════════╝${C_RESET}"
    echo

    rm -rf "$ZIP_DIR"

    if [ "$DOWNLOAD_SUCCESS" = true ] && [ "$EXTRACT_SUCCESS" = true ]; then
        return 0
    else
        return 1
    fi
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║                  Specific Download Wrappers                      ║
# ╚══════════════════════════════════════════════════════════════════╝

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

# ╔══════════════════════════════════════════════════════════════════╗
# ║                    Cheats Download                               ║
# ╚══════════════════════════════════════════════════════════════════╝

download_cheats() {
    echo
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
    echo -e "${C_CYAN}             Cheats          ${C_RESET}"
    echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
    
    local CHEATS_URL_A="https://github.com/turri21/Distribution_Senhor/raw/main/Cheats_a.zip"
    local CHEATS_URL_B="https://github.com/turri21/Distribution_Senhor/raw/main/Cheats_b.zip"
    local DEST_DIR="/media/fat"
    local TEMP_ZIP_A="/tmp/Cheats_a.zip"
    local TEMP_ZIP_B="/tmp/Cheats_b.zip"
    local SUCCESS=true
    
    # Part A
    echo -e "${C_BLUE}  Downloading Part A...${C_RESET}"
    if ! download_wrapper "$CHEATS_URL_A" "$TEMP_ZIP_A"; then
        log "Failed to download Cheats_a.zip" ERROR
        SUCCESS=false
    else
        echo -e "${C_BLUE}  Extracting Part A...${C_RESET}"
        
        local total_a=$(unzip -Z1 "$TEMP_ZIP_A" 2>/dev/null | grep -v '/$' | wc -l | tr -d '[:space:]')
        
        if [ -z "$total_a" ] || [ "$total_a" -eq 0 ] 2>/dev/null; then
            log "No files found in Cheats_a.zip" ERROR
            rm -f "$TEMP_ZIP_A"
            SUCCESS=false
        else
            start_progress_bar
            draw_progress_bar 0 "$total_a" "Starting..." "DL"
            
            # Extract in background
            unzip -o "$TEMP_ZIP_A" -d "$DEST_DIR" >/dev/null 2>&1 &
            local UNZIP_PID=$!
            
            # Time-based progress estimation
            local current=0
            local start_time=$(date +%s)
            
            while kill -0 $UNZIP_PID 2>/dev/null; do
                local now=$(date +%s)
                local elapsed=$((now - start_time))
                
                # Estimate: ~30 seconds per 1000 files
                local estimated_total=$(( (total_a / 1000) * 44 ))
                [ "$estimated_total" -lt 10 ] && estimated_total=10
                
                current=$(( (elapsed * total_a) / estimated_total ))
                [ "$current" -gt "$((total_a - 100))" ] && current=$((total_a - 100))
                [ "$current" -lt 0 ] && current=0
                
                draw_progress_bar "$current" "$total_a" "Extracting..." "EX"
                sleep 0.2
            done
            
            wait $UNZIP_PID
            local unzip_status=$?
            
            draw_progress_bar "$total_a" "$total_a" "Complete" "EX"
            finish_progress_bar
            
            if [ $unzip_status -eq 0 ]; then
                log "Cheats Part A installed successfully ($total_a files)." SUCCESS
            else
                log "Extraction failed for Cheats_a.zip (exit: $unzip_status)" ERROR
                SUCCESS=false
            fi
        fi
        rm -f "$TEMP_ZIP_A"
    fi
    
    # Part B
    echo -e "${C_BLUE}  Downloading Part B...${C_RESET}"
    if ! download_wrapper "$CHEATS_URL_B" "$TEMP_ZIP_B"; then
        log "Failed to download Cheats_b.zip" ERROR
        SUCCESS=false
    else
        echo -e "${C_BLUE}  Extracting Part B...${C_RESET}"
        
        local total_b=$(unzip -Z1 "$TEMP_ZIP_B" 2>/dev/null | grep -v '/$' | wc -l | tr -d '[:space:]')
        
        if [ -z "$total_b" ] || [ "$total_b" -eq 0 ] 2>/dev/null; then
            log "No files found in Cheats_b.zip" ERROR
            rm -f "$TEMP_ZIP_B"
            SUCCESS=false
        else
            start_progress_bar
            draw_progress_bar 0 "$total_b" "Starting..." "DL"
            
            unzip -o "$TEMP_ZIP_B" -d "$DEST_DIR" >/dev/null 2>&1 &
            local UNZIP_PID=$!
            
            local current=0
            local start_time=$(date +%s)
            
            while kill -0 $UNZIP_PID 2>/dev/null; do
                local now=$(date +%s)
                local elapsed=$((now - start_time))
                
                local estimated_total=$(( (total_b / 1000) * 44 ))
                [ "$estimated_total" -lt 10 ] && estimated_total=10
                
                current=$(( (elapsed * total_b) / estimated_total ))
                [ "$current" -gt "$((total_b - 100))" ] && current=$((total_b - 100))
                [ "$current" -lt 0 ] && current=0
                
                draw_progress_bar "$current" "$total_b" "Extracting..." "EX"
                sleep 0.2
            done
            
            wait $UNZIP_PID
            local unzip_status=$?
            
            draw_progress_bar "$total_b" "$total_b" "Complete" "EX"
            finish_progress_bar
            
            if [ $unzip_status -eq 0 ]; then
                log "Cheats Part B installed successfully ($total_b files)." SUCCESS
            else
                log "Extraction failed for Cheats_b.zip (exit: $unzip_status)" ERROR
                SUCCESS=false
            fi
        fi
        rm -f "$TEMP_ZIP_B"
    fi
    
    if [ "$SUCCESS" = true ]; then
        log "All Cheats installed successfully." SUCCESS
    else
        log "Cheats installation completed with some errors." WARN
    fi
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

# ╔══════════════════════════════════════════════════════════════════╗
# ║                        Main Process                              ║
# ╚══════════════════════════════════════════════════════════════════╝

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
        echo -e "${C_YELLOW}  ⚠  Operation cancelled by user. Goodbye!${C_RESET}"
        exit 1
    fi

    # Clear screen after menu selection
    clear

echo -e "${C_CYAN}"
cat << "EOF"
 ██████╗███████╗███╗   ██╗██╗  ██╗ ██████╗ █████╗            __           
██╔════╝██╔════╝████╗  ██║██║  ██║██╔═══██╗██╔══██╗         (  ) 
███████╗█████╗  ██╔██╗ ██║███████║██║   ██║██████╔╝          ||
╚════██║██╔══╝  ██║╚██╗██║██╔══██║██║   ██║██╔══██╗          ||
███████ ███████╗██║ ╚████║██║  ██║╚██████╔╝██║  ██║  __..___|""|_  
╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ /____________\ 
.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\____________/
EOF
echo -e "${C_RESET}"
echo -e "${C_WHITE}  ════════════════════════════════════════════════════════════════${C_RESET}"
echo -e "${C_WHITE}     ↓  Download session started  ·  please wait                  ${C_RESET}"
echo -e "${C_WHITE}  ════════════════════════════════════════════════════════════════${C_RESET}"

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
        echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
        echo -e "${C_CYAN}        RBF / MGL Cores      ${C_RESET}"
        echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
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
        echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
        echo -e "${C_CYAN}           MRA Files         ${C_RESET}"
        echo -e "${C_CYAN}  ═══════════════════════════${C_RESET}"
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
    echo -e "${C_GREEN}"
    cat << "DONE"
  ╔═══════════════════════════════════════════════╗
  ║                                               ║
  ║   ██████╗  ██████╗ ███╗   ██╗███████╗         ║
  ║   ██╔══██╗██╔═══██╗████╗  ██║██╔════╝         ║
  ║   ██║  ██║██║   ██║██╔██╗ ██║█████╗           ║
  ║   ██║  ██║██║   ██║██║╚██╗██║██╔══╝           ║
  ║   ██████╔╝╚██████╔╝██║ ╚████║███████╗         ║
  ║   ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝         ║
  ║                                               ║
  ║   +  All operations completed successfully.   ║
  ║   +  Safe to power off your Senhor FPGA.      ║
  ║                                               ║
  ╚═══════════════════════════════════════════════╝
DONE
    echo -e "${C_RESET}"
    echo
#   read -p "Press enter to continue..."
}

main
exit 0