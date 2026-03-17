#!/bin/bash
# =============================================================================
# scripts/05_prokka.sh
# Structural genome annotation using Prokka
#
# NANOPORE USERS: No change needed — Prokka annotates contigs regardless
#   of how they were assembled. Use the Medaka-polished FASTA as input.
#   Polishing first is important: unannotated frameshifts from raw Nanopore
#   errors will create spurious gene calls.
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

ASSEMBLY="${ASSEMBLY_OUT}/contigs.fasta"
SAMPLE_PREFIX="WGS_sample"         # change to your sample/project name
THREADS=16

echo "======================================================"
echo " Step 5: Prokka — Structural Annotation"
echo " Input : ${ASSEMBLY}"
echo " Output: ${PROKKA_OUT}"
echo "======================================================"

module load prokka/1.14

prokka \
    --outdir "${PROKKA_OUT}" \
    --prefix "${SAMPLE_PREFIX}" \
    --metagenome \
    --cpus "${THREADS}" \
    "${ASSEMBLY}"

echo ""
echo "[Prokka] Annotation complete."
echo "Output files:"
echo "  .gff  → master annotation (GFF3); open in Artemis or IGV"
echo "  .gbk  → Genbank format"
echo "  .faa  → protein FASTA (CDS) — input for DRAM, METABOLIC, DIAMOND"
echo "  .fna  → nucleotide FASTA of contigs"
echo "  .ffn  → nucleotide FASTA of all predicted transcripts"
echo "  .txt  → annotation statistics summary"
echo "  .tsv  → tab-separated feature table"
