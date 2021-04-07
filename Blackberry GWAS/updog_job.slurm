#!/bin/bash

#SBATCH -J tmchizk_%j
#SBATCH --partition condo
#SBATCH -e dog-%j.err
#SBATCH -o dog-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=tmchizk@uark.edu
#SBATCH --mail-type=ALL

module load gcc/7.2.1 mkl/19.0.4 curl/7.69.1 R/3.6.3

cd $SLURM_SUBMIT_DIR

Rscript Dogify.R
