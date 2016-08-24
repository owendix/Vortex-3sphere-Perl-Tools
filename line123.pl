#!/usr/bin/perl
#prints 1st and 2nd line of output files = totalpts and nvort
#################################################
#Input: $filepre (without period) $incr"
#		e.g. ../code/oct0110a 1
#Output: 	time_1 totalpts_1 nvort_1
#			time_2 totalpts_2 nvort_2
#			...
#			time_245 totalpts_245 nvort_245
##################################################

$incr=pop(@ARGV);
$numstart=1;

$filepre=pop(@ARGV);	#don't include period

@tmp=split(/\//,$filepre);
$filename=pop(@tmp);

$tdiff=0;
$num=$numstart;

$tlast=0;
$done=0;
while (!$done){
	#Files are in their own directory
	$file="$filepre/$filename.$num";
	open(A,"<$file");
	
	if ($totalpts=<A>){
		chomp($totalpts);
		$nvort=<A>;
		chomp($nvort);
		$time=<A>;
		chomp($time);
	
		if($tdiff){
			$h=$time-$tlast;
		#	print "$h\n";
			$tlast=$time;
		}else{
			print "$time $totalpts $nvort\n";
			#print "$nvort\n";
		}
		$num+=$incr;
	}else{
		$done=1;
	}
	close A;
}

