use strict;

if(@ARGV!=2){
	print ".pl FileforTest columnsfortest(1,2,3,4) \n";
	exit;
}

my $indir;
$indir=shift;
open OUT1,">$indir.Enrich.p" or die"can't open file $indir $!\n";
open OUT1r,">$indir.Enrich.r" or die"can't open file $indir $!\n";

my $columns = shift;
my @col = split/,/,$columns;

print OUT1r "
data<-read.table(\"$indir\",sep=\"\\t\",quote=\"\",comment.char=\"\")
p<-data\$V$col[0];
r<-data\$V$col[0];
for(i in 1:length(p)){
#	p[i]<-fisher.test(matrix(c(data\$V$col[0]\[i],data\$V$col[1]\[i],data\$V$col[2]\[i],data\$V$col[3]\[i]),nrow=2))\$p
	p[i]<-fisher.test(matrix(c(data\$V$col[0]\[i],data\$V$col[1]\[i],data\$V$col[2]\[i],data\$V$col[3]\[i]),nrow=2))\$p
	r[i]<-log2(((data\$V$col[0]\[i]+1)*(data\$V$col[3]\[i]+1))/((data\$V$col[2]\[i]+1)*(data\$V$col[1]\[i]+1)))
}
FDR = p.adjust(p,\"fdr\")
z=FDR
z[r>=1] = qnorm(1-FDR[r>=1]/2)
z[r<1] = qnorm(FDR[r<1]/2)
write.table(cbind(data,p,FDR,r,z),\"$indir.Enrich.p\",sep=\"\\t\",quote=F,col.names=F,row.names=F)
";

close OUT1r;
`R CMD BATCH $indir.Enrich.r`;
