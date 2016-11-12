

## build pipeline scripts 

now=$(date +"%m-%d-%Y_%H:%M:%S")
export PATH=/home/ubuntu/software/tree-1.7.0:$PATH
export PATH=/home/ubuntu/.bds:$PATH

## script 
# BuildRNAseqExe=../Build_RNAseq.pl
BuildRNAseqExe=../Build_RNAseq.pl
SubmitRNAseqExe=Submit_RNAseq.DLBC.sh
RunRNAseqExe=../Run_RNAseq.bds


## project info 
project=DLBC
metadata=DLBC.metadata.txt
config=DLBC.pipeline.yaml
projdir=$PWD/myProject

## options
threads=2
mapq=0
force="--force"
tree="--tree tree"

## bds 
platform="--local"
scheduler=""
bdscfg=""
retry=0
# log="--log" ## Log all tasks (do not delete tmp files).
log=''

## command 
echo "START" `date`
echo "START" `date` " Running $BuildRNAseqExe "
perl $BuildRNAseqExe \
	--project $project \
	--metadata $metadata \
	--config $config \
	--projdir $projdir \
	--threads $threads \
	--mapq $mapq \
	--retry $retry \
	--pipeline $RunRNAseqExe \
	$force \
	$tree \
	$platform \
	$scheduler \
	$bdscfg \
	$log \
	>& Build_RNAseq.$project.$now.log

## submit pipeline master script
echo "START" `date` " Running $SubmitRNAseqExe "
sh $SubmitRNAseqExe

echo "END" `date`
