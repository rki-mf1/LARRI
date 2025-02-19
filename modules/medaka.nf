process medaka {
    // run medaka with default parameters + bacteria flag
    label 'medaka'
    publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_file), path(assembly_file)

    output:
    tuple val(sample_id), path("medaka.fasta)"), emit: polished_assembly
    path("medaka"), emit: medaka_folder

    script:
    """
    medaka_consensus -i ${fastq_file} -d ${assembly_file} -t ${task.cpus} --bacteria -m ${params.medaka_model} -o medaka
    cp medaka/consensus.fasta medaka.fasta
    """
}