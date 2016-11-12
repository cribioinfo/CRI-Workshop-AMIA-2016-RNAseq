
package RNAseq::PrintFlag;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::Util qw(Empty_Value);

our @EXPORT = qw(Print_Flag);
our @EXPORT_OK = qw(Print_Flag);

## ---------------------------------------

sub Print_Flag
{
  my ($config_list, $output_dir, $output_file) = @_;

  open(OUT, ">", "$output_dir/$output_file") or die $!;
  
  if(exists $config_list->{"pipeline"}->{"flags"}) {
    foreach my $key1 (sort keys %{$config_list->{"pipeline"}->{"flags"}}) {
      print OUT "\n## $key1\n";
      foreach my $key2 (sort keys %{$config_list->{"pipeline"}->{"flags"}->{$key1}}) {
        my $value = "";
        $value = Empty_Value($value, $config_list->{"pipeline"}->{"flags"}->{$key1}->{$key2});
        print OUT "$key2 = $value\n";
      }
    }
  }
  else {
    print STDERR "Print_Flag: config_list: key does not exist. pipeline=>flags\n";  
  }

  close(OUT);

  return $config_list;

}


## ---------------------------------------

1;

