# Palmetto HPC Guide (Clemson University)

This guide covers Palmetto-specific setup for the WGS pipeline. If you are on a different cluster, refer to your HPC's documentation and adapt the PBS or SLURM scripts accordingly.

---

## Connecting to Palmetto

**Linux / macOS:**
```bash
ssh <your_username>@login.palmetto.clemson.edu
```

**Windows:** Download and install [MobaXterm](https://mobaxterm.mobatek.net/download-home-edition.html), then connect to `login.palmetto.clemson.edu` on port 22 using SSH.

**Web browser (Open OnDemand):**
https://openod.palmetto.clemson.edu/pun/sys/dashboard

After login you will see:
```
(base) [username@login001 ~]$
```

---

## Useful Palmetto Commands

```bash
whatsfree          # see which compute nodes are currently free
checkquota         # check your home directory disk quota
checkzfs           # check ZFS storage quota (owners only)
qstat -xf <jobid>  # check status of a submitted job
qpeek <jobid>      # peek at stdout/stderr of a running job
freeres            # see free cores and RAM on nodes
module avail       # list all available software modules
module avail <tool> # check if a specific tool is available
```

---

## Storage on Palmetto

| Location | Purpose | Notes |
|----------|---------|-------|
| `/home/<username>/` | Scripts, config, small files | Quota-limited (~100 GB) |
| `/scratch1/<username>/` | Working directory for jobs | No quota, purged periodically |
| `/zfs/camplab/` | Lab shared storage | Large datasets, databases |

Store your raw reads and databases in `/zfs/camplab/`. Run jobs from `/scratch1/<username>/`. Keep only scripts and config files in `/home/`.

---

## Loading Modules on Palmetto

Instead of conda, Palmetto provides many tools as pre-installed modules:

```bash
module avail fastqc           # check available versions
module load fastqc/0.11.9     # load specific version
module list                   # see currently loaded modules
module purge                  # unload all modules
```

Tools not available as modules (e.g. DRAM, GTDBtk, METABOLIC) can be installed in conda environments in your home or scratch directory:

```bash
conda create -n wgs-pipeline -c bioconda -c conda-forge fastqc trimmomatic spades quast prokka diamond
conda activate wgs-pipeline
```

---

## Running an Interactive Job

Use interactive jobs for testing and short tasks. Do not run computationally heavy steps on the login node.

```bash
qsub -I -q bigmem -l select=1:ncpus=8:mem=32gb,walltime=2:00:00
```

> Interactive jobs terminate if you close your terminal or lose connection. Use batch jobs (see below) for anything that takes more than a few minutes.

---

## Submitting Batch Jobs on Palmetto

Batch jobs run in the background and are not affected by closing your terminal. Use the PBS scripts in the `pbs/` folder:

```bash
# Edit the header of the .pbs file first, then submit:
qsub pbs/01_fastqc.pbs

# Check job status:
qstat -xf <jobid>

# Cancel a job:
qdel <jobid>
```

### Standard PBS header for Palmetto

```bash
#!/bin/bash
#PBS -N job_name
#PBS -l select=1:ncpus=16:mem=128gb,walltime=12:00:00
#PBS -q bigmem
#PBS -j oe                      # merge stdout and stderr
#PBS -m abe                     # email on abort, begin, end
#PBS -M your_email@clemson.edu
```

**Queue options on Palmetto:**
- `bigmem` — high-memory nodes (recommended for SPAdes, GTDBtk, DRAM)
- `workq` — standard nodes (suitable for FastQC, Trimmomatic, DIAMOND)

Always set `cd /home/<username>/WGS-Pipeline` at the start of your PBS script to ensure relative paths resolve correctly.

---

## Recommended Resource Allocations (Palmetto)

| Step | Queue | CPUs | RAM | Walltime |
|------|-------|------|-----|---------|
| FastQC | workq | 8 | 32 GB | 4 h |
| Trimmomatic | workq | 16 | 64 GB | 8 h |
| metaSPAdes | bigmem | 32 | 750 GB | 48 h |
| MetaQUAST | workq | 16 | 64 GB | 6 h |
| Prokka | bigmem | 16 | 128 GB | 12 h |
| DRAM | bigmem | 32 | 256 GB | 48 h |
| METABOLIC | bigmem | 32 | 256 GB | 24 h |
| GTDBtk | bigmem | 40 | 512 GB | 72 h |
| DIAMOND | bigmem | 32 | 128 GB | 12 h |

---

## Medaka Polishing with GPU (Nanopore only)

If running the Nanopore version of the pipeline, Medaka benefits from a GPU node:

```bash
qsub -I -q bigmem -l select=1:ncpus=16:mem=128gb:ngpus=1,walltime=24:00:00
module load cuda/11.8
conda activate medaka-env
```

Check GPU node availability with `whatsfree` and filter for nodes listing `gpu`.

---

## Getting Help at Clemson

- Palmetto documentation: https://docs.rcd.clemson.edu/palmetto/
- Open OnDemand dashboard: https://openod.palmetto.clemson.edu
- Clemson RCD support: ithelp@clemson.edu
