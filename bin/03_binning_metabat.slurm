#!/bin/bash
#SBATCH --job-name=metabat
#SBATCH --output=logs/metabat_%j.out
#SBATCH --error=logs/metabat_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --partition=long
#SBATCH --time=3-00:00:00


# =====================================
# Script: binning_metabat.slurm
# Description:
# Générer le fichier de couverture,
# puis former des bins avec l'outil MetaBAT2
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

mkdir -p metabat

BAM_FILES=("$bam_dir"/*.bam)



#---------------------------------------------
# Calcul profondeur contigs multi-sample
# --------------------------------------------
echo "Calcul profondeur avec jgi_summarize_bam_contig_depths"

# calcul de la profondeur de couverture des contigs à partir des fichiers bam,
# résultat stocké dans le fichier deptht.txt
jgi_summarize_bam_contig_depths --outputDepth depth.txt "${BAM_FILES[@]}"



# -----------------------------
# Lancement de MetaBAT2
# -----------------------------
echo "Lancement MetaBAT2"
# formation de bins avec metabat2, en utilisant le fichier
# de couvertue depth.txt, avec 2500 pb et 200 kb pour la taille
# minimum de contigs utilisé et taille minimum d'un bin produire
# respectivement
metabat2 -i "$fasta" \
         -a depth.txt \
         -o metabat/bin \
         -t "$THREADS" \
         --unbinned \
         -m 2500 \
         -s 200000 
        
# ------------------------
# Copie des résultats 
# ------------------------

ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RESULT_DIR}"

scp depth.txt ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}
scp -r metabat ${REMOTE_USER}@${REMOTE_HOST}:${RESULT_DIR}/

echo "Résultats copiés dans ${RESULT_DIR}"

END_TIME=$(date +%s)
echo "End: $(date)"
echo "Runtime: $((END_TIME - START_TIME)) seconds"


