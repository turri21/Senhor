#!/bin/bash
# Senhor Multi-Folder File Download Script

###############################################
# ASCII Art Logo
###############################################
echo -e "\e[1;36m"
cat << "EOF"

                                           -*%@%%#####+-.                                           
                                         :@@@@%%%%%@@@@@@#.                                         
                                        -@@@-..::::::::*@@@:                                        
                           =*+.         @@@***:.:**=:=***@@#         :*#-                           
                         =@@@@@#.      =@@#:=-...-=::-==:@@@:      :#@@@@%:                         
                        *@@@%@@@@+     @@@#+===----===+++%@@+     +@@@@@@@@-                        
                      .%@@@+ .*@@@%:  .@@@--=+++****++++=+@@@   .%@@@*..%@@@=                       
                      @@@@- -= :@@@@= +@@%*++===-====++***@@@: -@@@@- +: %@@@=                      
                     @@@@- *@@@. #@@@#%@@-...::::-=---::::*@@**@@@%.-@@@@@@@@@@@@@@%+-              
                    %@@@- *@%=@@- +@@@@@%........:::::::::-@@@@@@@@@@@@@@@@%#*###@@@@@@*            
                  :#@@@= =@@==+@@+ -@@@@###***++*****##*#%%@@@@@@@#+===+-=:::=-=:::-+*@@%           
               .=%@@@@%:.@@@%%%@@@- -@@@----======+***###+-=*#*=-==+=+##*#######*++-=.%@@-          
              =@@@@@@@@@@@%#++++=++*%@@@##***##%%%#=:--::.-+-+*#%%*=-.:::::::::::=#%-:@@@:          
             %@@@-:.: =#%@@@@@@@@@@@@@%:.:....:==...-=:*%@@#+-..::..:::::::::::::::+%#@@+           
            +@@@%#*+++*%%##+*:--=::===..===:.:=--+##%*-:::.::::::.-..::::::::.-::::=@@@#            
            @@@@-.::.:..:---==+**##%#%##%####***+=-::....::::..:=+******+=-:::::::=%@@@#            
            @@@@@+:..........:.................::::::.::.:-+**#*+-:..::::-+%+::-+%@@@@@@            
            @@@@@@@#=:: ............:::::..: ::...---+*###=-        ...   .:#%@@@@#-%@@@            
            @@@* *@@@@@@+::.........::.::::.:-+*#%%*-        ..:+%@@@@@@*@@@@@@%-   %@@@            
            @@@#    :*@@@@@@@%+=-:.:-+%@@#*+=:             .%@@@@@@@@@@@@@@*=       %@@@            
            @@@#       .:-*%@@@@@@@@@@@%%%%%%%%@%%@@@@@@@@@@@@@@@@@#*+-:..          %@@@            
            @@@%.            .::-==+**###%%@@@@%####%@@@%==--::.                  .=@@@@            
            @@@@@+-------------------------@@@@%=---%@@@#------------------------+@@@@@@            
            @@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%@@@            
            @@@* #@@=-#-@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*:*:@@@@@@@@@@@@@@@@@@@@@@@+ %@@@            
           =@@@* +@@%++@@@@@@@@@@@@@@@@@@@@@@@@@*=-#@@@%%-@@@@@@@@@@@@@@@@@@@@@@@@= %@@@=           
        .*@@@@@* :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=+++@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  *@@@@@+         
       +@@@@*-.   *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-    -*@@@@=       
      #@@@#.       *@@@@@@@@@@@@@@@@@@@@@@@@@@@#++++#@@@@@@@@@@@@@@@@@@@@@@@@@@@=       :%@@@+      
     *@@@+          =@@@@@@@@@@@@@@@@@@@@@%=-@@@@=+@@@@=:*@@@@@@@@@@@@@@@@@@@@@:          #@@@=     
    .@@@#             +@@@@@@@@@@@@@@@@@%::---:*@@@@+:----:*@@@@@@@@@@@@@@@@@-             %@@@     
    =@@@=              .:*@@@@@@@@@@@@@@#*----------------+#@@@@@@@@@@@@@%+:.              =@@@=    
    *@@@:                  :-==+**++@@@#-*%-----+%%=:---:#*=*@%@#+**+==-:                  :@@@+    
    =@@@=                  .......-@=.%@@%==++#@@@@@%*++==%@@%.:%+........                 =@@@=    
    .@@@%.                  ......@-..%*#%%@@@#=----*@@@@%%*=@:..@-.....                   %@@@     
     =@@@%                    .. +#  #*.....#@@@@@@@@@@#.....-@..=@ ..                    %@@@=     
      =@@@@+                     == :@........::::::::....... %+.-#                     +@@@@=      
       :%@@@@*=.                    =@ ...................... +#                    .-*@@@@%:       
         -#@@@@*                    .:     ..............     ..                    @@@@@#=         
           .@@@*                                                                    @@@@            
            @@@*                                                                    @@@@            
            @@@*                                                                    @@@@            
           -@@@*                                                                    @@@@-           
        .*@@@@@*                                                                    %@@@@%+         
       .@@@@#=-:                                                                     :=#@@@%.       
       %@@@-                                .-*%@@@@%+:.                                -@@@%       
      .@@@*                               :@@@@@@@@@@@@@%.                               +@@@-      
       @@@%                              #@@@@*:....-*@@@@*                              +@@@-      
       *@@@+                           .%@@@+.        .+@@@#                            -@@@%       
        #@@@%+=========================#@@@=            +@@@*=========================+%@@@%:       
         =%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%+         
           .+%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=              +%%%%%%%%%%%%%%%%%%%%%%%%%%%%#=.           
EOF
echo -e "\e[0m"
echo "==============================================="
echo " Automated RBF Downloader for Senhor FPGA"
echo "==============================================="
echo 

###############################################
# Configuration
###############################################
REPO_OWNER="turri21"
REPO_NAME="Distribution_Senhor"
BASE_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main"

declare -A FOLDERS=(
    ["_Arcade"]="/media/fat/_Arcade"
    ["_Arcade/_ST-V"]="/media/fat/_Arcade/_ST-V"
    ["_Arcade/_ST-V/_JP Bios"]="/media/fat/_Arcade/_ST-V/_JP Bios"
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
    local msg="$(date "+%Y-%m-%d %H:%M:%S") - $1"
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

prompt_delete_mode() {
    echo -e "\e[1;33mDo you want to delete older versions of files? (y/N)\e[0m"
    read -rp "Enable deletion of old versions? [y/N]: " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        DELETE_OLD_FILES=true
        log "Old version deletion enabled."
    else
        log "Old version deletion disabled."
    fi
}

fetch_file_list() {
    local folder="$1"
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
        [[ "$line" =~ \.(rbf|mgl|mra)$ ]] && FILES+=("$line")
    done < "$list_file"

    local count=${#FILES[@]}
    if [ "$count" -eq 0 ]; then
        log "WARNING: No valid files found in $folder list"
        return 1
    fi

    log "Found $count supported files in $folder"
    return 0
}

delete_old_versions() {
    local folder="$1"
    local new_file="$2"
    local download_dir="${FOLDERS[$folder]}"
    local full_path_new="$download_dir/$new_file"

    # Extract base (everything up to the 2nd underscore) and version (after 2nd underscore)
    local base_prefix=$(echo "$new_file" | cut -d'_' -f1-2)
    local new_version=$(echo "$new_file" | cut -d'_' -f3 | cut -d'.' -f1)
    local ext="${new_file##*.}"

    for existing in "$download_dir"/"$base_prefix"_*."$ext"; do
        [[ ! -f "$existing" || "$existing" == "$full_path_new" ]] && continue

        local existing_file=$(basename "$existing")
        local existing_version=$(echo "$existing_file" | cut -d'_' -f3 | cut -d'.' -f1)

        if [[ "$existing_version" < "$new_version" ]]; then
            log "\e[31mDeleting older version: \e[0m\e[1;33m$existing_file\e[0m"
            rm -f "$existing"
        fi
    done
}

download_arcadealt() {
    ZIP_URL="https://github.com/turri21/Distribution_Senhor/raw/main/_Arcade/_alternatives.zip"
    DEST_DIR="/media/fat/_Arcade"
    TEMP_ZIP="/tmp/_alternatives.zip"

    # Optional: a marker file to indicate extraction already happened
    MARKER_FILE="$DEST_DIR/.alternatives_installed"

    if [ -f "$MARKER_FILE" ]; then
        echo "Arcade alternatives already downloaded and extracted. Skipping."
        return
    fi

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

    # Create marker file to avoid re-downloading/extracting
    touch "$MARKER_FILE"

    echo "Done."
}

download_file() {
    local folder="$1"
    local file="$2"
    local download_dir="${FOLDERS[$folder]}"
    local max_retries=3
    local retry_delay=2

    if [ -s "$download_dir/$file" ]; then
        log "Skipping existing file: $folder/$file"
        return 0
    fi

    for ((i=1; i<=max_retries; i++)); do
        log "Download attempt $i for $folder/$file..."
        if wget -q --tries=3 --timeout=15 "$BASE_URL/$folder/$file" -O "$TEMP_DIR/$file"; then
            if [ -s "$TEMP_DIR/$file" ]; then
                if $DELETE_OLD_FILES; then
                    delete_old_versions "$folder" "$file"
                fi
                mv "$TEMP_DIR/$file" "$download_dir/"
                log "Successfully downloaded: \e[1;32m$folder/$file\e[0m"
                return 0
            else
                log "Attempt $i: Downloaded empty file"
                rm -f "$TEMP_DIR/$file"
            fi
        fi
        sleep $retry_delay
    done

    log "ERROR: Failed to download after $max_retries attempts: \e[1;31m$folder/$file\e[0m"
    return 1
}

###############################################
# Main Process
###############################################

main() {
    check_internet

    prompt_delete_mode
    download_arcadealt

    log "=== Starting Senhor Multi-Folder File Update (RBF/MGL/MRA) ==="

    local total_success=0
    local total_files=0

    for folder in "${!FOLDERS[@]}"; do
        log "Processing folder: \e[1;35m$folder\e[0m"

        if fetch_file_list "$folder"; then
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

    rm -rf "$TEMP_DIR"
    echo -e "\e[1;35m=================================================================\e[0m"
    log "Update complete: \e[1;32m$total_success\e[0m of \e[1;33m$total_files\e[0m files processed"
    echo -e "\e[1;35m=================================================================\e[0m"
    read -p "Press enter to continue..."
}

main
exit 0

