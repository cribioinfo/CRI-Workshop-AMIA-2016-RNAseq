
package RNAseq::PrintMultiSample;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::Util qw(Empty_Value Add_Key BAM_Suffix);

our @EXPORT = qw(Print_MultiSample);
our @EXPORT_OK = qw(Print_MultiSample);

## ---------------------------------------

sub Print_MultiSample
{
  my ($config_list, $output_dir, $output_file, $sample_list, $proj_dir, $project, $metadata_file) = @_;

  ## initialize
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
    print STDERR "Print_MultiSample: sample_list: Genome is missing! Program terminated.\n";
    exit;
  }

  ## print attributes
  open(OUT, ">", "$output_dir/$output_file") or die $!;
  
  ## -----
  print OUT "\n## project information\n";
  print OUT "project = $project\n";
  print OUT "genome_assembly = $genome\n";

  ## -----
  print OUT "\n## project/sample directories/files\n"; 
  $print_list = Section_Proj($print_list, $proj_dir, $project, $metadata_file);
  foreach my $key (sort keys %{$print_list}) { print OUT "$key = ".$print_list->{$key}."\n"; }

  ## -----
  print OUT "\n## aligner/caller list\n";
  print OUT "aligners = ".join(",", sort keys %{$aligner_list})."\n";
  print OUT "callers = ".join(",", sort keys %{$caller_list})."\n";

  ## -----
  print OUT "\n## project QC files\n";
  print OUT "project_qc_summaryfile = $proj_dir/results/$project.qc_summary.tsv\n";
  print OUT "project_qc_flagfile = $proj_dir/results/$project.qc_flag.tsv\n";

  # ## -----
  # print OUT "\n## gatk callableloci merged across samples\n";
  # foreach my $aligner (sort keys %{$aligner_list}) {
  #   print OUT "$aligner\_loci_merged = $proj_dir/results/$project\_multisample/read_counts/$project.$aligner.target.bed\n";
  # }

  ## -----
  print OUT "\n## combined read count files\n";
  foreach my $aligner (sort keys %{$aligner_list}) {
    foreach my $caller (sort keys %{$caller_list}) {
      print OUT "$aligner\_$caller\_varfile = $proj_dir/results/$project\_multisample/read_counts/$project.$aligner.$caller.combined.raw_counts.txt\n";
    }
  }

  # ## -----
  # print OUT "\n## final annotation files\n";
  # foreach my $aligner (sort keys %{$aligner_list}) {
  #   foreach my $caller (sort keys %{$caller_list}) {
  #     print OUT "$aligner\_$caller\_annofile = $proj_dir/results/$project\_multisample/variant_annotation/$project.$aligner.$caller.flt.anno.txt\n";
  #   }
  # }

  ## -----
  print OUT "\n## ----- INPUTS ------ ##\n";

  ## -----
  @print_files = ();
  print OUT "\n## check QC files; samples saparated by [,]\n";
  foreach my $sample (sort keys %{$sample_list}) {
    push(@print_files, "$proj_dir/results/$project\_samples/$sample/$sample.qc_summary.tsv");
  }
  print OUT "qc_summaryfiles = ".join(",", @print_files)."\n";
  @print_files = ();
  foreach my $sample (sort keys %{$sample_list}) {
    push(@print_files, "$proj_dir/results/$project\_samples/$sample/$sample.qc_flag.tsv");
  }
  print OUT "qc_flagfiles = ".join(",", @print_files)."\n";

  ## -----
  @print_files = ();
  print OUT "\n## alignment files\n";
  foreach my $aligner (sort keys %{$aligner_list}) {
    @print_files = ();
    foreach my $sample (sort keys %{$sample_list}) {
      push(@print_files, "$proj_dir/results/$project\_samples/$sample/alignment/$sample.$aligner.merged$suffix.bam")
    }
    print OUT "$aligner\_bamfiles = ".join(",", @print_files)."\n";
  }

  ## -----
  @print_files = ();
  print OUT "\n## per-sample read count files\n";
  foreach my $aligner (sort keys %{$aligner_list}) {
    @print_files = ();
    foreach my $sample (sort keys %{$sample_list}) {
      push(@print_files, "$proj_dir/results/$project\_samples/$sample/read_counts/$sample.$aligner.read_counts.txt");
    }
    print OUT "$aligner\_readcountfiles = ",join(",", @print_files)."\n";
  }

  # ## -----
  # @print_files = ();
  # print OUT "\n## gatk callableloci bed files\n";
  # foreach my $aligner (sort keys %{$aligner_list}) {
  #   @print_files = ();
  #   foreach my $sample (sort keys %{$sample_list}) {
  #     push(@print_files, "/$proj_dir/results/$project\_samples/$sample/alignment/$sample.$aligner.merged$suffix.loci.callable.bed");
  #   }
  #   print OUT "$aligner\_loci_bedfiles = ",join(",", @print_files)."\n";
  # }

  close(OUT);

  return $config_list;

}

sub Section_Proj 
{
  my ($list, $proj_dir, $project, $metadata_file) = @_;

  $list->{"multisample_result_dir"} = "$proj_dir/results/$project\_multisample";
  $list->{"multisample_config"} = "$proj_dir/configs/$project\_project/$project.multisample.cfg";
  $list->{"multisample_log_dir"} = "$proj_dir/logs/$project\_multisample";
  # $list->{"report_dir"} = "$proj_dir/report/$project\_report";
  # $list->{"report_in_yaml"} = "$proj_dir/configs/$project\_project/$project.report.in.yaml";
  # $list->{"report_out_yaml"} = "$proj_dir/configs/$project\_project/$project.report.out.yaml";
  # $list->{"report_log_dir"} = "$proj_dir/logs/$project\_report";
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

