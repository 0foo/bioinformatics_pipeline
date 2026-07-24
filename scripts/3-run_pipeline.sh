#!/bin/bash
set -e
export PATH="/opt/conda/envs/bioenv/bin:/opt/conda/bin:/opt/bin:$PATH"
export FAMDB_DATA_DIR="/workspace/dfam_cache/FamDB_Data_extracted"

# Define root and workspace variables
WORKSPACE_DIR="/workspace"
GENOMES_DIR="$WORKSPACE_DIR/genomes"

# Define the array of genome IDs to process
GENOME_IDS=(
    "GCF_000001215.4"
    # Add additional genome IDs here as needed
)

# Define corresponding search terms for each genome ID in the array
SEARCH_TERMS=(
    "7227"
)

for i in "${!GENOME_IDS[@]}"; do
    GENOME_ID="${GENOME_IDS[$i]}"
    SEARCH_TERM="${SEARCH_TERMS[$i]}"
    DATA_DIR="$GENOMES_DIR/$GENOME_ID"
    OUT_DIR="$WORKSPACE_DIR/analysis/$GENOME_ID/earlgray_out"
    GENOME_FILE="$DATA_DIR/${GENOME_ID}_genomic.fna"

    echo "=========================================="
    echo "          PIPELINE CONFIGURATION          "
    echo "=========================================="
    echo "WORKSPACE_DIR : $WORKSPACE_DIR"
    echo "GENOME_ID     : $GENOME_ID"
    echo "SEARCH_TERM   : $SEARCH_TERM"
    echo "DATA_DIR      : $DATA_DIR"
    echo "OUT_DIR       : $OUT_DIR"
    echo "GENOME_FILE   : $GENOME_FILE"
    echo "=========================================="

    echo ">>> Cleaning up any residual RepeatMasker artifacts..."
    rm -f "$DATA_DIR"/*.prep \
          "$DATA_DIR"/*.tmp \
          "$DATA_DIR"/*.cat \
          "$DATA_DIR"/*.masked \
          "$DATA_DIR"/*.out \
          "$DATA_DIR"/*.tbl

    mkdir -p "$OUT_DIR"

    echo ">>> Executing EarlGrey for $GENOME_ID..."
    earlGrey -g "$GENOME_FILE" \
         -s "$GENOME_ID" \
         -r "$SEARCH_TERM" \
         -i "$FAMDB_DATA_DIR" \
         -o "$OUT_DIR" \
         -t 4

    echo ">>> Pipeline completed for $GENOME_ID."
done