
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

	\<NAME\>[=\<VALUE\>|NUL][\*]

Each value will be output as a constant named:

	\<SECTION_NAME\>_\<VALUE_NAME\>

