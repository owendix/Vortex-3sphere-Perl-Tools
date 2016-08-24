#!/usr/bin/perl
#######################################
#Input file from copied/pasted vortex segment point
#locations in gdb, creates columns of pts
#x y z w to convert with toplot3sph.pl
#######################################
#Input: ./gdbcore3sph.pl
#
#Output: 	if ($meth='core'):
#			x1 y1 z1 w1
#			...
#			if ($meth='hyper'):
#			ang1_1 ang2_1 ang3_1
#			...
#			if ($meth='fiber'):
#			x1_1 x2_1 x3_1 
#			...
#			if ($meth='stereo'):
#			x1 y1 z1
#			...
#######################################
$infile="gdb.nov1210d.1840.v2.pts.dat";
$meth=pop(@ARGV);	#core, hyper, fiber, stereo


if (!($meth=~/core/ || $meth=~/hyper/ || 
		$meth=~/fiber/ || $meth=~/stereo/)){
	die "Input methods: core, hyper, fiber, stereo\n";
}

open(A,"<$infile");
$cnt=0;
$k=0;
while ($data=<A>){
	if (!($data=~/gdb/)){
		@line=split(/\s+/,$data);
		$j=$cnt*2+1;	#=1 or 3, the index of $pnt
		$jstop=$j-1;
		while($j>=$jstop){
			$tmp=pop(@line);
			if ($tmp=~/[0-9]/){	#contains pt value
				chomp($tmp);
				chop($tmp);
				$pnt[$j]=$tmp;
				$j--;
			}
		}
		$cnt++;
		if ($cnt==2){
			$coreline[$k]="$pnt[0] $pnt[1] $pnt[2] $pnt[3]"; ##core pts
			$k++;
			$cnt=0;
		}
	}
}

for ($k=0;$k<=$#coreline;$k++){
	$newline=$coreline[$k];
	if ($meth=~/core/){
		$data=$newline."\n";
	}elsif ($meth=~/hyper/){
        $data=&hspher($newline);
    }elsif ($meth=~/stereo/){
		$vwdir='w';
		$vwsign=-1;
		($x,$y,$z,$w)=split(/\s+/,$newline);
		$r0=sqrt($x*$x+$y*$y+$z*$z+$w*$w);
        $data=&stgraph($newline,$vwdir,$vwsign,$r0);
    }elsif ($meth=~/fiber/){
        $data=&hopffib($newline);
    }
    if ($data!=-1){     #Signal from stgraph: didn't eval this pt
        print $data;
    }
}
close A;
#end main

#subroutines: convert x,y,z,w into 3D 
sub hopffib{
    local($x,$y,$z,$w,$fib1,$fib2,$fib3);
    ($x,$y,$z,$w)=split(/\s/,$_[0]);
    $fib1=$x*$z+$y*$w;
    $fib2=$y*$z-$x*$w;
    #$fib3=$x*$x+$y*$y-$z*$z-$w*$w;     #naive way-> possibly bad errors
    #$fib3=($x*$x-$z*$z)+($y*$y-$w*$w); #minimize intermediate sums for 
                                        #better accuracy
    $fib3=($x-$z)*($x+$z)+($y-$w)*($y+$w);#Rewrite->even better accuracy

    $fibs="$fib1 $fib2 $fib3\n";
}
sub hspher{
    local($thet1,$thet2,$thet3,$pi,$x,$y,$z,$w,$angs);
    $pi=3.1415926535898;
    ($x,$y,$z,$w)=split(/\s/,$_[0]);
    $thet1=atan2(sqrt($w**2+$z**2+$y**2),$x);   #tan(thet)=y/x; thet=atan2(y,x);
    $thet2=atan2(sqrt($w**2+$z**2),$y);
    $thet3=atan2($w,$z);
    $angs="$thet1 $thet2 $thet3\n";
}
sub stgraph{
    local(@dat,@dat2,$d1,$vwdir,$vwsign,$x,$xj,$denom,$knt,$cnt,$cnt2,$points,$r0);
    $vwsign=$_[2];      # =(+-)1
    @dat=split(/\s/,$_[0]); #points on 3sphere

    $r0=$_[3];      #Radius of the 3sphere (found in params.dat)

    $x=ord('x');            #returns the ascii value of 'x', 
    $vwdir=ord($_[1])-$x;       #$_[1] = x, y, z, or w
    if ($vwdir==-1){            #'w' < 'x', we want it higher than 'z'
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
        $points=-1;	#The signal not to print this value, 
				   	#since no ascii character evaluates to negative
    }
}
