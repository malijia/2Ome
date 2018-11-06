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

if (@ARGV == 0) {
	print "usage: .pl GenomeSize mpipeup/bg bin step 6(chr) out
	-f<type>		mp/bg ;type of depth file, mpipeup(dz,default) or bg, mp or bg file are sort by chr/pos;
				all files are assumed to be 1 based.
	-o			0:output 0,by default; 1:don't output 0;
	";
	exit;
}
GetOptions(\%opts, "f:s","o:i");
my $f="mp";
$f="bg" if($opts{"f"} =~/bg/i);
my $oflag=0;
$oflag=1 if($opts{'o'} == 1);

#######GFF annotaion
my $indir1 = shift;
Ptime("start! read file $indir1");
open(IN1, "$indir1") or die $!;
$indir1 = shift;
my $bin = shift;
my $step = shift;
my $batch=shift;
my $out = shift;
open(OUT1, ">$out") or die $!;


my %genome;
while(<IN1>){
	chomp;
	my @info = split/\t/;
	$genome{$info[0]} = $info[1];
}
close IN1;

my @order = sort{$a cmp $b} keys %genome;

my %sig;
my %TotalSig;
my $o=0;
my $chr;
my %chrflag;
my %Sigflag;
for(my$c=0;$c<@order;$c+=$batch){
	my %flag;
	for(my$i=0;$i<$batch&&($c+$i)<@order;$i++){
		$flag{$order[$c+$i]}=1;
	}
#	Ptime("$c start!");
	open(IN2, "$indir1") or die $!;
	while(<IN2>){
		chomp;
		my @info = split/\t/;
		$Sigflag{$info[0]} = 1;
	}
	close IN2;
	open(IN2, "$indir1") or die $!;
	while(<IN2>){
		next if(/^#/);
		chomp;
		my @info = split/\t/;
		next if($flag{$info[0]} != 1);
		$chr = $info[0] if($chr eq "");
		if($chr ne $info[0]){
#			Ptime("strat to output");
			output();
			$chr = $info[0];
		}
		$chrflag{$chr}=1;
		if($f eq "mp"){
			my $s = int($info[1]/$step) - int($bin/$step);
			my $e = int(($info[1])/$step);
			$TotalSig{$info[0]}+=$info[2];
			for(my $i=$s+1;$i<=$e;$i++){
				$sig{$info[0]}{$i} += $info[2];
			}
		}elsif($f eq "bg"){
			for(my $si=$info[1];$si<$info[2];$si++){
				my $s = int($si/$step) - int($bin/$step);
				my $e = int($si/$step);
				$TotalSig{$info[0]}+=$info[3];
				for(my $i=$s+1;$i<=$e;$i++){
					$sig{$info[0]}{$i} += $info[3];
				}
			}
		}else{
			print "Error, unknow file format\n";
			die;
		}
	}
#	Ptime("strat to output");
	output();
	close IN2;
}

sub output(){
	for(my $j=$o;$j<@order;$j++){
		my $chr = $order[$j];
		if($chrflag{$chr} !=1 && $Sigflag{$chr} == 1){
			last;
		}else{
#			Ptime("strat to output $chr $chrflag{$chr}");
			$o++;
			my $c=0;
			$c=1 if($bin==1);
#			print "$chr\t$genome{$chr}\n";
			$TotalSig{$chr}=0 if($TotalSig{$chr} eq "");
			for(my $i=0;$i<=(($genome{$chr}-$bin) >=0?($genome{$chr}-$bin):0);$i+=$step){
				if($sig{$chr}{$c} eq ""){
					print OUT1 "$chr\t".($i+1)."\t".($i+$bin)."\t-\t-\tNA\t0\t$genome{$chr}\t$TotalSig{$chr}\n" if($oflag==0);
				}else{
					print OUT1 "$chr\t".($i+1)."\t".($i+$bin)."\t-\t-\tNA\t$sig{$chr}{$c}\t$genome{$chr}\t$TotalSig{$chr}\n";
				}
				delete $sig{$chr}{$c};
				$c++;
			}
		}
	}
}

close OUT1;
Ptime("Done!");
