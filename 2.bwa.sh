#########################################################################
#	File Name: globBWAMEM.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Fri 11 Nov 2016 11:22:41 AM CST
#########################################################################

picard=./Software/picard-tools-1.102 
GATK=./Software/GenomeAnalysisTK-3.4-46 
CORE=8
R1=R1.paired.fastq.gz
R2=R2.paired.fastq.gz
SampleName=Sample1
REF=./Zh11.genome.fa #download at http://mbkbase.org/ZH11/
mkdir -p tmp_pipe_data
bwa mem -M -t $CORE -R "@RG\tID:$SampleName\tLB:$SampleName\tSM:$SampleName\tPL:illumina\tPU:$SampleName" $REF $R1 $R2|samtools view -bS - > tmp_pipe_data/$SampleName.source.bam
samtools view -h -b -q30 tmp_pipe_data/$SampleName.source.bam > tmp_pipe_data/$SampleName.bam
samtools sort -m 1g -@ $CORE tmp_pipe_data/$SampleName.bam -o tmp_pipe_data/$SampleName.sorted.bam
samtools index tmp_pipe_data/$SampleName.sorted.bam
samtools flagstat tmp_pipe_data/$SampleName.source.bam > tmp_pipe_data/$SampleName.source.mapinfo
java -Xmx10g -Djava.io.tmpdir=/tmp -jar \$picard/FixMateInformation.jar I=tmp_pipe_data/$SampleName.sorted.bam  O=tmp_pipe_data/$SampleName.fix.bam SO=coordinate VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true
java -Xmx10g -Djava.io.tmpdir=/tmp -jar \$picard/MarkDuplicates.jar I=tmp_pipe_data/$SampleName.fix.bam O=tmp_pipe_data/$SampleName.markdup.bam METRICS_FILE=tmp_pipe_data/$SampleName.markdup.metricsFile CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true ASSUME_SORTED=true
java -Xmx10g -Djava.io.tmpdir=/tmp -jar \$GATK/GenomeAnalysisTK.jar -nt $CORE -T RealignerTargetCreator -R $REF -o tmp_pipe_data/$SampleName.intervals.list -I tmp_pipe_data/$SampleName.markdup.bam
java -Xmx10g -Djava.io.tmpdir=/tmp -jar \$GATK/GenomeAnalysisTK.jar -T IndelRealigner -R $REF -I tmp_pipe_data/$SampleName.markdup.bam --targetIntervals tmp_pipe_data/$SampleName.intervals.list -o tmp_pipe_data/$SampleName.realigned.bam
