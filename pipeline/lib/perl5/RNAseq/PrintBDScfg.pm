
package RNAseq::PrintBDScfg;

use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(Print_BDS_Cfg);
our @EXPORT_OK = qw(Print_BDS_Cfg);

## ---------------------------------------

sub Print_BDS_Cfg
{
  my ($bds_cfg, $proj_dir, $bds_cfg_proj) = @_;

  # print "IN = $bds_cfg\nOUT = $bds_cfg_proj\n";

  if($bds_cfg =~ m/\S+/) {
    # print "BDS config file is supplied from command line.\n";
    # print "Copying this file to project directory.\n";
    if(-f $bds_cfg) { `cp -p $bds_cfg $proj_dir/$bds_cfg_proj`; }
    else {
      print STDERR "Print_BDS_Cfg: BDS config file does not exist. Copying $bds_cfg failed.\n";
    }
  }
  else {
    # print "BDS config file is not specified. Generating one in the project directory.\n";  
    $bds_cfg_proj = BDS_Cfg($proj_dir, $bds_cfg_proj);
  }

  # print "../Done!\n$bds_cfg_proj will be used for BDS configuration for this project.\n";

  return $bds_cfg_proj;
}

sub BDS_Cfg
{
  my ($dir, $filename) = @_;

  my $line = qq~

####--------------------------------------------------####
####                                                  ####
####         BigDataScript configuration file         ####
####                                                  ####
####             BDS documentation website            ####
####      http://pcingola.github.io/BigDataScript     ####
####                                                  ####
####--------------------------------------------------####

#---
# Mesos parameters
#---

#mesos.master = 127.0.0.1:5050

##---
## Default parameters
##---

## Default number of retries
retry = 0

## Wait time in between job submission (milli seconds)
waitAfterTaskRun = 1000

## Set task shell and sys shell env
taskShell = /bin/bash -e
sysShell = /bin/bash -e -c

## Default memory (-1 = unrestricted)
# mem = -1

## Default execution node (none)
# node = ""

## Add default queue name (if any)
# queue = ""

## Task timeout in seconds (default is one day)
# timeout = 86400

##---
## SGE parameters
##---

## Parallel environment in SGE (e.g. 'qsub -pe mpi 4')
## Custom CRI-openmp sge parallel environment added (allocation_rule \$pe_slots)
# sge.pe = orte
sge.pe = smp

## Parameter for requesting amount of memory in qsub (e.g. 'qsub -l mem 4G')
## Note on sge, mem_free is per slot!
sge.mem = mem_free

## Parameter for timeout in qsub (e.g. 'qsub -l h_rt 24:00:00')
sge.timeout = h_rt

~;

  open(OUT, ">", "$dir/$filename") or die $!;
  print OUT "$line\n";
  close(OUT);

  return $filename;
}


## ---------------------------------------

1;
