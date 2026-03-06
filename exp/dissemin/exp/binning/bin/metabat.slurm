#!/bin/bash
#SBATCH --job-name=metabat
#SBATCH --output=logs/metabat_%j.out
#SBATCH --error=logs/metabat_%j.err
#SBATCH --cpus-per-task=6
#SBATCH --mem=450G
#SBATCH --partition=lmge
#SBATCH --time=3-00:00:00


# Script slurm pour récupérer les bam et contigs, calculer la profondeur et générer des bins MetaBAT2


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
# Chargement de l'environnement conda
# -------------------------------------
source /home/hogbaguidi/miniforge3/etc/profile.d/conda.sh
conda activate binning

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}


# -----------------------------
# Variables à traiter et dossier scratch
# -----------------------------
REMOTE_USER="gbaguidi"
REMOTE_HOST="172.20.33.4"
REMOTE_BAM_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning/BAM_DIR"
REMOTE_FASTA="/data/mnt/stage-m2-hornes/dissemin/exp/binning/CONTIG_FASTA_DIR/assemble.fasta"


# scratch du job
SCRATCH=/storage/scratch/$USER/tmp/$SLURM_JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH

log "Scratch créé : $SCRATCH"


# ---------------------------------------------
# Copier BAM et contigs depuis serveur distant
# ---------------------------------------------
scp -r ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BAM_DIR} .
scp ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_FASTA} .

log "BAM détectés:"
ls -lh $BAM_DIR

#log "Copie terminée"

BAM_FILES=("$BAM_DIR"/*.bam)



#---------------------------------------------
# Calcul profondeur contigs multi-sample
# --------------------------------------------
log "Calcul profondeur avec jgi_summarize_bam_contig_depths"
export OMP_NUM_THREADS=2
jgi_summarize_bam_contig_depths --outputDepth depth.txt "${BAM_FILES[@]}"



# -----------------------------
# Lancement de MetaBAT2
# -----------------------------
log "Lancement MetaBAT2"
mkdir -p metabat2
metabat2 -i "$FASTA" \
         -a depth.txt \
         -o metabat2/bin \
         -t 6 \
         --unbinned \
         -m 2500 \
         -s 200000 
         
         
# Compter les bins générés
METABAT_BINS=$(ls metabat2/bin.*.fa 2>/dev/null | wc -l)
log "MetaBAT2: ${METABAT_BINS} bins générés"



# ----------------------------------
# Copie des résultats vers serveur
# ----------------------------------

RESULT_DIR="/data/mnt/stage-m2-hornes/dissemin/exp/binning/"
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp depth.txt ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/CONTIG_FASTA_DIR/
scp -r metabat2 ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/



# -----------------------------
# Fin du job
# -----------------------------
END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"
