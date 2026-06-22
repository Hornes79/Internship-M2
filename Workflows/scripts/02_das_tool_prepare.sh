#!/bin/bash

# ==============================================================================
# SCRIPT NAME: 02_das_tool_prep.sh
# DESCRIPTION: Converts binning outputs (MetaBAT2 & SemiBin2) into clean 
#              Contig2Bin TSV formats and cleans them for DAS Tool compatibility.
## Author:     Hornes
## Date:       June 2026
# ==============================================================================

# --- CONFIGURATION (USER INPUTS) ---
SAMPLES=("sample1" "sample2" "sample3")
METABAT_DIR="metabat2"
SEMIBIN_DIR="semibin2"
RAW_METABAT_TSV="metabat.tsv"
RAW_SEMIBIN_TSV="semibin.tsv"
# -----------------------------------

echo "Starting DAS Tool input preparation..."

# ------------------------------------------------------------------------------
# STEP 1: Process MetaBAT2 Outputs
# ------------------------------------------------------------------------------
echo " Converting MetaBAT2 fasta bins to a single TSV..."
if [ -d "$METABAT_DIR" ]; then
    # Native DAS Tool utility to map fasta bins back to contig IDs
    Fasta_to_Contig2Bin.sh -i "$METABAT_DIR" -e fa > "$RAW_METABAT_TSV"
else
    echo " MetaBAT2 directory '$METABAT_DIR' not found!"
    exit 1
fi

# ------------------------------------------------------------------------------
# STEP 2: Process SemiBin2 Multi-Sample Outputs
# ------------------------------------------------------------------------------
echo "Merging SemiBin2 multi-sample outputs into one TSV..."

for SAMPLE in "${SAMPLES[@]}"; do
    FILE="$SEMIBIN_DIR/samples/$SAMPLE/contig_bins.tsv"
    
    # Verify SemiBin2 output exists for this specific sample
    if [ -f "$FILE" ]; then
        echo "  -> Processing SemiBin2 file for: $SAMPLE"
        # Format the header to include the sample prefix (matching our co-assembly format)
        awk -v s="$SAMPLE" 'NR>1 {print s ":" $1 "\t" s "_SemiBin_" $2}' "$FILE" >> "$RAW_SEMIBIN_TSV"
    else
        echo " SemiBin2 file missing for sample: $SAMPLE (Skipping)"
    fi
done

# ------------------------------------------------------------------------------
# STEP 3: Final Matrix Cleaning for DAS Tool
# ------------------------------------------------------------------------------
echo " Isolation of Contig_ID and Bin_ID columns (2-column format)..."

# DAS Tool strictly requires a two-column layout: [Contig_ID \t Bin_ID]
if [ -f "$RAW_METABAT_TSV" ] && [ -f "$RAW_SEMIBIN_TSV" ]; then
    awk '{print $1 "\t" $NF}' "$RAW_METABAT_TSV" > metabat_clean.tsv
    awk '{print $1 "\t" $NF}' "$RAW_SEMIBIN_TSV" > semibin_clean.tsv
    echo "Cleaned files ready: 'metabat_clean.tsv' and 'semibin_clean.tsv'"
else
    echo " Clean step failed. One or both raw TSV files are missing."
    exit 1
fi


