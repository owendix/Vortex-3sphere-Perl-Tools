#!/usr/bin/perl
#Finds relative difference between line and previous line
#either divided by previous line or not (rel==1,0)
#################################
#col#s tell which columns to take diff of
#
#Input: ./diffline.pl infile col0 col1 ...
#Output: originaldata dif0 dif1 ...
#################################
$rel=0;
$infile=@ARGV[0];
open(A,"<$infile");
@alldat=<A>;
@oldl=split(/\s/,$alldat[0]);
$k=0;
for ($i=1;$i<=$#ARGV;$i++){
	if ($ARGV[$i]>=0 && $ARGV[$i]<=$#oldl){
		$cols[$k]=$ARGV[$i];
		$k++;
	}
}

for ($i=1;$i<=$#alldat;$i++){
	@l=split(/\s/,$alldat[$i]);
	for ($j=0;$j<=$#cols;$j++){
		if ($j==0){
			chomp($alldat[$i]);
			print "$alldat[$i] ";
		}
		if ($rel==1){
			$num = $l[$cols[$j]] - $oldl[$cols[$j]];
			$num = $num/$oldl[$cols[$j]];
		}else{
			$num = $l[$cols[$j]] - $oldl[$cols[$j]];
		}
		print "$num";
		if ($j!=$#cols){
			print " ";
		}else{
			print "\n";
		}
	}
	@oldl=@l;
}
close(A);
