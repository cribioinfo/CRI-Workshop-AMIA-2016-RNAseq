
package RNAseq::ParseMetadata;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::SampleList;

our @EXPORT = qw(Parse_Metadata);
our @EXPORT_OK = qw(Parse_Metadata);

## ---------------------------------------

sub Parse_Metadata
{
  my ($metadata_file, $sample_list) = @_;

  open(IN, "<", $metadata_file) or die $!;

  my $field_list;
  my $total = 0;
  my $skipped = 0;

  while(my $line = <IN>) {
  	chomp($line);

  	my @line = split(/\t/, $line);
  	for(my $i=0; $i<@line; $i++) { $line[$i] =~ s/\s+//g; } ## remove space

  	if($line =~ m/^Sample\t/) {
  		for(my $i=0; $i<@line; $i++) {
  			my $field = $line[$i];

  			if(exists $field_list->{$field}) { print STDERR "Parse_Metadata: field_list: key alreay exists. $field=>$i\n"; }
  			else { $field_list->{$field} = $i; }
  		}
  	}
  	elsif($line =~ m/^\S+/) {
  		$total++;
  		## skip commented samples
  		if($line =~ m/^#/) {
	  		$skipped++;
	  		next;
	  	}

	  	## parse sample info, sanity check and assign necessary values to each field
	  	$sample_list = Sample_List($sample_list, $field_list, \@line);
      
  	}
  	elsif($line =~ m/\S+/) {
  		print STDERR "Parse_Metadata: line not in format. $metadata_file: $line\n";
  	}

  }
  
  close(IN);

  print "Readgroup Total = $total\nReadgroup Skipped = $skipped\n";
  print "Sample Kept = ".scalar(keys %{$sample_list})."\n";

  return $sample_list;
}


## ---------------------------------------

1;
