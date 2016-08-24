#!/usr/bin/perl
# Makes a gnuplot script for a "movie"=series of plots printed sequentially
# Different vortices are separated into gnuplot "blocks"=series of 
# data rows separated by TWO blank row (at least it only prints diff
# colors w/ 2)
#For use with toplot3sph.pl
#######
#Old version: movie3sph.vortsRsep8files.pl, toplot3sph.vortsRsep8files.pl
######################################################################
#Change: $num, $numend, $nskip, $type, $fileprepost, and some parameters
#		below for how they're printed: $pvort,$vnum,$numprint
######################################################################
#gnuplot blocks:
#Lines don't connect between blocks of data: w lines or w linespoints
#w/o specifying which block: prints all blocks (vortices) same color
#Specify blocks with "index" or "every" command in gnuplot
#
#gnuplot One-Liners: (gnuplot abbrevs: w=with, l=lines, lp=linespoints)
#		Assumes vortices separated by blank line
#
##Print all vortices (0:5) same color:
# 	splot '3Dblockdatafile' w l
##Print all vortices different colors:
#	splot '3Dblockdatafile' index 0 w l,\
#		index 1 w l,\
#		index 2 w l,\
#		index 3 w l,\
# 		index 4 w l,\
#		index 5 w l
##Print first first 5 one color,last 1 different color:
#	splot '3Dblockdatafile' index 0:4 w l,\
#		index 5 w l
##Print every other vortex (all one color):
#	splot '3Dblockdatafile' every :2 w l
##Print every other data point (line):
#	splot '3Dblockdatafile' every 2 w l
######################################################################
use Math::Trig;

$flett=pop(@ARGV);#temporary, for multiple trials

$num = 1;
$numend = -1;	#set =-1 for largest file number
$nskip = 1;
#$type=pop(@ARGV);	#temporary: s, h, f
$type = "s";		#s=stereo,h=hyperspher,f=fiber(hopf)
#see toplot3sph.pl for difference btw f and cf
#$fileprepost = "oct0412a";	#don't include period
$fileprepost = "oct0412$flett";	#don't include period

$vnum=0;			#If vnum=0, takes nvort from files, title>=2
#$vnum=19;			#Max number of vortices you want printed
$pvort=-1;	#print only one vortex (0-inf), for print all vorts: -1
$pvort2=-1; #2nd vortex to print (>$pvort); set =-1 to disregard this quantity
#vortex colors: 0=red,1=grn,2=blu,3=prpl,4=aqua,5=brn,6=orng,7=lt.brn
$numprint=20;				#how many times to print one timestep
$lim=0.04;	#Fix the range (reduces rendering), set =0 to ignore (for hyper)
$pointsize=.3;
$rotx=60; $rotz=290; #default values 60,30: [0,360): rotx rotates about x-axis,
					#by num of degrees, rotz about z-axis
$slowrotate=0;		#=1 to rotate view
$dtheta=0.5;		#adjust rotation speed
$title=4;	#0 = notitle, 1 = number, 2 = time, 3=num & time,4=num,time,nvort


$fileprepre = "../code/";
$filepre="$fileprepre$fileprepost/$fileprepost";
if ($numend==-1){
	@tmp=glob("$filepre.*");
	$numend=$#tmp+1;
}

$outfilepre = "images";
$outfilepost = $fileprepost;
$outdir=$outfilepre."/".$fileprepost;
#Make directory for output movie file:
#Files have format: images/fileprepost/grb$type.filepost.vort#.file#
##mkdir $outdir;	#THIS WAS DONE IN toplottorus.pl

if ($type=~/h/){
	$datasymbols="lines";
	#$datasymbols="linespoints pt 5"; 	#best for hyper 
}else{
	$datasymbols="lines";				#best for stereo or fiber (hopf)
}
$outfile = "$outdir/movie$type.$outfilepost";
open(B,">$outfile");			#Produces a single output movie file
$numstart=$num;
if ($pvort>$pvort2){	#Ensures $pvort<=$pvort2!
	$tmp=$pvort;
	$pvort=$pvort2;
	$pvort2=$tmp;
}
#plot all points on a vortex at one time then move to next time
$numstart=$num;
if ($slowrotate){
	$rotz-=$dtheta;
}
while($num<=$numend) 
{	
	if ($slowrotate){
		$rotz+=$dtheta;
		$rotz = ($rotz<360)? $rotz: $rotz-360;#works if $dtheta is small
	}
	if ($title>=2){
		$file = $filepre.".".$num;
		open(A,"<$file");
		$npts =<A>;			#How many points on each vortex
		$nvort = <A>;			#Number of vortex rings
		chomp($nvort);
		$time = <A>;			#Time that each file is a snapshot for
		chomp($time);
		$time = sprintf("%.6f",$time);
		if ($num==$numstart && $type=~/f/){
			$tmp=<A>;
			$tmp=<A>;
			$pt=<A>;
			($tmp,$tmp,$x,$y,$z,$w)=split(/\s/,$pt);
			$r02=$x*$x+$y*$y+$z*$z+$w*$w;
			$lim=$r02*1.05;
		}
	}
	if($vnum==0 && $title>=2){
		$vstop=$nvort;
	}else{
		$vstop=$vnum;
	}
	if ($pvort==-1){
		$pcomma=$vstop-1;
	}else{
		$pcomma=($pvort<$vstop)?$pvort:-1;
		$pcomma=($pvort2<$vstop)?$pvort2:$pcomma;
	}
	$i = 0;
	$imax = $numprint;
	if ($num==$numstart){
		#print B "set terminal x11 size 1600,900\n";#Maximized on desktop
		if ($type=~/h/){
			print B "set pointsize ".$pointsize."\n";
		}
		if ($type=~/f/){
			print B "set size 0.7,1.0\n";
		}
		print B "set xlabel 'x'\n";
		print B "set ylabel 'y'\n";
		print B "set zlabel 'z'\n";
		print B "set ticslevel 0\n";
		print B "set view ".$rotx.",".$rotz."\n";
	}
	#Plot repeatedly to slow down the movie (based on processor speed)
   	while ($i < $imax){
		if ($slowrotate){
			print B "set view ".$rotx.",".$rotz."\n";
		}
		$i++;
		if ($pvort<$vstop){
			#selected pvort must be in range of possible vortices
			if ($type=~/h/){
				#If hyperspherical:
				print B "splot [0:3.1416][0:3.1416][0:6.2832] ";
				#print B "splot [0:3.1416][0:3.1416][2.8:3.14] ";
				#print B "splot [1:2][1:2][3:3.12] ";
			}elsif ($type=~/p/){
				print B "splot [-3.1416:3.1416][-3.1416:3.1416][0:3.1416] ";
			}elsif ($type=~/s/ || $type=~/f/){
				#If stereographic or (hopf) fibration, try:
				if($lim<=0){
					print B "splot ";
				}else{
					print B "splot [-$lim:$lim][-$lim:$lim][-$lim:$lim] ";
				}
			}
			$ptitle=0;
		}
		for ($vcnt=0;$vcnt<$vstop;$vcnt++){
			if ($pvort==-1 || $vcnt==$pvort || $vcnt==$pvort2){
				print B "\"grb$type.$outfilepost.$num\"";
				print B " index $vcnt w $datasymbols";
				if (!$title){
					print B " notitle";
				} elsif ($title==1){
					if($ptitle==0){
						print B ' t "n='.$num.'"';
					}else{
						print B " notitle";
					}
				} elsif ($title==2){
					if ($ptitle==0) {
						print B ' t "t='.$time.'"';
					}else{
						print B " notitle";
					}
				} elsif ($title==3){
					if ($ptitle==0){
						print B ' t "'.$num.', t='.$time.'"';
					}else{
						print B " notitle";
					}
				} elsif ($title==4){
					if ($ptitle==0){
						print B ' t "'.$num.', t='.$time.', nvrt='.$nvort.'"';
					}else{
						print B " notitle";
					}
				}
				if ($vcnt!=$pcomma){
					print B ', ';
				}
				$ptitle++;
			}
			if ($vcnt==($vstop-1)){
				print B "\n";
			}
		}
	}
	if ($title>=2){
		close (A);
	}
	$num+=$nskip;			#How many files to skip
}
close (B);
