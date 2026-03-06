#!/bin/bash
#SBATCH --job-name=contig_index
#SBATCH --output=contig_index_%j.out
#SBATCH --error=contig_index_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=90G
#SBATCH --partition=long
#SBATCH --time=2-00:00:00


# Script slurm pour récupérer les FASTA , créer un assemblage combiné et générer l'index Bowtie2 qui sera utilisé par la suite


START_TIME=$(date +%s)

# -----------------------------
# INFO JOB 
# -----------------------------
echo "========== JOB INFO =========="
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $(hostname)"
echo "Start: $(date)"
echo "=============================="


# -----------------------------
# Chargement environnement conda
# -----------------------------
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
FASTA_REMOTE_DIR="/data/mnt/Microstore_readonly/dissemin/assembly"
RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning/CONTIG_FASTA_DIR"
mkdir -p $RESULT_DIR

SCRATCH=/storage/scratch/$USER/tmp/$SLURM_JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH

log "Scratch créé : $SCRATCH"



# -----------------------------
# Lister tous les samples
# -----------------------------
SAMPLES=($(ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -d ${FASTA_REMOTE_DIR}/*" | xargs -n 1 basename))
log "Échantillons détectés : ${SAMPLES[*]}"



# -----------------------------
# Copier tous les FASTA
# -----------------------------
mkdir -p fasta
for SAMPLE in "${SAMPLES[@]}"; do
    log "Copie FASTA de $SAMPLE"
    mkdir -p fasta/$SAMPLE
    scp ${REMOTE_USER}@${REMOTE_HOST}:${FASTA_REMOTE_DIR}/${SAMPLE}/*.fasta.gz fasta/$SAMPLE/
done



# -----------------------------
# Créer l’assemblage combiné
# -----------------------------
log "Création de l'assemblage combiné..."
#ASSEMBLE="$RESULT_DIR/assemble.fasta"
rm -f $ASSEMBLE

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
log "Création de l’index Bowtie2..."

# Indexation
log "Indexation Bowtie2..."
bowtie2-build --large-index assemble.fasta contigs_index -p 8

log "Job terminé !"




# -----------------------------
# Copie vers serveur
# -----------------------------

RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning/CONTIG_FASTA_DIR"
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp assemble.fasta ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/
scp *contigs_index.* ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/


log "Copie terminée"



# -----------------------
# Fin du job 
# -----------------------

END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"





