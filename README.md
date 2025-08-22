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

## How to Run

To run **LARRI**, you must specify **exactly one input type**:  
- a **BAM** file using the `--bam` option  
- a **FASTQ** file using the `--fastq` option  
- a **pod5** file or folder using the `--pod5` option  

### Usage Examples

Run with a single BAM file:

```
nextflow run rki-mf1/LARRI -r 0.0.1 --bam 'sample.bam'
```

Run with multiple BAM files (using wildcard):

```
nextflow run rki-mf1/LARRI -r 0.0.1 --bam '*.bam'
```

Run with a single FASTQ file:

```
bash
nextflow run rki-mf1/LARRI -r 0.0.1 --fastq 'sample.fastq.gz'
```

Run with multiple FASTQ files (using wildcard):

```
nextflow run rki-mf1/LARRI -r 0.0.1 --fastq '*.fastq.gz'
```
Run with a single pod5 file:

```
nextflow run valegale/LARRI -r 0.0.1 --pod5 'file.pod5'
```

Run with a folder of pod5 files:

```
nextflow run valegale/LARRI -r 0.0.1 --pod5 '/path/to/folder/'
```

> **Important**:  
> - Only one of the options `--bam`, `--fastq`, or `--pod5` can be provided at a time.  
> - Multiple input files can only be used with `--bam` and `--fastq` (via wildcards).  
> - The `--pod5` option only supports a single file or a folder of files.  


## Running with Containers

Run using **Docker**:

```
nextflow run valegale/LARRI -r 0.0.1 --bam 'sample.bam' -profile docker
```
Run with **SLURM** and **conda** (currently not supported, but coming soon):
```
nextflow run valegale/LARRI -r 0.0.1 --bam 'sample.bam' -profile slurm,conda
```

Run with **SLURM** and **Singularity**:
```
nextflow run valegale/LARRI -r 0.0.1 --bam 'sample.bam' -profile slurm,singularity
```

# Dorado Basecalling

If pod5 files are provided as input, the pipeline will use **Dorado** to basecall the data.  

To also run [Dorado demultiplexing](https://github.com/nanoporetech/dorado?tab=readme-ov-file#barcode-classification), pass the `--demux` parameter. In this case:  
- The Dorado basecaller will **not trim the barcodes**.  
- The Dorado demux command will run immediately after basecalling.  

Optionally, a **tsv sample sheet** can be provided to specify which barcodes are of interest. The sample sheet is a simplified version of the one required by [Dorado](https://github.com/nanoporetech/dorado/blob/release-v1.1/documentation/SampleSheets.md) and has the following format:

| alias     | barcode   |
|-----------|-----------|
| species_1 | barcode13 |
| species_2 | barcode15 |
| species_3 | barcode16 |

Here, the `alias` column defines the user-selected sample names, which will be used by the pipeline to rename the barcodes.  
In the absence of a sample sheets, all barcodes will be assembled.
