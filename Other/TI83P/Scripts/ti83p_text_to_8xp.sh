#!/bin/bash
# TI-83 Plus core: converts a TI-Basic program written as text (.txt) to .8xp
#
# Run it from the MiSTer menu: Scripts > ti83p_text_to_8xp
# Pick a .txt file of games/TI83P (sub-folders included): the .8xp program is
# created next to it, under the program name. Then, in the core:
# Load TI file > NAME.8xp.
#
# Text format: one statement per line (leading ":" are accepted), symbols as
# real characters or ASCII (-> or the arrow, != or the not-equal sign, sqrt(
# or the root sign, L1, Y1, theta...). A first line "PROGRAM:NAME" gives the
# program name, otherwise the file name is used.

DIR="${TI83P_DIR:-/media/fat/games/TI83P}"
HELPER="$(dirname "$(readlink -f "$0")")/.ti83p/txt2prg.py"

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 was not found on this MiSTer."; exit 1
fi
if [ ! -f "$HELPER" ]; then
    echo "Missing file: $HELPER"; exit 1
fi

mapfile -t FILES < <(cd "$DIR" 2>/dev/null && find . -type f \( -iname '*.txt' \) ! -iname 'readme*' | sed 's|^\./||' | sort)
if [ ${#FILES[@]} -eq 0 ]; then
    echo "No .txt file in $DIR"
    echo "Copy the program text there (for example games/TI83P/MYPROG.txt)."
    exit 1
fi

CHOICE=""
if command -v dialog >/dev/null 2>&1; then
    ITEMS=()
    for i in "${!FILES[@]}"; do ITEMS+=("$((i + 1))" "${FILES[$i]}"); done
    N=$(dialog --clear --stdout --title "TI-83 Plus: text to .8xp" \
               --menu "Program to convert:" 20 70 13 "${ITEMS[@]}")
    clear
    [ -z "$N" ] && exit 0
    CHOICE="${FILES[$((N - 1))]}"
else
    echo "Program to convert:"
    for i in "${!FILES[@]}"; do echo "  $((i + 1)) ) ${FILES[$i]}"; done
    read -r -p "Number (Enter to cancel): " N
    [ -z "$N" ] && exit 0
    if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -lt 1 ] || [ "$N" -gt ${#FILES[@]} ]; then
        echo "Invalid number."; exit 1
    fi
    CHOICE="${FILES[$((N - 1))]}"
fi

echo "Converting $CHOICE ..."
python3 "$HELPER" "$DIR/$CHOICE"
sync
