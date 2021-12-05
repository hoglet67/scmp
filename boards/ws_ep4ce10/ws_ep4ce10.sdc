## Generated SDC file "ws_ep4ce10.out.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"

## DATE    "Tue Nov 30 23:59:22 2021"

##
## DEVICE  "EP4CE10F17C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_50m} -period 20.000 -waveform { 0.000 10.000 } [get_ports { clk_50m }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {cpu_clk} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 6 -divide_by 55 -master_clock {clk_50m} [get_pins {pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {clk_1m} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 50 -master_clock {clk_50m} [get_pins {pll|altpll_component|auto_generated|pll1|clk[1]}] 

create_generated_clock -name {clk_disp} -source [get_pins {pll|altpll_component|auto_generated|pll1|clk[1]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 4096 -master_clock {clk_1m} [get_keepers {counter[11]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

