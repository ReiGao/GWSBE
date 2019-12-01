#########################################################################
#	File Name: globCallUseGATK.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Thu 13 Nov 2014 02:01:03 PM CST
#########################################################################

#!/usr/bin/perl -w
use strict;
my @file=`find ./tmp_pipe_data -name "*.sorted.bam"|grep -v source`;
my $core=8;
my $input;
my $refdb="zh11.chrs.con.fasta";

foreach(@file){
	chomp $_;
	$input.="-I $_ ";
}
my $i=0;

my $dir="GATK";
open(OUT,">./SNPcallGATK.sh");
print OUT<<"EOF";
date
java -Xmx35g -Djava.io.tmpdir=$dir/tmp -jar ./Software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar -nt $core -glm BOTH -T UnifiedGenotyper -R $refdb $input  -o $dir/all_last.vcf -metrics $dir/all.UniGenMetrics -stand_call_conf 50.0 -stand_emit_conf 10.0 -dcov 1000 -A Coverage -A AlleleBalance
date
java -Xmx35g -Djava.io.tmpdir=$dir/tmp -jar ./Software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar  -R $refdb -T VariantFiltration -V:VCF $dir/all_last.vcf -o $dir/all_last.filtered.vcf --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "HARD_TO_VALIDATE" --filterExpression "DP < 5 " --filterName "LowCoverage" --filterExpression "QUAL < 30.0 " --filterName "VeryLowQual" --filterExpression "QUAL > 30.0 && QUAL < 50.0 " --filterName "LowQual" --filterExpression "QD < 1.5 " --filterName "LowQD" 
rm -Rf $dir/tmp
date
EOF
my $cc=`sh SNPcallGATK.sh`;

