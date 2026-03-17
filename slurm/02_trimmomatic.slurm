#!/bin/bash
#SBATCH --job-name=WGS_02_Trimmomatic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=08:00:00
#SBATCH --partition=your_partition
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@institution.edu

# module load trimmomatic/0.39
# conda activate wgs-pipeline

cd /path/to/WGS-Pipeline
bash scripts/02_trimmomatic.sh
