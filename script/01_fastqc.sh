#!/bin/bash
# =============================================================================
# scripts/01_fastqc.sh
# Quality control of raw Illumina reads using FastQC
#
# NANOPORE USERS: Replace FastQC with NanoPlot / NanoStat / PycoQC
#   NanoPlot --fastq reads.fastq.gz --outdir nanoplot_out --threads 8
#   NanoStat --fastq reads.fastq.gz > nanostats_summary.txt
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

echo "======================================================"
echo " Step 1: FastQC — Quality Control"
echo " Input : ${RAW_READS}"
echo " Output: ${FQC_OUT}"
echo "======================================================"

module load fastqc/0.11.9

fastqc \
  -o "${FQC_OUT}" \
  -f fastq \
  -t 8 \
  "${RAW_READS}"/*.fastq.gz

echo ""
echo "[FastQC] Done. Check ${FQC_OUT} for HTML reports."
echo "Key things to review:"
echo "  • Per Base Sequence Quality  → scores should stay above Q30"
echo "  • Adapter Content            → flag for trimming"
echo "  • Per Sequence GC Content    → deviations indicate contamination"
echo "  • Sequence Duplication Levels → high levels = PCR over-amplification"
