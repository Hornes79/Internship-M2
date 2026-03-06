#!/bin/bash
#SBATCH --job-name=bam_map
#SBATCH --output=logs/bam_%A_%a.out
#SBATCH --error=logs/bam_%A_%a.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --partition=lmge
#SBATCH --time=1-00:00:00
#SBATCH --array=1-48

# Script SLURM pour aligner les reads fastq sur des contigs(obtenues grâce au fasta) avec Bowtie2, générer des BAM triés et indexés, et copier des résultats vers le serveur distant

START_TIME=$(date +%s)

# -----------------------------
# INFO JOB 
# -----------------------------
echo "========== JOB INFO =========="
echo "Job ID: $SLURM_JOB_ID"
echo "Array ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $(hostname)"
echo "Node list: $SLURM_JOB_NODELIST"
echo "Start: $(date)"
echo "=============================="


# -------------------------------------
# Chargement de l'environnement conda
# -------------------------------------
source /home/hogbaguidi/miniforge3/etc/profile.d/conda.sh
conda activate binning


# -------------------------------------
# Variables pour les données
# -------------------------------------
REMOTE_USER="gbaguidi"
REMOTE_HOST="172.20.33.4"
FASTQ_REMOTE_DIR="/data/mnt/Microstore_readonly/dissemin/cleanreads"
INDEX_REMOTE="/data/mnt/Microstore_readonly/stage-m2-hornes/dissemin/exp/binning/CONTIG_FASTA_DIR/contigs_index*"
#RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning/BAM_DIR"


# -----------------------------
# Création du scratch
# -----------------------------
SCRATCH=/storage/scratch/$USER/tmp/$SLURM_JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH
mkdir -p fastq index



# -----------------------------
# Sample courant
# -----------------------------
SAMPLES_TXT="/home/hogbaguidi/samples.txt"
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SAMPLES_TXT})
echo "Traitement du sample : $SAMPLE"



# -----------------------------
# Copier FASTQ
# -----------------------------
mkdir -p fastq/$SAMPLE
scp ${REMOTE_USER}@${REMOTE_HOST}:${FASTQ_REMOTE_DIR}/${SAMPLE}/*.forward_humanFiltered.fastq.gz fastq/$SAMPLE/
scp ${REMOTE_USER}@${REMOTE_HOST}:${FASTQ_REMOTE_DIR}/${SAMPLE}/*.reverse_humanFiltered.fastq.gz fastq/$SAMPLE/


# -----------------------------
# Copier Assemble et Index Bowtie2 dans scratch
# -----------------------------
scp ${REMOTE_USER}@${REMOTE_HOST}:${INDEX_REMOTE} index/
INDEX_LOCAL="index/contigs_index"



# -----------------------------
# Alignement Bowtie2
# -----------------------------
FORWARD="fastq/$SAMPLE/${SAMPLE}.forward_humanFiltered.fastq.gz"
REVERSE="fastq/$SAMPLE/${SAMPLE}.reverse_humanFiltered.fastq.gz"

bowtie2 -x $INDEX_LOCAL -1 $FORWARD -2 $REVERSE -p 8 2> "$SAMPLE"_bowtie2.log \
    | samtools view -bS - \
    | samtools sort -@ 8 -o "$SAMPLE".bam

samtools index "$SAMPLE".bam


# -----------------------------
# Copie résultats vers serveur
# -----------------------------

RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning/BAM_DIR"
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp *bam* ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/

echo "BAM et index copiés vers $RESULT_DIR"




END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"

