#########################################################################
#	File Name: lofreq.sh
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Fri 11 Nov 2016 11:22:41 AM CST
#########################################################################
#call SNV one by one 

bam=Sample1.realgined.bam
name=Sample1
core=8
refdb=zh11.genome.fa
mkdir -p lofreq
./Software/lofreq call-parallel --pp-threads $core -f $refdb -o lofreq/$name.vcf $bam
