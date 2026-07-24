#!/usr/bin/env bash

set -e
TARGET_DIR="/opt/conda/envs/bioenv/share/famdb-3.0.0/Libraries/famdb"
mkdir -p "$TARGET_DIR"

echo "Populating FamDB libraries in $TARGET_DIR..."

# --- 1. Download/Verify Core and Taxonomy Files ---
download_and_verify() {
    local filename=$1
    local url="https://www.dfam.org/releases/Dfam_4.0/families/FamDB/${filename}.gz"
    local dest_gz="/tmp/${filename}.gz"
    local dest_ext="$TARGET_DIR/${filename}"

    if [ -f "$dest_ext" ]; then
        echo "Verified: $filename already extracted."
    else
        echo "Downloading $filename..."
        curl -sS -L "$url" -o "$dest_gz"
        echo "Decompressing $filename..."
        gunzip -c "$dest_gz" > "$dest_ext"
        rm -f "$dest_gz"
    fi
}

# Core + Curated + Diptera Partition
FILES=(
    "dfam40.0.h5" 
    "dfam40.curated.consensus.0.h5" 
    "dfam40.curated.hmm.0.h5" 
    "dfam40.uncurated.hmm.1.h5"
)

for file in "${FILES[@]}"; do
    download_and_verify "$file"
done

touch "$TARGET_DIR/.earlgrey.config.complete"
echo ">>> FamDB libraries successfully set up in the correct location."