process flye {
    // run flye with default parameters 
    label 'flye'
    publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_file)

    output:
    tuple val(sample_id), path("${sample_id}.flye_assembly.fasta"), emit: assembly
    path("flye_assembly"), emit: flye_folder

    script:
    meta = params.flye_meta ? '--meta' : ''
    genome_size = params.flye_meta ? '' : "-g ${params.genome_size_mb}m"
        """
        flye --nano-hq ${fastq_file} -t ${task.cpus} ${meta} ${genome_size} -o flye_assembly
        cp flye_assembly/assembly.fasta ${sample_id}.flye_assembly.fasta
        """
}