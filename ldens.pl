#!/usr/bin/perl
use Math::Trig;
################################################
##finds line length density by summing distances between 
##points in restart files accounts for periodic boundary 
##conditions over distance r0
#################################################
## Input: (e.g.) ./ldens.pl ../code/oct0110a 3 
##           where 3 is the number of files to skip (actually 3-1)
##
## Output:   time(oct0110a.1) line_length_density(oct0110a.1)
##           time(oct0110a.2) line_length_density(oct0110a.2)
##           ...
##           time(oct0110a.last) line_length_density(oct0110a.last)
#################################################

if ($#ARGV==1){#$ARGV[0] = filepre, $ARGV[1] = numskip
	$numskip = pop(@ARGV);
	if ($numskip<1){
		$numskip=1;
	}
}elsif ($#ARGV==0){
	$numskip=1;
}
$filepre = pop(@ARGV);

@tmpar = split(/\//,$filepre);
$filename=$tmpar[$#tmpar];  #Retrieve filename
#print "$filename\n";

$pi=3.1415926535898;
#$r0=0.05;		#pulls radius from data points, themselves
$a0=1.3e-8;	#core radius (cm)
$kap=9.969e-4;		#quantum of circulation (cm**2/sec)

$num = 1; 
$numlow=$num;
$done=0;
while(!$done){
	$dist = 0;
	$file = "$filepre/$filename.$num";
	open(A,"<$file") or die "Last file: $filename.$num";
	if (!($npts=<A>)){
		$done=1;
		break;	#might not be right syntax sometimes?
	}
	$nvort=<A>;
	$time=<A>;
	$dtime=<A>;
	chomp($time);
	#Retrieve number of points per vortex
	for($ivort=0, @vortpts=(); $ivort < $nvort; $ivort++){	
		$newline = <A>;
   	    ($start,$end,$term)=split(' ',$newline);				
   	    push (@vortpts, $end-$start+1);
	}
	#for all vortices
	for ($ivort=0; $ivort < $nvort; $ivort++){
		$dataline=<A>;
		@nl=split(/\s/,$dataline);
		$wold=pop(@nl);
		$zold=pop(@nl);
		$yold=pop(@nl);
		$xold=pop(@nl);
		#Store original point for later
		$xf=$xold;
		$yf=$yold;
		$zf=$zold;
		$wf=$wold;
		if ($num==$numlow && $ivort==0){
			$r0=sqrt(($xf*$xf+$yf*$yf)+($zf*$zf+$wf*$wf));
			#(3D volume of the surface of 4D sphere)^-1
			$volinv=.5*($pi**-2)*($r0**-3);		
			$beta=$kap/4/$pi*log($r0/$a0);	#approx, from rkf.c
		}
		for ($i=1; $i < $vortpts[$ivort]; $i++){
			$dataline=<A>;
			@nl=split(/\s/,$dataline);
			$w=pop(@nl);
			$z=pop(@nl);
			$y=pop(@nl);
			$x=pop(@nl);
			#$dist += sqrt(($x-$xold)*($x-$xold)+($y-$yold)*($y-$yold)+
				# 	($z-$zold)*($z-$zold)+($w-$wold)*($w-$wold));
			$temp2 = ($x-$xold)*($x-$xold)+($y-$yold)*($y-$yold)+
			 	($z-$zold)*($z-$zold)+($w-$wold)*($w-$wold);
			$dist += $r0*acos(1-$temp2/2/$r0/$r0);

			$xold = $x;
			$yold = $y;
			$zold = $z;
			$wold = $w;
        }
		#Complete the ring with original point	
		#$dist += sqrt(($x-$xf)*($x-$xf)+($y-$yf)*($y-$yf)+
		#	 	($z-$zf)*($z-$zf)+($w-$wf)*($w-$wf));
		$temp2 = ($x-$xf)*($x-$xf)+($y-$yf)*($y-$yf)+
			 	($z-$zf)*($z-$zf)+($w-$wf)*($w-$wf);
		$dist += $r0*acos(1-$temp2/2/$r0/$r0);
	}
	#$dist *= 0.5066061441;	#Make it per volume? Not correct
	$dist*=$volinv;
	
	##We want to see the evolution of line length density
	###Reduced time (following Schwarz)
	#$time*=$beta;

	#print "$time	$dist \n";
	print "$time $dist\n";
	#next file
	$num+=$numskip;
	close A;
}

