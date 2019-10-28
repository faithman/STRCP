#!/usr/bin/env nextflow 

params.email = "yewangfaith@gmail.com"
params.bed = "/projects/b1059/projects/Ye/ch/bedfile/subbed/*.bed"

datasets = Channel
                .fromPath(params.bed)
                .map { file -> tuple(file.baseName, file) }

process hipstr {

  tag { name }

  publishDir "CH_STR", mode: 'copy'
  cpus 4
  memory '32 GB'

  input:
  set name, file(bed) from datasets

  output: 
  file "${name}.vcf.gz"
  file "${name}_str.viz.gz"
  file "${name}_log.txt"
  file "${name}_stutter_models.txt"

  """
  HipSTR --bam-files /projects/b1059/projects/Ye/ch/CH_STR/bamlistcopy.tsv \\
       --fasta /projects/b1059/projects/Ye/ch/genome/Chicken.GRCg6a.fa \\
       --regions ${bed} \\
       --str-vcf ${name}.vcf.gz \\
       --output-filters \\
       --log ${name}_log.txt \\
       --stutter-out ${name}_stutter_models.txt \\
       --viz-out ${name}_str.viz.gz
  """
}


workflow.onComplete {

    summary = """
    Pipeline execution summary
    ---------------------------
    Completed at: ${workflow.complete}
    Duration    : ${workflow.duration}
    Success     : ${workflow.success}
    workDir     : ${workflow.workDir}
    exit status : ${workflow.exitStatus}
    Error report: ${workflow.errorReport ?: '-'}
    """

    println summary


    // mail summary
    if (params.email) {
        ['mail', '-s', 'str-nf', params.email].execute() << summary
    }//


}
