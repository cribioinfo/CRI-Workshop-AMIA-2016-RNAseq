
package RNAseq::BuildProjDir;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::Util qw(Make_Dir);

our @EXPORT = qw(Build_Proj_Dir);
our @EXPORT_OK = qw(Build_Proj_Dir);

## ---------------------------------------

sub Build_Proj_Dir
{
  my ($proj_dir, $project, $sample_list) = @_;

  Make_Dir("$proj_dir/checkpoints/$project\_chp");

  foreach my $sample (sort keys %{$sample_list}) {
    foreach my $dir (qw(configs logs results)) {
      Make_Dir("$proj_dir/$dir/$project\_samples/$sample");
    }
  }

  foreach my $dir (qw(logs results)) {
    # Make_Dir("$proj_dir/$dir/$project\_multisample");
  }

  # foreach my $dir (qw(aln annovar fastqc)) {
  #   Make_Dir("$proj_dir/report/$project\_report/$dir");
  # }

  Make_Dir("$proj_dir/configs/$project\_project"); 

  # foreach my $dir(qw(alignment alignment_metrics project_report qc_reports read_counts configs)) {
  #   Make_Dir("$proj_dir/archive/$project\_archive/$dir");     
  # }

  return $proj_dir;
}


## ---------------------------------------

1;

