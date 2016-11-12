
package RNAseq::BuildSampleCfg;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::Util qw(Empty_Value Value_And_Exit Value_And_Ctd Test_Hash);
use RNAseq::PrintSample;
use RNAseq::PrintReadgroup;

our @EXPORT = qw(Build_Sample_Cfg);
our @EXPORT_OK = qw(Build_Sample_Cfg);

## ---------------------------------------

sub Build_Sample_Cfg
{
  my ($sample_list, $config_list, $proj_dir, $project, $sample, $metadata_file, $force_flag) = @_;

  $sample_list = Print_Sample($sample_list, $config_list, $proj_dir, $project, $sample, $metadata_file, $force_flag);

  # Test_Hash($sample_list);

  foreach my $library (sort keys %{$sample_list->{$sample}}) {
    foreach my $readgroup (sort keys %{$sample_list->{$sample}->{$library}}) {
    	# print "readgroup = $readgroup\n";
		$sample_list = Print_Readgroup($sample_list, $config_list, $proj_dir, $project, $sample, $library, $readgroup);
	}
  }

  return $config_list;
}

## ---------------------------------------

1;

