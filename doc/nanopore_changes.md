# Nanopore Substitution Guide

This document details every change needed to adapt the main Illumina WGS pipeline for Oxford Nanopore Technology (ONT) long-read data. Steps not listed here are **unchanged** — they work identically on any assembly FASTA regardless of platform.

---

## Summary table

| Step | Illumina tool | Nanopore replacement | Action |
|---|---|---|---|
| 01 QC | FastQC | NanoPlot / NanoStat / PycoQC | **Replace** |
| 02 Trimming | Trimmomatic | NanoFilt / Chopper / Filtlong | **Replace** |
| 03 Assembly | metaSPAdes | Flye (--meta) / Canu | **Replace** |
| 03b Polishing | *(not needed)* | Medaka / Racon | **New step — required** |
| 04 Assembly QC | MetaQUAST | MetaQUAST | Keep ✓ |
| 05 Annotation | Prokka / RAST | Prokka / RAST | Keep ✓ |
| 06 Func. annotation | DRAM / METABOLIC | DRAM / METABOLIC | Keep ✓ |
| 07 Phylogenetics | GTDBtk / BPGA | GTDBtk / BPGA | Keep ✓ |
| 08 Downstream | DIAMOND | DIAMOND | Keep ✓ |
| PBS resources | Standard bigmem | More RAM + optional GPU | **Modify** |

---

## Step 01 — Replace FastQC with NanoPlot / NanoStat

FastQC metrics (per-base quality, adapter content) are designed for short, uniform Illumina reads and are not meaningful for Nanopore data.

**Install:**
```bash
pip install NanoPlot NanoStat
# or via conda:
conda install -c bioconda nanoplot nanostat pycoqc
```

**Run NanoPlot:**
```bash
NanoPlot \
  --fastq your_reads.fastq.gz \
  --outdir nanoplot_results \
  --threads 8 \
  --plots dot
```

**Run NanoStat (quick text summary):**
```bash
NanoStat --fastq your_reads.fastq.gz > nanostats_summary.txt
```

**Run PycoQC (if you have the sequencing summary file from Guppy/Dorado):**
```bash
pycoQC \
  -f sequencing_summary.txt \
  -o pycoqc_report.html
```

**Key metrics to check:**
- Read length N50 (want >5 kb for metagenomes)
- Mean / median quality score (Q10+ is acceptable; Q15+ is good)
- Total bases sequenced
- Read length distribution histogram

---

## Step 02 — Replace Trimmomatic with NanoFilt / Chopper

Nanopore reads do not have Illumina adapter contamination in the same way, so ILLUMINACLIP is irrelevant. The goal is filtering by **minimum read length** and **minimum quality score**.

**Install:**
```bash
pip install nanofilt
conda install -c bioconda filtlong chopper
```

**NanoFilt (simple, stdin/stdout):**
```bash
cat reads.fastq | NanoFilt \
  -q 10 \
  -l 500 \
  --maxlength 100000 \
  > filtered_reads.fastq

# -q 10   = minimum average quality score
# -l 500  = minimum read length (bp)
# --maxlength = discard very long outlier reads if needed
```

**Chopper (faster, supports gzipped input):**
```bash
gunzip -c reads.fastq.gz | chopper \
  -q 10 \
  -l 500 \
  --threads 8 \
  | gzip > filtered_reads.fastq.gz
```

**Filtlong (quality + length filtering, can subsample):**
```bash
filtlong \
  --min_length 1000 \
  --keep_percent 95 \
  reads.fastq.gz > filtered_reads.fastq.gz
```

---

## Step 03 — Replace metaSPAdes with Flye

SPAdes uses a de Bruijn graph approach that requires short, accurate reads. Nanopore reads are long and error-prone — Flye uses an overlap-layout-consensus approach that handles this correctly.

**Install:**
```bash
conda install -c bioconda flye
```

**Run Flye (metagenome mode):**
```bash
flye \
  --nano-raw filtered_reads.fastq \
  --meta \
  --out-dir flye_output \
  --threads 32 \
  --min-overlap 3000

# For high-quality (Q20+) Nanopore reads use --nano-hq instead of --nano-raw
```

**Alternative — Canu (better for single isolate genomes):**
```bash
canu \
  -p output_prefix \
  -d canu_output \
  genomeSize=5m \
  -nanopore filtered_reads.fastq
```

**Key output:**
```
flye_output/
  assembly.fasta        → use this as input for Medaka polishing
  assembly_info.txt     → contig statistics
  assembly_graph.gfa    → assembly graph (view in Bandage)
```

---

## Step 03b — NEW: Polishing with Medaka (required for Nanopore)

This step **does not exist** in the Illumina pipeline. Raw Nanopore assemblies have ~1–5% residual error from the signal processing. Medaka re-maps original reads back to the assembly and corrects errors by consensus voting.

**Install:**
```bash
pip install medaka
# or
conda install -c nanoporetech medaka
```

**Run Medaka:**
```bash
medaka_consensus \
  -i filtered_reads.fastq \
  -d flye_output/assembly.fasta \
  -o medaka_output \
  -t 8 \
  -m r941_min_high_g360

# -m flag: must match your basecalling model
# Common models:
#   r941_min_high_g360  → MinION, R9.4.1 flowcell, high accuracy Guppy
#   r941_min_sup_g507   → MinION, R9.4.1, super accuracy Guppy
#   r1041_e82_400bps_sup_v4.2.0 → R10.4.1 flowcell (newer chemistry)
# Check your run metadata or Guppy/Dorado config for the correct model.
```

**Key output:**
```
medaka_output/
  consensus.fasta    → use THIS as input for MetaQUAST and Prokka
```

**Optional — Racon (pre-polish before Medaka, improves results further):**
```bash
# Map reads to assembly first
minimap2 -x map-ont flye_output/assembly.fasta filtered_reads.fastq > reads_vs_assembly.paf

# Run Racon
racon \
  -t 16 \
  filtered_reads.fastq \
  reads_vs_assembly.paf \
  flye_output/assembly.fasta \
  > racon_polished.fasta

# Then run Medaka on racon_polished.fasta instead of the raw Flye output
```

---

## PBS script modifications for Nanopore

### Flye assembly PBS script

```bash
#!/bin/bash
#PBS -N WGS_03_Flye
#PBS -l select=1:ncpus=32:mem=500gb,walltime=48:00:00
#PBS -q bigmem
#PBS -j oe
#PBS -m abe
#PBS -M your_email@clemson.edu

cd /home/<your_username>/WGS-Pipeline

module load flye/2.9.2   # check: module avail flye
# or: conda activate flye-env

flye \
  --nano-raw /path/to/filtered_reads.fastq \
  --meta \
  --out-dir /scratch1/<username>/flye_output \
  --threads 32
```

### Medaka polishing PBS script (GPU recommended)

```bash
#!/bin/bash
#PBS -N WGS_03b_Medaka
#PBS -l select=1:ncpus=16:mem=128gb:ngpus=1,walltime=24:00:00
#PBS -q bigmem
#PBS -j oe
#PBS -m abe
#PBS -M your_email@clemson.edu

cd /home/<your_username>/WGS-Pipeline

# Load CUDA and activate medaka conda env
module load cuda/11.8
conda activate medaka-env

medaka_consensus \
  -i /path/to/filtered_reads.fastq \
  -d /scratch1/<username>/flye_output/assembly.fasta \
  -o /scratch1/<username>/medaka_output \
  -t 16 \
  -m r941_min_high_g360    # update to match your chemistry
```

> **Note:** GPU access on Palmetto requires adding `:ngpus=1` to your resource request. Medaka falls back to CPU if no GPU is found, but is significantly slower. Check available GPU nodes with `whatsfree`.

---

## Hybrid assembly (Illumina + Nanopore together)

If you have both data types, SPAdes supports hybrid assembly natively — long reads scaffold the short-read contigs:

```bash
spades.py \
  --meta \
  --pe1-1 R1_paired.fq.gz \
  --pe1-2 R2_paired.fq.gz \
  --nanopore filtered_nanopore_reads.fastq \
  -t 32 \
  -m 750 \
  -o hybrid_assembly_output
```

This approach gives you the best of both platforms: Nanopore spans repeats and structural elements, Illumina corrects base-level errors. Medaka polishing is usually not needed after hybrid assembly because the Illumina reads provide the error correction.

---

## Key differences in expected results

| Metric | Illumina assembly | Nanopore assembly |
|---|---|---|
| Number of contigs | Many (thousands) | Far fewer (tens to hundreds) |
| N50 | Lower | Much higher |
| Largest contig | Shorter | Can be chromosome-length |
| Base accuracy | Very high (~99.9%) | Lower before polishing (~95–99%) |
| Repeat resolution | Poor | Excellent |
| Methylation info | None | Available natively |

---

## Useful references

- [Flye documentation](https://github.com/fenderglass/Flye)
- [Medaka documentation](https://github.com/nanoporetech/medaka)
- [NanoPlot documentation](https://github.com/wdecoster/NanoPlot)
- [NanoFilt documentation](https://github.com/wdecoster/nanofilt)
- [Oxford Nanopore basecalling models](https://github.com/nanoporetech/dorado)
