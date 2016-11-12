#!/usr/bin/perl -w

=head1 LICENSE

Check_QC.pl

Copyright (C) 2013-2015 Center for Research Informatics, The University of Chicago

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

############################################################################################
# Riyue Bao 01/26/2015
# This script parses fastqc_data.txt file and decides whether the R1/R2reads.fq pass QC.
############################################################################################


use strict;
use Cwd;
use Cwd 'abs_path';
use IO::Handle;
use Getopt::Long;
use FileHandle;
use File::Basename;

##############################
# Arguments from command line
##############################

## print menu
my $PROG = basename($0);
my $menu = Print_Menu($PROG);
if(@ARGV == 0) { print "\n$menu\n"; exit; }

## get opt 
my $file = "";
my $readgroup = "";
my $sample = "sample";
my $outputdir = "./";
my $metrics = "";

&GetOptions( 
	"file|f:s" => \$file,
	"readgroup|rg:s" => \$readgroup,
	"sample|s:s" => \$sample,
	"output|o:s" => \$outputdir,
	"metrics|m:s" => \$metrics,
	
) or die $!;

## check
if ($file eq "" || $readgroup eq "") { print STDERR "Input file missing! \n$menu\n"; exit(1); }	

## command
my $command = "$PROG --file \"$file\" --readgroup $readgroup --sample $sample --output $outputdir";
if($metrics) { $command .= " --metrics \"$metrics\"" }

$outputdir =~ s/\/$//;
if ( ! -d $outputdir) { `mkdir -p $outputdir`; }

##############################
# Main 
##############################

print"\n[COMMANDS]\n$command\n\n[PROGRESS]\n";

## initialize 
my $output = "$outputdir/$sample.qc_summary.tsv";
my $version = "NA";
my $file_count = 0;
my @files = split(/,/, $file);
my @rgs = split(/,/, $readgroup);
my @metrics = split(/,/, $metrics);
my $rg_list;
my $qc_list;
my $metrics_list;

## print sample info 
print "Sample_id = $sample\n";
print "Readgroup_list = ( ".join(" ", @rgs)." )\n";
print "Metrics_list = ( ".join(" ", @metrics)." )\n\n";

## check input zip fastqc.zip and rg: are they 1:1 match?
if (scalar(@files) != scalar(@rgs)) {
	print STDERR "File list length is not consistent with readgroup list. Program terminated! \nfilelist=".scalar(@files)."; rglist=".scalar(@rgs)."\n";
	exit(1);
}

## record metrics
foreach (@metrics) {
	my @info = split(/:/, $_);
	$metrics_list->{$info[0]}->{"1"} = $info[1];
	$metrics_list->{$info[0]}->{"2"} = $info[2];
}
# Test_Hash($metrics_list);

## run start
Update_Progress("Prepare unzipped qc report file");
$rg_list = Unzip_QC($rg_list, \@rgs, \@files);
# Test_Hash($rg_list);

open(OUT, ">", $output) or die $!;

Update_Progress("Check read quality based on metrics");
foreach my $rg (sort keys %{$rg_list}) {
	foreach my $fn (sort keys %{$rg_list->{$rg}}) {
		my $out = $rg_list->{$rg}->{$fn};
		print "Checking ... file=$out\n";
		$out =~ s/\.zip$//;

		$file_count++;
		$qc_list = Open_File($qc_list, $metrics_list, $rg, $fn, "$out/fastqc_data.txt", \@metrics);
	}
}
# Test_Hash($qc_list);

Update_Progress("Printing PASS and FAIL readgroups");
$qc_list = Print_RG($qc_list);

close(OUT);

## run end
Update_Progress("QC summary written into $output");
Update_Progress("Program run finished\n");

##############################
# Functions
##############################

sub Print_RG
{
	my ($qc_list) = shift;

	foreach my $sample (sort keys %{$qc_list}) {
		my $sample_flag = "FAIL";

		open(OUT, ">", "$outputdir/$sample.qc_flag.tsv") or die $!;

		foreach my $rg (sort keys %{$qc_list->{$sample}}) {
			my $rg_flag = "PASS";

			foreach my $filename (sort keys %{$qc_list->{$sample}->{$rg}}) {
				foreach my $metrics (sort keys %{$qc_list->{$sample}->{$rg}->{$filename}}) {
					my $flag = $qc_list->{$sample}->{$rg}->{$filename}->{$metrics};
					if($flag eq "FAIL") { $rg_flag = "FAIL";}
				}
			}

			if($rg_flag eq "PASS") { $sample_flag = "PASS"; }
			print OUT "RG\t$rg\t$rg_flag\n";
		}
		
		print OUT "SM\t$sample\t$sample_flag\n";

		if($sample_flag eq "FAIL") {
			`echo $outputdir > $outputdir/sample.exclude`;
		}
	}

	close(OUT);

	return $qc_list;
}

sub Open_File
{
	my ($qc_list, $metrics_list, $rg, $fn, $report, $metrics_ref) = @_;

	my ($filename, $encoding, $total, $length, $gc, $dup, $nfd) = ("NA") x 8;
	my $n = 0;
	my $qual_list;
	my ($qual_start, $nfd_start, $n_start, $dup_start) = (0) x 4;
	my ($qual_total, $qual_fail) = (0) x 4;
	my (@Amean, @Tmean, @Gmean, @Cmean);
	my $i = 0;

	for(my $i=5; $i<=40; $i+=5) { $qual_list->{$i} = 0; }

	open(IN, "<", $report) or die $!;

	## collect qc metrics
	while(my $line = <IN>) {
		chomp($line);
		$i++;

		if($line =~ m/^##FastQC\s+(\S+)\s*$/) {
			$version = $1;
		}
		elsif($line =~ m/^Filename\s+(\S+)\s*$/) {
			$filename = $1;
		}
		elsif($line =~ m/^Encoding\s+(.*)\s+$/) {
			$encoding = $1;
			if($encoding =~ m/Sanger|Illumina 1.9/) { $encoding = "Phred33"; }
			elsif($encoding =~ m/Illumina 1.5/) { $encoding = "Phred64"; }
		}
		elsif($line =~ m/^Total Sequences\s+(\d+)\s*$/) {
			$total = $1;
		}
		elsif($line =~ m/^Sequence length\s+(\d+)\s*$/) {
			$length = $1;
		}
		elsif($line =~ m/^%GC\s+(\d+)\s*$/) {
			$gc = $1;
		}
		
		if($line =~ m/^>>Per base sequence quality/) { $qual_start = 1; }
		if($line =~ m/^>>Per base sequence content/) { $nfd_start = 1; }
		if($line =~ m/^>>Per base N content/) { $n_start = 1; }
		if($line =~ m/^>>Sequence Duplication Levels/) { $dup_start = 1; }

		if($line =~ m/^>>END_MODULE/) {
			($qual_start, $nfd_start, $n_start, $dup_start) = (0) x 4;
		}

		#print "line $i: $section_start\n";

		if($line =~ m/^\d+|^#/) {
			my @line = split(/\t/, $line);
			
			if($qual_start == 1 && $line =~ m/^\d+/) {
				$qual_total++;

				my $qual = $line[3];
				if($line[3] < $metrics_list->{"QUAL"}->{"1"}) { $qual_fail++; }
				foreach my $q (sort{$a<=>$b} keys %{$qual_list}) {
					if($qual >= $q) { $qual_list->{$q}++; }
				}
			}
			elsif($nfd_start == 1 && $line =~ m/^\d+/) {
				push (@Gmean, $line[1]);
			    push (@Amean, $line[2]);
			    push (@Tmean, $line[3]);
			    push (@Cmean, $line[4]);
			}
			elsif($n_start == 1 && $line =~ m/^\d+/) {
				$n += $line[1];
			}
			elsif($dup_start == 1 && $line =~ m/^#Total Duplicate Percentage\s+(\S+)\s*$/) {
				$dup = $1; 
			}
		}
	}

	close(IN);

	## check qc metrics
	# print (@Amean, @Tmean, @Gmean, @Cmean)."\n";
	$nfd = Calculate_NFD($nfd, \@Amean, \@Tmean, \@Gmean, \@Cmean);
	$qc_list = Check_QC($qc_list, $metrics_list, $sample, $rg, $filename, ($qual_fail/$qual_total), $nfd, $gc, $n, $dup);
	# Test_Hash($qc_list);

	# print "$version, $filename, $encoding, $total, $length, $gc, $n, $dup, $nfd\nQuals: ";
	# foreach (sort{$a<=>$b} keys %{$qual_list}) { print $qual_list->{$_}." "; }
	# print "\n";
	# print "qual_total=$qual_total; qual_fail = $qual_fail\n";

	## print qc_summary
	if($n ne "NA") { $n = sprintf("%.2f", $n); }
	if($dup ne "NA") { $dup = sprintf("%.2f", $dup); }
	if($nfd ne "NA") { $nfd = sprintf("%.2f", $nfd); }
	if($file_count == 1) { 
		print OUT Print_Header(); 
		foreach my $metrics (sort keys %{$metrics_list}) { 
			print OUT "\t$metrics:".$metrics_list->{$metrics}->{"1"}.":".$metrics_list->{$metrics}->{"2"}; 
		}
		print OUT "\n";
	}
	print OUT "$sample\t$rg\t$filename\t$encoding\t$total\t$length";
	foreach (sort{$a<=>$b} keys %{$qual_list}) { print OUT "\t".sprintf("%.2f",($qual_list->{$_} / $qual_total) * 100); }
	print OUT "\t$gc\t$n\t$dup\t$nfd";
	foreach my $metrics (sort keys %{$metrics_list}) {
		if(exists $qc_list->{$sample}->{$rg}->{$filename}->{$metrics}) {
			print OUT "\t".$qc_list->{$sample}->{$rg}->{$filename}->{$metrics};
		}
		else { print OUT "NA"; }
	}
	print OUT "\n";
	
	return $qc_list;
}

sub Unzip_QC
{
	my ($rg_list, $rgs_ref, $files_ref) = @_;

	foreach my $rg (@{$rgs_ref}) { 
		my $file = shift @{$files_ref};
		my @pefiles = split(/:/, $file);

		foreach my $pe (@pefiles) {
			my $pefn = $pe;
			my $out = $pe;
			$pefn =~ s/^\S*\///g;

			if(exists $rg_list->{$rg}->{$pe}) { print STDERR "Unzip_QC: rg_list: key already exists! $rg=>$pe\n"; }
			else { $rg_list->{$rg}->{$pefn} = $pe; }
			
			if($pefn =~ m/\.zip$/) {
				$out =~ s/\.zip$//;
				my $exdir = ".";
				if($pe =~ m/^(\S+)\//g) { $exdir = $1; }
				if( ! -e "$out/fastqc_data.txt") { print "Unzipping ... out=$out\/\n"; `unzip $pe -d $exdir`; }
				else { print "Unzipped folder already exists! out=$out\/\n"; }
			}
			else {
				print STDERR "Unzip_QC: Input file does not have .zip extension. Program terminated!\nfile=$pefn\n";
				exit(1);
			}
		}
	}

	return $rg_list;
}

sub Check_QC
{
	my ($qc_list, $metrics_list, $sample, $rg, $filename, $qual_fail_frac, $nfd, $gc, $n, $dup) = @_;

	foreach my $metrics (sort keys %{$metrics_list}) {
		my $flag = "PASS";
		my $value = "";

		if($metrics eq "QUAL") {
			$value = $qual_fail_frac;
			if ($value > $metrics_list->{$metrics}->{"2"}) { $flag = "FAIL"; }
		}
		else {
			if($metrics eq "NFD") { $value = $nfd; }
			elsif($metrics eq "GC") { $value = $gc; }
			elsif($metrics eq "N") { $value = $n; }
			elsif($metrics eq "DUP") { $value = $dup; }

			if($value < $metrics_list->{$metrics}->{"1"} || 
			$value > $metrics_list->{$metrics}->{"2"}) { $flag = "FAIL"; }

		}
	
		print "- $metrics: ".sprintf("%.2f",$value)." [ $flag ]\n";
		$qc_list->{$sample}->{$rg}->{$filename}->{$metrics} = $flag;
	}


	return $qc_list;
}

sub Calculate_NFD
{
	my ($NFD, $Amean_ref, $Tmean_ref, $Gmean_ref, $Cmean_ref) = @_;

	my @Amean = @{$Amean_ref};
	my @Tmean = @{$Tmean_ref};
	my @Gmean = @{$Gmean_ref};
	my @Cmean = @{$Cmean_ref};

    my $catCount = @Gmean;
    my ($Asum,$Csum,$Gsum,$Tsum,$aNFD,$cNFD,$gNFD,$tNFD) = (0,0,0,0,0,0,0,0);
    ($Asum+=$_) for @Amean;
    ($Csum+=$_) for @Cmean;
    ($Gsum+=$_) for @Gmean;
    ($Tsum+=$_) for @Tmean;
    my ($Aavg,$Cavg,$Gavg,$Tavg) = ($Asum/$catCount,$Csum/$catCount,$Gsum/$catCount,$Tsum/$catCount);
    my ($Adiff,$Cdiff,$Gdiff,$Tdiff);
    foreach my $mean (@Amean) {$aNFD += ($mean-$Aavg)**2;}
    foreach my $mean (@Cmean) {$cNFD += ($mean-$Cavg)**2;}
    foreach my $mean (@Gmean) {$gNFD += ($mean-$Gavg)**2;}
    foreach my $mean (@Tmean) {$tNFD += ($mean-$Tavg)**2;}
    $aNFD = sqrt($aNFD/$catCount);
    $cNFD = sqrt($cNFD/$catCount);
    $gNFD = sqrt($gNFD/$catCount);
    $tNFD = sqrt($tNFD/$catCount);
    $NFD = sprintf ("%.02f",$aNFD+$cNFD+$gNFD+$tNFD);

    return $NFD;
}

sub Print_Header
{
	my $header = qq~##VERSION="FastQC $version"
##SAMPLE="Sample ID"
##READGROUP="ReadGroup ID"
##FILENAME="Filename of the sequence fastq file"
##ENCODING="Fastq format, Phred33 or 64"
##TOTAL="Total numeber of sequences"
##LENGTH="Sequence length in bp"
##QUAL[5,10,15,20,25,30,35,40]="Percentage of bases with Lower Quartile Quality >= [5,10,15,20,25,30,35,40]"
##GC="Average GC content"
##N="Total N content"
##DUP="Total Duplicate Percentage"
##NFD="Nucleotide frequency distortion, sum of the variance in nucleotide frequency across A,T,G,C"
##QUAL:X:Y="At least Y% of the bases have >=X quality (Lower Quartile)"
##NFD:X:Y="NFD is between X and Y"
##GC:X:Y="Average GC content is between X% and Y%"
##N:X:Y="Total N content is between X and Y"
##DUP:X:Y="Total duplicate percentage is between X% and Y%"
#SAMPLE	READGROUP	FILENAME	ENCODING	TOTAL	LENGTH	QUAL5	QUAL10	QUAL15	QUAL20	QUAL25	QUAL30	QUAL35	QUAL40	GC	N	DUP	NFD~;

	return $header;
}

sub Print_Menu
{

	my $PROG = shift;

	my $menu = qq~
## This script parses fastqc_data.txt file and decides whether the R1/R2reads.fq pass QC.
Usage: 
 $PROG -f|--file <fastqc.zip> -rg|--readgroup <rgid> -s|--sample <sample> 
            -o|--outputdir <output_directory> -m|--metrics <qc_thresholds>

Output: 
 One QC summary table will be generated: 
 [sample.qc_summary.tsv] QC metrics of all readgroups

 One QC flag table will be generated: 
 [sample.qc_flag.tsv] QC flags (FAIL or PASS) of readgroups and sample

Options:
 [-f|--file]      : Fastqc zip file. R1 and R2 separated by [:], and readgroups separated by [,].
              Note: Must be double-quoted ( -f "file1:file2,file3:file4,...").
 [-rg|--readgroup]: Readgroup ID for each (pair of) read file. Separated by [,].
              Note: When using this script in pipelines, make sure the readgroup id is consistent with metadata table.
 [-s|--sample]    : Sample ID. 
              Note: When using this script in pipelines, make sure the sample id is consistent with metadata table.
 [-o|--outputdir] : Output directory.
 [-m|--metrics]   : QC thresholds to determine whether R1/R2 reads pass or fail. 
                    Multiple thresholds are separated by [,] (no space allowed!).
                    Format is  
                    QUAL:30:50 [ 50% of the bases have <30 quality (Lower Quartile) ]
                    NFD:0:10 [ NFD is between 0 and 10 ]
                    GC:40:60 [ average GC content is between 40% and 60% ]
                    N:0.0:0.1 [ total N content is between 0.0 and 0.1 ]
                    DUP:0:60 [ total duplicate percentage is between 0% and 60% ]
              Note: Must be double-quoted ( -m "QUAL:30:50,NFD:10:30" ).

Metrics:
 QUAL (Per base quality)
 NFD (Nucleotide frequency distortion, sum of the variance in nucleotide frequency across A,T,G,C)
 GC (Average GC content)
 N (Total N content)
 DUP (Total duplicate percentage)

Example: 
$PROG -f "../myProject/results/LCAexome_samples/father_SRR504517/qc_reports/father_SRR504517_2_fastqc.zip: \\
 ../myProject/results/LCAexome_samples/father_SRR504517/qc_reports/father_SRR504517_1_fastqc.zip" \\
 -rg father_SRR504517 \\
 -s father_SRR504517 \\
 -o ./ \\
 -m "QUAL:30:50,NFD:0:10,GC:40:60,N:0:2,DUP:0:30"

Release: 2015-02-26
Contact: Riyue Bao <rbao\@uchicago.edu>

~;

	return $menu;
}

sub Update_Progress
{
	my $progress = shift;
	
	print "[ ",Local_Time(), " ] $progress\n";
	
	return $progress;
}


sub Test_Hash
{
	my $hash = shift;
	
	foreach my $key (sort keys %{$hash}) {
		print "$key=>\n";
		
		if($hash->{$key} =~ m/^HASH/)
		{
			Test_Hash($hash->{$key});
			print "\n";
		}
		elsif($hash->{$key} =~ m/^ARRAY/)
		{
			print join(" ", @{$hash->{$key}}), "\n";
		}
		else
		{
			print $hash->{$key}, "\n";
		}
	
	}

	return $hash;
}

#Print local time
sub Local_Time
{
	my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	my  @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	my $year = 1900 + $yearOffset;
	#my $theTime = "$hour:$minute:$second, $weekDays[$dayOfWeek], $months[$month] $dayOfMonth, $year";
	
	my $digits = 2;
	$month = Add_Prefix($month, $digits);
	$dayOfMonth = Add_Prefix($dayOfMonth, $digits);
	$hour = Add_Prefix($hour, $digits);
	$minute = Add_Prefix($minute, $digits);
	$second = Add_Prefix($second, $digits);	
	my $theTime = "$month-$dayOfMonth-$year\_$hour:$minute:$second";
	
	#print "Local time: ", $theTime, "\n";
	return $theTime;
} 

sub Add_Prefix
{
	my ($number, $digits) = @_;
	
	if($number =~ m/^\d{$digits}$/)
	{	
		return $number;
	}
	else
	{
		$number = "0".$number;
		Add_Prefix($number, $digits);
	}

}

