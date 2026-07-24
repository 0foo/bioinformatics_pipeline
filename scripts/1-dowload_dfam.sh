#!/usr/bin/env bash

set -e
CACHE_DIR="/workspace/src_cache"
mkdir -p "$CACHE_DIR"

H5_CACHE_DIR="$CACHE_DIR/FamDB_Data"
H5_EXTRACT_DIR="$CACHE_DIR/FamDB_Data_extracted"
mkdir -p "$H5_CACHE_DIR" "$H5_EXTRACT_DIR"

echo "Populating flat source cache in $CACHE_DIR..."

# --- 1. Download/Verify Core and Taxonomy Files ---
download_and_verify() {
    local filename=$1
    local url="https://www.dfam.org/releases/Dfam_4.0/families/FamDB/${filename}.gz"
    local dest_gz="$H5_CACHE_DIR/${filename}.gz"
    local dest_ext="$H5_EXTRACT_DIR/${filename}"

    if [ -f "$dest_ext" ]; then
        echo "Verified: $filename exists."
    else
        echo "Downloading $filename..."
        curl -Lfv "$url" -o "$dest_gz"
        echo "Decompressing $filename..."
        gunzip -c "$dest_gz" > "$dest_ext"
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