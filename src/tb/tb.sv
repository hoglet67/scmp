`timescale	1 ns / 1 ns


module tb ();

	reg		clk_50m;
	reg		rst_n;
	wire	[3:0]	led_n;
	

	scmp_dom  
	dut
	(
		.clk_50m(clk_50m),
		.rst_n(rst_n),
		.led_n(led_n)
	);
	defparam dut.C_SIZE = 9;

	always
		#10 clk_50m <= ~clk_50m;

	initial begin
		
		rst_n <= 1'b1;
		clk_50m <= 1'b0;

		#1000	rst_n <= 1'b0;

		#5000	rst_n <= 1'b1;


		#100000;

		$stop;

	end


endmodule