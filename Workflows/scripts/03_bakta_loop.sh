#!/bin/bash

# ==============================================================================
# SCRIPT NAME: 03_bakta_loop.sh
# DESCRIPTION: Automates functional annotation across a directory of MAGs (FASTA)
#              using Bakta in metagenome mode.
## Author    : Hornes
## Date      : June 2026
# ==============================================================================

# --- CONFIGURATION (USER INPUTS) ---
BIN_DIR="/path/to/data_mag_hmq"   # Input directory containing your dereplicated MAGs (.fa)
OUT_DIR="/path/to/bakta_hmq"      # Base output directory for Bakta results
BAKTA_DB="/path/to/db-bakta-full" # Absolute path to the full Bakta database
THREADS=16                         # Number of CPU threads per Bakta run
# -----------------------------------

echo "Starting batch Bakta functional annotation..."

# Ensure output root folder exists
mkdir -p "$OUT_DIR"

# ------------------------------------------------------------------------------
# Loop through each MAG file
# ------------------------------------------------------------------------------
for bin in "$BIN_DIR"/*.fa; do
    
    # Check if any .fa files exist to prevent running on an empty glob
    if [ -f "$bin" ]; then
        name=$(basename "$bin" .fa)
        echo "Launching Bakta for genome: $name"
        
        # Run Bakta with --meta flag for Metagenome Assembled Genomes
        bakta --db "$BAKTA_DB" \
            --threads "$THREADS" \
            --meta \
            --output "$OUT_DIR/$name" \
            --prefix "$name" \
            "$bin"
            
        echo "  -> Completed annotation for $name"
    else
        echo " No .fa files found in directory: $BIN_DIR"
        exit 1
    fi
done

echo " All MAGs have been annotated successfully."



