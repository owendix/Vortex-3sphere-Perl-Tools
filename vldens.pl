#!/usr/bin/perl
use Math::Trig;
#finds each vortex's line length density by summing 
#distances between points in restart files

$numst=1;

$nskip = pop(@ARGV);
$filepre = pop(@ARGV);	#don't include period

$pi=3.1415926535898;
#$r0=.05;		#pulls radius from data points, themselves

$a0=1.3e-8;	#core radius (cm)
$kap=9.969e-4;		#quantum of circulation (cm**2/sec)

for($num=$numst; $num<=$numend; $num+=$nskip, @vortpts=()){
	#$dist = 0;	#do this after every vortex
	$file = $filepre.$num;
	open(A,"<$file") or die "Couldn't open input file: $infile\n";
	$npts =<A>;
	$nvort = <A>;
	$time = <A>;
	$dtime=<A>;
	chomp($time);
	#Retrieve number of points per vortex
	for ($ivort=0; $ivort < $nvort; $ivort++){	
		$newline = <A>;
        ($start,$end,$term)=split(' ',$newline);				
        push (@vortpts, $end-$start+1);
	}
	for ($ivort=0; $ivort < $nvort; $ivort++){
		$newline = <A>;
		@nl=split(/\s/,$newline);
		$wold=pop(@nl);
		$zold=pop(@nl);
		$yold=pop(@nl);
		$xold=pop(@nl);
		#Store original point for later
		$xf=$xold;
		$yf=$yold;
		$zf=$zold;
		$wf=$wold;
		if ($num==$numst && $ivort==0){
			$r0=sqrt(($xf*$xf+$yf*$yf)+($zf*$zf+$wf*$wf));
			#(3D volume of the surface of 4D sphere)^-1
			$volinv=.5*($pi**-2)*($r0**-3);		
			$beta=$kap/4/$pi*log($r0/$a0);	#approx, from rkf.c	
		}
		$dist=0.0;	#Set with each vortex: diff from ldens.pl
		for ($i=0; $i < $vortpts[$ivort]; $i++){
			$newline=<A>;
			@nl=split(/\s/,$newline);
			$w=pop(@nl);
			$z=pop(@nl);
			$y=pop(@nl);
			$x=pop(@nl);
			$temp2 = ($x-$xold)*($x-$xold)+($y-$yold)*($y-$yold)+
			 	($z-$zold)*($z-$zold)+($w-$wold)*($w-$wold);
			$dist += $r0*acos(1-$temp2/(2*$r0*$r0));

			$xold = $x;
			$yold = $y;
			$zold = $z;
			$wold = $w;
        }
		#Complete the ring with original point	
		$temp2 = ($x-$xf)*($x-$xf)+($y-$yf)*($y-$yf)+
			 	($z-$zf)*($z-$zf)+($w-$wf)*($w-$wf);
		$dist += $r0*acos(1-$temp2/2/$r0/$r0);
		
		###Reduced time (following Schwarz)
		#$time*=$beta;
		
		$dist*=$volinv;#Set with each vortex: diff from ldens.pl
		if ($ivort==0){
			print "$time ";
		}
		print "$dist";#Print for each vortex: diff from ldens.pl
		if ($ivort==($nvort-1)){
			print "\n";
		}else{
			print " ";
		}
	}
	close A;	
}

