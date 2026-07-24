#!/bin/bash
set -e

# Define root and top-level workspace variables
WORKSPACE_DIR="/workspace"
REPO_DIR="$WORKSPACE_DIR/bioinformatics_pipeline"
REF_GENOMES_FILE="$REPO_DIR/reference-genomes.json"
GENOME_ID=$(jq -r '.genome_id' "$REF_GENOMES_FILE")
SEARCH_TERM=$(jq -r '.repeat_search_term' "$REF_GENOMES_FILE")
DATA_DIR="$WORKSPACE_DIR/data/$GENOME_ID"
OUT_DIR="$WORKSPACE_DIR/analysis/$GENOME_ID/earlgray_out"
GENOME_FILE="$DATA_DIR/${GENOME_ID}_genomic.fna"

# Print all custom variables for inspection before running anything
echo "=========================================="
echo "          PIPELINE CONFIGURATION          "
echo "=========================================="
echo "WORKSPACE_DIR : $WORKSPACE_DIR"
echo "REPO_DIR      : $REPO_DIR"
echo "REF_GENOMES   : $REF_GENOMES_FILE"
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

echo ">>> Executing EarlGrey..."
earlGrey -g "$GENOME_FILE" \
     -s "$GENOME_ID" \
     -r "$SEARCH_TERM" \
     -D "/workspace/dfam_cache/FamDB_Data_extracted" \
     -o "$OUT_DIR" \
     -t 4

echo ">>> Pipeline completed successfully."