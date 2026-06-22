#!/bin/bash

# ==============================================================================
# SCRIPT NAME: 01_concat_fasta.sh
# DESCRIPTION: Reformats individual sample FASTA headers to include the sample 
#              name (preventing ID conflicts) and merges them into a single 
#              co-assembly file.
## Author:     Hornes
## Date:       June 2026
# ==============================================================================

# --- CONFIGURATION (USER INPUTS) ---
SAMPLES=("sample1" "sample2" "sample3") # sample names 
INPUT_DIR="fasta"                        # Parent directory containing sample folders
ASSEMBLE="assemble.fasta"                # Output combined co-assembly file
# -----------------------------------

echo "Starting FASTA reformatting and concatenation..."


# ------------------------------------------------------------------------------
# Loop through samples and reformat headers
# ------------------------------------------------------------------------------
for SAMPLE in "${SAMPLES[@]}"; do
    echo "[STEP] Processing sample: $SAMPLE"
    
    # Target all compressed fasta files within the sample directory
    for FILE in "$INPUT_DIR/$SAMPLE"/*.fasta.gz; do
        
        # Check if files actually exist to avoid loop errors
        if [ -f "$FILE" ]; then
            echo "  -> Processing file: $(basename "$FILE")"
            
            # Decompress on the fly and use awk to append 'sample_name:' right after the '>' character
            gunzip -c "$FILE" \
            | awk -v sample="$SAMPLE" '/^>/{contig=substr($1,2); print ">"sample":"contig; next} {print}' \
            >> "$ASSEMBLE"
        fi
    done
done

echo "Combined co-assembly file created: $ASSEMBLE"



