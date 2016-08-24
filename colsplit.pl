#!/usr/bin/perl
#
$infile = "velstruct.dec0909b.dat";
$outfilepre = "vstruct/vst.dec0909b";	#No period
$outfilepost = "dat";	#No period
$num=0;
$outfile = $outfilepre.".".$num.".".$outfilepost;
open(A,"<$infile");
open(B,">$outfile");
@dat = <A>;
for ($i=0;$i<=$#dat;$i++){
	@data=split(/\s/,$dat[$i]);
	if ($data[0]==0){
		close(B);
		$outfile=$outfilepre.".".$num.".".$outfilepost;
		open(B,">$outfile");
		$num++;
	}
	print B "$dat[$i]";
}
close(A);
close(B);
