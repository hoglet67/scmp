
# Microcode perl script

The microcode.pl file takes an input file and produces a verilog package file
containing a set of type definitions that can be used to encode microcode and 
a "pla" file which contains a combinatorial process that encodes a pla/rom of 
the microcode.

## Definitions

The first section of the file contains a set of definitions which are used to
define vertical slices of microcode outputs which will be generated for each 
microcode step.

### Section

	SECTION:<NAME>,<TYPE>,<WIDTH>

Within definitions a SECTION will define a microcode attribute which can be
included in each microcode step. Each microcode line will comprise a set of 
these sections

TYPE can be one of

*	BITMAP - a bitmap of values which may be combined to turn on multiple
	signals
*	ONEHOT - much like a bitmap but only one value will be "hot" i.e. b'1
	at a time
*	INDEX - values will be a binary index i.e. 0..(2^WIDTH)-1
*	SIGNED - values will be a binary index i.e. -(2^WIDTH-1)..(2^WIDTH-1)-1

WIDTH is the binary width of the section


After a SECTION tag there follows a set of value definitions

### Value definition:

	\t<NAME>[=<NUM>|NUL][*]

Each value will be output as a constant named:

	<SECTION_NAME>_<VALUE_NAME>

A single value in each section may be marked with an asterisk(\*) to indicate
that this is the default value for microcode lines that contain no setting for
this section. If no line in a section is marked thus the first value will be
used.

In ONEHOT and BITMAP sections values without a specified NUM will be given
a value based on their order in the file. Each value will be assigned a value
starting b'1 and shifting left one for each value i.e. the second value will
be b'10

In INDEX sections values without a specified NUM will be given the next
highest value

Where \<NUM\> is specified this is treated as a "named value" it can either be
a numeric value starting with apostrophe(') or a value based on other values
in this section combined using verilog operators.


### Definitions End

	CODESTART=<PC WIDTH>

Marks the end of the definitions section and the start of the microcode section.

A set of type definitions for each section and constants for each value/named value
will be emitted to the scmp_microcode_pla.gen.pak.sc


## MICROCODE

The rest of the file after the line starting CODESTART= is the microcode. Lines
in the microcode section can be either labels or code lines. 

Each non-blank microcode line is given a zero-based index. Lines may be referred
to using labels.

### Labels

	<LABEL_NAME>:

A label line must start with a letter or digit (no leading whitespace) and 
consist of a label name. Labels may be used to refer to microcode lines by name
in the HDL and in the microcode definitions.

### Microcode lines

	<SECTION_NAME>=<VALUE_NAME>|@LABEL|#LABEL[,<SECTION_NAME>=<VALUE_NAME>|@LABEL|#LABEL]

Each microcode line contains a set of values for each section that needs a 
non-default value. Each value must come from the set of named values or be a 
label reference:

#### Relative label reference

	@<LABEL>

These should normally only be used in signed sections and will add a line value
which is the difference between the index of the label and index of the current line



