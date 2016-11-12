
package RNAseq::GetOpt;

use strict;
use warnings;
use IO::Handle;
use Getopt::Long;
use FileHandle;
use File::Basename;
use Exporter qw(import);
use Cwd qw(abs_path);
use lib dirname(abs_path($0)).'/lib/perl5';

## options
use vars qw($opt_force);
use vars qw($opt_local);
use vars qw($opt_ssh);
use vars qw($opt_cluster);
use vars qw($opt_moab);
use vars qw($opt_pbs);
use vars qw($opt_sge);
use vars qw($opt_log);

our @EXPORT = qw(Get_Opt @aligners @callers $bds_cfg $bds_cfg_proj $command $config_file $config_list $job_script $metadata_file $platform $proj_dir $project $sample_list $scheduler $threads $tree_exe $tree_output $force_flag $log_flag $mapq_min $retry $pipeline_script);
our @EXPORT_OK = qw(Get_Opt);

## ---------------------------------------

## initialize 
our @aligners = qw(star);
our @callers = qw(featurecounts);
our $bds_cfg = "";
our $bds_cfg_proj = "";
our $command = "";
our $config_file = "";
our $config_list;
our $job_script = "";
our $metadata_file = "";
our $platform = "";
our $proj_dir = "./";
our $project = "myProject";
our $sample_list;
our $scheduler = "";
our $threads = 1;
our $tree_exe = "";
our $tree_output = "";
our $force_flag = 0;
our $log_flag = 0;
our $mapq_min = 0;
our $retry = 0;
our $pipeline_script = 'Run_RNAseq.bds';

sub Get_Opt
{
  my ($program, $menu) = @_;

  my $pl_count = 0;
  my $sd_count = 0;

  &GetOptions( 
    "p|project:s" => \$project,
    "m|metadata:s" => \$metadata_file,
    "c|config:s" => \$config_file,
    "d|projdir:s" => \$proj_dir,
    "t|threads:i" => \$threads,
    "q|mapq:i" => \$mapq_min,
    "y|retry:i" => \$retry,
    "tree:s" => \$tree_exe,
    "bdscfg:s" => \$bds_cfg,
    "pipeline:s" => \$pipeline_script,
    "force",
    "local",
    "ssh",
    "cluster",
    "moab",
    "pbs",
    "sge",
    "log"
  ) or die $!;

  ## assign values
  if($opt_force) { $force_flag = 1; }
  if($opt_local) { $platform = "local"; $pl_count++; }
  if($opt_ssh) { $platform = "ssh"; $pl_count++; }
  if($opt_cluster) { $platform = "cluster"; $pl_count++; }
  if($opt_moab) { $scheduler = "moab"; $sd_count++; }
  if($opt_pbs) { $scheduler = "pbs"; $sd_count++; }
  if($opt_sge) { $scheduler = "sge"; $sd_count++; } 
  if($opt_log) { $log_flag = 1; }
  $tree_output = "$project.tree.txt"; 
  $job_script = "Submit_RNAseq.$project.sh";
  $bds_cfg_proj = "$project.bds.cfg";

  ## sanity check
  if($metadata_file eq "" || $config_file eq "") { print STDERR "Input file missing! \n$menu\n"; exit(1); } 
  if($platform eq "") { 
    print STDERR "Warning! No platform specified. Pipeline will run -local.\n";
    $platform = "local"; 
  }
  if($platform eq "cluster" && $scheduler eq "") {
    print STDERR "Platform is cluster but Scheduler is empty. \n$menu\n"; exit(1); 
  }
  if($pl_count > 1) {
    print STDERR "Platform can only be specified once! Use one of the three options [-local -ssh -cluster].\n$menu\n";
    exit(1);
  }
  if($sd_count > 1) {
    print STDERR "Scheduler can only be specified once! Use one of the three options [-moab -pbs -sge].\n$menu\n";
    exit(1);
  }

  ## command
  $command = "$program --project $project --metadata $metadata_file --config $config_file --projdir $proj_dir --threads $threads --mapq $mapq_min";
  if($force_flag) { $command .= " --force"; }
  if($tree_exe) { $command .= " --tree $tree_exe"; }
  if($opt_local) { $command .= " --local"; }
  if($opt_ssh) { $command .= " --ssh"; }
  if($opt_cluster) { $command .= " --cluster"; }
  if($opt_moab) { $command .= " --moab"; }
  if($opt_pbs) { $command .= " --pbs"; }
  if($opt_sge) { $command .= " --sge"; } 
  if($log_flag) { $command .= " --log"; }
  $command .= " --retry $retry --bdscfg $bds_cfg --pipeline $pipeline_script";

  $proj_dir =~ s/\/$//;
  if ( ! -d $proj_dir) { mkdir $proj_dir; }

  ## print command and info 
  $command = Print_Cmd($command);

  return $program;
}

sub Print_Cmd
{
  my $command = shift;

  print "\n[COMMANDS]\n$command\n";
  print "\n[INFO]\n";
  print "Project Title                     = [ $project ]\n";
  print "Project Directory                 = [ $proj_dir ]\n";
  print "Sample Metadata Table             = [ $metadata_file ]\n";
  print "Pipeline Master Script            = [ $pipeline_script ]\n";
  print "Pipeline Configuration File       = [ $config_file ]\n";
  print "Number of Threads                 = [ $threads ]\n";
  print "Minumum Mapping Quality           = [ $mapq_min ]\n";
  print "Force All Samples                 = [ ";
  if($force_flag) { print "ON"; } else { print "OFF"; } 
  print " ]\n";
  print "Platform                          = [ $platform ]\n";
  print "Scheduler                         = [ $scheduler ]\n";
  print "Retry                             = [ $retry ]\n";
  print "BigDataScript Configuration       = [ $bds_cfg ]\n";
  print "Pipeline Master Submission Script = [ $job_script ]\n";
  print "Log Mode                          = [ ";
  if($log_flag) { print "ON"; } else { print "OFF"; }
  print " ]\n"; 
  print "\n[PROGRESS]\n";

  return $command;
}


## ---------------------------------------

1;
