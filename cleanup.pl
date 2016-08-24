#!/usr/bin/perl

$infile="../../code/conf1.ip.dat";
$outfile="../../code/conf1.ip2.dat";
open(A,"<$infile");
open(B,">$outfile");
while (<A>){

	if ($_=~/=/){
		@temp=split(/\s/);
		chomp(@temp);
		$f=pop(@temp);
		print B $f,"\n";
	}
}
close A;
close B;
