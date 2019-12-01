#########################################################################
#       File Name: lofreq.sh
#       > Author: QiangGao
#       > Mail: qgao@genetics.ac.cn 
#       Created Time: Fri 11 Nov 2016 11:22:41 AM CST
#########################################################################
#call SNV one by one use strelka
core=8
bam=Sample1.realigned.bam
name=Sample1
refdb=Zh11.genome.fa
mkdir -p strelka
./Software/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaGermlineWorkflow.py \\
        --bam $_ \\
        --referenceFasta $refdb \\
        --runDir ./strelka/$name
cd ./strelka/$name
./runWorkflow.py -m local -j $core
cd ../..
