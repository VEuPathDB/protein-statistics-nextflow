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
  tabfiles.collectFile(name: params.outputFileName, storeDir: params.outputDir)
}

process findStats {
  container = 'bioperl/bioperl:stable'

input:
    path subsetFasta

  output:
    path 'stats_subset.tab'

  script:
  """
  calcStats --fastaFile $subsetFasta \
    --outFile stats_subset.tab
  """
}
