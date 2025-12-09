
#!/bin/bash -e

iverilog -g 2009 \
         ../../src/scmp_microcode_pla.gen.pak.sv \
         ../../src/scmp_microcode_pla.gen.sv \
         ../../src/scmp_microcode_oppc.gen.sv  \
         ../../src/scmp_micrcode.sv \
         ../../src/scmp_alu.sv \
         ../../src/reg8.sv  \
         ../../src/mux_oh.sv \
         ../../src/scmp.sv \
         ps2_intf.sv \
         tm1638.sv \
         keypad.sv \
         debug.sv \
         lcds.sv \
         ../../tb/tb_tangnano20kdock_lcds.sv

echo Running iverilog simulation
./a.out

gtkwave dump.vcd lcds.gtkw
