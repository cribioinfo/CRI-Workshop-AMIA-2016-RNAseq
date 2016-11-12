
package RNAseq::PrintSoftware;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::Util qw(Empty_Value);

our @EXPORT = qw(Print_Software);
our @EXPORT_OK = qw(Print_Software);

## ---------------------------------------

sub Print_Software
{
  my ($config_list, $output_dir, $output_file, $mapq_min, $threads) = @_;

  open(OUT, ">", "$output_dir/$output_file") or die $!;
  
  if(exists $config_list->{"pipeline"}->{"software"}) {
    ## print main parameters
    if(exists $config_list->{"pipeline"}->{"software"}->{"main"}) {
      print OUT "\n## global settings\n";
      foreach my $key (sort keys %{$config_list->{"pipeline"}->{"software"}->{"main"}}) {
          my $value = "";
          $value = Empty_Value($value, $config_list->{"pipeline"}->{"software"}->{"main"}->{$key});

          ## overwrite values with command line argument input
          if($key eq "min_map_qual") { $value = $mapq_min; }
          if($key eq "threads") { $value = $threads; }
        
          print OUT "main_$key = $value\n";
        }
    }
    else {
      print STDERR "Print_Software: config_list: key \"main\" does not exist!\n";
    }

    ## print software-specific parameters
    foreach my $key1 (sort keys %{$config_list->{"pipeline"}->{"software"}}) {
      if($key1 ne "main") { 
        print OUT "\n## $key1\n";
        foreach my $key2 (sort keys %{$config_list->{"pipeline"}->{"software"}->{$key1}}) {
          my $value = "";
          $value = Empty_Value($value, $config_list->{"pipeline"}->{"software"}->{$key1}->{$key2});

          ## update threads according to main threads
          ## bwa fastqc ivc novoalign picard pigz samtools
          ## gatk only if split_flag = 0
          if($key2 eq "threads") {
            if($key1 =~ m/bwa|fastqc|freebayes|ivc|mpileup|novoalign|picard|pigz|platypus|samtools|gatk|star|featurecounts/) { $value = $threads; }
            # if($key1 eq "gatk" && $split_flag == 0) { $value = $threads; }
          }

          print OUT "$key1\_$key2 = $value\n";
        }
      }
    }
  }
  else {
    print STDERR "Print_Software: config_list: key does not exist. pipeline=>software\n";  
  }

  close(OUT);

  return $config_list;

}


## ---------------------------------------

1;

