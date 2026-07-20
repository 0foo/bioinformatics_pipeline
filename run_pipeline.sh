#!/bin/bash
set -e

# Export full environment path first so binary tools (like 'datasets') can be found
export PATH="/workspace/drivers/EarlGrey:/workspace/drivers/RepeatMasker:/workspace/drivers/RepeatMasker/Libraries/FamDB:/workspace/drivers/bin:/workspace/drivers/rmblast/bin:$PATH"

echo ">>> Loading configuration..."
GENOME_ID=$(python3 -c 'import json; print(json.load(open("reference-genomes.json"))["genome_id"])')
SEARCH_TERM=$(python3 -c 'import json; print(json.load(open("reference-genomes.json"))["repeat_search_term"])')

# echo ">>> Downloading genome $GENOME_ID..."
# mkdir -p data/archives data/$GENOME_ID
# datasets download genome accession $GENOME_ID --include genome,gff3 --filename data/archives/$GENOME_ID.zip
# unzip -o -p data/archives/$GENOME_ID.zip "ncbi_dataset/data/$GENOME_ID/*.fna" > data/$GENOME_ID/${GENOME_ID}_genomic.fna
# unzip -o -p data/archives/$GENOME_ID.zip "ncbi_dataset/data/$GENOME_ID/*.gff" > data/$GENOME_ID/genomic.gff

echo ">>> Setting up environment..."
bash scripts/setup_famdb.sh

echo ">>> Patching hardcoded paths in EarlGrey..."
sed -i 's|/data/toby/EarlGrey|/workspace/drivers/EarlGrey|g' /workspace/drivers/EarlGrey/scripts/headSwap.sh

echo ">>> Cleaning up any residual RepeatMasker artifacts..."
rm -f data/$GENOME_ID/*.prep \
      data/$GENOME_ID/*.tmp \
      data/$GENOME_ID/*.cat \
      data/$GENOME_ID/*.masked \
      data/$GENOME_ID/*.out \
      data/$GENOME_ID/*.tbl

echo ">>> Configuring paths..."
export PERL5LIB="/workspace/drivers/RepeatMasker"
export FAMDB_DIR="/workspace/drivers/RepeatMasker/Libraries/FamDB"
export FAMDB_DATA_DIR="/workspace/drivers/FamDB_Data"
export SCRIPT_DIR="/workspace/drivers/EarlGrey/scripts"

OUT_DIR="analysis/$GENOME_ID/earlgray_out"
GENOME_FILE="data/$GENOME_ID/${GENOME_ID}_genomic.fna"

mkdir -p "$OUT_DIR"

echo ">>> Executing EarlGrey..."
/workspace/drivers/EarlGrey/earlGrey -g "$(pwd)/$GENOME_FILE" \
     -s "$GENOME_ID" \
     -r "$SEARCH_TERM" \
     -o "$(pwd)/$OUT_DIR" \
     -t 7

echo ">>> Pipeline completed successfully."