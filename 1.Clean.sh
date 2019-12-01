#1.1 clean resquence data using Trimmomaitc;
R1=Sample1.R1.fastq.gz
R2=Sample1.R2.fastq.gz
project=GWSBE
sampleName=Sample1
outdir=$sampleName
core=8
java -jar ./Software/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads $core -phred33  $R1 $R2 $outdir/R1_trim_paired.clean.fq.gz $outdir/R1_trim_unpaired.clean.fq.gz $outdir/R2_trim_paired.clean.fq.gz $outdir/R2_trim_unpaired.clean.fq.gz ILLUMINACLIP:./Software/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:3 LEADING:2 TRAILING:10 SLIDINGWINDOW:1:2 MINLEN:75
#1.2 filter Quliyt < 10 over 10% reads; 
my $QUAL=10;
my $PROPER=10;
gunzip -c $outdir/R2_trim_paired.clean.fq.gz| fastq_quality_filter -v -q $QUAL -p $PROPER -z -Q 33 -o $outdir/R1.fastx.fq.gz
gunzip -c $outdir/R2_trim_paired.clean.fq.gz| fastq_quality_filter -v -q $QUAL -p $PROPER -z -Q 33 -o $outdir/R2.fastx.fq.gz
#1.3 fix mispair;
perl Script/fixPaired.pl $outdir/R1.fastx.fq.gz $outdir/R2.fastx.fq.gz $project $outdir
#1.4 gzip finial fastq file
pigz -p $core $outdir/R1.paired.fastq
pigz -p $core $outdir/R2.paired.fastq
#finail get the clean paired fastq;
#R1.paired.fastq
#R2.paired.fastq
