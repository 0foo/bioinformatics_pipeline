import json
import os

# Load targeted runtime constraints from local configuration file
with open("reference-genomes.json", "r") as f:
    config_data = json.load(f)

GENOME_ID = config_data["genome_id"]
SPECIES_NAME = config_data["species_name"]
SEARCH_TERM = config_data["repeat_search_term"]

rule all:
    input:
        f"analysis/{GENOME_ID}/earlgray_out/{GENOME_ID}_summary.txt"

rule download_genome:
    output:
        zip = "data/archives/{GENOME_ID}.zip",
        fna = "data/{GENOME_ID}/{GENOME_ID}_genomic.fna",
        gff = "data/{GENOME_ID}/genomic.gff"
    log:
        "logs/download/{GENOME_ID}.log"
    shell:
        """
        mkdir -p data/archives data/{wildcards.GENOME_ID}
        datasets download genome accession {wildcards.GENOME_ID} --include genome,gff3 --filename {output.zip} > {log} 2>&1
        unzip -p {output.zip} "ncbi_dataset/data/{wildcards.GENOME_ID}/*.fna" > {output.fna}
        unzip -p {output.zip} "ncbi_dataset/data/{wildcards.GENOME_ID}/*.gff" > {output.gff}
        """
# Rule to handle setup ONCE
rule setup_environment:
    output: 
        "logs/setup.done"
    shell:
        """
        bash scripts/setup_famdb.sh
        touch logs/setup.done
        """
rule process_earlgray:
    input: 
        fna = "data/{GENOME_ID}/{GENOME_ID}_genomic.fna",
        setup = "logs/setup.done"
    output: 
        "analysis/{GENOME_ID}/earlgray_out/{GENOME_ID}_summary.txt"
    log: 
        out = "logs/earlgray/{GENOME_ID}.out",
        err = "logs/earlgray/{GENOME_ID}.err"
    shell:
        """
        # Set paths
        OUT_DIR="analysis/{wildcards.GENOME_ID}/earlgray_out"
        GENOME_FILE="data/{wildcards.GENOME_ID}/{wildcards.GENOME_ID}_genomic.fna"
        
        # Create output directory
        mkdir -p "$OUT_DIR"
        
        # Clean up residual artifacts from previous manual or failed runs
        rm -f "data/{wildcards.GENOME_ID}/"*.prep \
              "data/{wildcards.GENOME_ID}/"*.tmp \
              "data/{wildcards.GENOME_ID}/"*.cat \
              "data/{wildcards.GENOME_ID}/"*.masked \
              "data/{wildcards.GENOME_ID}/"*.out \
              "data/{wildcards.GENOME_ID}/"*.tbl
        
        # Export environment variables so child processes inherit them correctly
        export PATH="/workspace/drivers/EarlGrey:/workspace/drivers/RepeatMasker:/workspace/drivers/RepeatMasker/Libraries/FamDB:/workspace/drivers/bin:/workspace/drivers/rmblast/bin:$PATH"
        export PERL5LIB="/workspace/drivers/RepeatMasker"
        export FAMDB_DIR="/workspace/drivers/RepeatMasker/Libraries/FamDB"
        export FAMDB_DATA_DIR="/workspace/drivers/FamDB_Data"
        export SCRIPT_DIR="/workspace/drivers/EarlGrey/scripts"
        
        # Execute earlGrey
        /workspace/drivers/EarlGrey/earlGrey -g "$(pwd)/$GENOME_FILE" \
             -s "{wildcards.GENOME_ID}" \
             -r "{SEARCH_TERM}" \
             -o "$(pwd)/$OUT_DIR" \
             -t 7 > {log.out} 2> {log.err}
        
        # Verify success and create output signal
        if [ -f "$OUT_DIR/{wildcards.GENOME_ID}_summary.txt" ]; then
            echo "Pipeline run completed successfully" > {output}
        else
            echo "Error: Summary file not created." >&2
            exit 1
        fi
        """
onsuccess:
    # If the pipeline finishes successfully, clean up the flag
    shell("rm -f logs/setup.done")

onerror:
    # If the pipeline fails, clean up the flag so the next run tries setup again
    shell("rm -f logs/setup.done")