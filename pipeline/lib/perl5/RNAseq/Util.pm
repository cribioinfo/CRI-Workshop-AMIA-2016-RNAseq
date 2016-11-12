
package RNAseq::Util;

use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw();
our @EXPORT_OK = qw(Info Parse_Inputfiles Test_Hash Local_Time RGstring
                    Make_Dir Line_Value Empty_Value Value_And_Exit Value_And_Ctd
                    Add_Key BAM_Suffix Set_Fastqc_File Set_Paired_Flag);

## ---------------------------------------

## set fastqc filename from fastq filename
sub Set_Fastqc_File
{
  my ($seq, $value) = @_;

  $seq = Empty_Value($seq, $value);
  if(defined $seq && $seq =~ m/\S+/) {
    $seq =~ s/.fastq.gz$/_fastqc/;
    $seq =~ s/.fq.gz$/.fq_fastqc/;
  }

  return $seq;
}

 ## decide refined bam filename based on pipeline module flags
sub BAM_Suffix
{
  my ($suffix, $hash_ref) = @_;

  if(exists $hash_ref->{"run_remove_duplicates"} &&
      defined $hash_ref->{"run_remove_duplicates"} &&
      $hash_ref->{"run_remove_duplicates"} eq "1") { $suffix .= ".dedup"; }
  if(exists $hash_ref->{"run_gatk_indel_realn"} &&
      defined $hash_ref->{"run_gatk_indel_realn"} &&
      $hash_ref->{"run_gatk_indel_realn"} eq "1") { $suffix .= ".realn"; }
  if(exists $hash_ref->{"run_gatk_bqsr"} &&
      defined $hash_ref->{"run_gatk_bqsr"} &&
      $hash_ref->{"run_gatk_bqsr"} eq "1") { $suffix .= ".recal"; }

  return $suffix;
}

## add aligner/caller from config file flags
sub Add_Key
{

  my ($hash_ref, $key, $list) = @_;

  if(exists $hash_ref->{$key}) {
    foreach my $key2 (sort keys %{$hash_ref->{$key}}) {
      my $value = $hash_ref->{$key}->{$key2};
      # print "value = $value\n";
      if($key2 =~ m/^run_(\w+)$/) { 
        # print "$1\n";
        if($value) { $list->{$1} = ""; }
      }
      else { 
        print STDERR "config_list: key not in format! Must be \"run_$key\". Currently it is \"$key2\"\n"; 
      }
    }
  }

  return $list;
}


## retrieve sample list values 
sub Value_And_Exit 
{
  my ($var, $hash_ref, $key) = @_;

  if(exists $hash_ref->{$key}) {
    $var = $hash_ref->{$key};
  }
  if($var eq "") {
    print STDERR "$key is missing! Program terminated.\n";
    exit;
  }

  return $var;
}

## retrieve seqfile location
sub Value_And_Ctd
{
  my ($var, $hash_ref, $key) = @_;

  if(exists $hash_ref->{$key}) {
    $var = $hash_ref->{$key};
  }
  if($var eq "") {
    print STDERR "$key is missing! Program continue.\n";
  }

  return $var;
}

sub RGstring
{
  my ($sample, $library, $readgroup, $platform, $center, $date, $unit) = @_;

  my $RGstring = "\@RG\\tID:$readgroup\\tPL:$platform\\tLB:$library\\tSM:$sample";
  if($center ne "") { $RGstring .= "\\tCN:$center"; }
  if($date ne "") { $RGstring .= "\\tDT:$date"; }
  if($unit ne "") { $RGstring .= "\\tPU:$unit"; }

  return $RGstring;
}


sub Make_Dir
{
  my $dir = shift;

  if(! -d $dir) { `mkdir -p $dir`; }

  return $dir;
}

sub Line_Value
{
  my ($field_list, $field, $line_ref) = @_;

  if(exists $field_list->{$field} && defined $line_ref->[$field_list->{$field}] ) { 
    return $line_ref->[$field_list->{$field}]; 
  }
  else { 
    return ""; 
  }
}

sub Empty_Value
{
  my ($var, $value) = @_;

  ## assign value if it is not empty
  if(defined $value && $value =~ m/\S+/) {
    $var = $value;
  }

  return $var;
}

sub Info
{
  my $progress = shift;
  
  print "[ ",Local_Time(), " ] $progress\n";
  
  return $progress;
}

sub Parse_Inputfiles
{
  my @files = @_;

  my @files_new;
  
  if(@files == 1 && $files[0] =~ m/^(\S*)\*(\S*)$/) {
    @files_new = <$1*$2>;
  }
  elsif(@files > 1) {
    foreach my $file(@files) {
      if($file =~ m/^(\S*)\*(\S*)$/) {
        @files_new = (@files_new, <$1*$2>);
      }
      else {
        push(@files_new, $file);
      }
    }
  }
  else {
    @files_new = @files;
  }

  return @files_new;
}

sub Test_Hash
{
  my $hash = shift;
  
  foreach my $key (sort keys %{$hash}) {
    print "$key=>\n";
    
    if($hash->{$key} =~ m/^HASH/) {
      Test_Hash($hash->{$key});
      print "\n";
    }
    elsif($hash->{$key} =~ m/^ARRAY/) {
      print join(" ", @{$hash->{$key}}), "\n";
    }
    else {
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
  
  if($number =~ m/^\d{$digits}$/) { 
    return $number;
  }
  else {
    $number = "0".$number;
    Add_Prefix($number, $digits);
  }

}


## ---------------------------------------

1;
