#!/usr/bin/perl
#
#Count the maximum vortex in printed files
#as a function of totalpts

$numskip=pop(@ARGV);	#how many to skip by
$filepre=pop(@ARGV);	#e.g. ../code/may2209a.

$num=1;
while(1){
	$file=$filepre.$num;
	open(A,"<$file") or die;
	$totalpts=<A>;
	chomp($totalpts);
	$nvort=<A>;
	chomp($nvort);
	<A>;
	$vmax=0;
	for ($i=0;$i<$nvort;$i++){
		$v=<A>;
		($start,$end,$term)=split(/\s/,$v);
		$vsize=$end-$start+1;
		if($vsize>$vmax){
			$vmax=$vsize;
		}
	}
	print "$totalpts  $vmax\n";
	close A;
	$num+=$numskip;
}
