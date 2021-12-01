
FPGA_DIR=../../boards/ws_ep4ce10
SIM_DIR=$(FPGA_DIR)/simulation

TARGETS=test nibl.asxx
HEX=$(addsuffix .hex,$(TARGETS))
SIMS=$(addprefix $(SIM_DIR)/,$(HEX))
FPGAS=$(addprefix $(FPGA_DIR)/,$(HEX))

all:	$(SIMS) $(FPGAS)

clean:
	-rm $(SIMS) 2>/dev/nul ||:
	-rm $(FPGAS) 2>/dev/nul ||:
	-rm $(HEX) 2>/dev/nul ||:
	-rm $(addsuffix .ihx,$(TARGETS)) 2>/dev/nul ||:
	-rm $(addsuffix .lst,$(TARGETS)) 2>/dev/nul ||:
	-rm $(addsuffix .bin,$(TARGETS)) 2>/dev/nul ||:
	-rm $(addsuffix .rel,$(TARGETS)) 2>/dev/nul ||:
	-rm $(addsuffix .vhx,$(TARGETS)) 2>/dev/nul ||:

%.bin:	%.ihx
	hex2bin 0x0000 $< $@

%.ihx:	%.rel
	aslink -i -m -o $@ $< -e

%.rel:	%.asm
	asscmp -o -l $@ $<

%.vhx: %.bin
	/usr/bin/hexdump -v -e '/1 "%02X" " "' $< >$@
	
$(FPGA_DIR)/%.hex: %.ihx
	cp $< $@
	
$(SIM_DIR)/%.hex: %.ihx
	cp $< $@