#!/bin/bash

datadir='/home/ubuntu/data/rnaseq/fullset'
indir="$datadir/fastqc $datadir/picard $datadir/rseqc"
outdir="$datadir/multiqc"

# run
multiqc="/home/ubuntu/anaconda2/envs/multiqc/bin/multiqc"
$multiqc -d --title "AMIA 2016 Workshop RNAseq MultiQC Report" -f -o $outdir $indir
