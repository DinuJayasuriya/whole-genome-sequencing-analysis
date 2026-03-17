#!/bin/bash
#SBATCH --job-name=WGS_01_FastQC
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --partition=your_partition      # update to match your cluster
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@institution.edu

# Load conda or module — uncomment whichever applies to your system:
# module load fastqc/0.11.9
# conda activate wgs-pipeline

cd /path/to/WGS-Pipeline                # update to your repo path
bash scripts/01_fastqc.sh
