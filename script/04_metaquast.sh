#!/bin/bash
# =============================================================================
# scripts/04_metaquast.sh
# Assembly quality assessment using MetaQUAST
#
# NANOPORE USERS: No change needed — MetaQUAST works on any assembly FASTA.
#   If using Medaka-polished output, point ASSEMBLY to medaka_output/consensus.fasta
#   Expect better N50 and fewer contigs than Illumina assemblies.
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

ASSEMBLY="${ASSEMBLY_OUT}/contigs.fasta"
THREADS=16

echo "======================================================"
echo " Step 4: MetaQUAST — Assembly Quality Assessment"
echo " Assembly: ${ASSEMBLY}"
echo " Output  : ${QUAST_OUT}"
echo "======================================================"

module load quast/5.0.2

# Without reference (typical for metagenomes)
quast.py \
    -o "${QUAST_OUT}" \
    --threads "${THREADS}" \
    "${ASSEMBLY}"

# Optional — with reference genome (if available):
# quast.py -o "${QUAST_OUT}" -r reference.fasta "${ASSEMBLY}"

echo ""
echo "[MetaQUAST] Done. Open ${QUAST_OUT}/report.html for results."
echo "Key metrics to check:"
echo "  N50          → longer is better; reflects assembly continuity"
echo "  # contigs    → fewer is better"
echo "  Largest contig"
echo "  Total length → should match expected genome size"
echo "  GC (%)       → compare to known GC of target organism"
