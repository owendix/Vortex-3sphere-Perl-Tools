#!/usr/bin/perl

$infile=pop(@ARGV);
$pattst='\(0,0,';		#$,|,[,(,\,/ must be preceded by \ to work as regex
$pattend=',0,';
$patthalt='t=0.019099';	#no more sets: change to long gobbledigook to ignore
$inclusive=0;	#do (1) or do not (0) include pattend line

$cutoff=900;	#maximum set size, don't look for pattend forever
$scrn=0;	#=1: print to screen, =0, print each set to diff outfile
$outfilepre="yy";	#outfile xx000, xx001, etc.
$dig=4;	#=3: xx000, =2: xx00, etc.

open(A,"<$infile");

$inside=0;
$nsets=0;	#number of sets
while($_=<A>){
	if ($inside==0){	#look for start of set
		if (/$pattst/){
			$buffer[0]=$_;
			$setsz=1;
			$inside=1;
		}
	}else{	#set started, look for end
		$buffer[$setsz]=$_;
		$setsz++;	#tells how many are stored
		if (/$pattend/){
			$inside=0;	#start looking for another set
			#print buffered set
			if ($scrn){
				for ($i=0;$i<$setsz;$i++){
					print "$buffer[$i]";
				}
				print "set $nsets:\n";	#separate sets
			}else{
				#print outfilename with leading zeros
				$n=sprintf("%0".$dig."u",$nsets);	#u is unsigned int
				$outfile=$outfilepre.$n;
				open(B,">$outfile");
				if ($inclusive==0){
					$setsz--;	#don't print last line
				}
				for ($i=0;$i<$setsz;$i++){
					print B "$buffer[$i]";
				}
				close(B);
			}
			$setsz=0;	
			$nsets++;
		}elsif ($setsz>$cutoff){	#stop looking, dump buffered set
			$inside=0;
			$setsz=0;
		}
	}
	if (/$patthalt/){#hit halt point
		last;
	}	
}
