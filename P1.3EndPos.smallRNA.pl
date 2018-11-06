#!/usr/bin/perl
#Informatic Biology departments of Beijing Genomics Institute (BGI) 
use strict;
use luzhk;
use Getopt::Long;
my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 


Usage: $program .pl Control.clipper.fastq.filter.sam out
	-PE       0(singleend), default 1(pairend)
	-help               output help information

USAGE

GetOptions(\%opts, "PE:i","help!");
die $usage if ( @ARGV==0 || defined($opts{"help"}));

#****************************************************************#
#--------------------Main-----Function-----Start-----------------#
#****************************************************************#
BEGIN {
	push @INC, "/home/luzhk/Documents/bin/";
}
if (@ARGV != 2) {
	print "usage: .pl Control.clipper.fastq.filter.sam out\n";
	exit;
}

my $PEFlag = 1;
$PEFlag = $opts{'PE'} if($opts{'PE'} ne "");

my $infile = shift;
open(IN1, $infile) or die $!;
$infile = shift;
#open(OUT, "|sort -k2,2nr >$infile") or die $!;
open(OUT, ">$infile") or die $!;

Ptime("start!");
my %total;

while (<IN1>) {
	next if (/^#/);
	if (/^@/){
		next;
	}
	chomp;
	my @info = split/\t/;
	my $strand="+";
	$strand = "-" if(($info[1]&16) == 16);
	next if(($info[1]&64) != 64 && $PEFlag == 1);
	my $test = $info[1]&16;
#	print "$info[1]\t$test\n";
	my @seq = split//,$info[9];
#	print "strand $strand\t$info[9]\n";
	my $Rs=$info[3];
	my $Re=$Rs+length($info[9])-1;
	my $pR=1;
	my $pS=1;
	my $pL=1;
	my %POSmap;
	my $flag=0;
	my $Rlen = length($info[9]);
	my @temp = split//,$info[9];
	while($info[5]=~/([0-9]+)([MIDNSHPX=])/g){
		if($2 eq "M"){
			for(my $i=0;$i<$1;$i++){
				$POSmap{$pL+$i}{'R'}=$pR+$i;
				$POSmap{$pL+$i}{'S'}=$pS+$i;
			}
			$pR+=$1;
			$pS+=$1;
			$pL+=$1;
		}elsif($2 eq "D" || $2 eq "N"){
			$pR+=$1;
		}elsif($2 eq "I"){
			for(my $i=0;$i<$1;$i++){
				$POSmap{$pL+$i}{'R'}=$pR+1;
			}
			$pS+=$1;
		}else{
			print "Error, can't parse $_\n";
			$flag=1;
		}
	}
	foreach my $p(sort{$a<=>$b} keys %POSmap){
#		print "$p:$POSmap{$p}{'R'};";
	}
#	print "\n";
	foreach my $p(sort{$a<=>$b} keys %POSmap){
#		print "$p:$POSmap{$p}{'S'};";
	}
#	print "\n";
	my @Porder = sort{$a<=>$b} keys %POSmap;
	if($strand eq "-"){
		my $p = $POSmap{$Porder[0]}{'R'}+$info[3]-1;
		print OUT "$info[2]\t$p\t$p\t$Rlen,$info[3],$info[7]\t$temp[0]\t-\n";
	}else{
		my $p = $POSmap{$Porder[-1]}{'R'}+$info[3]-1;
		print OUT "$info[2]\t$p\t$p\t$Rlen,$info[3],$info[7]\t$temp[-1]\t+\n";
	}
}
close IN1;

close OUT;

Ptime("Done!");


