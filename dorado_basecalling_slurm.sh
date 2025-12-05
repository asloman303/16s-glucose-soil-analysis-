#!/bin/bash

#SBATCH --job-name=dorado_array
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --gres=gpu:1
#SBATCH --partition=gpu
#SBATCH --output=dorado_%A_%a.out
#SBATCH --error=dorado_%A_%a.err
### EDITED: Array now runs from 1 to 11, since there are only 11 barcode folders.
#SBATCH --array=1-11

#--------------------------------------------------------------------------------
# 1. SETUP & CONFIGURATION
#--------------------------------------------------------------------------------

echo "======================================================"
echo "Job Started: $(date)"
echo "Job ID: $SLURM_JOB_ID, Array Task ID: $SLURM_ARRAY_TASK_ID"
echo "Running on node: $SLURM_JOB_NODELIST"
echo "======================================================"

module purge
module load dorado/0.9.1-foss-2023a-CUDA-12.1.1

# --- DEFINE PATHS ---
MODEL_PATH="models/dna_r9.4.1_e8_sup@v3.6"


mkdir -p output_bams


BARCODE_FOLDERS=(
  barcode01 barcode02 barcode03
  barcode04 barcode05 barcode06
  barcode07 barcode08 barcode09
  barcode10 barcode12
)

INDEX=$((SLURM_ARRAY_TASK_ID - 1))
INPUT_FOLDER=${BARCODE_FOLDERS[$INDEX]}


INPUT_DIR="${INPUT_FOLDER}"
OUTPUT_BAM="output_bams/${INPUT_FOLDER}.bam"

echo "Input Directory for this job: $INPUT_DIR"
echo "Output BAM for this job: $OUTPUT_BAM"

#--------------------------------------------------------------------------------
# 2. RUN DORADO BASECALLER
#--------------------------------------------------------------------------------

echo "Starting Dorado basecaller for a single barcode..."

dorado basecaller \
  "$MODEL_PATH" \
  "$INPUT_DIR" \
  > "$OUTPUT_BAM"

echo "======================================================"
echo "Job Finished: $(date)"
echo "======================================================"
