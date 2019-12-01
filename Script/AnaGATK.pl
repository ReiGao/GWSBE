#########################################################################
#	File Name: AnaGATK.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Mon 17 Sep 2018 10:02:08 PM CST
#########################################################################

#!/usr/bin/perl -w
use strict;
my $minDepth=500;
my $maxDepth=40000;

my $vcf="all_last.filtered.vcf";
open(IN,"../WT.txt") or die "WT.txt is not in ../";
my @name=<IN>;
close IN;
my %wt;
foreach(@name){
	chomp $_;
	$wt{$_}+=1;
}
my $wtnum=keys %wt;
close IN;
open(IN,"$vcf") or die "$vcf is not exists\n";
my @samplename;
my %back;
my %count;
my $all=0;
my $last=0;
open(OUT,">filter.vcf");
while(<IN>){
	chomp $_;
	if($_=~/^#CHROM/){
		@samplename=split("\t",$_);
		for(my $i=9;$i<@samplename;$i++){
			if(exists $wt{$samplename[$i]}){
				$back{$i}=$samplename[$i];
			}
		}
	}
	if($_=~/^#/){
		print OUT "$_\n";
		next;
	}
	$all+=1;
	my ($DP)=$_=~/DP=(\d+)/;
	next if($DP<$minDepth);
	next if($DP>$maxDepth);
	my @tmp=split("\t",$_);
	#next if($tmp[4]=~/\,/);
	#next if($_=~/Low/i);
	my $flag=0;
	my $homonum=0;
	my $missing=0;
	my $het=0;
	my %wttype;
	foreach my $i( keys %back){
		if($i=~/\.\/\./){
			$missing+=1;
		}
		next if($i=~/\.\/\./);
		my ($a,$b)=$tmp[$i]=~/(\d)[\/|\|](\d)/;
		if($a!=$b){
			$het+=1;
		}
		if($a==$b){
			$homonum+=1;
			$wttype{$a}+=1;
		}
	}
	if($missing >2){
		$flag=1;
	}elsif($het>0){
		$flag=2;
	}elsif($homonum =! $wtnum){
		$flag=3;	
	}
	#print "$het\t$missing\t$homonum\n" if($het>0);
	$count{$flag}+=1;
	next if($flag != 0);
	$last+=1;
	my @keys=keys %wttype;
	next if(@keys>1);
	$tmp[2]=$keys[0];
	my $out=join("\t",@tmp);
	print DP "$DP\n";
	next if($DP<100);
	print OUT "$out\n";
}
close IN;
close OUT;
close DP;
foreach(keys %count){
	print "Type$_\t$count{$_}\n";
}
print "all\t$all\nLast\t$last\n";

