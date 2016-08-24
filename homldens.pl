#!/usr/bin/perl
use Math::Trig;
###################################################
#finds line length density by summing distances 
#between points in restart files. stores distances 
#into bins based off what orthant (n-dim equivalent 
#of a quadrant, octant, etc.) the points are in
###################################################
#Usage: Before use: set dim=3 for hopf projection 
# 		density, 4 for R^4 (S^3)
# 
# 		./homldens.pl ../code/feb0312a 1 > hfeb03a.dat
#
#Output: (dim=4: 16 orthants)
#		time1 ldens0 ldens1 ldens2 ldens3 ... ldens15
#		time2 ldens0 ldens1 ldens2 ldens3 ... ldens15
#		... 
####################################################

#number of dimensions: 
#both for 3sphere, but =3, hopf projection; =4 for R^4
if ($#ARGV==2){# $ARGV[0]=$filepre, $ARGV[1]=$numskip, $ARGV[2]=$dim
	$dim=pop(@ARGV);
	if ($dim!=3 && $dim!=4){
		die "Illegal number of dimensions: only 3 or 4 allowed\n";
	}
}else{
	$dim=4;
}
$numskip = pop(@ARGV);
if ($numskip<1){
	$numskip=1;
}
$filepre = pop(@ARGV);

$prvortdens=0;	#print density per orthant per vortex 
				#(instead of per orthant w/ all vortices combined)

#Extract filename under filename's directory
@tmp=split(/\//,$filepre);
$filename=pop(@tmp);


$pi=3.1415926535898;
#$r0=.05;		#pulls radius from data points, themselves
	#volinv expression: when homog., density per orthant ~ overall density

$a0=1.3e-8;	#core radius (cm)
$kap=9.969e-4;		#quantum of circulation (cm**2/sec)

$num = 1; 
$numlow=$num;
$done=0;
while(!$done){
	$file = "$filepre/$filename.$num";
	open(A,"<$file") or die "Last file: $filename.$num";
	if (!($npts=<A>)){
		$done=1;
		break;	#might not be right syntax sometimes?
	}
	$nvort = <A>;
	$time = <A>;
	$dtime=<A>;
	chomp($time);
	#Retrieve number of points per vortex
	for ($ivort=0,@vortpts=();$ivort<$nvort;$ivort++){	
		$newline = <A>;
        ($start,$end,$term)=split(' ',$newline);				
        push (@vortpts, $end-$start+1);#adds to end of @vortpts
	}
	if (!$prvortdens){
		#d is distance: length in each orthant (indexed by k)
		for ($k=0;$k<2**$dim;$k++){#set to zero for each file
			$d[$k]=0.0;
			#if ($prvortdens) zero inside for (ivort) loop
		}
	}
	for ($ivort=0;$ivort<$nvort;$ivort++){
		if ($prvortdens){#also store distance per vortex per orthant
			for ($k=0;$k<2**$dim;$k++){
				$dv[$ivort][$k]=0.0;
			}
		}
		#first point is special: can't compute distance yet
		$data=<A>;
		if ($dim==3){#hopf
			@nl=split(/\s/,$data);
			#pull off last 4 (of 6)
			$tmp="$nl[2] $nl[3] $nl[4] $nl[5]";
			$data=&hopffib($tmp);	#call hopf fibration subroutine
		}
		@nl=split(/\s/,$data);
		for ($j=$dim-1;$j>=0;$j--){
			$rold[$j]=pop(@nl);	##w, then z, then, y, then x
			#Store original point for later
			$rf[$j]=$rold[$j];
		}
		#compute properties of this trial
		if ($numlow==$num && $ivort==0){
			#compute radius of 3sphere
			for ($r0=0.0,$j=0;$j<$dim;$j++){
				$r0+=$rf[$j]*$rf[$j];
			}
			$r0=sqrt($r0);
			#compute volume
			if ($dim==3){#hopf: S^2 of radius (original r0*r0)
				$volinv=8/(4*$pi*$r0**2);	#1/((1/8)*4*pi*r^2)
			}elsif ($dim==4){#3sphere: R^4
				#(1/16*3D volume of the surface of 4D sphere)^-1
				$volinv=16/(2*($pi**2)*$r0**3);
			}else{
				exit(1);
			}
			$beta=$kap/4/$pi*log($r0/$a0);	#approx, from rkf.c
		}
		#sum distance within each orthant
		for ($i=1;$i<=$vortpts[$ivort];$i++){
			if ($i!=$vortpts[$ivort]){#last point in vortex is special
				$data=<A>;
				if ($dim==3){#hopf
					@nl=split(/\s/,$data);
					#pull off last 4 (of 6)
					$tmp="$nl[2] $nl[3] $nl[4] $nl[5]";
					$data=&hopffib($tmp);	#call hopf fibration subroutine
				}
				@nl=split(/\s/,$data);
			}#else: $rold[] was set to $r (last on vortex)
			for ($j=$dim-1,$temp2=0.0;$j>=0;$j--){
				if ($i!=$vortpts[$ivort]){
					$r[$j]=pop(@nl);
				}else{#last point connects to first point
					$r[$j]=$rf[$j];#saved from before for (vortpts) loop
				}
				#straight line distance, squared
				$temp2+=($r[$j]-$rold[$j])*($r[$j]-$rold[$j]);
			}
			#index of $d[ ] is best thought in binary:
			#if any component <0 its index bit gets a 0
			#otherwise, it gets a 1. Each component gets its own bit. 
			#the full index is the inclusive or of all $dimensions index 
			# bits: if x<0, y<0, z>0, w<0: (in binary), $dint=0010 = 4
			for ($j=0,$dint=0.0;$j<$dim;$j++){
				#if 4 dimensional
				#x<0 --> xint = 0; x>=0 --> xint=1
				#y<0 --> yint = 0; y>=0 --> yint=2
				#z<0 --> zint = 0; z>=0 --> zint=4
				#w<0 --> wint = 0; w>=0 --> wint=8
				if ($rold[$j]<0){
					$rint[$j]=0;
				}else{
					$rint[$j]=2**$j;#like bit shifting but more obvious
				}
				$dint |= $rint[$j];	#inclusive or with component index bits
				#print STDERR "j=$j dint=$dint rint[j]=$rint[$j] \n";
			}
			#I HOPE THIS IS PORTABLE!
			#print "$dint\n";
			#increment that index with the distance along sphere
			$temp2=$r0*acos(1-$temp2/(2*$r0*$r0));
			if ($prvortdens){#add length per orthant per vortex
				$dv[$ivort][$dint] += $temp2;
			}else{
				$d[$dint] += $temp2;
			}
			#reset old point
			for ($j=0;$j<$dim;$j++){
				$rold[$j]=$r[$j];
			}
	    }#for (vortpts)
		if ($prvortdens){
			for ($k=0;$k<2**$dim;$k++){
				$dv[$ivort][$k]*=$volinv;
			}
		}#else (don't print dens. per vortex): outside for (ivorts) loop
	}#for (ivorts)
	#divide by volume
	if (!$prvortdens){
		for ($k=0;$k<2**$dim;$k++){
			$d[$k]*=$volinv;
		}
	}#else (print vortex density): step done within for (ivort) loop

	##We want to see the evolution of line length density
	###Reduced time (following Schwarz)
	#$time*=$beta;

	print "$time ";
	if ($prvortdens){
		for ($ivort=0;$ivort<$nvort;$ivort++){
			for ($k=0;$k<2**$dim;$k++){
				print "$dv[$ivort][$k]";
				if ($ivort==($nvort-1) && $k==(2**$dim-1)){
					print " ";
				}else{
					print "\n";
				}
			}
		}
	}else{
		for ($k=0;$k<2**$dim;$k++){
			if ($k!=((2**$dim)-1)){
				print "$d[$k] ";
			}else{
				print "$d[$k]\n";
			}
		}
	}
	$num+=$numskip;
	close A;
}

sub hopffib{#from construction of hopf fibration
    local($x,$y,$z,$w,$fib1,$fib2,$fib3);
    ($x,$y,$z,$w)=split(/\s/,$_[0]);
    $fib1=2*($x*$z+$y*$w);
    $fib2=2*($y*$z-$x*$w);
    #$fib3=$x*$x+$y*$y-$z*$z-$w*$w;     #naive way-> possibly bad errors
    #$fib3=($x*$x-$z*$z)+($y*$y-$w*$w); #minimize intermediate sums for 
                                        #better accuracy
    $fib3=($x-$z)*($x+$z)+($y-$w)*($y+$w);#Rewrite->even better accuracy

    #sqrt($fib1**2+$fib2**2+$fib3**2)=$r0**2

    $fibs="$fib1 $fib2 $fib3\n";
}	
