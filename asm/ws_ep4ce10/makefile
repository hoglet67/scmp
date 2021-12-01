
FPGA_DIR=../../boards/ws_ep4ce10/
SIM_DIR=$(FPGA_DIR)/simulation

all:	test.vhx $(SIM_DIR)/test.hex $(FPGA_DIR)/test.hex

clean:
	-rm test.ihx test.map test.bin test.rel test.lst test.hlr test.vhx 2>/dev/nul ||:

test.bin:	test.ihx
	hex2bin 0x0000 test.ihx test.bin

test.ihx:	test.rel
	aslink -i -m -o test.ihx test.rel -e

test.rel:	test.asm
	asscmp -o -l test.bin test.asm

test.vhx: test.bin
	/usr/bin/hexdump -v -e '/1 "%02X" " "' test.bin >test.vhx
	
$(FPGA_DIR)/test.hex: test.ihx
	cp test.ihx $(FPGA_DIR)/test.hex
	
$(SIM_DIR)/test.hex: test.ihx
	cp test.ihx $(SIM_DIR)/test.hex