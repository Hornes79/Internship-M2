#!/bin/bash

# ==============================================================================
# SCRIPT NAME: 05_filter_quality_mags.sh
# DESCRIPTION: Filters CheckM2 outputs for HQ/MQ MAGs and extracts Giant Viruses 
#              (NCLDV) from GVClass, then aggregates target FASTA files.
# AUTHOR     : Hornes
# DATE       : 2026
# ==============================================================================

# --- CONFIGURATION (USER INPUTS) ---
CHECKM2_REPORT="quality_report.tsv"
GVCLASS_DIR="gvclass_results"
SRC_FASTA_DIR="/path/to/dereplicated_genomes"

# Outputs
OUTPUT_DIR="/path/to/data_mag_hmq_dissemin"
HQ_MQ_LIST="name_mag_hq_mq.tsv"
GV_LIST="name_gv.tsv"
# -----------------------------------

echo "Starting MAG quality filtering and virus"
mkdir -p "$OUTPUT_DIR"

# ------------------------------------------------------------------------------
# STEP 1: Filter HQ and MQ MAGs from CheckM2 (Completeness >= 50, Contamination <= 10)
# ------------------------------------------------------------------------------
echo "Parsing CheckM2 report for High and Medium Quality MAGs"
if [ -f "$CHECKM2_REPORT" ]; then
    # CheckM2 header format: Name(1) Completeness(2) Contamination(3)
    # Generates a 2-column clean layout [Name \t Quality]
    awk -F'\t' 'NR>1 {
        if ($2 >= 50 && $3 <= 10) {
            qual = ($2 >= 90 && $3 <= 5) ? "HQ" : "MQ";
            print $1 "\t" qual
        }
    }' "$CHECKM2_REPORT" > "$HQ_MQ_LIST"
    echo "  ->  $(wc -l < "$HQ_MQ_LIST") HQ/MQ bacterial candidates."
else
    echo "  CheckM2 report '$CHECKM2_REPORT' not found"
fi

# ------------------------------------------------------------------------------
# STEP 2: Extract Giant Viruses (NCLDV) from GVClass
# ------------------------------------------------------------------------------
echo "Screening GVClass outputs for NCLDV targets"
rm -f "$GV_LIST"

if [ -d "$GVCLASS_DIR" ]; then
    # Parse all .tab outputs from GVClass, target d_NCLDV taxonomy, and select high score lines
    cat "$GVCLASS_DIR"/*.tab 2>/dev/null \
    | grep -v "^query" \
    | awk -F'\t' '$2 ~ /^d_NCLDV/ {print $1}' \
    | cut -d ':' -f2 | sort -u > "$GV_LIST"
    echo " Isolated $(wc -l < "$GV_LIST") NCLDV giant virus genomes."
else
    echo "GVClass directory '$GVCLASS_DIR' not found"
fi

# ------------------------------------------------------------------------------
# STEP 3: Transfer selected FASTA files to destination folder
# ------------------------------------------------------------------------------
echo "Transferring filtered genomes to central repository"

# Function to safely copy files
copy_mags() {
    local list_file=$1
    while read -r line || [[ -n "$line" ]]; do
        [ -z "$line" ] && continue
        genome_name=$(echo "$line" | cut -f1)
        src_file="$SRC_FASTA_DIR/${genome_name}.fa"

        if [ -f "$src_file" ]; then
            cp "$src_file" "$OUTPUT_DIR/"
            echo " ${genome_name}.fa"
        else
            echo "${src_file}"
        fi
    done < "$list_file"
}

[ -f "$HQ_MQ_LIST" ] && copy_mags "$HQ_MQ_LIST"
[ -f "$GV_LIST" ] && copy_mags "$GV_LIST"

echo "[SUCCESS] Quality filtering complete. Final dataset stored in: $OUTPUT_DIR"
