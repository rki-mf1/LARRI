#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// terminal prints
println " "
println "\u001B[32mProfile: $workflow.profile\033[0m"
println " "
println "\033[2mCurrent User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "Starting time: $nextflow.timestamp"
println "Workdir location:"
println "  $workflow.workDir\u001B[0m"
println " "

// error codes
if (params.profile) { exit 1, "--profile is WRONG use -profile" }
if ( !workflow.revision ) { 
  println "\033[0;33mWARNING: It is recommended to use a stable relese version via -r." 
  println "Use 'nextflow info valegale/ONT_methylation' to check for available release versions.\033[0m\n"
}
// help
if (params.help) { exit 0, helpMSG() }

