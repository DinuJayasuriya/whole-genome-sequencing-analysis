#!/bin/bash
# =============================================================================
# scripts/08_gtdbtk.sh
# Phylogenetic classification using GTDBtk
# Runs full workflow: identify → align → classify → (optional) de_novo_wf
#
# NANOPORE USERS: No change needed — GTDBtk classifies genome files,
#   platform-agnostic. Better contiguity from Nanopore assemblies can
#   actually improve marker gene detection.
# =============================================================================

source "$(dirname "$0")/../config/paths.sh"

GENOME_DIR="/zfs/camplab/dereplicated_genomes"   # your MAGs/genomes folder
EXT="fa"                                          # file extension (fa, fasta, gz)
THREADS=40
GTDBTK_BASE="${GTDBTK_OUT}"

export GTDBTK_DATA_PATH="${GTDBTK_DATA}"

echo "======================================================"
echo " Step 8: GTDBtk — Phylogenetic Classification"
echo " Input : ${GENOME_DIR}"
echo " Output: ${GTDBTK_BASE}"
echo "======================================================"

conda activate gtdbtk-env

# --- Step 8a: Identify marker genes ------------------------------------------
echo "[GTDBtk] Step 1/4: Identify..."
gtdbtk identify \
    --genome_dir "${GENOME_DIR}" \
    --out_dir "${GTDBTK_BASE}/identify" \
    --extension "${EXT}" \
    --cpus "${THREADS}"

# --- Step 8b: Align ----------------------------------------------------------
echo "[GTDBtk] Step 2/4: Align..."
gtdbtk align \
    --identify_dir "${GTDBTK_BASE}/identify" \
    --out_dir "${GTDBTK_BASE}/align" \
    --cpus "${THREADS}"

# --- Step 8c: Classify -------------------------------------------------------
echo "[GTDBtk] Step 3/4: Classify..."
gtdbtk classify \
    --genome_dir "${GENOME_DIR}" \
    --align_dir "${GTDBTK_BASE}/align" \
    --out_dir "${GTDBTK_BASE}/classify" \
    -x "${EXT}" \
    --cpus "${THREADS}"

# --- Step 8d: De novo workflow (optional — custom taxonomy) ------------------
# echo "[GTDBtk] Step 4/4: De novo workflow..."
# gtdbtk de_novo_wf \
#     --genome_dir "${GENOME_DIR}" \
#     --out_dir "${GTDBTK_BASE}/de_novo" \
#     --extension "${EXT}" \
#     --bacteria \
#     --cpus "${THREADS}" \
#     --outgroup_taxon p__Chloroflexota \
#     --skip_gtdb_refs \
#     --custom_taxonomy_file "${GTDBTK_BASE}/Custom_taxonomy_file.csv"

# --- Step 8e: Convert to iTOL format for visualization ----------------------
echo "[GTDBtk] Converting to iTOL format..."
gtdbtk convert_to_itol \
    --input_tree "${GTDBTK_BASE}/classify/gtdbtk.bac120.decorated.tree" \
    --output_tree "${GTDBTK_BASE}/itol_output_tree"

conda deactivate

echo ""
echo "[GTDBtk] Done."
echo "  Upload ${GTDBTK_BASE}/itol_output_tree to https://itol.embl.de for visualization."
