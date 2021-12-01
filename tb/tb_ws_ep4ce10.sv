/* A testbench for the ws_epm1270 top level module
*/



`timescale	1 ns / 1 ns

`define baud 19200
`define halfbit (1000000000 / (`baud * 2))

string TESTSTR = "Ishbel";


module tb_ws_ep4ce10 ();

	logic		clk_50m;
	logic		rst_n;
	logic	[3:0]	led_n;
	logic		r_sin;


	ws_ep4ce10
	dut
	(
		.clk_50m(clk_50m),
		.rst_n(rst_n),
		.led_n(led_n),
		.sin(r_sin)
	);
	defparam dut.C_SIZE = 9;
	defparam dut.SIM = 1;

	always
		#10 clk_50m <= ~clk_50m;

	initial begin
		
		rst_n <= 1'b1;
		clk_50m <= 1'b0;

		#1000	rst_n <= 1'b0;

		#5000	rst_n <= 1'b1;


		#80000000;

		$stop;

	end


	logic signed[4:0] serpos = -1;

	initial begin
		forever begin
			#`halfbit;
				r_sin <= 1'b1;
			#`halfbit;
				r_sin <= 1'b0;
		end
	end


endmodule