
package RNAseq::BuildProjCfg;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::PrintFlag;
use RNAseq::PrintSoftware;
use RNAseq::PrintReference;
use RNAseq::PrintMultiSample;

our @EXPORT = qw(Build_Proj_Cfg);
our @EXPORT_OK = qw(Build_Proj_Cfg);

## ---------------------------------------

sub Build_Proj_Cfg
{
  my ($sample_list, $config_list, $proj_dir, $project, $metadata_file, $mapq_min, $threads) = @_;

  my $print_list;
  my $output_dir = "$proj_dir/configs/$project\_project";
  my @keys = qw(flag software reference multisample);
  foreach my $key (sort @keys) { $print_list->{$key} = "$project.$key.cfg"; }  

  ## build project.flag.cfg
  $config_list = Print_Flag($config_list, $output_dir, $print_list->{"flag"});

  ## build project.software.cfg
  $config_list = Print_Software($config_list, $output_dir, $print_list->{"software"}, $mapq_min, $threads);

  ## build project.reference.cfg
  $config_list = Print_Reference($config_list, $output_dir, $print_list->{"reference"});

  ## build project.multisample.cfg
  $config_list = Print_MultiSample($config_list, $output_dir, $print_list->{"multisample"}, $sample_list, $proj_dir, $project, $metadata_file);

  return $config_list;
}


## ---------------------------------------

1;

