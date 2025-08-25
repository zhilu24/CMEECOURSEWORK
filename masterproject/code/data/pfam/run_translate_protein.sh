#!/bin/bash
#PBS -N prot_translate
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=8:mem=50gb
#PBS -j oe
#PBS -o /rds/general/user/zz8024/home/scripts/translate.log

# Load the Anaconda environment 
module load anaconda3/personal
source ~/.bashrc    # Ensure the `conda` command is available
conda activate opt_env

# Change to the job submission directory
cd /rds/general/user/zz8024/home/scripts/

# Run the Python script
python translate_protein.py
