# GWSBE
Regenerated Rice Re-sequencing to evaluating genome-wide specificity of base editors

This is the pipiline for this paper.


#### Dependencies

```
perl 
bwa
samtools
bedtools
```


## 1.Clean fastq file using 1.Clean.sh.
  please set the the R1,R1,Sample,core at the top of shell,Then use this command:
``` 
   sh 1.clean.sh
``` 
## 2.using bwa to mapping the reads to the Refgenome;
  The RefGenome ZH11 can be download at http://mbkbase.org/ZH11/;
``` 
   sh 2.bwa.sh
```  
  The mapping result will in the tmp_pipe_data file;
  The *.realigned.bam is the bam file use for GATK,Lofreq and strelka2;
  
## 3.Call SNV/Indel use GATK,Lofreq and Strelka2.

``` 
   sh 3.gatk.sh
   #all the bam in the tmp_pipe_date will be use to call the SNV/Indel;
   sh 4.lofreq.sh
   #one bam by one bam used to call snp;each sample will have its vcf file in the lofreq dir;
   sh 5.strelka.sh
   #one bam by one bam used to call snp;each sample will have its vcf file in the strelka dir;
```

## 4.filter all the varient produced by GATK/Lofreq/Strelka2 use wild type sample.

   First edit the WT.txt file to specify the wild type sample and make sure the sample name is correct.like follow:
	
```
    cat WT.txt
	
	Sample1
	Sample2
	Sample3
```
	
  Then use follow command to filter the Lofreq/Strelka2 Raw vcf;The filter vcf will be produce in the file name *.filter.vcf .
	
```
	cd Lofreq
	perl ../Script/AnaLoVcf.pl
	cd ..
	
	cd strelka
	perl ../Script/AnaStr2Vcf.pl
	cd ..
```

   The following filters GATK results, which include filtering regions of repeated sequences by depth to improve SNV accuracy. ($minDepth and $minDepth in the AnaGATK.pl)
   Corrects incorrect bases on the ref genome through wild-type status.
   The output file filter.vcf, the third column, 0 and 1 state, 0 means that all wild-type and reference genomes are the same, 1 means that all wild-type and reference genomes are different. 
   The filter vcf is named filter.vcf; 
#### This outfile of GATK is the base format of future analysis.
	
```
	cd GATK
	perl ../Script/AnaGATK.pl
	cd ..
```
	
## 5. GATK, Lofreq and strelka filtered intersection.
   This script will read the *.filter.vcf(Lofreq/Strelka2) and filtered.vcf(GATK) files and produce ALLSite.vcf file is the intersection file;
   the other outfile follows:
   
   * ALLSite.vcf --- The intersection vcf file ,the format same as GATK vcf.
   * AllSNP.jiaoji.summary.txt ---Contains SNV statistics files for all samples.
   * Mutation.*.txt---Contains statistics of different mutation types for each software(JJ name means intersection).
   * VennALLSITE --- This directory contains the specific information of the SNV generated by each software of all the samples, which can be used to draw Venn diagrams later.
   
```
	perl ./Script/ALLSITE.pl 
```

## 6.Obtaining and filtering regions of on target sites.

   We use BBmap(https://github.com/BioInfoTools/BBMap) to obtain the interval position information of sgRNA on the genome. Use the following command:
   
```
  bbmap/bbmap.sh in=Target.fa ref=./ZH11_genome_chr.cor.fasta out=bbmap.sam maxindel=100 k=10 slow
```
   then covert the outfile to the follow format:

```
	cat range.txt
	qName   tName   tStrand tStart  tEnd
	PBE-ACC-T3_P2_JS-2_HP2/0_23     Chr5    1       13098162        13098185
	PBE-ACC-T1_ACCB/0_23    Chr5    0       13097961        13097984
	PBE-ACC-T2_ACCC/0_23    Chr5    0       13098250        13098273
	PBE-WXB_P3_JS-5_HP3/0_23        Chr6    0       1765048 1765071
	.
	.
	.
	.

```
  
   The following script can be combined with ALLSite.vcf generated in step 5 to obtain all ontarget sites in the sgRNA region.

```
   perl getGeneRange.pl ALLSite.vcf ./range.txt
```
   The output file is ALL.vcf.GeneSample.pos.txt which contain all sample all site on-targe information.
   
## 7.Filter out On-target sites and get off-target sites.
   Covert format to the follow command
   
```
awk '{print $2"\t"$3"\t"$3}' ALL.vcf.GeneSample.pos.txt > target.txt
perl script/ALLSITEnotarget.pl

```
   * ALLnotarget.vcf--- The intersection vcf file with no on-target site ,the format same as GATK vcf.
   * AllSNP.jiaoji.summary.txt ---Contains SNV statistics files for all samples.
   * Mutation.*.txt---Contains statistics of different mutation types for each software(JJ name means intersection).
   * VennALLnotarge --- This directory contains the specific information of the SNV generated by each software of all the samples, which can be used to draw Venn diagrams later.

#### PBE only site use follow command.The output format is the same as above.

   PBE.vcf is the site only contain PBE off-target site.

```
perl script/JiaoJiPBE.pl

```
#### ABE only site use follow command;

   ABE.vcf is the site only contain PBE off-target site.
  
```
perl script/JiaoJiABE.pl

```
  
## 8. find sgRNA-like off-target edits
  
   We find the sgRNA-like off-target edits using Cas-offinder download from http://www.rgenome.net/cas-offinder/portable and follow the step on the web;
   The follow input file using to find lower 5 number of mismatch compare with sgRNA:
```
   C:\cas-offtarge\ZH11_genome_chr.cor.fasta
   NNNNNNNNNNNNNNNNNNNNNGG
   TTCCTCGTGCTGGACAAGTG 5
   AGCCATGGGAATGTAGACAA 5
   TCCACAGCTATCACACCCAC 5
   TCCTCGGTACGACCAGTACA 5
   CAGGTCCCCCGCCGCATGAT 5
   CGGCGACGGCGAGCAAGTGG 5
   TAGCACCCATGACAATGACA 5
   ACTAGATATCTAAACCATTA 5
   CATAGCACTCAATGCGGTCT 5
   CCTTGAATGCGCCCCCACTT 5
   AGCACATGAGAGAACAATAT 5
```
  
