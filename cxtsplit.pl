#!/usr/bin/perl
###########################################################
#splits data file based on context in one of two selected ways:
# 1. If a line contains $nblanks(=2) of whitespace in a row, 
#	those lines are removed 
#	and the data that is interweaved is separated into 
#	sequential files (less than $nblanks in a row, and they are untouched)
#	e.g.:
#	Input:
#		./cxtsplit.pl infile
#	Output:
#		infile.1 infile.2 infile.3
#
# 2. if a difference occurs in a selected column -> split file
#	e.g. 
#	Input (literally write "col="):
# 		./cxtsplit.pl file col=0
# 	Output: 
#		xx00 xx01 xx02 ... each containing a file with a common
#			value in the 0th column
#
# 3. or by including a certain number of lines within each file
# 	e.g.
#	Input:
#		./cxtsplit.pl file 19
#	Output: 
#		xx00 xx01 ...	each containing exactly 19 lines, with the final
#			containing the remaining lines
#
#	NOTE: Output prefix can be changed within the program
# 	NOTE: If a third argument is included, this specifies the number of
#		digits to include in the output filenames: xx01, xx001, xx0001
##############################################################

$infileprefix=1;	#=1, use infile name as prefix, add . between ##s

if (!$infileprefix){
	$prefix='xx';		#change output file prefix here
}

#set to 1 or zero for no 0 padding
$dig=0;				#number of numerical digits in output filename

#Check arguments
if ($#ARGV==1){		#$ARGV[0]=infile, $ARGV[1]=col=# or #
	$meth=pop(@ARGV);
}elsif ($#ARGV==0){
	$meth="whitespace";
	$nblanks=2;	#number of blanks, at which make a new file
}else{
	die "Illegal number of arguments\n";
}

#Prepare input and output files
$infile=pop(@ARGV);
if ($infileprefix){
	$prefix="$infile.";		#use infile. as prefix
}

#which method to split file
if ($meth=~/=/){#split by difference in column
	($a,$num)=split(/=/,$meth);
}elsif ($meth=~/whitespace/){
	$a="whitespace";
}elsif ($meth=~/[0-9]/ && $meth!~/[a-zA-Z]/){#just a number
	$a='line';
	$num=$meth;
}

open(A,"<$infile") or die "Unable to open $infile";
#The 3 different methods of splitting file
if ($a=~/whitespace/){
	$j=0;
	$blank=0;
	#if dig=2, %02u, which is fill zeros , field size 2, unsigned int
	$n=sprintf("%0$dig"."u",$j);
	$outfile=$prefix.$n;
	open (B,">$outfile");
	while ($data=<A>){
		if ($data=~/^\s*$/){#completely empty or only whitespace
			$blank++;	#found a blank line
		}elsif ($blank<$nblanks){#found less than required, keep them
			for ($k=0;$k<$blank;$k++){
				print B "\n";	#print all those blanks
			}
			$blank=0;	#reset, want that to stay in same file
		}elsif ($blank==$nblanks){#found two blank lines, didn't find another
			$j++;
			$blank=0;
			close B;	#close previous file
			$n=sprintf("%0$dig"."u",$j);
			$outfile=$prefix.$n;
			open (B,">$outfile");
		}
		if ($data!~/^\s*$/){#if not blank
			print B $data;
		}
		
	}
	close B;
}elsif ($a=~/col/){		#all in one file have common column value
	$k=0;
	$j=0;
	while ($data=<A>){
		$j++;
		@line=split(/\s/, $data);
		if ($j==0){
			$old=$line[$num];
		}
		$new=$line[$num];	
		if ($j==0 || $old!=$new){
			#print $i with leading zeros for outfile
			$n=sprintf("%0".$dig."u",$k);	
			$outfile=$prefix.$n;
			open(B,">$outfile");
			$k++;
			$old=$new;
		}
		print B $alldat[$j];
	}
}elsif ($a=~/line/){	#files have equal num of lines (except poss. last)
	$k=0;
	$j=0;
	while($data=<A>){#until file complete
		$j++;
		if (($j%$num)==0){
			#print $i with leading zeros for outfile
			$n=sprintf("%0".$dig."u",$k);	
			$outfile=$prefix.$n;
			open(B,">$outfile");
			$k++;
		}
		print B $data;	#print to output file		
	}	
}else{
	die "Illegal input argument\n";
}
