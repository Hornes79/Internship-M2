#!/bin/bash

# ==============================================================================
# SCRIPT NAME: 06_extract_resistance_virulence.sh
# DESCRIPTION: Automated screening of Bakta functional annotations to extract 
#              specific Antibiotic Resistance Genes (ARGs) and Virulence Factors.
## Author:       Hornes
## Date:         June 2026
# ==============================================================================

# --- CONFIGURATION (USER INPUTS) ---
BAKTA_OUT_DIR="/path/to/bakta_old_hmq"
OUTPUT_ARG_TSV="clean_antibio_mags.tsv"
OUTPUT_VF_TXT="mag_valide_vfdb.txt"
# -----------------------------------

echo "Commencing screening for ARGs and Virulence Factors"

# Reset output files
echo -e "MAG_Name\tGene_Symbol\tFunctional_Annotation" > "$OUTPUT_ARG_TSV"
rm -f "$OUTPUT_VF_TXT"

if [ ! -d "$BAKTA_OUT_DIR" ]; then
    echo "[ERROR] Bakta output directory $BAKTA_OUT_DIR does not exist."
    exit 1
fi

cd "$BAKTA_OUT_DIR" || exit 1

# ------------------------------------------------------------------------------
# STEP 1: Screen and clean ARGs (NCBIFam matches targeted at Antibiotics)
# ------------------------------------------------------------------------------
echo "Extracting specific Antibiotic Resistance Genes"

for dir in */ ; do
    mag_name=$(basename "$dir")
    tsv_file="${dir}${mag_name}.tsv"

    if [ -f "$tsv_file" ]; then
        # Awk rule: Filter NCBIFam hits, discard metals/biocides (ars, mer, cop, bcr...)
        # Keep specific beta-lactams, aminoglycosides, phenicols, efflux pumps (bla, aac, aph, cat, emr, mex...)
        awk -F'\t' -v mag="$mag_name" '
        $0 ~ /NCBIFam/ {
            gene = $7
            # Exclusion profile (Metals & broad-range stress resistance)
            if (gene ~ /^(ars|bcr|clp|cop|mer|gac|sme|smr|asr)/) next;

            # Inclusion profile (Confirmed true antibiotic resistance elements)
            if (gene ~ /^(bla|aac|aph|cat|cml|arr|fos|van|mex|emr|nor|tet|erm|cfr|dfr|sul|qnr)/) {
                annotation = $8
                for(i=9; i<=NF; i++) annotation = annotation " " $i
                sub(/ NCBI.*/, "", annotation) # Remove database technical trailing texts
                print mag "\t" gene "\t" annotation
            }
        }' "$tsv_file" >> "../$OUTPUT_ARG_TSV"
    fi
done

cd - > /dev/null || exit

# ------------------------------------------------------------------------------
# STEP 2: Screen Virulence Factors (VFDB tracking in inference data)
# ------------------------------------------------------------------------------
echo "Screening for validated Virulence Factors (VFDB)"

for dir in "$BAKTA_OUT_DIR"/*/ ; do
    mag_name=$(basename "$dir")

    # Check the precise inference file of Bakta for structural annotation proof
    if grep -qi "VFDB" "$dir"/*inference.tsv 2>/dev/null; then
        echo "$mag_name" >> "$OUTPUT_VF_TXT"
    fi
done

echo "[SUCCESS] Curation complete."
echo "True ARGs table saved in: $OUTPUT_ARG_TSV"
echo " MAGs with confirmed Virulence Factors saved in: $OUTPUT_VF_TXT"


