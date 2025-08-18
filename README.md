# LARRI - Long-reads Assembly Reconstruction and Refinement pIpeline

![](https://img.shields.io/github/v/release/rki-mf1/LARRI)
![](https://img.shields.io/badge/nextflow-22.01.0-brightgreen)
![](https://img.shields.io/badge/uses-Docker-blue.svg)
![](https://img.shields.io/badge/uses-Singularity-yellow.svg)
![](https://img.shields.io/badge/licence-GPL--3.0-lightgrey.svg)


This pipeline provides a comprehensive workflow for assembling long reads, supporting input files in FASTQ, BAM, or POD5 formats.

⚠ Note: The pipeline processes only one input type at a time.

For POD5 files, it uses [**Dorado**](https://github.com/nanoporetech/dorado) to basecall.

![Alt text](images/LARRI_workflow.png)

## Input
