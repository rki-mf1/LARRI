include { filtlong } from './../modules/filtlong.nf'
include { rasusa } from './../modules/rasusa.nf'
include { flye } from './../modules/flye.nf'
include { medaka } from './../modules/medaka.nf'

workflow assembly_wf {
    take: 
        fastq 

    main: 
        fastq_filtered_files = filtlong(fastq)
		fastq_filtered_subsampled_files = rasusa(fastq_filtered_files)
		fasta_files = flye(fastq_filtered_subsampled_files).assembly
		input_medaka = fastq_filtered_subsampled_files.join(fasta_files)
		polished_files = medaka(input_medaka).polished_assembly        

    emit: 
        polished_files

}