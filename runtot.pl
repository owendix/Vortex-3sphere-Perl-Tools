#!/usr/bin/perl
#######################################
#Takes specified column of data and creates
#running total at each column entry
#######################################
#Input: (e.g.) ./runtot.pl ../code/recon.oct1410a.dat 1 
#		where 1 is the column number [0,#num cols-1]
#Output:  col0 col1 col2 ... collast runtotcol
#
######################################
$col=pop(@ARGV);
$infile=pop(@ARGV);

open(A,"<$infile");
$sum=0;
while($line=<A>){
	@dat=split(/\s+/,$line);
	#print "$dat[0] $dat[1]\n";
	$sum+=$dat[$col];
	chomp($line);
	print "$line $sum\n";
}
close A;
