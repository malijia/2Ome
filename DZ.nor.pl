#!/usr/bin/perl
BEGIN {
	push @INC,"/home/luzhk/Documents/bin/";
}
use luzhk;
use strict;
use Getopt::Long;
my %opts;
my $program=`basename $0`;
chomp $program;

# zhikelu@gmail.com
# DATE: May 24, 2012 
#split GFF into small bins for each gene
#
#Add strand info for peaks by luzhk 04/19/2012

GetOptions(\%opts, "f:s");
if (@ARGV != 3) {
	print "usage: .pl 1.dz 1.libsiz nor.libsize
	-f<type>		mp/bg ;type of depth file, mpipeup(dz,default) or bg, mp or bg file are sort by chr/pos;
				all files are assumed to be 1 based.
	\n";
	exit;
}
my $f="mp";
$f="bg" if($opts{"f"} =~/bg/i);

my $infile = shift;
open(IN1, $infile) or die $!;
open(OUT1, ">$infile.nor.bedgraph") or die $!;
my $Lib1 = shift;
my $Lib = shift;

Ptime("start!");

while (<IN1>) {
	next if (/^#/);
	chomp;
	my @info = split/\t/;
	my $sig;
	if($f eq "mp"){
		$sig = sprintf("%.2f",$info[2]*$Lib/$Lib1);
		print OUT1 "$info[0]\t$info[1]\t$info[1]\t$sig\n";
	}elsif($f eq "bg"){
		$sig = sprintf("%.2f",$info[3]*$Lib/$Lib1);
		print OUT1 "$info[0]\t$info[1]\t$info[2]\t$sig\n";
	}
}
close IN1;
close OUT1;

Ptime("Done!");


