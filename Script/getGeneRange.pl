#########################################################################
#	File Name: getGeneRange.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Mon 15 Oct 2018 08:18:20 PM CST
#########################################################################

#!/usr/bin/perl -w
use strict;
my ($file,$range)=@ARGV;

if(!$file or !$range){
	print "USAGE:\nperl $0 ALLSite.vcf range.txt\n";
	exit;
}

open(IN,"$range") or die "$range Gene pos is not exists\n";
my %gene;
while(<IN>){
	next if($.==1);
	chomp $_;
	my @tmp=split(/\s+/,$_);
	my $gene=shift @tmp;
	$gene{$gene}{'Chr'}=$tmp[0];
	if($tmp[3]>$tmp[2]){
	$gene{$gene}{'S'}=$tmp[2];
	$gene{$gene}{'E'}=$tmp[3];
	}else{
	$gene{$gene}{'S'}=$tmp[3];
	$gene{$gene}{'E'}=$tmp[2];
	}
	print "$gene\t$gene{$gene}{'Chr'}\t$gene{$gene}{'S'}\t$gene{$gene}{'E'}\n";
}
close IN;
my @genes=keys %gene;
my %sam;
	
open(IN,"$file") or die "$file in not exists";
my $header;
my @sample;
open(OUT,">$file.GeneSample.pos.txt");
while(<IN>){
	chomp $_;
	if($_=~/#CHROM/){
		$header=$_;
		@sample=split(/\s+/,$_);
		#print "$sample[9]\n";
	}
	next if($_=~/#/);
	my @tmp=split("\t",$_);
	my $flag=0;
	foreach my $gene (@genes){
		next if($tmp[0] ne $gene{$gene}{'Chr'});
		if($tmp[1]>=$gene{$gene}{'S'} and $tmp[1]<=$gene{$gene}{'E'}){
			$flag=$gene;
			#print "$gene\t$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]\t$tmp[4]\n";
		}
	}
	next if($flag eq 0);
	#print "$flag\t$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]\t$tmp[4]\n";
	for(my $i=9;$i<@tmp;$i++){
		#print "$sample[$i] = $tmp[$i]\n";
		next if($tmp[$i]=~/\.\/\./);
		my ($a,$b,$d1,$d2)=$tmp[$i]=~/(\d)\/(\d)\:(\d+)\,(\d+)/;
		my @depth;
		push(@depth,$d1);
		push(@depth,$d2);
		next if($a==$b and $a==$tmp[2] ); #and ($d1==0 or $d2==0));
		$sam{$sample[$i]}{$flag}+=1;
		#print "$flag\t$sample[$i]\t$tmp[0]\t$tmp[1]\t$a\/$b\t$d1\t$d2\n";
		my $sum=$d1+$d2;
		print OUT "$flag\t$sample[$i]\t$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]\t$tmp[4]\t$a\/$b\t$depth[$tmp[2]]\t$sum\n";
	}
}
close IN;
close OUT;

