
package RNAseq::SetBDSenv;

use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(Set_BDS_env);
our @EXPORT_OK = qw(Set_BDS_env);

## ---------------------------------------

## set BDS environment
sub Set_BDS_env
{
  my $file = shift;

  # my @lines = (". /etc/profile.d/modules.sh", 
  #              "module load java/1.7.0",
  #              "export PATH=/data/.bds:\$PATH");

  my @lines = ();

  return @lines;
}

## ---------------------------------------

1;
