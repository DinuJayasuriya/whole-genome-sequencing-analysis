#!/bin/bash
#SBATCH --job-name=WGS_03_SPAdes
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=750G
#SBATCH --time=48:00:00
#SBATCH --partition=highmem               # use your cluster's high-memory partition
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@institution.edu

# NANOPORE: Replace this script with 03_flye.slurm
# See docs/nanopore_changes.md for Flye + Medaka SLURM scripts.

# module load spades/3.15.3
# conda activate wgs-pipeline

cd /path/to/WGS-Pipeline
bash scripts/03_spades.sh
