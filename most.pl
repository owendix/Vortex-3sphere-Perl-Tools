#!/usr/bin/perl
#Finds the largest value of a column split by whitespaces in a file

$file="untitled.txt";
open(A,"<$file");
$colnum=1;

$vortnum=0;
while (<A>)
{
	chomp($_);
	@dat=split(/\s/,$_);
	$vn=$dat[$colnum];
	if ($vortnum<$vn)
	{
		$vortnum=$vn;
	}
}
print "$vortnum\n";
close A;
