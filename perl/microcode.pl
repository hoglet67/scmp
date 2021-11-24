#!/usr/bin/perl

use strict;
use POSIX;
use Data::Dumper qw(Dumper);

my $TABWIDTH=8;

sub usage($) {
	my ($msg) = @_;

	if ($msg) {
		print STDERR "$msg\n";
	}

	die "microcode.pl <input.txt> <output folder>\n";


}

sub header($) {
	my ($fh) = @_;

	print $fh "// This file was generated with microcode.pl - DO NOT EDIT\n";
	print $fh "\n";
}

my $fn_in = shift || usage "No input file";
my $dir_out = shift || usage "No output directory";
-d $dir_out || usage "$dir_out is not a directory";

my $fn_out_v = "$dir_out/scmp_microcode_pla.gen.sv";
my $fn_out_pak = "$dir_out/scmp_microcode_pla.gen.pak.sv";

open(my $fh_in, "<", $fn_in) || die "Cannot open \"$fn_in\" for input";


my $state = 0; #state machine for reading input 0 = defs, 1 = code
my $cur_section;
my %sections = ();
my @secorder = ();
my $code_ix = 0;
my %code_labels = ();
my $tot_size = 0;

my $sz_pc;

my @microcode=();

while (<$fh_in>) {
	my $l = $_;
	$l =~ s/[\s|\r]+$//;
	$l =~ s/\s*#.*//;

	if ($l =~ /^\s*#/ || $l =~ /^\s*$/) {
		#ignore it's a comment or blank
	} elsif ($state == 0) {
		# definitions
		if ($l =~ /^SECTION:([A-Za-z]\w*),(BITMAP|ONEHOT|INDEX|SIGNED),(\d+)/) {
			$cur_section = $1;
			my $cur_sec_type = $2;
			my $cur_sec_size = $3;
			my $cur_sec_ix = 0;

			if (exists $sections{$cur_section}) {
				die "repeated section $cur_section";
			}

			$sections{$cur_section} = {
				type => $cur_sec_type,
				size => $cur_sec_size,
				maxix => $cur_sec_ix,
				indices => [],
				values => [],
				named_values => []
			};
			push @secorder, $cur_section;
			$tot_size += $cur_sec_size;

		} elsif ($l =~ /^\s+([A-Za-z]\w*)\s*=\s*NUL\s*(\*)?\s*$/) {
			#special case NUL
			my $name = $1;
			my $def = $2;
			my $curs = $sections{$cur_section};

			$curs || die "Values before section";

			if ($def) {
				$curs->{def} = $name;
			}
			push @{$curs->{named_values}}, {
				name => $name,
				value => $curs->{size} . '\'d0'
			};
		} elsif ($l =~ /^\s+([A-Za-z]\w*)\s*=\s*([^*]+)(\*)?\s*$/i) {
			#named value
			my $name = $1;
			my $val = $2;
			my $def = $3;
			my $curs = $sections{$cur_section};

			$curs || die "Values before section";

			if ($def) {
				$curs->{def} = $name;
			}

			if ($val =~ /^\'/)
			{
				$val = $curs->{size} . $val;				
			}

			bounds_check(parseval($val,$cur_section,$curs),$cur_section,$curs);

			push @{$curs->{named_values}}, {
				name => $name,
				value => $val
			};
		} elsif ($l =~ /\s+([A-Za-z]\w*)(\*?)\s*$/) {
			my $name = $1;
			my $def = $2;
			my $curs = $sections{$cur_section};
			my $type = $curs->{type};
			my $size = $curs->{size};

			$curs || die "Values before section";

			my $ix = $curs->{maxix};

			if ($def) {
				$curs->{def} = $name;
			}

			if ($type eq "INDEX") {
				bounds_check($ix, $cur_section, $curs);
				push @{$curs->{indices}}, {
					name => $name,
					value => $ix
				};
			} elsif ($type eq "ONEHOT" || $type eq "BITMAP" ) {
				bounds_check(2**$ix, $cur_section, $curs);
				push @{$curs->{indices}}, {
					name => $name,
					value => "'d" . $ix
				};
				push @{$curs->{values}}, {
					name => $name,
					value => $size . "'b" . "0" x ($size - $ix - 1) . "1" . "0" x $ix
				};
			} else {
				die "Attempt add bare value when TYPE != INDEX, ONEHOT or BITMAP";
			}

			$curs->{maxix} = $ix + 1;


		} elsif ($l =~ /^\s*CODESTART=(\d+)\s*$/) {
			$state = 1;	

			$sz_pc = $1;
		
		} else {
			die "unrecognized line in definitions section : $l";
		}
	} elsif ($state == 1) {
		# microcode


		if ($l =~ /^\s*(\w+):\s*$/) {
			$code_labels{$1} = $code_ix;
			push @microcode, {type=>"COMMENT", comment=>"$1 = $code_ix"};
		} elsif ($l =~ /^\s*(\s*\w+\s*=\s*@?\w+)(\s*,\s*(\s*\w+=\s*@?\w+))*\s*$/) {
			my @parms2 = split(/\s*,\s*/, $l);

			my %params = ();
			foreach my $p (@parms2) {
				my @pp = split(/\s*=\s*/, $p);
				scalar @pp == 2 || die "Bad code parameter $p";
				my ($sec, $lbl) = @pp;

				$sec =~ s/\s//;
				$lbl =~ s/\s//;


				$params{$sec} = $lbl;				
			}

			my @mc_vals = ();
			foreach my $sec (@secorder) {
				my $curs = $sections{$sec};

				$curs || die "missing section $sec";


				my $ps = $params{$sec};
				if ($ps && $ps =~ /^@(\w+)$/) {
					push @mc_vals, "UCLBL_$1-$curs->{size}'d$code_ix";
				} else {
					my $v;
					if (!$ps || !($ps =~ /^UCLBL_/))
					{
						$v = "${sec}_";
					} 

					if ($ps) {
						$v .= $ps;
					} elsif (exists $curs->{def}) {
						$v .= $curs->{def};
					} else {
						die "No default value for $sec and none supplied in this line";
					}	
					push @mc_vals, $v;	
				}	
			}
			push @microcode, {type=>"MICROCODE", code_ix=>$code_ix, vals=>\@mc_vals};	
			$code_ix++;

			foreach my $pk (keys %params) {
				if (!exists $sections{$pk}) {
					die "unknown parameter $pk";
				}
			}


		} else {
			die "unrecognized line in code section : $l";
		}

	} else {
		die "unimplemented state=$state";
	}
}



open(my $fh_out_v, ">", $fn_out_v) || die "Cannot open \"$fn_out_v\" for output";

print $fh_out_v "import scmp_microcode_pak::*;\n";

header $fh_out_v;

print $fh_out_v "module scmp_microcode_pla(\n";
print $fh_out_v "\tinput\tMCODE_PC_t\tpc,\n";
print $fh_out_v "\toutput\tMCODE_t\tmcode\n";
print $fh_out_v ");\n\n";

print $fh_out_v "always_comb begin\n";
print $fh_out_v "\tcase(pc)\n";

print $fh_out_v "\t//\t\t\t\t";

#calculate the maximum length of each section's values/name
for my $i (0 .. $#secorder) {
	my $sec = @secorder[$i];
	my $curs = $sections{$sec};
	my $maxl = length($sec);
	foreach my $m (@microcode) {
		my $ll = length(@{$m->{vals}}[$i]);
		if ($ll > $maxl) {
			$maxl = $ll;
		}
	}

	# add one for space between labels
	$maxl++; 

	$curs->{textw} = $maxl+1;

	print $fh_out_v $sec;
	print $fh_out_v pad(length($sec), $maxl);
}

foreach my $m (@microcode) {
	if ($m->{type} eq "COMMENT") {
		print $fh_out_v "\t// $m->{comment}\n";
	} elsif ($m->{type} eq "MICROCODE") {
		print $fh_out_v "\t\t${sz_pc}'d$m->{code_ix}:\tmcode =\t{\t";
		
		my $ls = $#{$m->{vals}};
		for my $i (0 .. $ls) {
			my $sec = @secorder[$i];
			my $curs = $sections{$sec};
			my $mcv = @{$m->{vals}}[$i];

			print $fh_out_v $mcv;
			if ($i == $ls) {
				print $fh_out_v pad(length($mcv), $curs->{textw});
			} else {
				print $fh_out_v "," . pad(length($mcv)+1, $curs->{textw});
			}
		}

		print $fh_out_v "};\n";

	} else {
		die "Unexpected type";
	}
}

print $fh_out_v "\t\tdefault:mcode = {\t";
my $ls = $#secorder;
for my $i ( 0 .. $ls ) {
	my $sec = @secorder[$i];
	my $curs = $sections{$sec};

	my $def = $curs->{def};
	if (!$def) {
		$def = @{$curs->{values}}[0]->{name};
	}

	$def = "${sec}_${def}";

	print $fh_out_v $def;
	if ($i == $ls) {
		print $fh_out_v pad(length($def), $curs->{textw});
	} else {
		print $fh_out_v "," . pad(length($def)+1, $curs->{textw});
	}

}
print $fh_out_v "};\n";

#print $fh_out_v "\t\tdefault: mcode = 0;\n";
print $fh_out_v "\tendcase\n";
print $fh_out_v "end\n";
print $fh_out_v "endmodule\n";


open(my $fh_out_pak, ">", $fn_out_pak) || die "Cannot open \"$fn_out_pak\" for output";
print $fh_out_pak "package scmp_microcode_pak;\n";
header $fh_out_pak;

my $first;
foreach my $sec (@secorder) {

	my $curs = $sections{$sec};
	$curs || die "Values before section";
	my $type = $curs->{type};
	my $indices = $curs->{indices};
	my $values = $curs->{values};
	my $named_values = $curs->{named_values};

	print $fh_out_pak "// $sec\n";

	#print $fh_out_pak "`define\tSZ_$sec\t$curs->{size}\n";
	my $szm1 = $curs->{size} - 1;

	if ($type eq "ONEHOT" || $type eq "BITMAP") {
		if (scalar @$indices)	{
			print $fh_out_pak "typedef enum {\n"
		}
		$first = 1;
		for my $nv (@$indices) {
			if ($first) {
				$first = 0;
			} else {
				print $fh_out_pak ",\n";
			}	
			print $fh_out_pak "\t${sec}_IX_$nv->{name}\t= $nv->{value}";
		}
		if (scalar @$indices)	{
			print $fh_out_pak "\n} ${sec}_ix_t;\n"
		}

		if ($type eq "ONEHOT") {
			if (scalar @$values)	{
				print $fh_out_pak "typedef enum logic [$szm1:0] {\n";
			} else {
				print $fh_out_pak "typedef logic [$szm1:0] ${sec}_t;\n";
			}
			$first = 1;
			for my $nv (@$values) {
				if ($first) {
					$first = 0;
				} else {
					print $fh_out_pak ",\n";
				}	
				print $fh_out_pak "\t${sec}_$nv->{name}\t= $nv->{value}";
			}
			if (scalar @$values)	{
				print $fh_out_pak "\n} ${sec}_t;\n"
			}
		} else {
			print $fh_out_pak "typedef logic [$szm1:0] ${sec}_t;\n";
			for my $nv (@$values) {
				print $fh_out_pak "const\t${sec}_t\t${sec}_$nv->{name}\t= $nv->{value};\n";
			}			
		}

		if (scalar @$named_values) {
			print $fh_out_pak "\n";	
		}
		for my $nv (@$named_values) {			
			my $val2 = $nv->{value};
			$val2 =~ s/(?<!')\b([a-z]\w*)\b/${sec}_$1/gi;
			print $fh_out_pak "const\t${sec}_t\t${sec}_$nv->{name}\t= $val2;\n";
		}
	} elsif ($type eq "SIGNED" || $type eq "INDEX") {
		my $szm1 = $curs->{size} - 1;
		print $fh_out_pak "typedef logic " . (($type eq "SIGNED")?"signed":"") . "[$szm1:0] ${sec}_t;\n";
		for my $nv (@$values) {			
			print $fh_out_pak "const\t${sec}_t\t${sec}_$nv->{name}\t= $nv->{value};\n";
		}
		for my $nv (@$named_values) {			
			my $val2 = $nv->{value};
			$val2 =~ s/(?<!')\b([a-z]\w+)\b/${sec}_$1/gi;
			print $fh_out_pak "const\t${sec}_t\t${sec}_$nv->{name}\t= $val2;\n";
		}		
	}	
}

print $fh_out_pak "\n";

print $fh_out_pak "typedef struct packed {\n";
foreach my $sec (@secorder) {
	printf $fh_out_pak "\t${sec}_t\t" . lc(${sec}) . ";\n";
}
print $fh_out_pak "} MCODE_t;\n";


print $fh_out_pak "\n";
print $fh_out_pak "typedef logic [7:0] MCODE_IX_t;\n";
foreach my $lbl (keys %code_labels) {
	print $fh_out_pak "const MCODE_IX_t UCLBL_$lbl = ${sz_pc}'d$code_labels{$lbl};\n";
}

printf $fh_out_pak "typedef logic [%d:0] MCODE_PC_t;\n", $sz_pc-1;

print $fh_out_pak "endpackage";

# output enough tabs and spaces to pad a string of length $l to $w, $TABWIDTH defines tab size
# NOTE: $w2 will be rounded up to next TAB stop
sub pad($$) {	
	my ($l, $w) = @_;
	my $w2 = $TABWIDTH * ceil($w/$TABWIDTH);

	$w2 -= $l;

	return "\t" x ceil($w2/$TABWIDTH);
}

sub bounds_check($$$) {
	my ($val, $cur_section, $curs) = @_;

	if ($curs->{type} eq "INDEX") {
		$val < 2**$curs->{size} || die sprintf "Value (%d) too large for INDEX size %s:%d", $val, $cur_section, $curs->{size};
	} elsif ($curs->{type} eq "BITMAP" || $curs->{type} eq "ONEHOT") {
		$val < 2**$curs->{size} || die sprintf "Value (%d) too large for BITMAP/ONEHOT size %s:%d", $val, $cur_section, $curs->{size};		
		$curs->{type} eq "ONEHOT" && countbits($val) > 1 && die sprintf "More than one bit (%b) set in ONEHOT %s", $val, $cur_section;
	} elsif ($curs->{type} eq "SIGNED") {
		(
			$val >= -(2**($curs->{size}-1))
		&&	$val < (2**($curs->{size}-1))
		)	|| die sprintf "Value (%d) too large for SIGNED size %s:%d", $val, $cur_section, $curs->{size};
	} else {
		die "Unknown type ($curs->{type}) in bounds_check $cur_section";
	}
}

sub parseval($$$) {
	my ($vs,$cur_section,$curs) = @_;

	if ($vs =~ /^([^\|]+)\|(.*)$/) {
		return parseval($1,$cur_section,$curs) | parseval($2,$cur_section,$curs);
	} else {
		if ($vs =~ /^[a-zA-Z]/) {
			my ($vv) = grep { $vs eq $_->{name} } @{$curs->{values}};
			if (!$vv) {
				($vv) = grep { $vs eq $_->{name} } @{$curs->{named_values}};
			}
			$vv || die "Cannot find value $vs in section $cur_section in parseval";
			return parseval($vv->{value});
		} else {
			$vs =~ /^\d*\'([dbx])(.*?)\s*$/ || die "Expecting numeric literal got \"$vs\" in parseval";
			my ($base, $v) = ($1, $2);
			if ($base eq "b") {
				return oct("0b" . $v);
			} elsif ($base eq "d") {
				return $v;
			} elsif ($base eq "x") {
				return hex($v);
			} else {
				die "Unexpected base ($base) in parseval";
			}
		} 
	}
}

sub countbits($) {
	my ($v) = @_;
	my $count = 0;
	while ($v) {
		if ($v & 0x1) {
			$count++;
		}

		$v >>= 1;
	}
	return $count;
}