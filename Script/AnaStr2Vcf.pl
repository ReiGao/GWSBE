#########################################################################
#	File Name: AnaStr2Vcf.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Thu 06 Dec 2018 09:09:56 AM CST
#########################################################################

#!/usr/bin/perl -w
my @file=`find ./ -name "variants.vcf.gz"`;
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
	#../LC-ZP-2-2/results/variants/variants.vcf.gz
	my ($name)=$file=~/.*\/(.*?)\/resu/;
	next if(!(exists $back{$name}));
	#print "$name\n";
	open(IN,"gzip -dc $file|");
	while(<IN>){
		next if($_=~/^#/);
		my %h;
		my @tmp=split("\t",$_);
		my @t1=split(":",$tmp[8]);
		my @t2=split(":",$tmp[9]);
		@h{@t1}=@t2;
		my ($a,$b)=$h{"AD"}=~/(\d+)\,(\d+)/;
		#print "$tmp[0]\t$tmp[1]\t$tmp[8]\t$tmp[9]\t$h{'AD'}\n";
		my $af=$b/($a+$b) unless ($a+$b==0);
		next if($a+$b==0);
		#print "$tmp[0]\t$tmp[1]\t$af\n";
		$count{$tmp[0]}{$tmp[1]}+=1;
		$base{$tmp[0]}{$tmp[1]}{$tmp[4]}+=1;
		$basef{$tmp[0]}{$tmp[1]}+=$af;
	}
	close IN;
}
open(OUT,">WT.all.txt");
open(OUT1,">WT.diff.txt");
my %dif;
my %back;
foreach my $chr(sort %count){
	my @pos=sort keys %{$count{$chr}};
	foreach my $pos (@pos){
		my $flag=0;
		my $base;
		if($count{$chr}{$pos}==8){
			my @base=keys %{$base{$chr}{$pos}};
			if(@base>1){
				$flag=0;
				$back{$chr}{$pos}+=1;
			}else{
				if($basef{$chr}{$pos}==8){
				$flag=1;
				$dif{$chr}{$pos}="$base[0]";
				$base=$base[0];
				}else{
				 $flag=0;
				 $back{$chr}{$pos}+=1;
				}
			}
		}else{
			$flag=0;
			$back{$chr}{$pos}+=1;
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
	my ($name)=$file=~/.*\/(.*?)\/resu/;
	print "$name\n";
	next if(exists $back{$name});
	open(IN,"zcat $file|");
	open(OUT,">$name.filter.vcf");
	while(<IN>){
		next if($_=~/^#/);
		next if($_!~/^Chr/);
		next if($_!~/\tPASS\t/);
		my @tmp=split("\t",$_);
		#next if(length $tmp[3]>1);
		#next if(length $tmp[4]>1);
		my %h;
		my @tmp=split("\t",$_);
		my @t1=split(":",$tmp[8]);
		my @t2=split(":",$tmp[9]);
		@h{@t1}=@t2;
		my ($a,$b)=$h{"AD"}=~/(\d+)\,(\d+)/;
		#print "$tmp[0]\t$tmp[1]\t$tmp[8]\t$tmp[9]\t$h{'AD'}\n";
		my $af=$b/($a+$b) unless ($a+$b==0);
		next if(exists $back{$tmp[0]}{$tmp[1]});
		if(exists $dif{$tmp[0]}{$tmp[1]}){
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
