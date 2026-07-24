#!/usr/bin/env bash

set -e
CACHE_DIR="/workspace/dfam_cache"
H5_CACHE_DIR="$CACHE_DIR/FamDB_Data"
H5_EXTRACT_DIR="$CACHE_DIR/FamDB_Data_extracted"
TARGET_DIR="/opt/conda/envs/bioenv/share/famdb-3.0.0/Libraries/famdb"

mkdir -p "$H5_CACHE_DIR" "$H5_EXTRACT_DIR" "$TARGET_DIR"

echo "Populating flat source cache in $H5_EXTRACT_DIR..."

# --- 1. Download/Verify Core and Taxonomy Files ---
download_and_verify() {
    local filename=$1
    local url="https://www.dfam.org/releases/Dfam_4.0/families/FamDB/${filename}.gz"
    local dest_gz="$H5_CACHE_DIR/${filename}.gz"
    local dest_ext="$H5_EXTRACT_DIR/${filename}"

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
    
    # Create symlink from cache extraction directory to the required target location
    if [ ! -e "$TARGET_DIR/$file" ]; then
        ln -s "$H5_EXTRACT_DIR/$file" "$TARGET_DIR/$file"
        echo "Created symlink for $file"
    fi
done

touch "$TARGET_DIR/.earlgrey.config.complete"
echo ">>> Dfam cache populated and symlinked successfully."