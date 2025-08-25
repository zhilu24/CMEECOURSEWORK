#!/bin/bash
#PBS -N pfam_batch
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=256:mem=400gb
#PBS -q v1_large72
#PBS -o /rds/general/user/zz8024/home/scripts/finalpfam_output.out
#PBS -e /rds/general/user/zz8024/home/scripts/finalpfam_output.err
#PBS -j oe


module load anaconda3/personal

source ~/.bashrc

conda activate opt_env


#Start resource logger
(
  while true; do
    timestamp=$(date +%Y-%m-%dT%H:%M:%S)
    echo "[$timestamp] ===== Resource usage ====="
    top -b -n 1 | head -n 12
    echo ""
    sleep 1200
  done
) >> /rds/general/user/zz8024/home/scripts/prot2pfam_resource_usage_${PBS_JOBID:-$$}.log &
LOGGER_PID=$!



cd /rds/general/user/zz8024/home/scripts
./prot2pfam_cluster.sh -c 1 -j 250 -e 1e-3 /rds/general/user/zz8024/home/data/translated_proteins_backup_new/*.faa

wait
if ps -p $LOGGER_PID > /dev/null; then
  kill $LOGGER_PID
fi
