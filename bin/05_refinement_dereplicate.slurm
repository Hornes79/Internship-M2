#!/bin/bash
#SBATCH --job-name=rafinement_dereplicate
#SBATCH --output=logs/raf_derep_%j.out
#SBATCH --error=logs/raf_derep_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --partition=long
#SBATCH --time=72:00:00


# =====================================
# Script: refinemnt_dereplicate.slurm
# Description:
# Intègre les bins formés par MetaBAT2 et SemiBin2,
# faire le rafinnement de ces bins avec DAS_Tool,
# suivie de la déréplication des bins avec dRep
#
# Auteur: Hornès.G
# =====================================

START_TIME=$(date +%s)

echo "========== JOB INFO =========="
echo "Job ID: $SLURM_JOB_ID"
echo "Array ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $(hostname)"
echo "Start: $(date)"
echo "=============================="

# -------------------------------------
# Chargement environnement
# -------------------------------------
source ~/.bashrc
conda activate binning

# -------------------------------------
# Paramètres des variables
# -------------------------------------
REMOTE_USER="user"
REMOTE_HOST="remote.server"

METABAT="/path/to/metabat_bin"
SEMIBIN="/path/to/semibin_bin"
FASTA="/path/to/fasta"

RESULT_DIR="/path/to/output"

THREADS=${SLURM_CPUS_PER_TASK:-8}

# -------------------------------------
# Création de l'espace de travail
# -------------------------------------
SCRATCH=/scratch/$USER/$SLURM_JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH

# -------------------
# Copie des bins
# -------------------
scp -r ${REMOTE_USER}@${REMOTE_HOST}:${METABAT} .
scp -r ${REMOTE_USER}@${REMOTE_HOST}:${SEMIBIN} .
scp ${REMOTE_USER}@${REMOTE_HOST}:${FASTA} .

SAMPLES=( $(find semibin2/samples/ -maxdepth 1 -mindepth 1 -type d -exec basename {} \;) )

# -----------------------------
# DAS Tool
# -----------------------------

# Préparation des fichiers tsv nécessaire pour DAS_Tool,
# contenant la liste des bins et les contigs qui les forment
Fasta_to_Contig2Bin.sh -i metabat2 -e fa > metabat.tsv

OUT_TSV="semibin.tsv"
for SAMPLE in "${SAMPLES[@]}"; do
    FILE="semibin2/samples/$SAMPLE/contig_bins.tsv"
    if [ -f "$FILE" ]; then
        awk -v s="$SAMPLE" 'NR>1 {print s ":" $1 "\t" s "_SemiBin_" $2}' "$FILE" >> "$OUT_TSV"
    fi
done

awk '{print $1 "\t" $NF}' metabat.tsv > metabat_clean.tsv
awk '{print $1 "\t" $NF}' semibin.tsv > semibin_clean.tsv



# Lancement de DAS_Tool
# Rafinnement lancé avec tout les options pas défault
DAS_Tool \
    -i semibin_clean.tsv,metabat_clean.tsv \
    -l semibin,metabat \
    -c assemble.fasta \
    -o das_tool \
    -t 8 \
    --write_bins 


conda deactivate    
    
    
# -----------------------------
# dRep
# -----------------------------
conda activate drep
# déréplication à 95% des bins obtenus à l'issue de l'étape précedente
# afin de ne pas avoir des MAGs redondants,
# l'outil CheckM intégré n'est pas utilisé
# autres options par défault
dRep dereplicate \
    drep_output \
    -g das_tool_DASTool_bins/*.fa \
    --ignoreGenomeQuality \
    -p 8


# -----------------------------
# Copie résultats
# -----------------------------
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp -r das_tool drep ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/ 

echo "Résultats copiés dans ${RESULT_DIR}"
 
END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"


