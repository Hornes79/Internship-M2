#!/bin/bash
#SBATCH --job-name=semibin
#SBATCH --output=logs/semibin_%j.out
#SBATCH --error=logs/semibin_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=180G
#SBATCH --partition=lmge
#SBATCH --time=3-00:00:00


# Script slurm pour récupérer les fichiers nécessaires pour la formation de bins avec l'outil SemiBin2

set -euo pipefail

START_TIME=$(date +%s)

# -----------------------------
# INFO JOB 
# -----------------------------
echo "========== JOB INFO =========="
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $(hostname)"
echo "Start: $(date)"
echo "=============================="


# ------------------------------------
# Chargement de l'environnement conda
# ------------------------------------
source /home/hogbaguidi/miniforge3/etc/profile.d/conda.sh
conda activate binning

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}


# -----------------------------
# Variables
# -----------------------------
REMOTE_USER="gbaguidi"
REMOTE_HOST="172.20.33.4"
RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning"


# -----------------
# Scratch local
# -----------------
SCRATCH="/storage/scratch/$USER/tmp/$SLURM_JOB_ID"
mkdir -p "$SCRATCH"
cd "$SCRATCH"
log "Scratch créé : $SCRATCH"


# ---------------------------------
# Chemins des fichiers à traiter
# ---------------------------------
BAM_DIR="/storage/scratch/hogbaguidi/tmp/BAM_DIR"
FASTA="/storage/scratch/hogbaguidi/tmp/assemble.fasta"

log "BAM détectés dans $BAM_DIR:"
ls -lh "$BAM_DIR"

# Liste des fichiers BAM
BAM_FILES=("$BAM_DIR"/*.bam)
log "Nombre de fichiers BAM : ${#BAM_FILES[@]}"



# -----------------------------
# SemiBin2 (multi-sample)
# -----------------------------
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8

log "Lancement de SemiBin2"
SemiBin2 multi_easy_bin \
    -i "$FASTA" \
    -b "${BAM_FILES[@]}" \
    -o semibin2 \
    -m 2500 \
    -p 8

log "SemiBin2 terminé, décompression des bins"

# -----------------------------------------
# Décompression bins produire par SemiBin
# -----------------------------------------
mkdir -p semibin_dezip

for bin in $(find semibin2/ -type f -name "*.fa.gz"); do
    [ -f "$bin" ] || continue
    gunzip -c "$bin" > semibin_dezip/$(basename "$bin" .gz)
done

SEMIBIN_BINS=$(find semibin_dezip -name "*.fa" 2>/dev/null | wc -l)
log "SemiBin2 : ${SEMIBIN_BINS} bins générés"


# --------------------------------------
# Copie résultats vers serveur distant
# --------------------------------------

RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning"
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp -rCp semibin2 semibin_dezip ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/

log "Transfert terminé. Job terminé avec succès."


# -------------------
# Fin de job
# -------------------
END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"


