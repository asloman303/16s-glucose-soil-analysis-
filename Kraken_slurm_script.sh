#!/bin/bash
#SBATCH --job-name=kraken2_array
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8         
#SBATCH --mem=128G                
#SBATCH --time=01:00:00           
#SBATCH --partition=nodes
#SBATCH --array=1-11
#SBATCH --output=kraken2_logs/kraken2_%A_%a.out
#SBATCH --error=kraken2_logs/kraken2_%A_%a.err

# --- SETUP ---
echo "======================================================"
echo "Job Started: $(date) for Array Task ID: $SLURM_ARRAY_TASK_ID"
echo "======================================================"

conda activate kraken2

# Create directories for logs and results
mkdir -p kraken2_logs
mkdir -p kraken2_results

DB_PATH=/mnt/scratch/projects/biol-soilv-2024/databases/kraken2_v2


FASTQ_FILES=(fastq_files/*.fastq)
INDEX=$((SLURM_ARRAY_TASK_ID - 1))
FQ_FILE=${FASTQ_FILES[$INDEX]}

# Get the base name of the sample 
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

