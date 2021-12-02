AS=~/build/asl-current/asl.exe
ASFLAGS=-L

P2BIN=~/build/asl-current/p2bin.exe

FPGA_DIR=../../boards/ws_ep4ce10
SIM_DIR=$(FPGA_DIR)/simulation

TARGETS=test nibl
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
	-rm $(addsuffix .cod,$(TARGETS)) 2>/dev/nul ||:

%.ihx:	%.bin
	bin2hex 0 $< $@

%.bin:	%.cod
	$(P2BIN) $< $@

%.cod:	%.asm
	$(AS) $(ASFLAGS) -o $@ $<

$(FPGA_DIR)/%.hex: %.ihx
	cp $< $@
	
$(SIM_DIR)/%.hex: %.ihx
	cp $< $@