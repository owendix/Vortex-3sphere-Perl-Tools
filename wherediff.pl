#!/usr/bin/perl
#Reports the line number and line of the first difference between files

$file1=pop(@ARGV);
$file2=pop(@ARGV);

open(A,"<$file1");
open(B,"<$file2");
$ct=1;
while (<B>){
	chomp($_);
	$fl1=<A>;
	chomp($fl1);
	if ($fl1!=$_){
		print "$ct    $fl1    $_\n";
		last;
	}
	$ct++;	
}
close A;
close B;
