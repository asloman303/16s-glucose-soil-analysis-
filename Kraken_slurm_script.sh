#!/bin/bash
#SBATCH --job-name=kraken2_array
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8         # Kraken2 can use multiple cores
#SBATCH --mem=128G                 # A standard Kraken2 DB can use a lot of RAM
#SBATCH --time=01:00:00           # 1 hour per sample is a safe starting point
#SBATCH --partition=nodes
#SBATCH --array=1-11
#SBATCH --output=kraken2_logs/kraken2_%A_%a.out
#SBATCH --error=kraken2_logs/kraken2_%A_%a.err

# --- SETUP ---
echo "======================================================"
echo "Job Started: $(date) for Array Task ID: $SLURM_ARRAY_TASK_ID"
echo "======================================================"

# Find the correct Kraken2 module on your system
# module spider Kraken2
module load Kraken2

# Create directories for logs and results
mkdir -p kraken2_logs
mkdir -p kraken2_results

### CRITICAL: Set the database path!
# You MUST find the path to a pre-built Kraken2 database on your cluster.
# Check your cluster's documentation or ask your system administrator.
DB_PATH=/mnt/scratch/projects/biol-soilv-2024/databases/kraken2_v2

# --- Get the list of FASTQ files ---
# We assume this script is submitted from the directory containing 'fastq_files'
FASTQ_FILES=(fastq_files/*.fastq)
INDEX=$((SLURM_ARRAY_TASK_ID - 1))
FQ_FILE=${FASTQ_FILES[$INDEX]}

# Get the base name of the sample (e.g., "barcode01")
SAMPLE_NAME=$(basename "$FQ_FILE" .fastq)

# --- RUN KRAKEN2 ---
echo "Running Kraken2 on $FQ_FILE..."

kraken2 --db $DB_PATH --threads $SLURM_CPUS_PER_TASK \
  --report "kraken2_results/${SAMPLE_NAME}.report" \
  --output "kraken2_results/${SAMPLE_NAME}.output" \
  "$FQ_FILE"

echo "Kraken2 complete for $SAMPLE_NAME."
echo "======================================================"
echo "Job Finished: $(date)"
echo "======================================================"

