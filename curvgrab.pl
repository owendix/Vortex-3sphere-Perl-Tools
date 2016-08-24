#!/usr/bin/perl

#For cmprcurv.dat extracting values
#cmprcurv.dat compares different methods of
#attaining the radius of curvature and the
#curvature vector, from rkf.c:localrz(), I input different
#methods of finding these quantities and ran gdb to see their 
#values as they ran over a period of time. This file is the output
#from running gdb and needs data extracted from it

$infile="cmprcurv.dat";
open(A,"<$infile");

@data=<A>;
$go=0;
$stopper=0;
for ($i=0;$i<$#data;$i++){
	if ($go){
		@row=split(/\s/,$data[$i]);
		$val=pop(@row);
		chomp($val);
		if ($go==2){
			#contains a bracket at end
			chop($val);	
		}
		
		if ($type==1){
			#r
			$r=$val;
		}
		elsif($type==2){
			#r2
			$r2=$val;
		}
		elsif ($type==3){
			#rad
			$r3=$val;
		}
		elsif ($type==4){
			#scurv
			$w=$val;
		}
		elsif ($type==5){
			#scurv2
			$w2=$val;
		}
		elsif ($type==6){
			#curv
			$w3=$val;
			$stopper=1;
		}
	}
	$go=0;
	if ($data[$i]=~/(gdb)/){
		if ($data[$i]=~/curv/){
			if ($data[$i]=~/scurv2/){
				#The Aarts method for s'', not reliable
				#in newpt...led to 'nan'
				$type=5;
			}
			elsif ($data[$i]=~/scurv/){
				#The Schwarz method for s'', reliable
				#did not lead to 'nan'
				$type=4;
			}
			else{##curv
				#ad hoc method for finding the 
				#direction of s'', with Schwarz method for
				#|R|
				$type=6;
			}
			$go=2;
		}
		elsif ($data[$i]=~/ r/){
			if ($data[$i]=~/rad/){
				#Schwarz method of |R|
				$type=3;
			}
			elsif ($data[$i]=~/r2/){
				#Aarts, unreliable method for |R|
				$type=2;
			}
			else{#r
				#Schwarz method of |R|, from newpt
				$type=1;
			}
			$go=1;
		}
	}
	if ($stopper){
		$r2=$r-$r2;
		$r3=$r-$r3;
		$w2=$w-$w2;
		$w3=$w-$w3;
		
		print "$r    $r2    $w    $w2    $w3\n";
	}
	$stopper=0;
}
close A;
