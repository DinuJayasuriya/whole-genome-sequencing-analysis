#!/bin/bash
# =============================================================================
# scripts/03_spades.sh
# Metagenomic genome assembly using metaSPAdes
#
# NANOPORE USERS: Replace metaSPAdes with Flye (--meta flag for metagenomes)
#   flye --nano-raw filtered_reads.fastq \
#        --meta \
#        --out-dir flye_output \
#        --threads 32
#
#   After Flye, you MUST run polishing (not needed for Illumina):
#   medaka_consensus \
#       -i filtered_reads.fastq \
#       -d flye_output/assembly.fasta \
#       -o medaka_output \
#       -t 8 \
#       -m r941_min_high_g360     # match your basecalling model
#
#   Other options: Canu (canu -p output -d outdir genomeSize=5m -nanopore reads.fastq)
#                  Miniasm + Minipolish (faster, lower accuracy)
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

THREADS=32
MEMORY=750       # GB — adjust to your allocation

# Paired trimmed reads (output from step 02)
R1="${TRIM_OUT}/${SAMPLE}_R1_paired.fq.gz"
R2="${TRIM_OUT}/${SAMPLE}_R2_paired.fq.gz"

echo "======================================================"
echo " Step 3: metaSPAdes — Genome Assembly"
echo " R1    : ${R1}"
echo " R2    : ${R2}"
echo " Output: ${ASSEMBLY_OUT}"
echo "======================================================"

module load spades/3.15.3

spades.py \
    --meta \
    --pe1-1 "${R1}" \
    --pe1-2 "${R2}" \
    -t "${THREADS}" \
    -m "${MEMORY}" \
    -o "${ASSEMBLY_OUT}"

echo ""
echo "[SPAdes] Assembly complete."
echo "Key output files:"
echo "  ${ASSEMBLY_OUT}/contigs.fasta     → use for annotation"
echo "  ${ASSEMBLY_OUT}/scaffolds.fasta   → higher-level assembly"
echo "  ${ASSEMBLY_OUT}/assembly_graph.fastg"
