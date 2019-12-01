#########################################################################
#       File Name: fixPaired.pl
#       > Author: QiangGao(BGI)
#       > Mail: qgao@genomics.cn
#       Created Time: Sun 01 Dec 2019 03:27:40 PM CST
##########################################################################
#20131218 version
#
my @sample=@ARGV;
if(@sample<4){
	usage();
}
my $sample=pop @sample;
my $project=pop @sample;

my %hash;
print "Begin:".localtime()."\n";
foreach my $sample (@sample){
chomp $sample;
	open($sample,"gzip -dc $sample|");
	my $flag;
	while(<$sample>){

		if($.==1){
			($flag)=$_=~/^(@\w\w\w)/;
		}

		if($_ =~/^$flag/){
#		if($_ =~/^\@HSQ/){
			my ($header,$tmp)=split(" ",$_);
			$hash{$header}+=1;
		}
	}
	close $sample;
	$.=0;
}
print "Read finished:".localtime()."\n";
my $unpaired=0;
my $ub=0;
my $allbase=0;
my $allnum=0;
foreach my $sample (@sample){
	chomp $sample;
	open(IN,"gzip -dc $sample|");
	open(R1out,">$sample.paired.fastq");
	open(R1unout,">$sample.unpaired.fastq");
	my $flag;
	while(defined($a=<IN>)){
		my $b=<IN>;
		my $c=<IN>;
		my $d=<IN>;
		#print $a;
		if($.==1){
			($flag)=$_=~/^(@\w\w\w)/;
		}
#		if($a=~/^\@HSQ/){
		if($a =~/^$flag/){
			my ($header,$tmp)=split(" ",$a);
			if($hash{$header}==2){
				$allnum+=1;
				$allbase+=length $b;
				print R1out $a;
				print R1out $b;
				print R1out $c;
				print R1out $d;
			}else{
				print R1unout $a;
				print R1unout $b;
				print R1unout $c;
				print R1unout $d;
				$unpaired+=1;
				$ub+=length $b; 
			}
		}
	}
	close R1out;
	close IN;
	close R1unout;
}

print "UnpairedReads:$unpaired\nUnpairedBase:$ub\n";
print "finished:".localtime()."\n";
open(OUT,">clean/$project.$sample.csv");
print OUT "$project,$sample,$allbase,$allnum,$unpaired,$ub\n";
close OUT;



sub usage{
	print "perl $0 r1.gz r2.gz\n";
}
