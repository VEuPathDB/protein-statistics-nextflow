#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//--------------------------------------------------------------------------
// Param Checking
//--------------------------------------------------------------------------

if(!params.fastaSubsetSize) {
  throw new Exception("Missing params.fastaSubsetSize")
}

if(params.inputFilePath) {
  seqs = Channel.fromPath( params.inputFilePath )
           .splitFasta( by:params.fastaSubsetSize, file:true  )
}
else {
  throw new Exception("Missing params.inputFilePath")
}

//--------------------------------------------------------------------------
// Main Workflow
//--------------------------------------------------------------------------

workflow {
  tabfiles = findStats(seqs)
  catFiles(tabfiles.collectFile(), params.outputFileName)
}

process findStats {
  container = 'bioperl/bioperl:stable'

input:
    path subsetFasta

  output:
    path 'stats_subset.tab'

  script:
  """
  calcStats --dataset $subsetFasta \
    --outFile stats_subset.tab
  """
}

process catFiles {
  container = 'bioperl/bioperl:stable'

  publishDir params.outputDir, mode: 'copy'

  input:
    path tab
    val outputFileName

  output:
    path 'proteinStats.tab'

  script:
  """
  cat $tab >> $outputFileName
  """
}

