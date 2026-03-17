#!/bin/bash
#SBATCH --job-name=WGS_06_DRAM
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=256G
#SBATCH --time=48:00:00
#SBATCH --partition=highmem
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@institution.edu

# conda activate wgs-pipeline

cd /path/to/WGS-Pipeline
bash scripts/06_dram.sh
