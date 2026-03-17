# 🧬 Whole Genome Sequencing (WGS) Analysis Pipeline

**Complete metagenomic WGS workflow on any Linux HPC: raw Illumina reads → assembly → annotation → phylogenetics**

> Part of the *From Field to Function* series — [dinujayasuriya.github.io](https://dinujayasuriya.github.io)

---

## 📌 Overview

Complete **whole genome sequencing analysis pipeline** covering quality control through functional and phylogenetic analyses. Developed for genome-resolved microbial community analysis on the **Clemson University Palmetto HPC cluster**, but designed to run on any Linux HPC (PBS or SLURM) or local workstation.

| | |
|---|---|
| **Platform** | Illumina paired-end (Nanopore substitutions documented) |
| **Scheduler** | PBS/Torque · SLURM |
| **HPC** | Clemson Palmetto (+ any Linux cluster) |
| **Assembly** | metaSPAdes 3.15.3 |
| **Annotation** | Prokka · DRAM · METABOLIC |
| **Downstream** | GTDBtk · BPGA · ANI · DDH |

> 🔵 **Nanopore users:** Tool substitutions are noted at each step — see [`docs/nanopore_changes.md`](docs/nanopore_changes.md)

---

## 🔬 Pipeline Overview

```
Raw Paired-End Reads (FASTQ)
        ↓
  01_fastqc.sh              — Raw read quality inspection
        ↓
  02_trimmomatic.sh         — Adapter trimming + quality filtering
        ↓
  03_spades.sh              — De novo metagenomic assembly (metaSPAdes)
        ↓
  04_metaquast.sh           — Assembly quality assessment
        ↓
  05_prokka.sh              — Structural genome annotation
        ↓
  06_dram.sh                — Functional / metabolic annotation (DRAM)
        ↓
  07_metabolic.sh           — Biogeochemical trait prediction (METABOLIC)
        ↓
  08_gtdbtk.sh              — Phylogenetic classification (GTDBtk)
```

> 📁 See the [`/scripts`](./script) folder for all runnable code

---

## 📁 Repository Structure

```
WGS-Pipeline/
├── scripts/
│   ├── 01_fastqc.sh              # Raw read QC
│   ├── 02_trimmomatic.sh         # Adapter trimming
│   ├── 03_spades.sh              # Genome assembly
│   ├── 04_metaquast.sh           # Assembly QC
│   ├── 05_prokka.sh              # Structural annotation
│   ├── 06_dram.sh                # Functional annotation
│   ├── 07_metabolic.sh           # Biogeochemical traits
│   └── 08_gtdbtk.sh              # Phylogenetics
├── pbs/                          # PBS/Torque batch job scripts
│   └── 01_fastqc.pbs ... 08_gtdbtk.pbs
├── slurm/                        # SLURM batch job scripts
│   └── 01_fastqc.slurm ... 08_gtdbtk.slurm
├── config/
│   └── paths.sh                  # Set all user paths here before running
├── docs/
│   ├── nanopore_changes.md       # Full Nanopore substitution guide
└── README.md
```

---

## ⚙️ Key Parameters

| Step | Tool | Parameter | Value | Notes |
|------|------|-----------|-------|-------|
| Trimming | Trimmomatic | `SLIDINGWINDOW` | 4:15 | 4-base window, min quality Q15 |
| Trimming | Trimmomatic | `LEADING / TRAILING` | 3 | Remove bases below Q3 at read ends |
| Trimming | Trimmomatic | `MINLEN` | 36 | Discard reads shorter than 36 bp |
| Assembly | metaSPAdes | `-m` | 750 | RAM in GB — adjust to your allocation |
| Assembly | metaSPAdes | `-t` | 32 | Threads |
| Annotation | Prokka | `--metagenome` | on | Required for metagenomic assemblies |
| DRAM | DRAM | annotate + distill | 2-stage | Annotate first, then distill |
| Phylogenetics | GTDBtk | `--cpus` | 40 | Reduce if node limits apply |

> ⚠️ Adjust `-m` (memory) and `-t` (threads) in `03_spades.sh` based on your cluster allocation

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/DinuJayasuriya/WGS-Pipeline.git
cd WGS-Pipeline

# 2. Install dependencies (conda recommended)
conda create -n wgs-pipeline -c bioconda -c conda-forge \
    fastqc trimmomatic spades quast prokka diamond gtdbtk
conda activate wgs-pipeline

# 3. Configure your paths (edit once — all scripts source this file)
nano config/paths.sh

# 4. Run steps in order
bash scripts/01_fastqc.sh
bash scripts/02_trimmomatic.sh
bash scripts/03_spades.sh
bash scripts/04_metaquast.sh
bash scripts/05_prokka.sh
bash scripts/06_dram.sh
bash scripts/07_metabolic.sh
bash scripts/08_gtdbtk.sh
```

**To submit as batch jobs:**
```bash
# PBS / Torque
qsub pbs/01_fastqc.pbs

# SLURM
sbatch slurm/01_fastqc.slurm
```

---

## 📊 Key Outputs

| Output | Description |
|--------|-------------|
| `01_fastqc/*.html` | Per-sample quality reports |
| `02_trimmomatic/*_paired.fq.gz` | Cleaned paired reads for assembly |
| `03_spades/contigs.fasta` | Final assembled contigs |
| `04_metaquast/report.html` | Assembly quality metrics (N50, # contigs, GC%) |
| `05_prokka/*.gff` | Master annotation — open in Artemis or IGV |
| `05_prokka/*.faa` | Protein FASTA — input for DRAM and METABOLIC |
| `06_dram/metabolism_summary.xlsx` | Curated metabolic categories |
| `06_dram/product.html` | Interactive metabolic heatmap |
| `07_metabolic/METABOLIC_result.xlsx` | Biogeochemical trait matrix |
| `07_metabolic/METABOLIC-Figures/` | Biogeochemical cycling diagrams |
| `08_gtdbtk/gtdbtk.bac120.decorated.tree` | Phylogenetic tree (upload to iTOL) |

---

## 📦 Requirements

```bash
# Install via conda (recommended)
conda create -n wgs-pipeline -c bioconda -c conda-forge \
    fastqc trimmomatic spades quast prokka diamond gtdbtk
conda activate wgs-pipeline

# DRAM and METABOLIC require separate environments — see their GitHub pages:
# DRAM:      https://github.com/WrightonLabCSU/DRAM
# METABOLIC: https://github.com/AnantharamanLab/METABOLIC

# Required databases (download separately):
# ├── Trimmomatic adapters    — bundled with Trimmomatic
# ├── DRAM databases          — DRAM-setup.py prepare_databases
# ├── GTDBtk reference data  — https://gtdb.ecogenomic.org/downloads
# └── SILVA / NCBI-nr         — for DRAM annotation
```

---

## 🔗 Downstream Analysis

Annotated outputs feed directly into comparative and community analyses:

- **Pan-genome analysis** — BPGA (core/accessory/unique gene families)
- **Species boundary testing** — ANI via EzBioCloud · DDH via GGDC 2.1
- **Phylogenetic visualization** — iTOL (upload GTDBtk output tree)
- **Metabolic heatmaps** — DRAM `product.html` interactive viewer

---

## 📄 Citation

> Jayasuriya D. et al. (in prep). Genome-resolved microbial community analysis. Clemson University.

If you use this pipeline, please also cite the individual tools: FastQC, Trimmomatic (Bolger et al. 2014), SPAdes (Bankevich et al. 2012), QUAST (Gurevich et al. 2013), Prokka (Seemann 2014), DRAM (Shaffer et al. 2020), GTDBtk (Chaumeil et al. 2019).

---

## 📫 Contact

**Dinu Jayasuriya** · PhD Candidate · Clemson University
🌐 [dinujayasuriya.github.io](https://dinujayasuriya.github.io) · 📚 [Google Scholar](https://scholar.google.com/citations?hl=en&user=IePuozkAAAAJ)
