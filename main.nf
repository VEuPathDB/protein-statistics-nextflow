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
  statsFiles = findStats(seqs)
  statsFiles.tab.collectFile(name: params.outputFileName, storeDir: params.outputDir)

  indexed = bedgraph2bigwig(statsFiles.bed.collectFile(name: "merged.bed"), statsFiles.proteinSizes.collectFile(), params.hydropathyOutputFileName)


}

process findStats {
  container = 'bioperl/bioperl:stable'

  input:
  path subsetFasta

  output:
  path 'stats_subset.tab', emit: tab
  path 'hydropathy.bed', emit: bed
  path 'proteinSizes', emit: proteinSizes

  script:
  """
  calcStats --fastaFile $subsetFasta \
    --outFile stats_subset.tab \
    --hydropathyOutput hydropathy.bed \
    --proteinSizesOutput proteinSizes
  """
}

process bedgraph2bigwig {
  container 'quay.io/biocontainers/ucsc-bedgraphtobigwig:469--h9b8f530_0'

  publishDir params.outputDir, mode: 'copy'

  input:
  path bed
  path sizes
  val outputFile

  output:
  path outputFile

  script:
  """
  sort -k1,1 -k2,2n $bed > sorted_input.bedgraph

  bedGraphToBigWig sorted_input.bedgraph $sizes $outputFile
  """

}
