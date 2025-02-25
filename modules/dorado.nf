process dorado_basecall{
    // run only dorado basecall without dorado demux (the folder has been previously demux)
    label 'dorado'
    publishDir "${params.outdir}/${sample_id}", mode: 'copy'
    containerOptions = '--gpus=1'
    
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

