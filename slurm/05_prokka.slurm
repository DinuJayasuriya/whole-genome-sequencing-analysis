#!/bin/bash
#SBATCH --job-name=WGS_05_Prokka
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=12:00:00
#SBATCH --partition=standard
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@institution.edu

# conda activate wgs-pipeline

cd /path/to/WGS-Pipeline
bash scripts/05_prokka.sh
