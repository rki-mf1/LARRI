process flye {
    // run flye with default parameters 
    label 'flye'
    publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_file)

    output:
    tuple val(sample_id), path("assembly.fasta"), emit: assembly
    path("flye_assembly"), emit: flye_folder

    script:
    """
    flye --nano-hq ${fastq_file} -t ${task.cpus} -g ${params.genome_size_mb}m -o flye_assembly
    cp flye_assembly/assembly.fasta assembly.fasta
    """
}