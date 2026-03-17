#!/bin/bash
# =============================================================================
# scripts/07_metabolic.sh
# Biogeochemical functional trait prediction using METABOLIC
#
# METABOLIC-G.pl  → metabolic capabilities only
# METABOLIC-C.pl  → metabolic + coverage + biogeochemical cycling diagrams
#
# NANOPORE USERS: No change needed — input is genome files, platform-agnostic.
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

GENOME_DIR="${PROKKA_OUT}"           # folder with annotated genome .fa files
READS_LIST="${SCRATCH}/reads_list.txt"  # path to file listing paired reads (for METABOLIC-C)
THREADS=32
METABOLIC_PATH="/zfs/camplab/METABOLIC"  # update to your METABOLIC install path

echo "======================================================"
echo " Step 7: METABOLIC — Biogeochemical Trait Prediction"
echo " Input : ${GENOME_DIR}"
echo " Output: ${METABOLIC_OUT}"
echo "======================================================"

# --- Option A: METABOLIC-G (genome classification only) ---------------------
echo "[METABOLIC-G] Running genome classification..."
perl "${METABOLIC_PATH}/METABOLIC-G.pl" \
    -in-gn "${GENOME_DIR}" \
    -o "${METABOLIC_OUT}/METABOLIC-G"

# --- Option B: METABOLIC-C (genome + coverage + biogeochemical diagrams) ----
# Uncomment below to use METABOLIC-C instead (requires a reads list file)
#
# echo "[METABOLIC-C] Running full community analysis..."
# perl "${METABOLIC_PATH}/METABOLIC-C.pl" \
#     -in-gn "${GENOME_DIR}" \
#     -r "${READS_LIST}" \
#     -o "${METABOLIC_OUT}/METABOLIC-C"

echo ""
echo "[METABOLIC] Done."
echo "Output includes:"
echo "  METABOLIC_result.xlsx             → metabolic trait matrix"
echo "  METABOLIC-Figures/                → biogeochemical cycling diagrams"
echo "  Each_HMM_Metabolism_summary.txt"
