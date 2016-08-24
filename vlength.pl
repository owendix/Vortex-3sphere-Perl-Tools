#!/usr/bin/perl
use Math::Trig;
################################################
##finds line length FOR EACH VORTEX by summing distances between 
##points in restart files 
#################################################
## Input: (e.g.) ./vlength.pl ../code/jan1212a/jan1212a.101
##
## Output:  vort= 0 length= (length_v0) wraps= (length_v0/(2pi*r0)) 
## 			vort= 1 length= (length_v1) wraps= (length_v1/(2pi*r0)) 
##           ...
#################################################

#Obtains 3sphere size (r0) from data
$file = pop(@ARGV);
$pi=3.1415926535898;

open(A,"<$file") or die "Couldn't open $filename: $!\n";
if ($npts=<A>){
	$nvort = <A>;
	$time = <A>;
	$dtime=<A>;
	chomp($time);
	$ivort = 0;
	#Retrieve number of points per vortex
	while ($ivort < $nvort){	
		$newline = <A>;
   	    ($start,$end,$term)=split(' ',$newline);				
   	    push (@vortpts, $end-$start+1);
		$ivort++;
	}
   	$ivort = 0;	#Which vortex we're looking at
	@alldata=<A>;
	$line=0;
	while ($ivort < $nvort){
		$dist=0;	#Reset distance each vortex
		$newline = $alldata[$line];
		$line++;
		#($xold,$yold,$zold,$wold)=split(' ',$newline);
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
		#obtain 3sphere size from data
		$r0=sqrt(($xf*$xf+$yf*$yf)+($zf*$zf+$wf*$wf));
		$i=1;
		#print "$line    $xf    $yf    $zf    $wf\n";
		while ($i < $vortpts[$ivort]){
			$newline = $alldata[$line];
   	        #($x,$y,$z,$w)=split(' ',$newline);
			@nl=split(/\s/,$newline);
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
			$i++;
		    $line++;
           	#print "$line    $x    $y    $z    $w\n";
        }
		#Complete the ring with original point	
		#$dist += sqrt(($x-$xf)*($x-$xf)+($y-$yf)*($y-$yf)+
		#	 	($z-$zf)*($z-$zf)+($w-$wf)*($w-$wf));
		$temp2 = ($x-$xf)*($x-$xf)+($y-$yf)*($y-$yf)+
			 	($z-$zf)*($z-$zf)+($w-$wf)*($w-$wf);
		$dist += $r0*acos(1-$temp2/2/$r0/$r0);

		
		print "vort= $ivort length= $dist wraps= ".($dist/(2*$pi*$r0))."\n";

        $ivort++;
	}
	
	close A;
}#else: First data read failed

