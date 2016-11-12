
package RNAseq::PrintSample;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::Util qw(Empty_Value Add_Key BAM_Suffix);

our @EXPORT = qw(Print_Sample);
our @EXPORT_OK = qw(Print_Sample);

## ---------------------------------------

sub Print_Sample
{

  my ($sample_list, $config_list, $proj_dir, $project, $sample, $metadata_file, $force_flag) = @_;

  ## initialize
  my $output_file = "$sample.cfg";
  my $output_dir = "$proj_dir/configs/$project\_samples/$sample";
  my @print_files;
  my $aligner_list;
  my $caller_list;
  my $print_list;
  my $genome = "";
  my $suffix = "";

  ## decide refined bam filename based on pipeline module flags
  $suffix = BAM_Suffix($suffix, $config_list->{"pipeline"}->{"flags"}->{"modules"});

  ## retrieve aligner/caller list
  $aligner_list = Add_Key($config_list->{"pipeline"}->{"flags"}, "aligners", $aligner_list);
  $caller_list = Add_Key($config_list->{"pipeline"}->{"flags"}, "callers", $caller_list);

  ## retrieve genome assembly 
  foreach my $sample (sort keys %{$sample_list}) {
    foreach my $library (sort keys %{$sample_list->{$sample}}) {
      foreach my $readgroup (sort keys %{$sample_list->{$sample}->{$library}}) {
        if(exists $sample_list->{$sample}->{$library}->{$readgroup}->{"Genome"}) {
          $genome = Empty_Value($genome, $sample_list->{$sample}->{$library}->{$readgroup}->{"Genome"});
          last;
        }
      }
    }
  }
  if($genome eq "") {
    print STDERR "Print_Sample: sample_list: Genome is missing! Program terminated.\n";
    exit;
  }

  ## print attributes
  open(OUT, ">", "$output_dir/$output_file") or die $!;
  
  ## -----
  print OUT "\n## project information\n";
  print OUT "project = $project\n";
  print OUT "sample = $sample\n";
  print OUT "genome_assembly = $genome\n";
  print OUT "force_include = $force_flag\n";

  ## -----
  print OUT "\n## project/sample directories/files\n"; 
  $print_list = Section_Sample($print_list, $proj_dir, $project, $sample, $metadata_file);
  foreach my $key (sort keys %{$print_list}) { print OUT "$key = ".$print_list->{$key}."\n"; }

  ## -----
  print OUT "\n## aligner/caller list\n";
  print OUT "aligners = ".join(",", sort keys %{$aligner_list})."\n";
  print OUT "callers = ".join(",", sort keys %{$caller_list})."\n";

  ## -----
  print OUT "\n## sample QC files\n";
  print OUT "qc_summaryfile = $proj_dir/results/$project\_samples/$sample/$sample.qc_summary.tsv\n";
  print OUT "qc_flagfile = $proj_dir/results/$project\_samples/$sample/$sample.qc_flag.tsv\n";

  ## -----
  print OUT "\n## alignment files\n";
  foreach my $aligner (sort keys %{$aligner_list}) {
    print OUT "$aligner\_alnfile = "."$proj_dir/results/$project\_samples/$sample/alignment/$sample.$aligner.merged.bam\n";
  }

  # ## -----
  # print OUT "\n## refined alignment files\n";
  # foreach my $aligner (sort keys %{$aligner_list}) {
  #   print OUT "$aligner\_refine_alnfile = "."$proj_dir/results/$project\_samples/$sample/alignment/$sample.$aligner.merged$suffix.bam\n";
  # }

  # ## -----
  # print OUT "\n## gatk callableloci files\n";
  # foreach my $aligner (sort keys %{$aligner_list}) {
  #   print OUT "$aligner\_callocifile = $proj_dir/results/$project\_samples/$sample/alignment/$sample.$aligner.merged$suffix.loci.callable.bed\n";
  # }

  ## -----
  print OUT "\n## per-sample read count files\n";
  foreach my $aligner (sort keys %{$aligner_list}) {
    foreach my $caller (sort keys %{$caller_list}) {
        my $ext = "raw_counts.txt";
        print OUT "$aligner\_$caller\_varfile = $proj_dir/results/$project\_samples/$sample/read_counts/$sample.$aligner.$caller.$ext\n";
    }
  }

  ## -----
  print OUT "\n## readgroup config files\n";
  @print_files = ();
  foreach my $library (sort keys %{$sample_list->{$sample}}) {
    foreach my $readgroup (sort keys %{$sample_list->{$sample}->{$library}}) {
      push(@print_files, "$proj_dir/configs/$project\_samples/$sample/$sample.$readgroup.cfg");
    }
  }
  print OUT "rg_configs = ".join(",", @print_files)."\n";

  close(OUT);

  return $sample_list;

}

sub Section_Sample 
{
  my ($list, $proj_dir, $project, $sample, $metadata_file) = @_;

  $list->{"sample_result_dir"} = "$proj_dir/results/$project\_samples/$sample";
  $list->{"sample_config"} = "$proj_dir/configs/$project\_samples/$sample.cfg";
  $list->{"sample_log_dir"} = "$proj_dir/logs/$project\_samples/$sample";
  $list->{"project_dir"} = "$proj_dir";
  $list->{"project_metadata_table"} = "$proj_dir/$metadata_file";
  my @keys = qw(flag reference software);
  foreach my $key (@keys) {
    $list->{"project_$key\_config"} = "$proj_dir/configs/$project\_project/$project.$key.cfg";
  }

  return $list;
}

## ---------------------------------------

1;

