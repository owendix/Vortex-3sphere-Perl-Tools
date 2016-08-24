#!/usr/bin/perl
######################
#Prints stereographic projection of S^3 points, along 
#with Hopf vector at each point, in stereographic coordinates
######################
#Input: ./quiverplot.pl file
##where file is a restart file
#
#Output: 	r=x y z w, 				v(r)=-y x -w z, 
#			s=stereo(r)=x' y' z', 	u=vstereo(r) (see vstereo for components)
#(to stdout)	s1 u1
#				s2 u2
#				...
######################
use Math::Trig;

$closevorts=1;	#=1, save first point and reprint at end of vortex to close 
				#lines.

#infile
$file=pop(@ARGV);
#$file="xyperturb.initial0.S3.dat";
#outfile: just prints to screen
open(A,"<$file") or die "Cannot open input file: $file\n";
open(B,">&STDOUT") or die "Cannot open STDOUT";
$npts=<A>;			#How many points on the vortex
$nvort=<A>;			#How many rings are there
$time=<A>;			#What time is this file a snapshot of
$dtime=<A>;

#How to split data between vortices
for ($i=0; $i<$nvort; $i++){	
	$newline=<A>;		#Reads the entire line as a string
	($start,$end,$term)=split(' ',$newline);	#Splits string
	$vortpts[$i]= $end-$start+1;	#How many lines to read per vortex
}

#For each vortex
for ($ivort=0; $ivort < $nvort; $ivort++){
	#print each line to a file
	for ($i=0; $i<$vortpts[$ivort]; $i++){   
		$newline = <A>;
		#Accounts for new format of restart files:
		#with index # and recon # printed first
		@nl=split(/\s/,$newline);
		$w=pop(@nl);
		$z=pop(@nl);
		$y=pop(@nl);
		$x=pop(@nl);
		if ($ivort==0 && $i==0){
			$r0=sqrt($x*$x + $y*$y + $z*$z + $w*$w);
		}
		$newline="$x $y $z $w";
		#data format: "x1 x2 x3"
		$vwsign=-1;#vec assumes this
		$vwdir="w";
		#only does stereographic method
		$data=&stgraph($newline,$vwdir,$vwsign,$r0);
		$vec=&vstereo($newline,$vwsign,$r0);
		chomp($data);	#remove \n from end
		if ($data!=-1){		#Signal from stgraph: didn't eval this pt
			if ($closevorts && $i==0){#store and reprint first point
				$firstpt="$data $vec";
			}
			print B "$data $vec";
		}
	}#end of for all points in one vortex
	if ($closevorts){#print first point again, to close loops
		print B $firstpt;	
	}
	if ($ivort!=$nvort-1){
		print B "\n\n";	#this way gnuplot will split vortices, even 
		#if they aren't different colors (colors obtained w/ gnuplot 
		#command "index": splot 'datafile' index 0 w l, 'datafile' 
		#index 1 w l,...
	}
}#end of all vortices in a file
close A;

sub vstereo{
	local(@dat,$vec,$vwsign,$r0,$i);
	#assumes projection point equals: +-w
	@r=split(/\s/,$_[0]);#format: "x y z w"
	$vwsign=$_[1];#= (+-)1
	$r0=$_[2];#= || @r ||
	$f=1-$vwsign*$r[3]/$r0;	#common factor: from +-w point
	if ($f>1e-12){#will be dividing by this
		$v[0]=-$r[1]*$f+$vwsign*$r[0]*$r[2]/$r0;
		$v[1]=$r[0]*$f+$vwsign*$r[1]*$r[2]/$r0;
		$v[2]=-$r[3]*$f+$vwsign*$r[2]*$r[2]/$r0;
		
		for ($i=0;$i<3;$i++){
			$v[$i]=$v[$i]/($f*$f);
		}
	}
	
	$vec="$v[0] $v[1] $v[2]\n";
}

sub stgraph{
	local(@dat,@dat2,$d1,$vwdir,$vwsign,$x,$xj,$denom,$knt,$cnt,$cnt2,$points,$r0);
	$vwsign=$_[2];		# =(+-)1
	@dat=split(/\s/,$_[0]);	#points on 3sphere
	
	$r0=$_[3];		#Radius of the 3sphere (found in params.dat)

	$x=ord('x');			#returns the ascii value of 'x', 
	$vwdir=ord($_[1])-$x;		#$_[1] = x, y, z, or w
	if ($vwdir==-1){			#'w' < 'x', we want it higher than 'z'
		$vwdir+=4;
	}
	#Separate the variable that corresponds with the projection axis
	$cnt=0;
	$knt=0;
	foreach $d1 (@dat){
		if ($knt!=$vwdir){
			$dat2[$cnt]=$d1;
			$cnt++;
		}else{
			$xj=$d1;
		}
		$knt++;
	}
	$cnt2=0;
	$denom=$r0-$vwsign*$xj;
	if ($denom>1e-15){
		foreach (@dat2){
			$dat2[$cnt2]=$r0*$dat2[$cnt2]/$denom;
			$cnt2++;
		}
		$points="$dat2[0] $dat2[1] $dat2[2]\n";
	}else{
		$points=-1;		#The signal not to print this value, since no ascii character evaluates to negative
	}
}
