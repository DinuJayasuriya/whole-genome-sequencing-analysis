#!/bin/bash
# =============================================================================
# scripts/02_trimmomatic.sh
# Adapter trimming and quality filtering of paired-end Illumina reads
#
# NANOPORE USERS: Replace Trimmomatic with NanoFilt or Chopper
#   NanoFilt -q 10 -l 500 < reads.fastq > filtered_reads.fastq
#   OR: cat reads.fastq | chopper -q 10 -l 500 > filtered_reads.fastq
#   Note: Nanopore reads don't have Illumina adapter contamination —
#         you are mainly filtering by minimum quality and minimum length.
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

THREADS=16

echo "======================================================"
echo " Step 2: Trimmomatic — Adapter Trimming"
echo " Input : ${RAW_READS}"
echo " Output: ${TRIM_OUT}"
echo "======================================================"

module load trimmomatic/0.39

# Loop over all sample pairs (expects R1/R2 naming convention)
for R1 in "${RAW_READS}"/*_R1*.fastq.gz; do
    R2="${R1/_R1/_R2}"
    SAMPLE=$(basename "${R1}" | sed 's/_R1.*//')

    echo ""
    echo "[Trimmomatic] Processing sample: ${SAMPLE}"

    java -jar "${EBROOTTRIMMOMATIC}/trimmomatic-0.39.jar" PE \
        -threads "${THREADS}" \
        "${R1}" "${R2}" \
        "${TRIM_OUT}/${SAMPLE}_R1_paired.fq.gz" \
        "${TRIM_OUT}/${SAMPLE}_R1_unpaired.fq.gz" \
        "${TRIM_OUT}/${SAMPLE}_R2_paired.fq.gz" \
        "${TRIM_OUT}/${SAMPLE}_R2_unpaired.fq.gz" \
        ILLUMINACLIP:"${ADAPTER_FILE}":2:30:10:2:True \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36

    echo "[Trimmomatic] ${SAMPLE} complete."
done

echo ""
echo "[Trimmomatic] All samples done."
echo "Output files per sample:"
echo "  *_R1_paired.fq.gz   → use these for assembly"
echo "  *_R2_paired.fq.gz   → use these for assembly"
echo "  *_unpaired.fq.gz    → discarded or optionally used with --pe1-s in SPAdes"
echo ""
echo "RECOMMENDED: Re-run FastQC on trimmed reads to confirm quality improvement."
