#!/bin/bash
export PATH="/workspace/bin:$PATH"
set -e

WORKSPACE_DIR="/workspace"
GENOMES_DIR="$WORKSPACE_DIR/genomes"
mkdir -p "$GENOMES_DIR"

# Define your list of target genomes directly in this array
GENOME_IDS=(
    "GCF_000001215.4"
)

echo "=========================================="
echo "    GENOME DOWNLOAD & CATALOG SCRIPT      "
echo "=========================================="

# 1. Fetch available genomes
CATALOG_DIR="$GENOMES_DIR/catalog"
mkdir -p "$CATALOG_DIR"
CATALOG_FILE="$CATALOG_DIR/drosophila_melanogaster_available_genomes.tsv"


CATALOG_FILE="$CATALOG_DIR/drosophila_melanogaster_available_genomes.json"

echo ">>> Fetching available NCBI genome assembly summary for Drosophila melanogaster..."
datasets summary genome taxon "Drosophila melanogaster" --format json > "$CATALOG_FILE"


echo ">>> Catalog saved to: $CATALOG_FILE"
echo "=========================================="

# 2. Process each target genome defined in the array
for i in "${!GENOME_IDS[@]}"; do
    GENOME_ID="${GENOME_IDS[$i]}"
    TARGET_DIR="$GENOMES_DIR/$GENOME_ID"
    GENOME_FILE="$TARGET_DIR/${GENOME_ID}_genomic.fna"
    ZIP_NAME="$GENOMES_DIR/${GENOME_ID}.zip"

    echo ""
    echo "------------------------------------------"
    echo "Processing [ $((i+1))/${#GENOME_IDS[@]} ]: $GENOME_ID"
    echo "------------------------------------------"

    if [ -f "$GENOME_FILE" ]; then
        echo ">>> Target genome file already exists locally: $GENOME_FILE"
        echo ">>> Skipping download and extraction."
    else
        mkdir -p "$TARGET_DIR"

        if [ -f "$ZIP_NAME" ]; then
            echo ">>> Found existing zip file: $ZIP_NAME. Skipping download."
        else
            echo ">>> Downloading $GENOME_ID via NCBI datasets..."
            datasets download genome accession "$GENOME_ID" --include genome --filename "$ZIP_NAME"
        fi
        
        echo ">>> Extracting genome files..."
        unzip -o "$ZIP_NAME" -d /tmp/ncbi_dataset
        
        # Dynamically find the extracted .fna file regardless of its specific release suffix
        EXTRACTED_FNA=$(find /tmp/ncbi_dataset/ncbi_dataset/data/$GENOME_ID -name "*_genomic.fna" | head -n 1)
        
        if [ -n "$EXTRACTED_FNA" ]; then
            cp "$EXTRACTED_FNA" "$GENOME_FILE"
            echo ">>> Successfully copied to: $GENOME_FILE"
        else
            echo "Error: Could not locate extracted genomic .fna file for $GENOME_ID"
            exit 1
        fi
        
        rm -rf /tmp/ncbi_dataset
    fi
done

echo ""
echo ">>> Script execution completed successfully."