process filtlong {
    // filter small size reads 
    label 'filtlong'
    //publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_file)

    output:
    tuple val(sample_id), path("${sample_id}.fastq.gz") 

    script:
        """
        filtlong --min_length ${params.min_length_filtlong} ${fastq_file} | gzip > ${sample_id}.fastq.gz
        """
}