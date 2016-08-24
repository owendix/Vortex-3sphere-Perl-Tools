#!/usr/bin/perl
#Finds average, std dev, min and max of specific columns in
#the input file $ARGV[0]. Columns specified
#by input $ARGV[1] $ARGV[2] ...
#############################################
# Input: ./avgcol.pl infile col#1 col#2 ...
# 
# Output: 	avgcol#1 avgcol#2 ...
# 		 	sdvcol#1 sdvcol#2 ...
#			maxcol#1 maxcol#2 ...
#			mincol#1 mincol#2 ...
############################################
#

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
open(A, "<$infile");
for ($j=0; $j<($#col+1); $j++){
	$mean[$j]=0;
	$stdv[$j]=0;
	$max[$j]=-1e10;
	$min[$j]=1e10;
	$cnt[$j]=0;
}
$i=0;
while($data=<A>){
	$i++;
	@dat=split(/\s+/,$data);
	for ($j=0; $j<($#col+1); $j++){
		#Algorithm is numer. stable, single-pass taken fm wikipedia:
		#similar to Higham 2002 pg ~ 12.
		if ($dat[$col[$j]]=~/[0-9]/){
			$dif = $dat[$col[$j]] - $mean[$j];
			$mean[$j] += $dif/($cnt[$j]+1);
			$stdv[$j] +=$dif*($dat[$col[$j]]-$mean[$j]);
	
			if ($dat[$col[$j]]>$max[$j]){
				$max[$j]=$dat[$col[$j]];
			}
			if ($dat[$col[$j]]<$min[$j]){
				$min[$j]=$dat[$col[$j]];
			}
			$cnt[$j]++;
		}
	}
}
@tmp=split(/\//,$infile);

if ($printheader || $sep=~/&/){
	if ($sep=~/&/){
		print "\\documentclass{article}\n";
		print "\\usepackage[left=0.5in,right=0.5in,top=0.5in,
			bottom=0.5in]{geometry}\n";
		print "\\begin{document}\n";
		print "\t\\begin{tabular}{c|c|c|c|c|c|c}\n";
	}
	print "#filename$sep";
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
	$stdv[$j] = sqrt($stdv[$j]/($cnt[$j]-1));
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
