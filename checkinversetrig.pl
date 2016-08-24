#!/usr/bin/perl
use Math::Trig;
#Check perl's implementation of acot, atan, atan2, atan(1/x)

$check=0;

if ($check==0){
	#Check atan(x) vs atan(1/x) vs 2atan(1/x)
	$dx=0.01;
	$xinit=-10;
	$xfin=10;
	$x=$xinit;
	while ($x<$xfin){
		if ($x!=0){
			$t=atan($x);#looks funky
			$ti=atan(1/$x);
			$t2i=2*atan(1/$x);
			print "$x $t $ti $t2i\n";
		}
		$x+=$dx;
	}
}elsif ($check==1){
	$dy=0.01;
	$dx=0.01;
	$yinit=-10;
	$yfin=10;
	$y=$yinit;
	while ($y<$yfin){
		if ($y!=0){
			$t1=atan2($y,1);
			$t2=atan2(-$y,-1);
			print "$y $t1 $t2\n";
		}
		$y+=$dy;
	}
}elsif ($check==2){
	#Check acot vs atan
	$dy=0.01;
	$dx=0.01;
	$yinit=-10;
	$xinit=-10;
	$xfin=10;
	$x=$xinit;
	while ($x<$xfin){
		if ($x!=0){
			$c=acot($x);#looks funky
			$t=atan($x);
			print "$x $c $t\n";
		}
		$x+=$dx;
	}
}
