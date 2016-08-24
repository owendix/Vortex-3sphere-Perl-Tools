#!/usr/bin/perl
#
#Prints the line number of the first two lines that
#DO NOT MATCH!! Also prints those lines
#
$file2=pop(@ARGV);
$file1=pop(@ARGV);

open(A,"<$file1");
open(B,"<$file2");

$go=1;
$count=0;
while($go){
	$count++;
	$f1=<A>;
	$f2=<B>;
	if ($f1!~/$f2/){
		print "$count\n$f1$f2";
		$go=0;
	}
}
close A;
close B;
