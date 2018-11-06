BEGIN {
	push @INC, "/home/luzhk/Documents/bin/";
}
use strict;
use luzhk;

# ljma@uchicago.edu
# 
#  

if (@ARGV != 5) {
	print "usage: .pl genome.transcript.len H1.IP.R1.gene.dz.extend.51.Depth step readslen out\n";
	exit;
}

my $infile = shift;
open(IN3, $infile) or die $!;
my $infile1 = shift;
my $step = shift;
my $rLen = shift;
$infile = shift;
open(OUT, " >$infile") or die $!;

Ptime("start!");
my %genome;
while(<IN3>){
	chomp;
	my @info = split/\t/;
	$genome{$info[0]} = $info[1];
}
close IN3;

my @order = keys %genome;

my $psedu=1;
open(IN1, $infile1) or die $!;
while (<IN1>) {
	next if (/^#/);
	chomp;
	my @info = split/\t/;
	next if($info[6]==0);
	my $a = sprintf("%.0f",$info[6]/$rLen)+$psedu;
	my $aM = sprintf("%.0f",$info[8]/($rLen*$genome{$info[0]}))+$psedu;
	next if($a<=$aM);
	my $T = sprintf("%.0f",$info[8]/$rLen);
	print OUT "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$a\t$T\t$aM\t$T\n";
}
close IN1;
close OUT;
Ptime("Done!");


