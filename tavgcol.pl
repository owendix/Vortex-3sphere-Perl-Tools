#!/usr/bin/perl
#Finds weighted time average, stdev, min, and max of 
#specific columns in the input file $ARGV[0]. Which columns 
#to average are specified in input $ARGV[1], $ARGV[2],...
#This means that time must be the 0th column in the 
#input file in $ARGV[0]
#
#Really this finds the integrated time
#average, approximating the integral with the non-uniform
#grid trapezoidal rule. To do this, it uses the 
#time spacing as the weighting factor. 
#It uses a numerically stable, online 
#(single pass) algorithm for calculating this weighted
#average and std dev. The numerical algorithm is an 
#adaptation from a wikipedia article on calculating the 
#weighted average in a stable way (which is similar to 
#the algorithm given in Higham, p. ~12), only I adapted 
#it to make the weighting factor the coefficients of the 
#non-uniform grid trapezoidal rule.
#
#You can specify the output format with $sepchoice
#############################################
# Input: ./avgcol.pl infile col#1 col#2 ...
# 
# Output: 	avgcol#1 sdvcol#1 mincol#1 maxcol#1 
#			avgcol#2 sdvcol#2 mincol#2 maxcol#2 
#			...	
############################################
#

$printheader=0;	#on automatically for LaTex: $sepchoice=5
$sepchoice=3;	#2 for .csv; 5 for LaTeX

if ($sepchoice==0){
	$sep="\t";
}elsif ($sepchoice==1){
	$sep="\t\t";
}elsif ($sepchoice==2){
	$sep=",";
}elsif ($sepchoice==3){
	$sep=" ";
}elsif ($sepchoice==4){
	$sep="    ";
}elsif ($sepchoice==5){
	$sep=" & ";			#for LaTeX
}


($infile,@col) = @ARGV;
#infile = "velcontrib.oct2909a.dat";
open(A, "<$infile") or die "Could not open file: $infile";
for ($j=0; $j<($#col+1); $j++){
	$sumweight[$j]=0;
	$mean[$j]=0;
	$stdv[$j]=0;
	$max[$j]=-1e10;
	$min[$j]=1e10;
	$cnt[$j]=0;
}
$i=0;
$done=0;
#need @datprev, @dat, @datnxt
if ($data=<A>){
	@datnxt=split(/\s+/,$data);
	@dat=@datnxt;
}else{	#read failed, reached eof, for example
	$done=1;
}
while($done==0){#This will be datnxt
	#manage data, prev=cur, cur=nxt
	@datprev=@dat;
	@dat=@datnxt;
	
	#read in nxt data, for weights
	if (!($data=<A>)){#true if reached end of file
		$done=1;#still need to calculate for
	}else{
		@datnxt=split(/\s+/,$data);
	}
	#for all the columns you want to average
	for ($j=0; $j<($#col+1); $j++){
		#Algorithm is numer. stable, single-pass adapted fm wikipedia:
		#similar to Higham 2002 pg ~ 12.
		if ($dat[$col[$j]]=~/[0-9]/){
			if ($done==0){
				if ($i==0){#first data point special
					$weight[$j]=0.5*($datnxt[0]-$dat[0]);#Time column
				}else{
					$weight[$j]=0.5*($datnxt[0]-$datprev[0]);#Time column
				}
			}else{#when done==1, on last data point = special
				$weight[$j]=0.5*($dat[0]-$datprev[0]);#Time column

			}
			#maybe detect end of file
			$temp=$weight[$j]+$sumweight[$j];
			$dif = $dat[$col[$j]] - $mean[$j];
			$R = $dif*$weight[$j]/$temp;
			$mean[$j] += $R;
			$stdv[$j] += $sumweight[$j]*$dif*$R;
			$sumweight[$j]=$temp;
	
			if ($dat[$col[$j]]>$max[$j]){
				$max[$j]=$dat[$col[$j]];
			}
			if ($dat[$col[$j]]<$min[$j]){
				$min[$j]=$dat[$col[$j]];
			}
			$cnt[$j]++;
		}else{
			print STDERR "Error: column $col[$j] contains no usable data\n";
		}
	}
	$i++;
}
@tmp=split(/\//,$infile);

if ($printheader || $sep=~/&/){
	if ($sep=~/&/){
		print "\\documentclass{article}\n";
		print "\\usepackage[left=0.5in,right=0.5in,top=0.5in,
			bottom=0.5in]{geometry}\n";
		print "\\begin{document}\n";
		print "\t\\begin{tabular}{c|c|c|c|c|c|c}\n";
		print "filename$sep";
	}else{
		print "#filename$sep";
	}
	print "column$sep";
	print "number$sep";
	print "average$sep";
	print "std-dev$sep";
	print "minimum$sep";
	print "maximum";
	if ($sep=~/&/){
		print " \\\\\n";
		print "\\hline\n";
	}else{
		print "\n";
	}
}
for ($j=0;$j<($#col+1);$j++){
	print "$tmp[$#tmp]$sep";
	print "$col[$j]$sep";
	print "$cnt[$j]$sep";
	printf '%.8g%s',$mean[$j],$sep;
	#standard deviation, not variance
	$stdv[$j] = sqrt(($stdv[$j]/$sumweight[$j]));
	printf '%.8g%s',$stdv[$j],$sep;
	printf '%.8g%s',$min[$j],$sep;
	printf '%.8g',$max[$j];
	if ($sep=~/&/){
		print " \\\\\n";
		print "\\hline\n";
	}else{
		print "\n";
	}
}
if ($sep=~/&/){
	print "\t\\end{tabular}\n";
	print "\\end{document}\n";
}

close (A);
