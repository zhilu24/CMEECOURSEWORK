#!/bin/bash
#PBS -N mmseqs_batch
#PBS -l select=1:ncpus=8:mem=32gb
#PBS -l walltime=24:00:00
#PBS -j oe
#PBS -o /rds/general/user/zz8024/home/scripts/dataprocess/mmseqs_final_output.log

cd $PBS_O_WORKDIR

# Load the necessary environment (if using conda)
module load anaconda3/personal
source ~/.bashrc
conda activate opt_env  


# Set input/output directories
INPUT_DIR="/rds/general/user/zz8024/home/data/translated_proteins_backup_new"
OUTPUT_DIR="/rds/general/user/zz8024/home/data/filtered_output"

# Run the batch MMseqs2 deduplication script
python mmseqs2.py "$INPUT_DIR" "$OUTPUT_DIR"