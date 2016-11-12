
package RNAseq::BuildProject;

use strict;
use warnings;
use YAML::Tiny;
use Data::Dumper;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';

use RNAseq::Util qw(Info Parse_Inputfiles Test_Hash Local_Time);
use RNAseq::GetOpt;
use RNAseq::ParseMetadata;
use RNAseq::BuildProjDir;
use RNAseq::BuildProjCfg;
use RNAseq::BuildSampleCfg;
# use RNAseq::BuildReportYaml;
# use RNAseq::BuildArchiveYaml;
use RNAseq::BuildPipelineJob;

our @EXPORT = qw(Build_Project);
our @EXPORT_OK = qw(Build_Project);

## ---------------------------------------

sub Build_Project
{

  my $progam = shift;
  
  Info("Read sample information from \"$metadata_file\"");
  $sample_list = Parse_Metadata($metadata_file, $sample_list);

  Info("Read pipeline configuration from \"$config_file\"");
  $config_list = YAML::Tiny::LoadFile($config_file);

  Info("Build project directory");
  $proj_dir = Build_Proj_Dir($proj_dir, $project, $sample_list);

  Info("Build project-level config files");
  $config_list = Build_Proj_Cfg($sample_list, $config_list, $proj_dir, $project, $metadata_file, $mapq_min, $threads);

  Info("Build sample-level config files");
  foreach my $sample (sort keys %{$sample_list}) {
    $config_list = Build_Sample_Cfg($sample_list, $config_list, $proj_dir, $project, $sample, $metadata_file, $force_flag);
  }

  # Info("Build project report yaml files");
  # $config_list = Build_Report_Yaml($sample_list, $config_list, $proj_dir, $project);

  # Info("Build project archive yaml files");
  # $config_list = Build_Archive_Yaml($sample_list, $config_list, $proj_dir, $project);

  Info("Build pipeline submission job script \"$job_script\"");
  $config_list = Build_Pipeline_Job($sample_list, $config_list, $proj_dir, $project, $platform, $scheduler, $retry, $job_script, $log_flag, $bds_cfg, $bds_cfg_proj, $pipeline_script);
  `chmod u+x $job_script`;

  Info("Copy metadata table to project directory");
  `cp -p $metadata_file $proj_dir`;

  if($tree_exe ne "") {
    Info("Write project directory tree structure into \"$tree_output\"");
    `$tree_exe $proj_dir > $proj_dir/$tree_output`;
  }

  Info("Output files written into project directory");

  return $progam;
}


## ---------------------------------------

1;
