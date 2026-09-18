#!/bin/bash

echo "Installing Maldita Castilla for Senhor!"

# --- Configuration ---
RAW_BASE="https://raw.githubusercontent.com/turri21/Senhor/main/ARM/MalditaCastilla"
WORK_DIR="/tmp/maldita_install"
ZIP_NAME="MalditaCastilla_script"

# --- Cleanup on exit (success or failure) ---
cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# --- Prepare working directory ---
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR" || { echo "Failed to create working directory"; exit 1; }

# --- Download split archive parts ---
echo "Downloading split archive..."
echo "Downloading part 1"
wget -q "$RAW_BASE/${ZIP_NAME}.z01" -O "${ZIP_NAME}.z01" || { echo "Download of .z01 failed"; exit 1; }
echo "Downloading part 2"
wget -q "$RAW_BASE/${ZIP_NAME}.z02" -O "${ZIP_NAME}.z02" || { echo "Download of .z02 failed"; exit 1; }
echo "Downloading part 3"
wget -q "$RAW_BASE/${ZIP_NAME}.zip" -O "${ZIP_NAME}.zip" || { echo "Download of .zip failed"; exit 1; }

# --- Merge and extract with 7zz ---
echo "Extracting split archive to /media/fat/..."
7zz x "${ZIP_NAME}.zip" -o/media/fat/ -y || { echo "7zz extraction failed"; exit 1; }

# --- Show what was extracted ---
echo "Extracted contents:"
ls -la /media/fat/ | grep -i maldita

# --- Fix permissions ---
echo "Fixing permissions..."
chmod 775 /media/fat/Scripts/Maldita* 2>/dev/null
chmod 775 /media/fat/games/gmloader/gmloader 2>/dev/null
chmod 775 -R "/media/fat/games/Maldita Castilla/" 2>/dev/null

# --- Flush writes to disk ---
echo "Syncing filesystem..."
sync

echo "Installation complete!"
# Cleanup of /tmp/maldita_install runs automatically via the EXIT trap