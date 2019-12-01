# GWSBE
Regenerated Rice Re-sequencing to evaluating genome-wide specificity of base editors

This is the pipiline for this paper.



## 1.Clean fastq file using 1.Clean.sh ;
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
  
## 3.Call SNV/Indel use GATK,Lofreq and Strelka2;

``` 
   sh 3.gatk.sh
   #all the bam in the tmp_pipe_date will be use to call the SNV/Indel;
   sh 4.lofreq.sh
   #one bam by one bam used to call snp;each sample will have its vcf file in the lofreq dir;
   sh 5.strelka.sh
   #one bam by one bam used to call snp;each sample will have its vcf file in the strelka dir;
```

## 4.filter all the varient produced by GATK/Lofreq/Strelka2 use wild type sample;

   First edit the wt.txt file to specify the wild type sample and make sure the sample name is correct.like follow:
	
```
    cat wt.txt
	
	Sample1
	Sample2
	Sample3
```
	
  Then use follow command to filter the Lofreq/Strelka2 Raw vcf;
	
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
   **The outfile of GATK is the base format of future analysis.
	
```
	cd GATK
	perl ../Script/AnaGATK.pl
	cd ..
```
	
## 5. GATK, Lofreq and strelka filtered intersection.
   
	
	
	
