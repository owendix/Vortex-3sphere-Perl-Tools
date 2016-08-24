#!/usr/bin/perl
######################
# Lops off start and end of restart files (vortex point data files) for gnuplot
# Projects R^4 data by either, fiber (hopf), hyper (hyperspherical) or stereo
# (stereographic) projection
# Prints projected vortex points into file for printing, with gnuplot,
# with TWO BLANK LINES between vortices, and if ($closevorts==1), by closing 
# the vortex loop onto itself.
# Can be modified to use either one data file or several: $normalinput=0,1
######################
#Input: ./toplot3sph.pl fiber OR
#		./toplot3sph.pl hspher OR
#		./toplot3sph.pl w -1 stereo (w & -1 mean projected from -r0.w point)
#Output: if ($normalinput==1){
#			./images/$filepost/grb$type.$filepost.$num (num=filenumber)
#			e.g.: ./images/feb0312a/grbf.feb0312a.16
#		}else{
#			STDOUT (raw projected data points) 	x11 x12 x13
#												x21 x22 x23
#												...
#		}
####################################################################
# 
use Math::Trig;

$flett=pop(@ARGV);#temporary, for multiple trials

$dontask=1;	#=1, doesn't ask about overwriting folder,=0, asks if applicable
$normalinput=1;	#=1 normalinput, multiple files
# =0, if just for a single file, infile set by hand, outfile set to STDOUT
$closevorts=1;	#=1, save first point and reprint at end of vortex to close 
				#lines.

if ($normalinput){
	print STDERR "Configured for a range of files, normalinput=$normalinput\n";
}else{
	print STDERR "Configured for a single file, normalinput=$normalinput\n";
}
if ($normalinput){#read from output of 3sphere trial
	$numst = 1; 
	$numend = 100;	#set = -1, to go until last file
	$nskip = 1;
	$fileprepre = "../code/";
	#$filepost = "feb0312a";	#don't include the period at end
	$filepost = "oct0412$flett";	#don't include the period at end
	$filepre = "$fileprepre$filepost/$filepost";	#Input file path
	#glob means get files matching expression
	if ($numend==-1){
		@tmp=glob("$filepre.*");
		$numend=$#tmp+1;	#checked, largest file number
	}
	$outfileprepre="images";
	$outdir=$outfileprepre."/".$filepost;
}else{#read one file, then output to screen
	#infile
	$file="../code/feb0312f/feb0312f.50";
	#$file="xyperturb.initial0.S3.dat";
	#outfile: just prints to screen
	$numst=0;
	$numend=0;
	$nskip=1;	#needed to exit loop
}
#Make directory for output files: 
#Files have format: images/filepost/grb$type.filepost.vort#.file#
if ($normalinput){
	if (!(mkdir $outdir)){#Returns false and sets $! (errno) if fails
	    print STDERR "Cannot mkdir $outdir\n";
	    print STDERR "$!\n";   #Print errno
		print STDERR "Existing directory and files will not be deleted,";
		print STDERR " but files of same name will be overwritten.\n";
		if (!$dontask){
			print STDERR "Would you like to continue?\n";
	    	print STDERR "Type 1 for yes, 0 for no.\n";
	    	my $input=<STDIN>;
	    	chomp $input;
	    	if ($input!=1){
	    	    die "Exiting program\n";
			}
		}
		print STDERR "Continuing...\n";
	}
}
#method of projecting 3sphere surface
$meth=pop(@ARGV);#stereo | hyper | fiber

if ($meth=~/stereo/){
	$vwsign=pop(@ARGV);
	$vwdir=pop(@ARGV);
	if ($vwdir=~/x/ || $vwdir=~/y/ || $vwdir=~/z/ || $vwdir=~/w/){
		if ($vwsign!=-1 && $vwsign!=1){
			die "Error, second argument needs to be -1 or 1\n";
		}
	}else{
		die "Error, first argument needs to be x, y, z, or w\n";
	}
	$type="s";
}elsif ($meth=~/hyper/){	
	$type="h";
}elsif ($meth=~/fiber/){
	$type="f";	#f = fibration (hopf)
}else{
	print STDERR "Error, need to include method of projection from 3sphere:\n";
	die "Either: hyper, stereo, or fiber\n";
}

if ($normalinput){
	$outfileprepre=$outdir."/grb$type";
	$outfilepre="$outfileprepre.$filepost";
}

for ($num=$numst; $num<=$numend; $num+=$nskip, @vortpts=()){
	if ($normalinput){
		$file = "$filepre.$num";
	}
	open(A,"<$file") or die "Cannot open input file: $file\n";
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
	if ($normalinput){
		$outfile="$outfilepre.$num";
		open(B,">$outfile") or die "Cannot open output file: $outfile\n";
	}else{
		open(B,">&STDOUT") or die "Cannot open STDOUT";
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
			if ($num==$numst && $i==0){
				$r0=sqrt($x*$x + $y*$y + $z*$z + $w*$w);
			}
		    $newline="$x $y $z $w";
			#if ($meth=~/coordsfiber/){
			#	$data=&hopfcoords($newline);
		    if ($meth=~/hyper/){
				$data=&hspher($newline);
		    }elsif ($meth=~/stereo/){
				$data=&stgraph($newline,$vwdir,$vwsign,$r0);
		    }elsif ($meth=~/fiber/){
				$data=&hopffib($newline);
			}
		    if ($data!=-1){		#Signal from stgraph: didn't eval this pt
				if ($closevorts && $i==0){#store and reprint first point
					$firstpt=$data;
				}
		   		print B $data;
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
	if ($normalinput){
		close B;
	}
	close A;
}

sub hopffib{#from construction of hopf fibration
	local($x,$y,$z,$w,$fib1,$fib2,$fib3);
	($x,$y,$z,$w)=split(/\s/,$_[0]);
	$fib1=2*($x*$z+$y*$w);
	$fib2=2*($y*$z-$x*$w);
	#$fib3=$x*$x+$y*$y-$z*$z-$w*$w;		#naive way-> possibly bad errors
	#$fib3=($x*$x-$z*$z)+($y*$y-$w*$w);	#minimize intermediate sums for 
										#better accuracy
	$fib3=($x-$z)*($x+$z)+($y-$w)*($y+$w);#Rewrite->even better accuracy

	#sqrt($fib1**2+$fib2**2+$fib3**2)=$r0**2

	$fibs="$fib1 $fib2 $fib3\n";
}
sub hspher{	
	local($thet1,$thet2,$thet3,$x,$y,$z,$w,$angs,$pi,$d1,$d2);
	($x,$y,$z,$w)=split(/\s/,$_[0]);
	#tan(thet)=y/x; thet=atan2(y,x);
	$d1=sqrt($w**2+$z**2+$y**2);
	$d2=sqrt($w**2+$z**2);
	if ($d1>1e-12 && $d2>1e-12 && $w>1e-12){
		$thet1=acot($x/$d1);	
		$thet2=acot($y/$d2);
		$thet3=$pi-2*atan2($w,($d2+$z));
		$angs="$thet1 $thet2 $thet3\n";		
	}else{
		$angs=-1;
	}
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
