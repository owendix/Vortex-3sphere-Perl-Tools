#!/usr/bin/perl
use Math::Trig;
################################################
#Calculates and prints setup=0, xy perturbed ring,
#or setup=1, yz perturbed ring
# 3sphere
#Has more points than what's stored in filename.1
################################################
#Input: ./makeinitial.pl setup(0 or 1)
#
#Output: restart file for initial perturbed ring in xy or yz plane
################################################

$setup=pop(@ARGV);
if ($setup!=0 && $setup!=1){
	die "setup=$setup; Only 0 or 1 allowed\n";
}

$perturb=1;
$n=10;
$amp=100;
$vortpts=1000;
$r0=0.005;

$M_PI=3.1415926535898;
$dtheta = 2. * $M_PI / $vortpts;
print "$vortpts\n";
print "1\n";#number of vortices
print "0\n";#time
print "0.01\n";#initial dt
print "0 ";
print $vortpts-1;
print " 0\n";
#actual data has index and recon number but this doesn't matter for plotting
#for validity: coefficient for x,y: |C| < sqrt(1-1/amp^2)
if ($setup=0){
	for ($i = 0; $i < $vortpts; $i++) {
		$corex = .9*$r0*cos($i * $dtheta);
		#corey = $r0 / $amp * sin($i * $dtheta * $n);
		$corey = .9 * $r0 * sin($i * $dtheta);
		if ($perturb){
			$corez = $r0/$amp*sin($i*$dtheta*$n);
		}else{
			$corez = 0;
		}
		#corez = .9 * r0 * sin(i * dtheta);
		$corew = sqrt($r0*$r0 - $corex*$corex - 
			$corey*$corey - $corez*$corez);
		print "$corex $corey $corez $corew\n";
	}
}elsif ($setup=1){
	for ($i = 0; $i < $vortpts; $i++) {
		$corey = .9*$r0*cos($i * $dtheta);
		#corey = $r0 / $amp * sin($i * $dtheta * $n);
		$corez = .9 * $r0 * sin($i * $dtheta);
		if ($perturb){
			$corex = $r0/$amp*sin($i*$dtheta*$n);
		}else{
			$corex = 0;
		}
		#corez = .9 * r0 * sin(i * dtheta);
		$corew = sqrt($r0*$r0 - $corex*$corex - 
			$corey*$corey - $corez*$corez);
		print "$corex $corey $corez $corew\n";
	}
}
