process rasusa {
    // subsample reads to a specific deepth of coverage
    label 'rasusa'
    //publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_file)

    output:
    tuple val(sample_id), path("${sample_id}_subsampled.fastq.gz") 

    script:
        """
        rasusa --version
        rasusa -h
        rasusa reads --coverage ${params.coverage_rasusa} --genome-size ${params.genome_size_mb}mB ${fastq_file} -o ${sample_id}_subsampled.fastq.gz
        """
}