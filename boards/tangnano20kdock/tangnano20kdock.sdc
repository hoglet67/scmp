set_operating_conditions -grade c -model slow -speed 8 -setup -hold

create_clock -name sys_clk -period 37.0370370370 -waveform {0 18.5185185185} [get_ports {sys_clk}] -add

// Create clock definitions for each of the derived clocks
create_generated_clock -name cpu_clk -source [get_ports {sys_clk}] -master_clock sys_clk -divide_by 16 -multiply_by 13 [get_nets {cpu_clk}]
create_generated_clock -name ram_clk -source [get_ports {sys_clk}] -master_clock sys_clk -divide_by 8 -multiply_by 13 [get_nets {ram_clk}]
