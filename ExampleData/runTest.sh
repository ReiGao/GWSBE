#########################################################################
#	File Name: runTest.sh
#	> Author: QiangGao(BGI)
#	> Mail: qgao@genomics.cn 
# Created Time: Wed 11 Nov 2020 05:20:25 PM CST
#########################################################################
#!/bin/bash
cd GATK
perl ../../Script/AnaGATK.pl
cd ..

cd Lofreq
perl ../../Script/AnaLoVcf.pl
cd ..
		
cd Strelka
perl ../../Script/AnaStr2Vcf.pl
cd ..

perl ../Script/ALLSITE.pl

perl ../Script/JiaoJiPBE.pl



