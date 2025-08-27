process dorado_basecaller {
    label 'dorado'
    if (params.run_dorado_with_gpu) {
	    if (workflow.profile.contains('slurm')) {
		clusterOptions = '--gpus=1 --time=06:00:00'
	    }
        if (workflow.profile.contains('docker')) {
                containerOptions '--gpus all'
        } 
        else if (workflow.profile.contains('singularity')) {
                containerOptions '--nv'
        }
        else if (!workflow.profile.contains('slurm')) { 
            containerOptions = '--gpus all'
        }
    }

    publishDir "${params.outdir}/${path_pod5.simpleName}", mode: 'copy'

    input:
    path(path_pod5)

    output:
    path("${path_pod5.simpleName}.bam")

    script:
    trim_adapters = params.demux ? '--trim primers' : ''
    modifications = params.modifications ? ',6mA,4mC_5mC' : ''
        """
        mkdir -p ${projectDir}/${params.dorado_models_folder}
        dorado basecaller sup${modifications} ${trim_adapters} \
            --models-directory ${projectDir}/${params.dorado_models_folder} \
            ${path_pod5} > ${path_pod5.simpleName}.bam
        """
}

process dorado_demux {    
    label 'dorado'
    publishDir "${params.outdir}/", mode: 'copy'

    input:
    path(path_basecalling)
    val(dorado_sheet)

    output:
    path("${path_basecalling.simpleName}_results_demux/*.bam")

    script:
        if (dorado_sheet) {
        """
        dorado demux --kit-name ${params.dorado_kit} --barcode-both-ends \
            --sample-sheet ${dorado_sheet} \
            --output-dir ${path_basecalling.simpleName}_results_demux ${path_basecalling}

        for file in "${path_basecalling.simpleName}_results_demux"/*.bam; do
            new_file=\$(basename "\$file" | sed 's/^[^_]*_//')
            mv "\$file" "${path_basecalling.simpleName}_results_demux/\$new_file"
        done
        """
        } else {
        """
        dorado demux --kit-name ${params.dorado_kit} --barcode-both-ends \
            --output-dir ${path_basecalling.simpleName}_results_demux ${path_basecalling}

        for file in "${path_basecalling.simpleName}_results_demux"/*.bam; do
            new_file=\$(basename "\$file" | sed 's/.*_//')
            mv "\$file" "${path_basecalling.simpleName}_results_demux/\$new_file"
        done
        """
        }

}

process transform_csv {
    input:
    path(user_sheet)

    output:
    path("input_dorado_sheet.csv"), emit: dorado_sheet

    script:
    """
    awk 'BEGIN {FS=OFS=","} NR==1 {print \$1, \$2, \"experiment_id\", \"flow_cell_id\", \"kit\"} NR>1 {print \$1, \$2, \"\", \"\", \"\"}' ${user_sheet} > input_dorado_sheet.csv
    """
}

