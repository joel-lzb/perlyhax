#! /user/bin/perl 

# Script to count bases, total length, total number of sequences, Ns, N50 and N90 in a fasta file.

use warnings;
use strict;

my $totalseq = 0; # keeps track of number of sequences
my $id = ''; # holds ID of current sequence 
my $length = 0; # holds length of current sequence 
my $total_length = 0; # total length of all sequences 
my $average_length = 0; # average length of sequences
my $n_count = 0; # N count of current sequence
my $n_total = 0; # total N of all sequences

my @sortArray;

my $infile = $ARGV[0];

my $x = @ARGV;
if($x < 1){die "Usage:$0 <seq.fa>\n Output to STDOUT\n";}

#open outputfile:
open(MYINFILE, $infile) or die "$!";

print "ID\tLENGTH\tNs\n"; #print header

while (<MYINFILE>) {
	chomp; 
	if (/^>(\S+)\s*(.*)$/) { #found description line
		if ($length > 0) {
			print "$id\t$length\t$n_count\n"; 
			push  @sortArray, $length;
			$totalseq = $totalseq+1; 
			$length = 0;
			$n_count = 0;
		}
		$id = $_; #or use $id=$1;
	} else { 
		$length += length; 
		$total_length += length; 
		my @char = split('',$_);
		foreach my $base(@char){
			if ($base =~ /[nN]/) {
				$n_count++;
				$n_total++;
			}	
		}
	}
}

print "$id\t$length\t$n_count\n\n" if $length > 0; # final entry
push  @sortArray, $length;
$totalseq = $totalseq+1;

$average_length = $total_length/$totalseq; 

# calculate N50 and N90:
my ($N50,$N90) = (0,0); 
@sortArray = sort{$b<=>$a} @sortArray; 
my ($count,$half,$ninety) = (0,0,0);
for (my $j = 0; $j < @sortArray; $j++){
	$count += $sortArray[$j];
	if (($count >= $total_length/2) && ($half == 0)){
		$N50 = $sortArray[$j];
		$half = $sortArray[$j]; #threshold mark
	}elsif (($count >= $total_length*0.9) && ($ninety == 0)){
		$N90 = $sortArray[$j];
		$ninety = $sortArray[$j]; #threshold mark
	}
}

print "SUMMARY:\n";
print "Total length: $total_length\n"; 
print "Total N found: $n_total\n"; 
print "Total Number of sequences: $totalseq\n"; 
print "Average length of sequences: $average_length\n"; 
print "Maximum length of sequences: $sortArray[0]\n";
print "Minimum length of sequences: $sortArray[$#sortArray]\n";
print "N50: $N50\n"; 
print "N90: $N90\n"; 
