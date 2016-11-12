
package RNAseq::SampleList;

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(abs_path);
use File::Basename;
use lib dirname(abs_path($0)).'/lib/perl5';
use RNAseq::CheckMetadata;
use RNAseq::Util qw(Line_Value RGstring);

our @EXPORT = qw(Sample_List);
our @EXPORT_OK = qw(Sample_List);

## ---------------------------------------

# Sample	Library	ReadGroup	Platform	SequencingCenter	Date	Lane	Unit	Flavor	Encoding	Run	Genome
# mother_III4_SRR504515	mother_III4_SRR504515	mother_III4_SRR504515	Illumina	MEEI		2	HWI-ST423_0087_2	2x101	Phred33	SRR504515	hg19

sub Sample_List
{
	my ($sample_list, $field_list, $line_ref) = @_;

	## initialize
  	my $sample = Line_Value($field_list, "Sample", $line_ref);
  	my $library = Line_Value($field_list, "Library", $line_ref);
  	my $readgroup = Line_Value($field_list, "ReadGroup", $line_ref);
  	my $platform = Line_Value($field_list, "Platform", $line_ref);
  	my $center = Line_Value($field_list, "SequencingCenter", $line_ref);
  	my $date = Line_Value($field_list, "Date", $line_ref);
  	my $lane = Line_Value($field_list, "Lane", $line_ref);
  	my $unit = Line_Value($field_list, "Unit", $line_ref);
  	my $run = Line_Value($field_list, "Run", $line_ref);
  	my $flavor = Line_Value($field_list, "Flavor", $line_ref);
  	my $encoding = Line_Value($field_list, "Encoding", $line_ref);
  	my $genome = Line_Value($field_list, "Genome", $line_ref);
  	my $seqfiles_total = 0;
  	my @seqfiles = (
  		Line_Value($field_list, "Seqfile1", $line_ref),
  		Line_Value($field_list, "Seqfile2", $line_ref),
  		Line_Value($field_list, "Seqfile3", $line_ref)
  		);

  	## re-assign
  	if($library !~ m/\S+/) { $library = $sample; }
  	foreach (($lane, $run)) { if($_ ne "") { $unit .= "_$_"; } }
  	foreach (@seqfiles) { if($_ ne "") { $seqfiles_total++; }}
  	if($encoding eq "") {
  		print STDERR "Sample_List: Encoding is missing. Assuming the FastQ format is Phred33+. Program continue.\n"; 
  		$encoding = 33;
  	}

  	## check whether the metadata is in format for each field
  	my @rg_required = ($sample, $library, $readgroup, $platform);
  	Check_Metadata($flavor, $encoding, $genome, $platform, $seqfiles_total, \@rg_required);

  	## construct @RG header for alignment
  	my $RGstring = RGstring($sample, $library, $readgroup, $platform, $center, $date, $unit);
  	# print "RGstring = $RGstring\n";

  	foreach my $field (sort keys %{$field_list}) {
  		if(exists $sample_list->{$sample}->{$library}->{$readgroup}->{$field}) {
  			print STDERR "Sample_List: sample_list: key already exists. $sample=>$library=>$readgroup=>$field\n";
  		}
  		else {
  			$sample_list->{$sample}->{$library}->{$readgroup}->{$field} = Line_Value($field_list, $field, $line_ref);
  		}
  	}

  	## update values according to the re-assigned ones
  	$sample_list->{$sample}->{$library}->{$readgroup}->{"Library"} = $library;
  	$sample_list->{$sample}->{$library}->{$readgroup}->{"Unit"} = $unit;
  	$sample_list->{$sample}->{$library}->{$readgroup}->{"Encoding"} = $encoding;
  	$sample_list->{$sample}->{$library}->{$readgroup}->{"RGstring"} = $RGstring;

  	return $sample_list;
}

## ---------------------------------------

1;
