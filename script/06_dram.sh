#!/bin/bash
# =============================================================================
# scripts/06_dram.sh
# Functional/metabolic annotation using DRAM (two-stage: annotate + distill)
#
# NANOPORE USERS: No change needed — DRAM takes genome FASTA files as input,
#   which are platform-agnostic once assembled and polished.
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

GENOME_DIR="${ASSEMBLY_OUT}"     # folder with .fa / .fasta genome files
THREADS=32

echo "======================================================"
echo " Step 6: DRAM — Functional Annotation"
echo " Input : ${GENOME_DIR}"
echo " Output: ${DRAM_ANNOT_OUT} / ${DRAM_DISTILL_OUT}"
echo "======================================================"

# DRAM is installed in a conda environment
conda activate DRAM

# --- Stage 1: Annotate -------------------------------------------------------
echo "[DRAM] Stage 1: Annotation..."
DRAM.py annotate \
    -i "${GENOME_DIR}/*.fa" \
    -o "${DRAM_ANNOT_OUT}" \
    --threads "${THREADS}"

# --- Stage 2: Distill --------------------------------------------------------
echo "[DRAM] Stage 2: Distillation..."
DRAM.py distill \
    -i "${DRAM_ANNOT_OUT}/annotations.tsv" \
    -o "${DRAM_DISTILL_OUT}" \
    --trna_path "${DRAM_ANNOT_OUT}/trnas.tsv" \
    --rrna_path "${DRAM_ANNOT_OUT}/rrnas.tsv"

conda deactivate

echo ""
echo "[DRAM] Done."
echo "Key output files:"
echo "  ${DRAM_ANNOT_OUT}/annotations.tsv  → raw gene-level annotations"
echo "  ${DRAM_DISTILL_OUT}/metabolism_summary.xlsx → curated metabolic categories"
echo "  ${DRAM_DISTILL_OUT}/product.html   → interactive metabolic heatmap"
