process medaka {
    // run medaka with default parameters + bacteria flag
    label 'medaka'
    publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_file), path(assembly_file)

    output:
    tuple val(sample_id), path("${sample_id}.medaka.fasta"), emit: polished_assembly
    path("medaka"), emit: medaka_folder

    script:
        medaka_model_parameter = (params.medaka_model.trim() != '') ? '-m' : ''
        bacteria_flag = params.bacteria_flag_medaka ? '--bacteria' : ''
        """
        medaka_consensus -i ${fastq_file} -d ${assembly_file} -t ${task.cpus} ${medaka_model_parameter} ${params.medaka_model} ${bacteria_flag} -o medaka
        cp medaka/consensus.fasta ${sample_id}.medaka.fasta
        """
}