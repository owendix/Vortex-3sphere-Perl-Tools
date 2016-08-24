#!/usr/bin/perl
#######################
#Compares two difft means of calculating
#cutoff reconnection distance
#######################
#
#
$a0=1.3e-8;
$r=1.0e-10;
while($r<1e10){
	$c1=2*$r/log($r/$a0);
	$c2a=$r/12;
	$c2b=$r/5;
	$r*=2.0;
	print "$r $c1 $c2a $c2b\n";
}
