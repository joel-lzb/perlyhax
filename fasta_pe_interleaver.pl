#!/usr/bin/perl

#Simple script to interleave two separate paired-end sequencing fasta files into one file for programs like IDBA-UD.

use warnings;
use strict;

my $fileA = $ARGV[0];
my $fileB = $ARGV[1];

my $x=@ARGV;
if($x<2){die "$0 <in1.fa> <in2.fa> \n Output to STDOUT\n";}

open(DAT1, $fileA) or die "$!";
open(DAT2, $fileB) or die "$!";

while(<DAT1>) {
	print $_;
	$_ = <DAT1>;
	print $_;

	$_ = <DAT2>;
	print $_;
	$_ = <DAT2>;
	print $_;
}

