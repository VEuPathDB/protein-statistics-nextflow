# protein-statistics-nextflow

Nextflow pipeline that computes sequence-derived statistics for a set of protein sequences.

## Overview

This pipeline is part of VEuPathDB's genomic data workflows. Given a FASTA file of
protein sequences, it computes, per protein:

- isoelectric point (pI)
- minimum and maximum molecular weight
- per-residue hydropathy (Kyte-Doolittle scale)
- protein length

The input FASTA is split into subsets and processed in parallel by a BioPerl-based
script (`bin/calcStats`). Per-residue hydropathy scores are written as BED intervals,
merged across all subsets, and converted into a BigWig track with UCSC's
`bedGraphToBigWig`, so the hydropathy profile of a proteome can be loaded directly
into a genome/protein browser alongside the molecular weight and pI summary statistics.

## Requirements

- [Nextflow](https://www.nextflow.io/) (DSL2)
- A container engine: Docker (default) or Singularity/Apptainer

Containers used:
- `bioperl/bioperl:stable` — sequence statistics calculation
- `quay.io/biocontainers/ucsc-bedgraphtobigwig` — BigWig conversion

## Usage

```
nextflow run VEuPathDB/protein-statistics-nextflow -r main -resume \
  --inputFilePath /path/to/proteins.fa \
  --outputDir /path/to/output \
  -C conf/docker.config
```

To run under Singularity/Apptainer (e.g. on an HPC cluster via LSF), use the
corresponding config instead:

```
nextflow run VEuPathDB/protein-statistics-nextflow -r main -resume \
  --inputFilePath /path/to/proteins.fa \
  --outputDir /path/to/output \
  -C conf/lsf.config
```

There is a single, unnamed entry point — no `-entry` flag is needed.

## Key Parameters

| Parameter | Default | Description |
|---|---|---|
| `inputFilePath` | `data/input.fa` | FASTA file of protein sequences to analyze |
| `fastaSubsetSize` | `500` | Number of sequences per subset chunk processed in each parallel task |
| `outputFileName` | `proteinStats.tab` | Name of the tab-delimited statistics output file |
| `hydropathyOutputFileName` | `hydropathy.bw` | Name of the BigWig hydropathy track |
| `outputDir` | `$launchDir/output` | Directory where output files are published |

## Output

Written to `outputDir`:

- **`proteinStats.tab`** — tab-delimited file with one row per protein: protein ID,
  isoelectric point, minimum molecular weight, maximum molecular weight.
- **`hydropathy.bw`** — BigWig track of per-residue Kyte-Doolittle hydropathy scores
  across all input proteins, keyed by protein ID and residue position.
