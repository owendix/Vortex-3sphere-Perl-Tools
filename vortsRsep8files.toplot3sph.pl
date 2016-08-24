#!/usr/bin/perl
# Lops off start and end of restart files for gnuplot.
# Restart file stores point locations on the vortex ring
# at a set point in time
use Math::Trig;

#$flett=pop(@ARGV);#temporary, for multiple trials

$normalinput=0;	#=1 normalinput, multiple files
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
	$numend = -1;	#set = -1, to go until last file
	$nskip = 1;
	$fileprepre = "../code/";
	$filepost = "feb0312b";	#don't include the period at end
	#$filepost = "feb0312$flett";	#don't include the period at end
	$filepre = $fileprepre.$filepost."/".$filepost;	#Input file path
	#glob means get files matching expression
	if ($numend==-1){
		@tmp=glob("$filepre.*");
		$numend=$#tmp+1;	#checked, largest file number
	}
	$outfileprepre="images";
	$outdir=$outfileprepre."/".$filepost;
}else{#read one file, then output to screen
	#infile
	$file="../code/feb0312c/feb0312c.190";
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
	    print STDERR "Would you like to continue?\n";
	    print STDERR "Type 1 for yes, 0 for no.\n";
	    my $input=<STDIN>;
	    chomp $input;
	    if ($input!=1){
	        die "Exiting program\n";
	    }else{
			print STDERR "Continuing\n";
		}
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
	$type="s.";
}elsif ($meth=~/hyper/){	
	$type="h.";
}elsif ($meth=~/fiber/){
	$type="f.";	#f = fibration (hopf)
}else{
	print STDERR "Error, need to include method of projection from 3sphere:\n";
	die "Either: hyper, stereo, or fiber\n";
}

if ($normalinput){
	$outfileprepre=$outdir."/grb$type";	#type includes period at end
	$outfilepre=$outfileprepre.$filepost;
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
	#For each vortex
	for ($ivort=0; $ivort < $nvort; $ivort++){
		if ($normalinput){
			$outfile="$outfilepre.$ivort.$num";
	    	open(B,">$outfile") or die "Cannot open output file: $outfile\n";
		}
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
				if ($normalinput){
		    		print B $data;
				}else{
					print $data;
				}
		    }
		}#end of for all points in one vortex
		if ($normalinput){
			if ($closevorts){#print first point again, to close loops
				print B $data;	
			}
        	close (B);
		}else{
			if ($closevorts){#print first point again, to close loops
				print $data;	
			}
			print "\n";	#this way gnuplot will split vortices, even if 
			#they aren't different colors: so I don't have to run movie3sph.pl
		}
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
	local($thet1,$thet2,$thet3,$x,$y,$z,$w,$angs);
	($x,$y,$z,$w)=split(/\s/,$_[0]);
	$thet1=atan2(sqrt($w**2+$z**2+$y**2),$x);	#tan(thet)=y/x; thet=atan2(y,x);
	$thet2=atan2(sqrt($w**2+$z**2),$y);
	$thet3=atan2($w,$z);
	$angs="$thet1 $thet2 $thet3\n";		
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
