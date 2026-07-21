#!/bin/bash
set -e

echo ">>> Loading configuration..."
GENOME_ID=$(python3 -c 'import json; print(json.load(open("reference-genomes.json"))["genome_id"])')
SEARCH_TERM=$(python3 -c 'import json; print(json.load(open("reference-genomes.json"))["repeat_search_term"])')

echo ">>> Cleaning up any residual RepeatMasker artifacts..."
rm -f data/$GENOME_ID/*.prep \
      data/$GENOME_ID/*.tmp \
      data/$GENOME_ID/*.cat \
      data/$GENOME_ID/*.masked \
      data/$GENOME_ID/*.out \
      data/$GENOME_ID/*.tbl

OUT_DIR="analysis/$GENOME_ID/earlgray_out"
GENOME_FILE="data/$GENOME_ID/${GENOME_ID}_genomic.fna"

mkdir -p "$OUT_DIR"

echo ">>> Executing EarlGrey..."
# earlGrey is now a global command managed by Conda
earlGrey -g "$(pwd)/$GENOME_FILE" \
     -s "$GENOME_ID" \
     -r "$SEARCH_TERM" \
     -o "$(pwd)/$OUT_DIR" \
     -t 7

echo ">>> Pipeline completed successfully."