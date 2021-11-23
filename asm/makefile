

all:	test.vhx

clean:
	-rm test.ihx test.map test.bin test.rel test.lst test.hlr 2>/dev/nul ||:

test.bin:	test.ihx
	hex2bin 0x0000 test.ihx test.bin

test.ihx:	test.rel
	aslink -i -m -o test.ihx test.rel -e

test.rel:	test.asm
	asscmp -o -l test.bin test.asm

test.vhx: test.bin
	/usr/bin/hexdump -e '/1 "%02X" " "' test.bin >test.vhx