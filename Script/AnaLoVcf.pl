#########################################################################
#	File Name: AnaLoVcf.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Thu 06 Dec 2018 09:09:56 AM CST
#########################################################################

#!/usr/bin/perl -w
use strict;
my @file=glob("./*.vcf.gz");
my %back;
open(IN,"../WT.txt") or die "WT.txt is not in ../";
while(<IN>){
	chomp $_;
	$back{$_}+=1;
}
close IN;
my %count;
my %base;
my %basef;
foreach my $file (@file){
	my ($name)=$file=~/.*\/(.*?)\.vcf/;
	next if(!(exists $back{$name}));
	open(IN,"gunzip -c $file|");
	while(<IN>){
		next if($_=~/^#/);
		my @tmp=split("\t",$_);
		my ($af)=$_=~/AF=(.*?);/;
		$count{$tmp[0]}{$tmp[1]}+=1;
		$base{$tmp[0]}{$tmp[1]}{$tmp[4]}+=1;
		$basef{$tmp[0]}{$tmp[1]}+=$af;
	}
	close IN;
}
open(OUT,">WT.all.txt");
open(OUT1,">WT.diff.txt");
my %dif;
my %back1;
foreach my $chr(sort %count){
	my @pos=sort keys %{$count{$chr}};
	foreach my $pos (@pos){
		my $flag=0;
		my $base;
		if($count{$chr}{$pos}==keys %back){
			my @base=keys %{$base{$chr}{$pos}};
			if(@base>1){
				$flag=0;
				$back1{$chr}{$pos}+=1;
			}else{
				if($basef{$chr}{$pos}== keys %back){
				$flag=1;
				$dif{$chr}{$pos}="$base[0]";
				$base=$base[0];
				}else{
				 $flag=0;
				 $back1{$chr}{$pos}+=1;
				}
			}
		}else{
			$flag=0;
			$back1{$chr}{$pos}+=1;
		}
		if($flag==0){
			print OUT "$chr\t$pos\t$count{$chr}{$pos}\n";
		}
		if($flag==1){
			print OUT1 "$chr\t$pos\t$count{$chr}{$pos}\t$base\n";
		}

	}
}
close OUT;
close OUT1;
foreach my $file (@file){
	my ($name)=$file=~/\/(.*?)\.vcf/;
	next if(exists $back{$name});
	open(IN,"gunzip -c $file|");
	open(OUT,">$name.filter.vcf");
	while(<IN>){
		next if($_=~/^#/);
		#next if($_!~/^Chr/);
		my @tmp=split("\t",$_);
		next if(exists $back1{$tmp[0]}{$tmp[1]});
		if(exists $dif{$tmp[0]}{$tmp[1]}){
			my ($af)=$_=~/AF=(.*?);/;
			#print "$af\t$_\n";
			next if($af==1);
		}
		$tmp[2]=$tmp[3];
		if(exists $dif{$tmp[0]}{$tmp[1]}){
			$tmp[2]=$dif{$tmp[0]}{$tmp[1]};
		}
		my $out=join("\t",@tmp);
		print OUT $out;
	}
	close IN;
	close OUT;
}
