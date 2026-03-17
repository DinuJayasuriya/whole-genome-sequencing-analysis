#!/bin/bash
#SBATCH --job-name=WGS_04_MetaQUAST
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=06:00:00
#SBATCH --partition=standard
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@institution.edu

# conda activate wgs-pipeline

cd /path/to/WGS-Pipeline
bash scripts/04_metaquast.sh
