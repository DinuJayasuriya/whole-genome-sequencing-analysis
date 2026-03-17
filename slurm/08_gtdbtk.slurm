#!/bin/bash
#SBATCH --job-name=WGS_08_GTDBtk
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=512G
#SBATCH --time=72:00:00
#SBATCH --partition=highmem
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@institution.edu

# conda activate wgs-pipeline

cd /path/to/WGS-Pipeline
bash scripts/08_gtdbtk.sh
