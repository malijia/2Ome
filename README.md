# 2Ome
a customized analysis pipeline for Nm-seq

### Overview of the processing pipeline


### Pre-filtering
Sequencing reads from Illumina NextSeq-500 were pre-processed by removing standard adapters “AGATCGGAAGAGCACACGTCT” using Cutadapt. According to the rationale of the experimental design, a customized script was further used to filter out reads that do not carry the correct in-line barcode sequence in the most 3’ of sequencing reads  (Figure 1a). Another 5-nt from the most 5′ and most 3′ of the remaining reads were further chopped and these sequences were used as barcode to distinguish PCR duplicates from the enriched fragments. We name reads that passed all above filtering and processing as “post-filtering”, which were used in the following analysis.
```
cutadapt -f fastq -n 1 -e 0.1 -O 2 -m 15 -a AGATCGGAAGAGCACACGTCT -A GATCGTCGGACTGTAGAACT  -o $s.1.fastq.clipper -p $s.2.fastq.clipper $s.1.fastq $s.2.fastq
perl Dai.index2.pl $s.1.fastq.clipper,$s.2.fastq.clipper CTATAT
```

### Alignment and 2’OMe site identification
The post-filtering reads were mapped to human reference genome (hg38) and transcriptome with Tophat. In order to find significantly enriched sites that carrying the 2’OMe modification, we used the 3’ end of sequencing reads to calculate the depth of each position of all RNA molecules. We reasoned that signals on a potential 2’OMe site should present significant enrichment over the other regions on the same transcript, as well as over the same position of the matched input. On each nucleotide, we calculated the depths in both OED-treated sample and intact mRNA sample (input). Specifically, the following numbers were calculated and Chi-squared test was performed: the depth of the current site (Dbase) in both OED-treated and input samples, the total depth of the transcript (DSum) in the OED-treated and input samples, and the average depth of the transcript in the OED-treated sample (DAve). Positive sites were recorded if it meets the following criteria:
(1) Chi(Dbase_Nm*, D*Ave_Nm, Dbase_input*, D*Ave_input): log2(ratio)>=1 & Dbase_*Nm* >= 10
(2) Chi(Dbase_Nm*, D*Sum_Nm, DAve_Nm*, D*Sum_Nm): p-value < 0.01 & log2(Dbase_Nm / DAve_Nm)>=2.
```
### alignment and find enrichment region
$s=sampleName
$bin=binDir
$genome=species
$genomeDir=genomeDir

tophat -o $s.index --solexa-quals -p 20 -g 2 -G $genomedir/$genome.gtf --no-discordant --no-mixed --transcriptome-index=$genomedir/Tophat2/$genome $genomedir/$genome $s.1.fastq.clipper.index $s.2.fastq.clipper.index 
### calculate single nucleotide depth
perl $bin/P1.3EndPos.smallRNA.pl -PE 0 $s.bam.uniq.sam $s.2.uniq.bed
cat $s.2.uniq.bed|sort -k1,1 -k2,2n -k4,4 -k6,6 > $s.2.uniq.nodup.bed
perl $bin/DZ.nor.pl $s.uniq.nodup.bed.p.dz $a 1000000
perl $bin/DZ.nor.pl $s.uniq.nodup.bed.n.dz $a 1000000
perl $bin/Genome.exp.pl -o 1 $genomedir/$genome.genome $s.uniq.nodup.bed.p.dz 1 1 60000 $s.uniq.nodup.genome.p.exp
perl $bin/Genome.exp.pl -o 1 $genomedir/$genome.genome $s.uniq.nodup.bed.n.dz 1 1 60000 $s.uniq.nodup.genome.n.exp
perl $bin/BedExp.gene.fortest.pl $genomedir/$genome.transcript.len $s.OED.uniq.nodup.exp 1 1 $s.OED.uniq.fortest
perl $bin/Enrich.pl $s.OED.$t.all.gene.fortest 7,9,8,9
```
