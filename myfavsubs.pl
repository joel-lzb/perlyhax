#!/user/bin/perl

# my collection of favourite perl subroutines!


########################################################################
## &removeDups(@allstuff)
## Removes any duplicate entries in an array.
sub removeDups {
    return keys %{{ map { $_ => 1 } @_ }};
}
########################################################################



########################################################################
## &cleanIndex($string)
## Cleans the string of "weird" characters.
sub cleanIndex {
	my $name = $_[0];
	$name =~ s/[\/\\\(\)\.\+\&\$\@\!\#\%\*\=\{\}\[\]\:\;\"\'\<\>\,\? ]/_/g;
	return $name;
}
########################################################################



########################################################################
## &calcMeanWND(@WindDirectionDeg)
## Calculates the average wind direction from an array of wind direction records in degrees.
sub calcMeanWND { 
	my($y, $x) = (0,0);
	my $Pi = 3.14159265;
	foreach my $point(@{$_[0]}) {
		unless($point){ # if no data, don't calculate.
			next;
		}
		unless($point <= 360){ # if direction is >360, don't calculate.. In NOAA data, 990 is used to denote unknown direction.
			next;
		}
		($y,$x) = ($y + sin($point*$Pi/180), $x + cos($point*$Pi/180));
	}
	my $atan = atan2($y,$x);
	$atan += 2*$Pi while $atan < 0;
	$atan -= 2*$Pi while $atan > 2*$Pi;
	my $result = sprintf("%.2f",$atan*180/$Pi);
	return ($result);
}
########################################################################



########################################################################
## &Dir2Deg($cardinalPoints)
## Converts the 32 cardinal points of a compass into degrees.
sub Dir2Deg {
	my %dirin = (
		N => '0',
		NbE => '11.25',
		NNE => '22.5',
		NEbN => '33.75',
		NE => '45',
		NEbE => '56.25',
		ENE => '67.5',
		EbN => '78.75',
		E => '90',
		EbS => '101.25',
		ESE => '112.5',
		SEbE => '123.75',
		SE => '135',
		SEbS => '146.25',
		SSE => '157.5',
		SbE => '168.75',
		S => '180',
		SbW => '191.25',
		SSW => '202.5',
		SWbS => '213.75',
		SW => '225',
		SWbW => '236.25',
		WSW => '247.5',
		WbS => '258.75',
		W => '270',
		WbN => '281.25',
		WNW => '292.5',
		NWbW => '303.75',
		NW => '315',
		NWbN => '326.25',
		NNW => '337.5',
		NbW => '348.75'
	);
	
	my $degout;
	if ($dirin{$_[0]}){
		$degout = $dirin{$_[0]};
	} else {
		$degout = "";
	}
	return $degout;
}
########################################################################



########################################################################
## &ConvertDate($date)
## Converts some date formats to the YYYYMMDD standard.
sub ConvertDate {

	#contains /:
	# DD/MM/YYYY (8)
	# DD/MM/YY (6)
	# D/MM/YYYY @ DD/M/YYYY (7) basket..
	# D/MM/YY @ DD/M/YY (5)	basket..

	#only numbers:
	# DDMMYYYY (8)
	# DDMMYY (6)
	# DMYYYY (6) basket..
	# DMMYYYY @ DDMYYYY (7)	basket..
	# DMMYY @ DDMYY (5) basket..
	my $dirtyDate = $_[0];
	my $cleanDate = $_[0];
	$cleanDate =~ s/[-_\/\\ ]//g; # clean the data of "-","_","/"," ","\"
	my @formatedDate; #store as @array => $array[0]=year, $array[1]=month, $array[2]=day

	my @digits = split ("",$cleanDate);
	my $formatLength = scalar(@digits);
	if ($formatLength == 8) { # DDMMYYYY (8)
		if ($digits[4] == 0) { # this would mean the format is likely YYYYMMDD @ YYYYDDMM
			die "format is likely YYYYMMDD and cannot proceed!\t$dirtyDate\t$cleanDate\n";
		}
		my $year = "$digits[4]$digits[5]$digits[6]$digits[7]";
		my $month = "$digits[2]$digits[3]";		
		my $day = "$digits[0]$digits[1]";

		if ($month > 12 ) { # american format?
			die "format is likely MMDDYYYY and cannot proceed!\t$dirtyDate\t$cleanDate\n";
		}
		push @formatedDate, $year;
		push @formatedDate, $month;
		push @formatedDate, $day;

	} elsif ($formatLength == 6){ # DDMMYY (6)
		my $year;
		my $month = "$digits[2]$digits[3]";		
		my $day = "$digits[0]$digits[1]";

		if ($day > 31) { # likely YYMMDD @ DMYYYY
			die "format is likely YYMMDD @ DMYYYY and cannot proceed!\t$dirtyDate\t$cleanDate\n";
		}

		if ($month > 12 ) {  # american format?
			die "format is likely MMDDYY and cannot proceed!\t$dirtyDate\t$cleanDate\n";
		}
		# reformat:
		if ($digits[4] > 1) { # assuming there are no 1910s and earlier datasets...
			$year = "19$digits[4]$digits[5]";
		} else { # year 2000+
			$year = "20$digits[4]$digits[5]";
		}
		push @formatedDate, $year;
		push @formatedDate, $month;
		push @formatedDate, $day;

	} elsif ($formatLength == 4){ # DMYY (4)
		my $year;
		my $month = "0$digits[1]";		
		my $day = "0$digits[0]";

		# reformat:
		if ($digits[2] > 1) { # assuming there are no 1910s and earlier datasets...
			$year = "19$digits[2]$digits[3]";
		} else { # year 2000+
			$year = "20$digits[2]$digits[3]";
		}
		push @formatedDate, $year;
		push @formatedDate, $month;
		push @formatedDate, $day;

	}elsif (scalar @digits == 7) { # DMMYYYY @ DDMYYYY (7)
		if ($digits[3] == 0) { # this would mean the format is likely YYYYMMD @ YYYYMDD
			die "format is likely YYYYM.D. and cannot proceed!\t$dirtyDate\t$cleanDate\n";
		}
		my $year = "$digits[3]$digits[4]$digits[5]$digits[6]";
		my $month;
		my $day;

		if ($digits[1] > 1 ) { # likely DDMYYYY
			die "format is likely DDMYYYY and cannot proceed in!\t$dirtyDate\t$cleanDate\n";
		} else { # DMMYYYY
			$month = "$digits[1]$digits[2]";		
			$day = "0$digits[0]";			
		}
		push @formatedDate, $year;
		push @formatedDate, $month;
		push @formatedDate, $day;

	}elsif (scalar @digits == 5) { # DMMYY @ DDMYY (5)
		if ($dirtyDate =~ /(\/)/ || $dirtyDate =~ /(\-)/ ) { # If have delimiter, use it to split to either DMMYY or DDMYY.
			my ($day, $month, $year);
			my ($dayOld,$monthOld,$yearOld) = split ("$1",$dirtyDate);
			if ($yearOld > 20) { # assuming there are no 1910s and earlier datasets...
				$year = "19$yearOld";
			} else { # year 2000+
				$year = "20$yearOld";
			}

			if ($monthOld < 10) { #change single digits to two
				$month = "0$monthOld";
			} else {
				$month = $monthOld;
			}

			if ($dayOld < 10) { #change single digits to two
				$day = "0$dayOld";
			} else {
				$day = $dayOld;
			}

			push @formatedDate, $year;
			push @formatedDate, $month;
			push @formatedDate, $day;
			
		}else { # If it doesn't have any delimiter (/ or -), treat it as DMMYY.
			my $year = "$digits[3]$digits[4]";
			my $month = "$digits[1]$digits[2]";		
			my $day = "$digits[0]";
			if ($month > 12 ) { # american format?
				die "format has $formatLength numbers and cannot proceed!\t$dirtyDate\t$cleanDate\n";
			}
			push @formatedDate, $year;
			push @formatedDate, $month;
			push @formatedDate, $day;
		}

	} else {
		die "format is a complex format with $formatLength numbers and cannot proceed!\t$dirtyDate\t$cleanDate\n";
	}


	my $newDate = join ("",@formatedDate);
	return $newDate;

}
########################################################################



