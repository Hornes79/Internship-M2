#!/bin/bash
#SBATCH --job-name=semibin
#SBATCH --output=logs/semibin_%j.out
#SBATCH --error=logs/semibin_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=180G
#SBATCH --partition=long
#SBATCH --time=3-00:00:00


# =====================================
# Script: binning_semibin.slurm
# Description:
# Formation de bins à partir de nos échantillons 
# avec l'outil SemiBin2
#
# Auteur: Hornès.G
# =====================================


START_TIME=$(date +%s)

# -----------------------------
# INFO JOB 
# -----------------------------
echo "========== JOB INFO =========="
echo "Job ID: $SLURM_JOB_ID"
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

REMOTE_FASTA="/path/to/fasta"
REMOTE_BAM_DIR="/path/to/bam_dir"
RESULT_DIR="/path/to/output"

THREADS=${SLURM_CPUS_PER_TASK:-16}

# -------------------------------------
# Création de l'espace de travail
# -------------------------------------
SCRATCH=/scratch/$USER/$SLURM_JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH

mkdir -p semibin semibin_dezip

BAM_FILES=("$bam_dir"/*.bam)

# -------------
# SemiBin2 
# -------------
echo "Lancement de SemiBin2"
# Semibin2 lancé en mode multi échantillon,
# la taille mininum de contig considéré est de 2500
# puis ici l'outil gère le calcul des couverture
SemiBin2 multi_easy_bin \
    -i "$fasta" \
    -b "${BAM_FILES[@]}" \
    -o semibin2 \
    -m 2500 \
    -p "$THREADS"

echo "SemiBin2 terminé, décompression des bins"

# -----------------------------------------
# Décompression bins produire par SemiBin
# -----------------------------------------
for bin semibin/bins/*.fa.gz; do
    gunzip -c "$bin" > semibin_dezip/$(basename "$bin" .gz)
done


# -------------------------
# Copie des résultats 
# -------------------------

ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp -r semibin2 semibin_dezip ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/

echo "Résultats copiés dans ${RESULT_DIR}"


END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"


