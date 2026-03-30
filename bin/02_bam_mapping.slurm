#!/bin/bash
#SBATCH --job-name=bam_map
#SBATCH --output=logs/bam_%A_%a.out
#SBATCH --error=logs/bam_%A_%a.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --array=1-48

# =====================================
# Script: bam_mapping.slurm
# Description:
# Alignement de reads paired-end FASTQ sur des contigs
# avec Bowtie2, puis génération de fichiers BAM triés et indexés.
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

FASTQ_REMOTE_DIR="/path/to/fastq"
INDEX_REMOTE="/path/to/index/contigs_index*"
RESULT_DIR="/path/to/output"

SAMPLES_TXT="/path/to/samples.txt" # liste contenant le nom des échantillons à traiter

THREADS=${SLURM_CPUS_PER_TASK:-8}

# -------------------------------------
# Création de l'espace de travail
# -------------------------------------
SCRATCH=/scratch/$USER/$SLURM_JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH

mkdir -p fastq index

# -------------------------------------
# Sélection du sample à traiter 
# -------------------------------------
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SAMPLES_TXT})
echo "Traitement du sample : $SAMPLE"

# -------------------------------------
# Copie des FASTQ
# -------------------------------------
mkdir -p fastq/$SAMPLE

scp ${REMOTE_USER}@${REMOTE_HOST}:${FASTQ_REMOTE_DIR}/${SAMPLE}/*.forward.fastq.gz fastq/$SAMPLE/
scp ${REMOTE_USER}@${REMOTE_HOST}:${FASTQ_REMOTE_DIR}/${SAMPLE}/*.reverse.fastq.gz fastq/$SAMPLE/

# -------------------------------------
# Copie index Bowtie2
# -------------------------------------
scp ${REMOTE_USER}@${REMOTE_HOST}:${INDEX_REMOTE} index/
INDEX_LOCAL="index/contigs_index"

# -------------------------------------
# Alignement
# -------------------------------------
FORWARD="fastq/$SAMPLE/${SAMPLE}.forward.fastq.gz"
REVERSE="fastq/$SAMPLE/${SAMPLE}.reverse.fastq.gz"

echo "Alignement avec Bowtie2..."

bowtie2 -x $INDEX_LOCAL -1 $FORWARD -2 $REVERSE -p $THREADS 2> ${SAMPLE}_bowtie2.log \
    | samtools view -bS - \
    | samtools sort -@ $THREADS -o ${SAMPLE}.bam

# Index BAM
samtools index ${SAMPLE}.bam

# -------------------------------------
# Copie résultats
# -------------------------------------
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp ${SAMPLE}.bam ${SAMPLE}.bam.bai ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/

echo "Résultats copiés dans ${RESULT_DIR}"

END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"


