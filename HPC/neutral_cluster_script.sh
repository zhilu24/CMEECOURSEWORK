#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=1gb

module load anaconda3/personal

echo "R is about to run"

cp $HOME/zz8024_HPC_2024_MAIN.R $TMPDIR
cp $HOME/Demographic.R $TMPDIR
cp $HOME/zz8024_HPC_neutral_cluster.R $TMPDIR
R --vanilla <zz8024_HPC_neutral_cluster.R

mv neutral_simulation_results_iter*.rda $HOME/output_files

echo "R has finished running"