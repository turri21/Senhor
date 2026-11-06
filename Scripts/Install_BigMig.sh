#!/bin/bash
#
# BigMig installer for Senhor
# Finds the newest dated BigMig_Senhor_YYYYMMDD.zip in the GitHub folder,
# downloads it with wget, extracts the CONTENTS of the dated top-level
# archive directory into /media/fat, sets permissions, and updates MiSTer.ini.

set -euo pipefail

FAT="/media/fat"
INI="$FAT/MiSTer.ini"
API_URL="https://api.github.com/repos/turri21/Senhor/contents/ARM/BigMig?ref=main"

say() {
    printf '[BigMig Senhor] %s\n' "$*"
}

die() {
    printf '[BigMig Senhor] ERROR: %s\n' "$*" >&2
    exit 1
}

[ -d "$FAT" ] || die "$FAT does not exist. Is the SD card mounted?"
[ -w "$FAT" ] || die "Cannot write to $FAT. Run this script with sufficient permissions."
[ -f "$INI" ] || die "$INI was not found."

command -v wget >/dev/null 2>&1 || die "wget is not installed."
command -v unzip >/dev/null 2>&1 || die "unzip is not installed."
command -v python3 >/dev/null 2>&1 || die "python3 is required to identify the newest release."

TMP_DIR="$(mktemp -d /tmp/bigmig-senhor.XXXXXX)" || die "Could not create temporary directory."
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

LISTING="$TMP_DIR/github-folder.json"
ZIP_FILE="$TMP_DIR/BigMig_Senhor_latest.zip"
EXTRACT_DIR="$TMP_DIR/extracted"

say "Checking GitHub for the newest Senhor package..."
wget -q --tries=3 --timeout=60 \
    --header="Accept: application/vnd.github+json" \
    --header="User-Agent: BigMig-Senhor-Installer" \
    -O "$LISTING" "$API_URL" || die "Could not retrieve the GitHub folder listing."

[ -s "$LISTING" ] || die "GitHub returned an empty folder listing."

DOWNLOAD_URL="$(python3 - "$LISTING" <<'PY'
import datetime
import json
import re
import sys

try:
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        entries = json.load(f)
except Exception as exc:
    raise SystemExit("Could not parse GitHub folder listing: %s" % exc)

if not isinstance(entries, list):
    raise SystemExit("GitHub did not return a folder listing.")

candidates = []
pattern = re.compile(r"^BigMig_Senhor_(\d{8})\.zip$", re.IGNORECASE)

for entry in entries:
    if not isinstance(entry, dict) or entry.get("type") != "file":
        continue
    match = pattern.fullmatch(entry.get("name", ""))
    if not match:
        continue
    try:
        release_date = datetime.datetime.strptime(match.group(1), "%Y%m%d").date()
    except ValueError:
        continue
    url = entry.get("download_url")
    if isinstance(url, str) and url.startswith("https://raw.githubusercontent.com/"):
        candidates.append((release_date, entry["name"], url))

if not candidates:
    raise SystemExit("No valid BigMig_Senhor_YYYYMMDD.zip package was found in ARM/BigMig.")

candidates.sort(key=lambda item: (item[0], item[1]))
print(candidates[-1][2])
PY
)" || die "Could not identify the latest Senhor ZIP."

ZIP_NAME="${DOWNLOAD_URL##*/}"
say "Latest package: $ZIP_NAME"
say "Downloading package with wget..."
wget -q --show-progress --tries=3 --timeout=60 \
    -O "$ZIP_FILE" "$DOWNLOAD_URL" || die "Package download failed."

[ -s "$ZIP_FILE" ] || die "The downloaded ZIP file is empty."
unzip -tq "$ZIP_FILE" >/dev/null || die "The downloaded package is not a valid ZIP archive."

mkdir -p "$EXTRACT_DIR"
say "Extracting archive to a temporary directory..."
unzip -oq "$ZIP_FILE" -d "$EXTRACT_DIR" || die "Could not extract the package."

# The archive has a dated wrapper directory, e.g.
# BigMig_Senhor_20261104/. Install its contents, not that wrapper directory.
WRAPPER_NAME="${ZIP_NAME%.zip}"
SOURCE_DIR="$EXTRACT_DIR/$WRAPPER_NAME"
[ -d "$SOURCE_DIR" ] || die "Expected archive directory '$WRAPPER_NAME' was not found inside the ZIP."

# Refuse to continue if the expected files are not directly inside the wrapper.
[ -f "$SOURCE_DIR/linux/Emu68.img" ] || die "Expected file not found inside '$WRAPPER_NAME': linux/Emu68.img"
[ -e "$SOURCE_DIR/MiSTer_BigMig" ] || die "Expected item not found inside '$WRAPPER_NAME': MiSTer_BigMig"

say "Installing contents of $WRAPPER_NAME directly into $FAT..."
cp -a "$SOURCE_DIR/." "$FAT/" || die "Could not copy package contents to $FAT."

say "Flushing installed files to the SD card..."
sync

[ -f "$FAT/linux/Emu68.img" ] || die "Expected file not found after installation: $FAT/linux/Emu68.img"
[ -e "$FAT/MiSTer_BigMig" ] || die "Expected item not found after installation: $FAT/MiSTer_BigMig"

say "Setting permissions..."
chmod 755 "$FAT/linux/Emu68.img" || die "Could not chmod linux/Emu68.img."
chmod 755 "$FAT/MiSTer_BigMig" || die "Could not chmod MiSTer_BigMig."

# Only update MiSTer.ini if the exact BigMig configuration is not already present.
# This avoids rewriting the file or creating another [BigMig] entry on repeat installs.
if awk '
    /^[[:space:]]*\[BigMig\][[:space:]]*$/ {
        in_bigmig = 1
        next
    }
    in_bigmig && /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
        in_bigmig = 0
    }
    in_bigmig && /^[[:space:]]*main[[:space:]]*=[[:space:]]*MiSTer_BigMig[[:space:]]*$/ {
        found = 1
    }
    END { exit(found ? 0 : 1) }
' "$INI"; then
    say "MiSTer.ini already contains [BigMig] with main=MiSTer_BigMig; leaving it unchanged."
else
    say "Adding [BigMig] configuration to MiSTer.ini..."
    INI_FILTERED="$TMP_DIR/MiSTer.ini.filtered"
    INI_NEW="$TMP_DIR/MiSTer.ini.new"

    # Remove any old [BigMig] section before appending the desired configuration.
    awk '
        /^[[:space:]]*\[BigMig\][[:space:]]*$/ {
            skip = 1
            next
        }
        skip && /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            skip = 0
        }
        !skip { print }
    ' "$INI" > "$INI_FILTERED"

    cat "$INI_FILTERED" > "$INI_NEW"
    printf '\n[BigMig]\nmain=MiSTer_BigMig\n' >> "$INI_NEW"

    cp -p "$INI" "$INI.bak" || die "Could not back up MiSTer.ini."
    chmod --reference="$INI" "$INI_NEW" 2>/dev/null || true
    mv "$INI_NEW" "$INI" || die "Could not update MiSTer.ini."
fi

say "Installation completed successfully."
say "Installed package: $ZIP_NAME"
say "Installed archive contents directly into $FAT (without the dated wrapper directory)."
say "MiSTer.ini configured with [BigMig] / main=MiSTer_BigMig"
say "Flushing final changes to the SD card..."
sync

say "Previous configuration backed up to $INI.bak"
say "BigMig is installed successfully! You can now run the BigMig core from _Computers using the menu."
