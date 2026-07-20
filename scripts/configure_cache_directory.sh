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

# --- 2. Cache RepeatMasker Tarball ---
if [ ! -f "$CACHE_DIR/RepeatMasker-4.2.4.tar.gz" ]; then
    curl -sSL "https://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.2.4.tar.gz" -o "$CACHE_DIR/RepeatMasker-4.2.4.tar.gz"
fi

# --- 3. Cache Repos ---
[ ! -d "$CACHE_DIR/famdb_repo" ] && git clone https://github.com/Dfam-consortium/FamDB.git "$CACHE_DIR/famdb_repo"
[ ! -d "$CACHE_DIR/EarlGrey" ] && git clone https://github.com/TobyBaril/EarlGrey.git "$CACHE_DIR/EarlGrey"

# --- 4. Cache TRF (Corrected repository organization and size validation) ---
if [ ! -f "$CACHE_DIR/trf" ] || [ $(stat -c%s "$CACHE_DIR/trf" 2>/dev/null || echo 0) -lt 1000 ]; then
    echo "Downloading valid TRF binary..."
    curl -L "https://github.com/Benson-Genomics-Lab/TRF/releases/download/v4.09.1/trf409.linux64" -o "$CACHE_DIR/trf"
    chmod +x "$CACHE_DIR/trf"
fi

# --- 5. Cache RMBlast ---
VERSION="2.17.1+"
TARBALL="rmblast-${VERSION}-x64-linux.tar.gz"
URL="https://www.repeatmasker.org/rmblast/${TARBALL}"

if [ ! -f "$CACHE_DIR/rmblast.tar.gz" ]; then
    echo "Downloading RMBlast ${VERSION}..."
    curl -Lfv "$URL" -o "$CACHE_DIR/rmblast.tar.gz"
fi

if [ ! -d "$CACHE_DIR/rmblast" ]; then
    echo "Extracting RMBlast..."
    mkdir -p "$CACHE_DIR/rmblast"
    tar -xzf "$CACHE_DIR/rmblast.tar.gz" -C "$CACHE_DIR/rmblast" --strip-components=1
fi
echo "Cache configuration complete."