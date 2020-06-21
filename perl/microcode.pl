#!/usr/bin/perl

use strict;

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
my $fn_out_vh = "$dir_out/scmp_microcode_pla.gen.vh";

open(my $fh_in, "<", $fn_in) || die "Cannot open \"$fn_in\" for input";
open(my $fh_out_v, ">", $fn_out_v) || die "Cannot open \"$fn_out_v\" for output";
open(my $fh_out_vh, ">", $fn_out_vh) || die "Cannot open \"$fn_out_vh\" for output";

print $fh_out_v "`include \"scmp_microcode_pla.gen.vh\"\n";

header $fh_out_v;
header $fh_out_vh;


my $state = 0; #state machine for reading input 0 = defs, 1 = code
my $cur_section;
my %sections = ();
my @secorder = ();
my $code_ix = 0;
my %code_labels = ();
my $tot_size = 0;

my $sec_pc;
my $sz_pc;

while (<$fh_in>) {
	my $l = $_;
	$l =~ s/[\s|\r]+$//;

	if ($l =~ /^\s*#/ || $l =~ /^\s*$/) {
		#ignore it's a comment or blank
	} elsif ($state == 0) {
		if ($l =~ /^SECTION:(\w+),(BITMAP|ONEHOT|INDEX|SIGNED),(\d+)/) {
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
				indeces => [],
				values => [],
				named_values => []
			};
			push @secorder, $cur_section;
			$tot_size += $cur_sec_size;

		} elsif ($l =~ /^\s*(\w+)=NUL(\*)?/) {
			#special case NUL
			my $name = $1;
			my $def = $2;
			my $curs = $sections{$cur_section};

			$curs || die "Values before section";

			if ($def) {
				$curs->{def} = $name;
			}
			push $curs->{named_values}, {
				name => $name,
				value => $curs->{size} . '\'d0'
			};
		} elsif ($l =~ /^\s*(\w+)=([^*]+)(\*)?/i) {
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

			push $curs->{named_values}, {
				name => $name,
				value => $val
			};
		} elsif ($l =~ /\s+(\w+)(\*?)\s*$/) {
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
				push $curs->{indeces}, {
					name => $name,
					value => $ix
				};
			} elsif ($type eq "ONEHOT" || $type eq "BITMAP" ) {				
				push $curs->{indeces}, {
					name => $name,
					value => "'d" . $ix
				};
				push $curs->{values}, {
					name => $name,
					value => $size . "'b" . "0" x ($size - $ix - 1) . "1" . "0" x $ix
				};
			} else {
				die "Attempt add bare value when TYPE != INDEX, ONEHOT or BITMAP";
			}

			$curs->{maxix} = $ix + 1;


		} elsif ($l =~ /^\s*CODESTART\s*$/) {
			$state = 1;	

			$sec_pc = $sections{"NEXTPC"};
			$sec_pc || die "expecting section NEXTPC";
			$sz_pc = $sec_pc->{size};

			print $fh_out_v "module scmp_microcode_pla(\n";

			print $fh_out_v "\tinput\twire\t[`SZ_NEXTPC-1:0]\tpc";
			for my $s (@secorder) {
				print $fh_out_v ",\n\toutput\treg\t[`SZ_$s-1:0]\t" . lc($s) ;
			}
			print $fh_out_v ");\n\n";

			print $fh_out_v "reg [`SZ_MCODE-1:0] cur;\n";
			print $fh_out_v "assign {";
			my $first=1;
			for my $s (@secorder) {
				if ($first) {
					$first = 0;
				} else {
					print $fh_out_v ", ";
				}
				print $fh_out_v lc($s);
			}
			print $fh_out_v "} = cur;\n";

			print $fh_out_v "always_comb begin\n";
			print $fh_out_v "\tcase(pc)\n";
		
		} else {
			die "unrecognized line in definitions section : $l";
		}
	} elsif ($state == 1) {



		if ($l =~ /^\s*(\w+):\s*$/) {
			$code_labels{$1} = $code_ix;
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

			print $fh_out_v "\t\t${sz_pc}'d${code_ix}:\tcur =\t{";
			my $first = 1;
			foreach my $sec (@secorder) {
				my $curs = $sections{$sec};

				$curs || die "missing section $sec";

				if (!$first) {
					print $fh_out_v ",\t";
				} else {
					print $fh_out_v "\t";
					$first = 0;
				}

				my $ps = $params{$sec};
				if ($ps && $ps =~ /^@(\w+)$/) {
					print $fh_out_v "`UCLBL_$1-$curs->{size}'d${code_ix}";
				} else {
					if (!$ps || !($ps =~ /^UCLBL_/))
					{
						print $fh_out_v "`${sec}_";
					} else {
						print $fh_out_v "`";
					}
					if ($ps) {
						print $fh_out_v $ps;
					} elsif (exists $curs->{def}) {
						print $fh_out_v $curs->{def};
					} else {
						die "No default value for $sec and none supplied in this line";
					}		
				}		
			}

			foreach my $pk (keys %params) {
				if (!exists $sections{$pk}) {
					die "unknown parameter $pk";
				}
			}

			print $fh_out_v "};\n";
			$code_ix++;

		} else {
			die "unrecognized line in code section : $l";
		}

	} else {
		die "unimplemented state=$state";
	}
}

print $fh_out_v "\t\tdefault: cur = `SZ_MCODE'd0;";
print $fh_out_v "\tendcase\n";
print $fh_out_v "end\n";
print $fh_out_v "endmodule\n";


foreach my $sec (@secorder) {

	my $curs = $sections{$sec};
	$curs || die "Values before section";
	my $type = $curs->{type};
	my $indeces = $curs->{indeces};
	my $values = $curs->{values};
	my $named_values = $curs->{named_values};

	print $fh_out_vh "// $sec\n";

	print $fh_out_vh "`define\tSZ_$sec\t$curs->{size}\n";

	if ($type eq "ONEHOT" || $type eq "BITMAP") {
		if (scalar @$indeces)	{
			print $fh_out_vh "\n";
		}
		for my $nv (@$indeces) {
			print $fh_out_vh "`define\t${sec}_IX_$nv->{name}\t$nv->{value}\n";
		}
		if (scalar @$values)	{
			print $fh_out_vh "\n";
		}
		for my $nv (@$values) {			
			print $fh_out_vh "`define\t${sec}_$nv->{name}\t$nv->{value}\n";
		}
		if (scalar @$named_values) {
			print $fh_out_vh "\n";	
		}
		for my $nv (@$named_values) {			
			my $val2 = $nv->{value};
			$val2 =~ s/(?<!')\b([a-z]\w+)\b/`${sec}_$1/gi;
			print $fh_out_vh "`define\t${sec}_$nv->{name}\t$val2\n";
		}
	} elsif ($type eq "SIGNED" || $type eq "INDEX") {
		if (scalar @$values)	{
			print $fh_out_vh "\n";
		}
		for my $nv (@$values) {			
			print $fh_out_vh "`define\t${sec}_$nv->{name}\t$nv->{value}\n";
		}
		if (scalar @$named_values) {
			print $fh_out_vh "\n";	
		}
		for my $nv (@$named_values) {			
			my $val2 = $nv->{value};
			$val2 =~ s/(?<!')\b([a-z]\w+)\b/`${sec}_$1/gi;
			print $fh_out_vh "`define\t${sec}_$nv->{name}\t$val2\n";
		}		
	}	
}

print $fh_out_vh "\n";
print $fh_out_vh "`define SZ_MCODE ${tot_size}\n";



print $fh_out_vh "\n";
foreach my $lbl (keys %code_labels) {
	print $fh_out_vh "`define UCLBL_$lbl ${sz_pc}'d$code_labels{$lbl}\n";
}
