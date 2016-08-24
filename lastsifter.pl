#!/usr/bin/perl
#Sifts through last.feb1009a.ivort.dat to find pattern matches

$endi=4610;
$starti=2228;

$file='../../code/last.feb1009a.ivort.dat';
open(A,"<$file");

@array=<A>;	

$cnt1=0;
foreach $dat (@array)
{	
	if ($dat=~/ = /)
	{
		#print "$dat";	#Check
		@data=split(/\s/,$dat);
		$i=pop(@data);
		#print "$i\n";	#Check
		
		for ($cnt2=($cnt1+1);$cnt2<=($#array);$cnt2++)
		{
			if ($array[$cnt2]=~/ = /)
			{
				@temp=split(/\s/,$array[$cnt2]);
				$j=pop(@temp);
				
				if ($i==$j)
				{
					print "ln# val  ln# val\n";
					print "$cnt1 $i $cnt2 $j\n";	#print line #'s of the two identical points
				}				
			}
				
		}
	}
	$cnt1++;
}		
