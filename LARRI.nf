#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// terminal prints
println " "
println "\u001B[32mProfile: $workflow.profile\033[0m"
println " "
println "\033[2mCurrent User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "Starting time: $nextflow.timestamp"
println "Workdir location:"
println "  $workflow.workDir\u001B[0m"
println " "

// error codes
if (params.profile) { exit 1, "--profile is WRONG use -profile" }
// help
if (params.help) { exit 0, helpMSG() }


include { bam2fastq } from './modules/samtools.nf'
include { filtlong } from './modules/filtlong.nf'
include { rasusa } from './modules/rasusa.nf'
include { flye } from './modules/flye.nf'
include { medaka } from './modules/medaka.nf'
include { dorado_basecaller; dorado_demux; transform_csv } from './modules/dorado.nf'

// INPUT FILES

// Ensure either BAM or pod5 is specified, but not both
if (!params.bam && !params.pod5) { 
	error """\033[0;31mERROR:\033[0m You must specify either a BAM file/folder using the --bam option OR a pod5 file/folder using the --pod5 option.
	
	\033[0;33mUsage example:\033[0m
	nextflow LARRI.nf --bam '*.bam' 
	nextflow LARRI.nf --pod5 '*.pod5'
	"""
	exit 1
} else if (params.bam && params.pod5) {
	error """\033[0;31mERROR:\033[0m You cannot specify both --bam and --pod5 at the same time. Please provide only one.
	
	\033[0;33mUsage example:\033[0m
	nextflow LARRI.nf --bam '*.bam' 
	nextflow LARRI.nf --pod5 '*.pod5'
	"""
	exit 1
} else if (params.bam) { 
	bam_input_ch = Channel
		.fromPath(params.bam, checkIfExists: true)
		.map { file -> tuple(file.baseName, file) }
} else { 
	pod5_input_ch = Channel
		.fromPath(params.pod5, checkIfExists: true)
	if (params.demux) {
		sample_sheet_path = params.sample_sheet ? file(params.sample_sheet) : false

		if (sample_sheet_path && !sample_sheet_path.exists()) {
			exit 1, "ERROR: Sample sheet file '${params.sample_sheet}' not found"
		}

	}
}


/*********************** 
* MAIN WORKFLOW
************************/

workflow {

  // workflow with BAM input (only assembly) 
	if (params.bam) {
		fastq_files = bam2fastq(bam_input_ch)
		fastq_filtered_files = filtlong(fastq_files)
		fastq_filtered_subsampled_files = rasusa(fastq_filtered_files)
		fasta_files = flye(fastq_filtered_subsampled_files).assembly
		input_medaka = fastq_filtered_subsampled_files.join(fasta_files)
		polished_files = medaka(input_medaka).polished_assembly 
	} 

	// worfklow with pod5 input (dorado basecalling)
 	else if (params.pod5) {
		
		if (params.demux) {
			basecalled_bam = dorado_basecaller(pod5_input_ch)
			dorado_sheet = sample_sheet_path ? transform_csv(sample_sheet_path) : ""
			bam_folder = dorado_demux(basecalled_bam, dorado_sheet)
		} 
		
		else {
			bam_folder = dorado_basecaller(pod5_input_ch)
		}

  }

}


// --help
def helpMSG() {
	c_green = "\033[0;32m";
	c_reset = "\033[0m";
	c_yellow = "\033[0;33m";
	c_blue = "\033[0;34m";
	c_red = "\033[0;31m";
	c_dim = "\033[2m";
	log.info """
	____________________________________________________________________________________________

	LARRI - Long-reads Assembly Reconstruction and Refinement pIpeline

	${c_yellow}Usage example:${c_reset}
	nextflow LARRI.nf  --bam '*.bam' 

	${c_yellow}Input${c_reset}
	${c_green} --bam ${c_reset}             '*.bam'         -> BAM file to be assembled
 
	${c_dim}  ..change above input to csv:${c_reset} ${c_green}--list ${c_reset}

	${c_yellow}General Options:${c_reset}
	--cores             Max cores per process for local use [default: $params.cores]
	--max_cores         Max cores (in total) for local use [default: $params.max_cores]
	--memory            Max memory for local use [default: $params.memory]
	--outdir            Name of the result folder [default: $params.outdir]

	${c_dim}Nextflow options:
	-with-report rep.html    cpu / ram usage (may cause errors)
	-with-dag chart.html     generates a flowchart for the process tree
	-with-timeline time.html timeline (may cause errors)
	-resume                  resume a previous calculation w/o recalculating everything (needs the same run command and work dir!)

	${c_yellow}Caching:${c_reset}
	--singularityCacheDir   Location for storing the Singularity images [default: $params.singularityCacheDir]
	-w                      Working directory for all intermediate results [default: work] 

	${c_yellow}Execution/Engine profiles:${c_reset}
	The pipeline supports profiles to run via different ${c_green}Executers${c_reset} and ${c_blue}Engines${c_reset} e.g.: -profile ${c_green}local${c_reset},${c_blue}docker${c_reset}
	
	${c_blue}Engines${c_reset} (choose one):
	  docker
	
	Per default: -profile local,docker is executed (-profile standard).
	
	${c_reset}
	""".stripIndent()
}