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


// CHECK INPUT

// Ensure either BAM, fastq or pod5 is specified
if (!params.bam && !params.pod5 && !params.fastq) { 
    error """\033[0;31mERROR:\033[0m You must specify (only) one of the following options: 
    a BAM file using the --bam option, 
    a pod5 file/folder using the --pod5 option, 
    or a FASTQ file using the --fastq option.
    
    \033[0;33mUsage examples:\033[0m
    nextflow LARRI.nf --bam '*.bam' 
    nextflow LARRI.nf --fastq '*.fastq.gz'
    nextflow LARRI.nf --pod5 'file.pod5'  # For a single pod5 file
    nextflow LARRI.nf --pod5 '/path/to/folder/'  # For a folder containing pod5 files
    """
    exit 1
} 
// Ensure exactly one input (BAM, fastq or pod5) is specified
else if ((params.bam && params.pod5) || (params.bam && params.fastq) || (params.pod5 && params.fastq)) {
    error """\033[0;31mERROR:\033[0m You cannot specify more than one of the following options at the same time: 
    --bam, --pod5, or --fastq. Please provide only one.
    
    \033[0;33mUsage examples:\033[0m
    nextflow LARRI.nf --bam '*.bam' 
    nextflow LARRI.nf --pod5 '*.pod5'
    nextflow LARRI.nf --fastq '*.fastq.gz'
    """
    exit 1
} 

else if ((params.bam || params.fastq) && params.basecalling) {
	println """\033[0;33mWARNING The parameter --basecalling was selected, but no pod5 file/folder was provided.
	"""
}

/*********************** 
* MAIN WORKFLOW
************************/

include { bam2fastq; unzip } from './modules/samtools.nf'
include { dorado_basecaller; dorado_demux; transform_csv } from './modules/dorado.nf'
include { assembly_wf } from './workflows/assembly.nf' 

workflow {

	// workflow with fastq input (only assembly)
	if (params.fastq) {
		if (params.fastq.endsWith('.fastq.gz')){
			fastq_input_ch = Channel.fromPath(params.fastq, checkIfExists: true)
			fastq_files = unzip(fastq_input_ch).map {file -> tuple(file.baseName, file)}
		} else if (params.fastq.endsWith('.fastq')){
			fastq_files = Channel.fromPath(params.fastq, checkIfExists: true)
				.map {file -> tuple(file.baseName, file)}
		} else {
            error """\033[0;31mERROR:\033[0m The specified FASTQ file must have a .fastq or .fastq.gz extension.
            
            \033[0;33mUsage examples:\033[0;33m
            nextflow LARRI.nf --fastq 'file.fastq' 
            nextflow LARRI.nf --fastq 'file.fastq.gz'
            """
            exit 1
		}
		assembly_wf(fastq_files)
	}

    // workflow with BAM input (only assembly) 
	else if (params.bam) {
		if (params.bam.endsWith('.bam')){
			bam_input_ch = Channel
				.fromPath(params.bam, checkIfExists: true)
				.map {file -> tuple(file.baseName, file)}

			fastq_files = bam2fastq(bam_input_ch)
		} else {
            error """\033[0;31mERROR:\033[0m The specified BAM file must have a .bam extension.
            
            \033[0;33mUsage examples:\033[0;33m
            nextflow LARRI.nf --bam 'file.bam' 
            """
            exit 1
		}
		assembly_wf(fastq_files)
	} 


	// worfklow with pod5 input (dorado basecalling)
 	else if (params.pod5) {
		pod5_input_ch = Channel.fromPath(params.pod5, checkIfExists: true)
			
		// workflow with dorado basecalling and dorado demux
		if (params.demux) {
			// create dorado sample sheet if the sample sheet is provided
			sample_sheet_path = params.sample_sheet ? file(params.sample_sheet) : false
			if (sample_sheet_path && !sample_sheet_path.exists()) {exit 1, "ERROR: Sample sheet file '${params.sample_sheet}' not found"}
			dorado_sheet = sample_sheet_path ? transform_csv(sample_sheet_path) : ""

			//basecalling + demux
			basecalled_bam = dorado_basecaller(pod5_input_ch)
			bam_files_output = dorado_demux(basecalled_bam, dorado_sheet).flatten()
			bam_files = bam_files_output.filter {file -> file.simpleName != "unclassified"}
				.map {file -> tuple(file.baseName, file)}
		}
		
		// workflow with only dorado basecaller 
		else {
			//basecalling
			bam_folder = dorado_basecaller(pod5_input_ch)
			bam_files = bam_folder.map {file -> tuple(file.baseName, file)}
		}

		if (!params.basecalling){
			//running the assembly unless the user specified to only basecall 
			fastq_files = bam2fastq(bam_files)
			assembly_wf(fastq_files)
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
	nextflow run rki-mf1/LARRI --bam '*.bam' 
	nextflow run rki-mf1/LARRI --fastq '*.fastq.gz' 
	nextflow run rki-mf1/LARRI --pod5 file.pod5                     # For a single pod5 file
	nextflow run rki-mf1/LARRI --pod5 /path/to/folder/              # For a folder containing pod5 files
	nextflow run rki-mf1/LARRI --pod5 file.pod5 --basecalling       # Run only basecalling

	${c_yellow}Input${c_reset}
	${c_green} --bam ${c_reset}      '*.bam'                            -> BAM file to be assembled
	${c_green} --fastq ${c_reset}    '*.fastq'                          -> FASTQ file to be assembled
	${c_green} --pod5 ${c_reset}     file.pod5 or /path/to/folder/    	-> Pod5 file or folder containing pod5 files
 

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