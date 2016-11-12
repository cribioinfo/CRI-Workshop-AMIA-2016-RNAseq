#!/usr/bin/env perl

=head1 LICENSE

Build_RNAseq.pl

Copyright (C) 2016-2016 Center for Research Informatics, The University of Chicago

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

##############################################################################
# Riyue Bao 08/22/2016
# This script prepares project directory and config files for running CRI RNAseq pipeline.
##############################################################################
use strict;
use warnings;
use Cwd;
use Cwd qw(abs_path);
use IO::Handle;
use Getopt::Long;
use FileHandle;
use File::Basename;

## GMD modules
use lib dirname(abs_path($0))."/lib/perl5";
use RNAseq::PrintMenu;
use RNAseq::GetOpt;
use RNAseq::BuildProject;

##############################
# Main
##############################

## initialize
my $author = "Riyue Bao";
my $email = "rbao\@uchicago.edu";
my $org = "Center for Research Informatics, The University of Chicago";
my $version = "0.5.0";
my $release_date = "2016-11-03";
my $license = "LGPLv3";
my $desc = "Build project directory and config files for running RNAseq pipeline";
my $url = "https://github.com/riyuebao/CRI-Workshop-Nov2016-RNAseq";
my $program = basename($0);
my $dir = cwd();
my $time = localtime();
my $sttime = time;

## print menu
my $menu = Print_Menu($program, $author, $email, $version, $release_date, $license, $desc);
if(@ARGV == 0) { print "\n$menu\n"; exit; }

## run start
Print_Header();

## get command line options
$program = Get_Opt($program, $menu);

## build project directory and config files
$program = Build_Project($program);

## run end
Print_Footer();

##############################
# Functions
##############################

sub Print_Header
{
	my $sep = "-" x 80;
	my $header = qq~
$sep
Program            : $program
Version            : $version
Date/Time          : $time
Current Directory  : $dir

Copyright (c) 2016 $org
For support and documentation go to: $url
$sep~;

	print "$header\n";
}

sub Print_Footer
{
	# sleep 5;
	my $elptime = time - $sttime;
	my $footer = qq~
Program finished! Elapsed time: $elptime seconds.
~;

	print "$footer\n";
}
