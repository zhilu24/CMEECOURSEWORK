#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=1gb

module load anaconda3/personal

echo "R is about to run"

cp $HOME/Demographic.R $TMPDIR
cp $HOME/demographic_cluster1.R $TMPDIR
R --vanilla <demographic_cluster1.R

mv simulation_results* $HOME/output_files/

echo "R has finished running"



