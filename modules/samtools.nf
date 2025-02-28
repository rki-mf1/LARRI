process bam2fastq {
    // converts the BAM file from Dorado to FASTQ format 
    label 'samtools'
    //publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(bam_file)

    output:
    tuple val(sample_id), path("${sample_id}.fastq") 

    script:
    """
    samtools bam2fq ${bam_file} > ${sample_id}.fastq
    """
}

process unzip {
    input:
    path fastq_compressed

    output:
    path "${fastq_compressed.baseName}" 
    script:
    """
    gunzip -c ${fastq_compressed} > ${fastq_compressed.baseName}
    """
}