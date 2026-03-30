#!/bin/bash
#SBATCH --job-name=contig_index
#SBATCH --output=logs/contig_index_%j.out
#SBATCH --error=logs/contig_index_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=90G
#SBATCH --partition=long
#SBATCH --time=2-00:00:00


# =====================================
# Script: contig_index.slurm
# Description:
# Crèation d'un fichier fasta combiné de l'assemble des échantillons,
# puis indexation du fasta avec Bowtie2
#
# Auteur: Hornès.G
# =====================================

START_TIME=$(date +%s)

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

FASTA_REMOTE_DIR="/path/to/fasta"
RESULT_DIR="/path/to/output"

THREADS=${SLURM_CPUS_PER_TASK:-8}

# -------------------------------------
# Création de l'espace de travail
# -------------------------------------
SCRATCH=/scratch/$USER/$SLURM_JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH

mkdir -p fasta

# -----------------------------
# Lister tous les samples
# -----------------------------
SAMPLES=($(ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -d ${FASTA_REMOTE_DIR}/*" | xargs -n 1 basename))
echo "Échantillons détectés : ${SAMPLES[*]}"

# -----------------------------
# Copie des FASTA
# -----------------------------
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Copie FASTA de $SAMPLE"
    mkdir -p fasta/$SAMPLE
    scp ${REMOTE_USER}@${REMOTE_HOST}:${FASTA_REMOTE_DIR}/${SAMPLE}/*.fasta.gz fasta/$SAMPLE/
done

# -----------------------------
# Créer l’assemblage combiné
# -----------------------------
echo "Création de l'assemblage combiné..."

for SAMPLE in "${SAMPLES[@]}"; do
    for FILE in fasta/$SAMPLE/*.fasta.gz; do
        gunzip -c "$FILE" \
        | awk -v sample="$SAMPLE" '/^>/{contig=substr($1,2); print ">"sample":"contig; next} {print}' \
        >> assemble.fasta
    done
done

# -----------------------------
# Index Bowtie2
# -----------------------------
echo "Création de l’index Bowtie2..."

# Indexation
echo "Indexation Bowtie2..."
bowtie2-build --large-index assemble.fasta contigs_index -p $THREADS


# -----------------------------
# Copie résultats
# -----------------------------

RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning/CONTIG_FASTA_DIR"
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp assemble.fasta ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/
scp contigs_index.* ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/

echo "Résultats copiés dans ${RESULT_DIR}"


END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"


