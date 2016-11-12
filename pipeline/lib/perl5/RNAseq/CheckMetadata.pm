
package RNAseq::CheckMetadata;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::Util qw(RGstring);

our @EXPORT = qw(Check_Metadata);
our @EXPORT_OK = qw(Check_Metadata);

## ---------------------------------------

sub Check_Metadata
{
  my ($flavor, $encoding, $genome, $platform, $seqfiles_total, $rg_required_ref) = @_;

  my $flag = 0;

  foreach my $value (@{$rg_required_ref}) {
      if($value eq "") { 
        print STDERR "Check_Metadata: Missing required \@RG fields. [Sample, Library, ReadGroupID, Platform] = [".join(",",@{$rg_required_ref})."]."; 
        $flag = 1;          
      }
    }
    if($platform ne "Illumina") {
      print STDERR "Check_Metadata: Platform must be \"Illumina\" (case ses=nsitive). Currently it is \"$platform\"."; 
      $flag = 1;             
    }
    if($encoding != 33 && $encoding != 64) {
      print STDERR "Check_Metadata: Encoding is neither 33 nor 64. Currently it is \"$encoding\"."; 
      $flag = 1;            
    }
    if($genome eq "") {
      print STDERR "Check_Metadata: Genome is missing. Must be hg19."; 
      $flag = 1;
    }
    elsif($genome !~ m/grch38/i) {
      print STDERR "Check_Metadata: Genome is not in format. Currently supported genomes include GRCh38. It is \"$genome\"."; 
      $flag = 1;
    }
  if($flavor =~ m/^(\d+)x(\d+)$/) {
    if(($1==1 || $1==2) &&($1 != $seqfiles_total) ) {
      print STDERR "Check_Metadata: Flavor is not consistent with seqfiles. Flavor=$flavor, SeqfileTotal=$seqfiles_total."; 
      $flag = 1;  
    }
    elsif ($1!=1 && $1!=2) {
      print STDERR "Check_Metadata: Flavor is not in format (1 or 2 x readlength). Currently it is \"$flavor\"."; 
        $flag = 1; 
    }
  }

  if($flag) { print " Program terminated!\n"; exit; }
}



## ---------------------------------------

1;
