#########################################################################
#	File Name: JiaoJiPBE.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Mon 15 Oct 2019 09:13:21 PM CST
#########################################################################

my %filter;
my $file="target.txt" or die "target.txt is not existst\n";
open(IN,"$file");
while(<IN>){
	chomp $_;
	my @tmp=split("\t",$_);
	$filter{$tmp[0]}{$tmp[$1]}{$tmp[2]}=1;
	}
close IN;



my $outdir="./VennPBE/";
my $cc=`mkdir -p $outdir`;
my @stfile=glob("./strelka/*.filter.vcf");
my @lofile=glob("./LoFreq/*.filter.vcf");
my $gatk="./GATK/filter.vcf";
open(OUTLAST,">PBE.vcf");
my %str;
foreach my $vcf(@stfile){
print "$vcf\n";
open(IN,"$vcf") or die "$vcf is not exists\n";
my ($name)=$vcf=~/.*\/(.*?)\./;
open(OUT,">$outdir/$name.str.venn");
while(<IN>){
	my $flag=0;
	next if($_!~/\tPASS\t/);
	my @tmp=split("\t",$_);
	my %h;
	my @tmp=split("\t",$_);
	next if(exists $filter{$name}{$tmp[0]}{$tmp[1]});
	my @t1=split(":",$tmp[8]);
	my @t2=split(":",$tmp[9]);
	@h{@t1}=@t2;
	my ($a,$b)=$h{"AD"}=~/(\d+)\,(\d+)/;
	my $af=$b/($a+$b) unless ($a+$b==0);
	if($tmp[2]==$tmp[3]){
		$flag=1 if($tmp[3]=~/C/ and $tmp[4]=~/T/);
		$flag=1 if($tmp[3]=~/G/ and $tmp[4]=~/A/);
	}elsif($tmp[2]==$tmp[4]){
		 $flag=1 if($tmp[4]=~/C/ and $tmp[3]=~/T/);
         $flag=1 if($tmp[4]=~/G/ and $tmp[3]=~/A/);
	}else{
		print "ERRO $tmp[2]\n";
		next;
	}
	next if($flag==0);
	if($af==1){
		$sum{$name}{HOMO}+=1;
	}else{
		$sum{$name}{HET}+=1;
	}
	if($flag==1){
			$str{$name}{$tmp[0]}{$tmp[1]}+=1;
			print OUT "$tmp[0]\_$tmp[1]\n";
		}
	}
	close IN;
	close OUT;
}







my %lof;
#my @lofile=glob("/public-dss/Project/Project_Test/GaoLab2018/ZH112019/LoFreq/Ana/*.filter.vcf");
foreach my $vcf(@lofile){
open(IN,"$vcf") or die "$vcf is not exists\n";
my ($name)=$vcf=~/.*\/(.*?)\./;
print "lo\t$name\n";
open(OUT,">$outdir/$name.lof.venn");
while(<IN>){
	my $flag=0;
	my @tmp=split("\t",$_);
	next if(exists $filter{$name}{$tmp[0]}{$tmp[1]});
	my ($af)=$_=~/AF=(.*?);/;
	if($af==1){
		$sum1{$name}{HOMO}+=1;
	}else{
		$sum1{$name}{HET}+=1;
	}
	if($tmp[2]==$tmp[3]){
		$flag=1 if($tmp[3]=~/C/ and $tmp[4]=~/T/);
		$flag=1 if($tmp[3]=~/G/ and $tmp[4]=~/A/);
	}elsif($tmp[2]==$tmp[4]){
		 $flag=1 if($tmp[4]=~/C/ and $tmp[3]=~/T/);
         $flag=1 if($tmp[4]=~/G/ and $tmp[3]=~/A/);
	}else{
		print "ERRO $tmp[2]\n";
		next;
	}
	next if($flag==0);

	if($flag==1){
		$lof{$name}{$tmp[0]}{$tmp[1]}+=1;
		#print "$name $tmp[0] $tmp[1]\n";
		print OUT "$tmp[0]\_$tmp[1]\n";
	}
	}
	close IN;
	close OUT;
}

open(VCF,"$gatk");
my @name;
my $all=0;
my $hashdp;
my $hashComp;
my $hashsnp;
my %handle;
my %sum;
my %sum1;
while(<VCF>){
	chomp $_;
	if($_=~/#CHROM/){
		@name=split("\t",$_);
		print OUTLAST "##fileformat=VCFv4.1\n$_\n";
		for(my $i=9;$i<@name;$i++){
			open($handle{$name[$i]},">./$outdir/$name[$i].gatk.venn");
		}
	}
	next if($_=~/#/);
	my @tmp=split("\t",$_);
	next if($tmp[6] =~ /low/i);
	next if(length $tmp[3]>1);
	next if(length $tmp[4]>1);
	for(my $i=9;$i<@tmp;$i++){
		next if($tmp[$i]=~/\.\/\./);
		my ($a,$b)=$tmp[$i]=~/(\d)\/(\d)/;
		if($a==$b and $a==$tmp[2]){
			$sum1{$name[$i]}{HOMO}+=1;
		}
		if($a!=$b){
			$sum1{$name[$i]}{HET}+=1;
		}
	}

	my $flag=0;
	if($tmp[2]==0){
 		$flag=1 if($tmp[3]=~/C/ and $tmp[4]=~/T/);
		$flag=1 if($tmp[3]=~/G/ and $tmp[4]=~/A/);
	}elsif($tmp[2]==1){
		 $flag=1 if($tmp[4]=~/C/ and $tmp[3]=~/T/);
         $flag=1 if($tmp[4]=~/G/ and $tmp[3]=~/A/);
	}else{
		print "ERRO $tmp[2]\n";
		next;
	}
	next if($flag==0);

	for(my $i=9;$i<@tmp;$i++){
		next if($tmp[$i]=~/\.\/\./);
		next if(exists $filter{$name[$i]}{$tmp[0]}{$tmp[1]});
		my $outflag=0;
		my ($a,$b)=$tmp[$i]=~/(\d)\/(\d)/;
		if($a==$b and $a!=$tmp[2]){
			$outflag=1;
		}
		if($a!=$b){
			$outflag=1;
		}
		print {$handle{$name[$i]}} "$tmp[0]\_$tmp[1]\n" if($outflag==1);
	}
	my $outflag=0;
	for(my $i=9;$i<@tmp;$i++){
		#print "{$name[$i]}{$tmp[0]}{$tmp[1]}\tlo=$lof{$name[$i]}{$tmp[0]}{$tmp[1]})\n" if($tmp[0]=~/Chr5/ and $tmp[1]=~/237948/);
		if(!(exists $lof{$name[$i]}{$tmp[0]}{$tmp[1]}) or !(exists $str{$name[$i]}{$tmp[0]}{$tmp[1]})){
			$tmp[$i]='./.';
		}
		if(exists $filter{$name[$i]}{$tmp[0]}{$tmp[1]}){
			$tmp[$i]='./.';
		}
		next if($tmp[$i]=~/\.\/\./);
		my ($a,$b)=$tmp[$i]=~/(\d)\/(\d)/;
		if($a==$b and $a!=$tmp[2]){
			$sum{$name[$i]}{HOMO}+=1;
			$outflag=1;
		}
		if($a!=$b){
			$sum{$name[$i]}{HET}+=1;
			$outflag=1;
		}
	}
	my $now=join("\t",@tmp);
	print OUTLAST "$now\n" if($outflag==1);
}
close VCF;
close OUTLAST;
open(OUT,">PBE.jiaoji.summary.txt");
print OUT "Name\tPBEHomo\tPBEHet\tPBEAll\tallHomo\tallHet\tAll\n";
foreach my $name (sort keys %sum1){
	my $hom=$sum{$name}{HOMO};
	my $het=$sum{$name}{HET};
	my $all=$hom+$het;
	my $all2=$sum1{$name}{HOMO}+$sum1{$name}{HET};
	print OUT "$name\t$hom\t$het\t$all\t$sum1{$name}{HOMO}\t$sum1{$name}{HET}\t$all2\n";
}
close OUT;

for(my $i=9;$i<@name;$i++){
		close $handle{$name{$i}};
}
