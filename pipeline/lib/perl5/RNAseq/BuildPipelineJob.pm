
package RNAseq::BuildPipelineJob;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::SetBDSenv;
use RNAseq::PrintBDScfg;

our @EXPORT = qw(Build_Pipeline_Job);
our @EXPORT_OK = qw(Build_Pipeline_Job);

## ---------------------------------------

sub Build_Pipeline_Job
{
  my ($sample_list, $config_list, $proj_dir, $project, $platform, $scheduler, $retry, $job_script, $log_flag, $bds_cfg, $bds_cfg_proj, $pipeline_script) = @_;

  my @samples = sort keys %{$sample_list};
  my @aligners = Add_Values($config_list->{"pipeline"}->{"flags"}, "aligners");
  my @callers = Add_Values($config_list->{"pipeline"}->{"flags"}, "callers");
  my @lines = Set_BDS_env($job_script);
  # my $pipeline_script = "Run_RNAseq.bds";
  my $sm = "";
  my $pl = "";
  my $sd = "";
  my $log = "";
  my $samplefile = "$project.samplelist";
  my $header = "";
  my $retry_max = 10;
  my $sample_total_max = 5;
  # my $report_format = ' -reportHtml -reportYaml';
  my $report_format = '';

  ## decide job submission header
  # $header = Job_Header($header, $platform, $scheduler);
  if($platform eq "cluster") { $sd = "-s $scheduler"; }
  if($retry > $retry_max) { $retry = $retry_max; }
  if($log_flag) { $log = " -l"; }

  ## if sample total > sample_total_max, write sample ids into a file 
  if(@samples > $sample_total_max) {
    open(SM, ">", "$proj_dir/$samplefile") or die $!;
    print SM join("\n", @samples)."\n";
    close(SM);

    $sm = "-samplefile $proj_dir/$samplefile";
  }
  else {
    $sm = "-samples ".join(" ", @samples);
  }

  ## print job sumission file 
  $job_script = Print_Job($job_script, $bds_cfg_proj, \@aligners, \@callers, \@lines, $report_format, $retry, $log, $pl, $sd, $pipeline_script, $proj_dir, $project, $sm);

  ## print BDS configuration file for this project
  $bds_cfg_proj = Print_BDS_Cfg($bds_cfg, $proj_dir, $bds_cfg_proj);

  return $config_list;
}

sub Print_Job
{
  my ($job_script, $bds_cfg_proj, $aligners_ref, $callers_ref, $lines_ref, $report_format, $retry, $log, $pl, $sd, $pipeline_script, $proj_dir, $project, $sm) = @_;

  open(OUT, ">", $job_script) or die $!;

  print OUT "#!/bin/bash\n";
  print OUT "\n\n\n## set up environment\n";
  print OUT "\nnow=\$\(date +\"\%m-\%d-\%Y\_\%H:\%M:\%S\"\)\n";
  print OUT "\n".join("\n", @$lines_ref)."\n";
  print OUT "\n## submit job \n";
  print OUT "\nbds -c $proj_dir/$bds_cfg_proj $report_format -y $retry $log $pl $sd $pipeline_script -aligners ".join(" ", @$aligners_ref)." -callers ".join(" ", @$callers_ref)." -projdir $proj_dir -project $project $sm > Run_RNAseq.$project.\$now.log.out 2> Run_RNAseq.$project.\$now.log.err\n";

  close(OUT);

  return $job_script;
}

sub Add_Values
{
  my ($hash_ref, $key) = @_;

  my @values;

  if(exists $hash_ref->{$key}) {
    foreach my $aln (sort keys %{$hash_ref->{$key}}) {
      if($hash_ref->{$key}->{$aln} == 1) {
        $aln =~ s/^run_//;
        push(@values, $aln);
      }
    }
  }

  return @values;
}

sub Job_Header
{
  my ($header, $platform, $scheduler) = @_;

  if($platform eq "local") {}
  elsif($platform eq "ssh") {}
  elsif($platform eq "cluster") {
    if($scheduler eq "moab") {}
    elsif($scheduler eq "pbs") {
      $header = "\n#PBS -l nodes=1:ppn=1\n";
      $header .= "#PBS -l mem=2gb\n";
      $header .= "#PBS -l walltime=48:00:00\n";
      $header .= "#PBS -j oe\n";
    }
    elsif($scheduler eq "sge") {
    }    
  }

  return $header;
}

## ---------------------------------------

1;

