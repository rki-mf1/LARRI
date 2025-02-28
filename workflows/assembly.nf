include { filtlong } from './../modules/filtlong.nf'
include { rasusa } from './../modules/rasusa.nf'
include { flye } from './../modules/flye.nf'
include { medaka } from './../modules/medaka.nf'

workflow assembly_wf {
    take: 
        fastq 

    main: 
        def input = fastq

        if (params.run_filtlong) {
            input = filtlong(input)
        }
        if (params.run_rasusa) {
            input = rasusa(input)
        }
        
        fasta_files = flye(input).assembly

		input_medaka = fastq.join(fasta_files)
		polished_files = medaka(input_medaka).polished_assembly        

    emit: 
        polished_files
}