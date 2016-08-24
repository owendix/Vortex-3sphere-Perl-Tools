#!/usr/bin/perl
#Finds average, std dev, min and max of specific columns in
#the input file $ARGV[0]. Columns specified
#by input $ARGV[1] $ARGV[2] ...
#############################################
# Input: ./avrow.pl infile numskip
# 
# Output: 	row1-col0 ... av_row(col1st->end) std-dev(col1st->end) min() max()
# 		 	row2-col0 ... av_row(col1st->end) std-dev(col1st->end) min() max()
#			...
############################################
#


$col1st=1;	#first column to include in average: skips col 0
#$coln=?;	#default, averages until end

$numskip=pop(@ARGV);#number of lines to skip, not files 
$infile=pop(@ARGV);

open(A,"<$infile") or die "Invalid file\n";

$i=0;
while($data=<A>){
	if (!($i % $numskip)){	#skip every numskip
		#reset for each row
		$mean=0;
		$stdv=0;
		$max=-1e10;
		$min=1e10;
		$cnt=0;
		@dat=split(/\s+/,$data);
		if ($i==0){
			$coln=$#dat;	#average until end
			if ($col1st>=$coln){
				die "Column range (\$coln-\$col1st+1) must be > 1\n";
			}
		}
		#find stats, iterating over each column, in range, within a single row
		for ($j=$col1st; $j<=$coln; $j++){
			#Algorithm is numer. stable, single-pass taken fm wikipedia:
			#similar to Higham 2002 pg ~ 12.
			if ($dat[$j]=~/[0-9]/){#just make sure it had numerical data
				$dif = $dat[$j] - $mean;
				$mean += $dif/($cnt+1);
				$stdv +=$dif*($dat[$j]-$mean);
		
				if ($dat[$j]>$max){
					$max=$dat[$j];
				}
				if ($dat[$j]<$min){
					$min=$dat[$j];
				}
				$cnt++;
			}
		}#for all columns in range in a row
		#print un-averaged columns first
		for ($j=0;$j<$col1st;$j++){
			print "$dat[$j] ";
		}
		#print stats
		print "$cnt ";
		print "$mean ";
		#standard deviation, not variance
		$stdv = sqrt($stdv/($cnt-1));
		print "$stdv ";
		print "$min ";
		print "$max\n";
	}#skip every numskip lines
	$i++;
}#while ($data=<A>)

close (A);
