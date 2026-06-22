#!/bin/bash

# ==============================================================================
# SCRIPT NAME: 04_genome_def.sh
# DESCRIPTION: Parses a directory of MAGs to generate a 2-column mapping file
#              (Genome \t Contig) required by CoverM for network profiling.
## Author:     Hornes
## Date:       June 2026
# ==============================================================================

# --- CONFIGURATION (USER INPUTS) ---
MAG_DIR="data_all_mag"     # Folder containing all non-redundant MAG files (.fa)
OUTPUT="genome_def_all.tsv" # Name of the mapping file to generate
# -----------------------------------

echo " Initializing genome definition file generation..."

# Create or overwrite output file and write CoverM headers
echo -e "genome\tcontig" > "$OUTPUT"

# ------------------------------------------------------------------------------
#  Parse MAGs and extract contig headers
# ------------------------------------------------------------------------------
for fasta in "$MAG_DIR"/*.fa; do
    
    # Ensure files exist before processing
    if [ -f "$fasta" ]; then
        genome=$(basename "$fasta" .fa)
        echo " Extracting contig IDs from genome: $genome"
        
        # Grep fasta headers, remove the '>' symbol, and stream into the TSV file
        grep "^>" "$fasta" | sed 's/>//' | while read -r contig; do
            echo -e "${genome}\t${contig}" >> "$OUTPUT"
        done
    else
        echo "No .fa MAG files detected in: $MAG_DIR"
        rm -f "$OUTPUT" # Clean up empty file
        exit 1
    fi
done

echo " CoverM mapping file generated successfully: $OUTPUT"









