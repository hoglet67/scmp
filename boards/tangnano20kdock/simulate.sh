
#!/bin/bash

iverilog -g 2009 \
         ../../src/scmp_microcode_pla.gen.pak.sv \
         ../../src/scmp_microcode_pla.gen.sv \
         ../../src/scmp_microcode_oppc.sv  \
         ../../src/scmp_micrcode.sv \
         ../../src/scmp_alu.sv \
         ../../src/reg8.sv  \
         ../../src/mux_oh.sv \
         ../../src/scmp.sv \
         tangnano20kdock.sv \
         ../../tb/tb_tangnano20kdock.sv

echo Running iverilog simulation
./a.out

gtkwave dump.vcd tangnano20kdock.gtkw
