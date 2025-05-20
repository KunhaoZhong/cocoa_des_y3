#!/bin/bash

#SBATCH --job-name=GG_MCMC
#SBATCH --output=GG_MCMC-%A_%a.out
#SBATCH -e GG_MCMC-%A_%a.out.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=16
#SBATCH --qos=regular
#SBATCH --time=48:00:00
#SBATCH --constraint=cpu

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Slurm job NAME is $SLURM_JOB_NAME
echo Slurm job ID is $SLURM_JOBID
echo Number of task is $SLURM_NTASKS
echo Number of cpus per task is $SLURM_CPUS_PER_TASK

cd $SLURM_SUBMIT_DIR

source /global/u1/k/kunhaoz/miniconda3/etc/profile.d/conda.sh
conda activate /global/common/software/des/kunhaoz/cocoa_common
export CONDA_PREFIX=/global/common/software/des/kunhaoz/cocoa_common
source start_cocoa
source ./projects/des_y3/scripts/start_des_y3.sh
export COBAYA_USE_FILE_LOCKING=false

export OMP_PROC_BIND=close
if [ -n "$SLURM_CPUS_PER_TASK" ]; then
  export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
else
  export OMP_NUM_THREADS=1
fi

$CONDA_PREFIX/bin/mpirun -n ${SLURM_NTASKS} --oversubscribe --map-by numa:pe=${OMP_NUM_THREADS} cobaya-run ./projects/des_y3/GG_MCMC${SLURM_ARRAY_TASK_ID}.yaml -r