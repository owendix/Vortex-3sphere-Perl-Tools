#!/usr/bin/perl
#Print particular lines in reverse order

$infile="outapr1309a.im.dat";
$outfile="outapr1309a.im2.dat";
open(A,"<$infile");
open(B,">$outfile");
$ct=0;
while (<A>){
	
	if ($_=~/=/){
		@temp=split(/\s/);
		chomp(@temp);
		$array[$ct]=$temp[$#temp];
		$ct++;
	}
}
foreach (@array){
	$f=pop(@array);
	print B $f,"\n";
}
close A;
close B;
