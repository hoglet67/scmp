/* A testbench for the ws_epm1270 top level module
*/



`timescale	1 ns / 1 ns

`define baud 1200
`define halfbit (1000000000 / (`baud * 2))

string TESTSTR = "Ishbel";


module tb_ws_ep4ce10 ();

	logic		clk_50m;
	logic		rst_n;
	logic	[3:0]	led_n;
	logic		r_sin;
	logic		i_ser_tx;
	logic		i_ser_rx;

	ws_ep4ce10
	dut
	(
		.clk_50m(clk_50m),
		.rst_n(rst_n),
		.led_n(led_n),
		.ser_tx(i_ser_tx),
		.ser_rx(i_ser_rx)
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


	logic 	[7:0]	char_tx;
	typedef enum {IDLE, BITS, STOP} t_serstate;
	t_serstate ser_state = IDLE;

	//A quick n dirty serial reader
	initial begin
		ser_state <= IDLE;


		forever begin
			if (ser_state == IDLE) begin
				@(negedge i_ser_tx);
				#`halfbit;
				ser_state <= BITS;
				char_tx <= 8'b10000000;
				#`halfbit;
				#`halfbit;
			end else begin
				if (ser_state == BITS) begin
					if (char_tx[0])
						ser_state <= STOP;
					char_tx[6:0] <= char_tx[7:1];
					char_tx[7] <= i_ser_tx;
					#`halfbit;
					#`halfbit;
				end else begin
					$display("Read char [%h] %s", char_tx, char_tx);
					ser_state <= IDLE;					
					#`halfbit;
					#`halfbit;
				end
				

			end


		end

	end

	string test_str = {"A\x0d"};
	logic [7:0] char_rx;

	initial begin
		i_ser_rx <= 1'b1;
		#44000000;		// wait for prompt to print

		foreach (test_str[i]) begin
			i_ser_rx <= 1'b0;	//start bit;
			char_rx <= test_str[i];
			#`halfbit;
			#`halfbit;
			foreach (char_rx[j]) begin
				i_ser_rx <= char_rx[7-j];
				#`halfbit;
				#`halfbit;
			end
			i_ser_rx <= 1'b1;
			#`halfbit;
			#`halfbit;
			#`halfbit;
			#`halfbit;

		end;

	end


endmodule