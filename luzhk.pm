package luzhk;

use strict;

require Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 1.00;
@ISA = qw(Exporter);
@EXPORT = qw(Ptime Overlap Merge median max min avg sum codon2aa readFa GC tmCal encodeFa decodeFa);
@EXPORT_OK = qw(Ptime Overlap Merge median max min avg sum codon2aa readFa GC tmCal encodeFa decodeFa);


sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}


sub median{
	my (@array) = @_;
	my @infoS = sort{$a <=> $b} @array;
	if(@infoS%2 != 0){
		return $infoS[int(@infoS/2)];
	}else{
		return ($infoS[@infoS/2-1]+$infoS[@infoS/2])/2;
	}
}

sub avg{
	my (@array) = @_;
	my $sum=0;
	foreach my $i(@array){
		$sum+=$i/@array;
	}
	return $sum;
}

sub sum{
	my (@array) = @_;
	my $sum=0;
	foreach my $i(@array){
		$sum+=$i;
	}
	return $sum;
}

sub min{
	my (@array) = @_;
	my @infoS = sort {$a<=>$b} @array;
	return $infoS[0];
}

sub max{
	my (@array) = @_;
	my @infoS = sort {$a<=>$b} @array;
	return $infoS[-1];
}
1;

