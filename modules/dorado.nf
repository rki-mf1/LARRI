process dorado_basecall{
    // run only dorado basecall without dorado demux (the folder has been previously demux)

    if (params.run_dorado_with_gpu) {
	    if (workflow.profile.contains('slurm')) {
		clusterOptions = '--gpus=1 --time=06:00:00'
	    }
            if (workflow.profile.contains('docker')) {
                containerOptions '--gpus all'
            }
            else if (workflow.profile.contains('singularity')) {
                containerOptions '--nv'
            }
        else {containerOptions '--gpus all'}
    }

    publishDir "${params.outdir}/${path_pod5.simpleName}", mode: 'copy'
    
    input:
    path(path_pod5)

    output:
    path("${path_pod5.simpleName}.bam")

    script:
    """
    mkdir -p ${projectDir}/dorado_models 
    dorado basecaller sup \
        --models-directory ${projectDir}/dorado_models \
        ${path_pod5} > ${path_pod5.simpleName}.bam
    """
}



