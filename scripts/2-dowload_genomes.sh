#!/bin/bash
set -e

WORKSPACE_DIR="/workspace"
DATA_DIR="$WORKSPACE_DIR/data"
mkdir -p "$DATA_DIR"

# Define your list of target genomes directly in this array
GENOME_IDS=(
    "GCF_000001215.4"
    # Add more accessions here as needed, e.g.:
    # "GCF_000005165.2"
)

echo "=========================================="
echo "    GENOME DOWNLOAD & CATALOG SCRIPT      "
echo "=========================================="

# 1. Download a complete list of available genomes for Drosophila melanogaster
CATALOG_DIR="$WORKSPACE_DIR/catalog"
mkdir -p "$CATALOG_DIR"
CATALOG_FILE="$CATALOG_DIR/drosophila_melanogaster_available_genomes.tsv"

echo ">>> Fetching available NCBI genome assembly summary for Drosophila melanogaster..."
datasets summary genome taxon "Drosophila melanogaster" --as-json | jq -r '
  ["Accession", "OrganismName", "ReleaseDate", "AssemblyLevel"],
  (.reports[]? | [
    .accession,
    .organism.organism_name,
    .assembly_info.release_date,
    .assembly_info.assembly_level
  ]) | @tsv
' > "$CATALOG_FILE"

echo ">>> Catalog saved to: $CATALOG_FILE"
echo "=========================================="

# 2. Download each target genome defined in the array above
for i in "${!GENOME_IDS[@]}"; do
    GENOME_ID="${GENOME_IDS[$i]}"
    TARGET_DIR="$DATA_DIR/$GENOME_ID"
    GENOME_FILE="$TARGET_DIR/${GENOME_ID}_genomic.fna"

    echo ""
    echo "------------------------------------------"
    echo "Processing [ $((i+1))/${#GENOME_IDS[@]} ]: $GENOME_ID"
    echo "------------------------------------------"

    if [ -f "$GENOME_FILE" ]; then
        echo ">>> Already exists locally: $GENOME_FILE"
        echo ">>> Skipping download."
    else
        echo ">>> Downloading $GENOME_ID via NCBI datasets..."
        mkdir -p "$TARGET_DIR"
        
        ZIP_NAME="${GENOME_ID}.zip"
        datasets download genome accession "$GENOME_ID" --include genome --filename "$ZIP_NAME"
        
        echo ">>> Extracting genome files..."
        unzip -o "$ZIP_NAME" -d /tmp/ncbi_dataset
        cp "/tmp/ncbi_dataset/ncbi_dataset/data/$GENOME_ID/${GENOME_ID}_genomic.fna" "$GENOME_FILE"
        
        rm -rf "$ZIP_NAME" /tmp/ncbi_dataset
        echo ">>> Successfully downloaded: $GENOME_FILE"
    fi
done

echo ""
echo ">>> Script execution completed successfully."