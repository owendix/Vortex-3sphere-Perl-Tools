#!/usr/bin/perl
#######################################
#Takes specified column of data and creates
#running difference (entry-entry_prior) at 
#each column entry. First entry is just the value itself:
#assumes previous virtual entry = 0.
#######################################
#Input: (e.g.) ./runtot.pl ../code/recon.oct1410a.dat 1 
#		where 1 is the column number [0,#num cols-1]
#Output:  col0 col1 col2 ... collast rundiffcol
#
######################################
$col=pop(@ARGV);
$infile=pop(@ARGV);

open(A,"<$infile");
$last=0;
$cnt=0;
while($line=<A>){
	@dat=split(/\s+/,$line);
	$diff=$dat[$col]-$last;
	chomp($line);
	print "$line $diff\n";
	$last=$dat[$col];
}
close A;
