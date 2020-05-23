module scmp
(
input	wire		clk,
input	wire		rst_n,
output  wire	[11:0]	addr
);

	// indices for selecting a read/load from the high read/write buses
	parameter	SEL_H_NONE 	= 5'b00000;
	parameter	SEL_H_P0_OH 	= 5'b00001;
	parameter	SEL_H_P1_OH 	= 5'b00010;
	parameter	SEL_H_P2_OH 	= 5'b00100;
	parameter	SEL_H_P3_OH 	= 5'b01000;
	parameter	SEL_H_ADDR_OH 	= 5'b10000;


	wire	[7:0]	reg8_addr_h_q;
	wire	[7:0]	reg8_addr_l_q;
	wire	[7:0]	reg8_p_h_q[3:0];
	wire	[7:0]	reg8_p_l_q[3:0];

	
	wire	[4:0]	ld_h;	//load pointer /address / addr hi - note more than one or none may be active
	wire	[8:0]	ld_l;	//load pointer / address / accum / ext / stat / data


	parameter	LD_H_IX_P0	= 'd0;
	parameter	LD_H_IX_P1	= 'd1;
	parameter	LD_H_IX_P2	= 'd2;
	parameter	LD_H_IX_P3	= 'd3;
	parameter	LD_H_IX_ADDR	= 'd4;


	parameter	LD_L_IX_P0	= 'd0;
	parameter	LD_L_IX_P1	= 'd1;
	parameter	LD_L_IX_P2	= 'd2;
	parameter	LD_L_IX_P3	= 'd3;
	parameter	LD_L_IX_ADDR	= 'd4;
	parameter	LD_L_IX_ACC	= 'd5;
	parameter	LD_L_IX_EXT	= 'd6;
	parameter	LD_L_IX_STAT	= 'd7;
	parameter	LD_L_IX_D	= 'd8;

	wire	[7:0]	write_bus_hi;
	wire	[2:0]	write_bus_hi_src_oh;

	parameter	WR_H_IX_RD_H	= 'd0;	// loop back from high read bus
	parameter	WR_H_IX_RD_INC4	= 'd1;	// incrementer
	parameter	WR_H_IX_RD_L	= 'd2;	// low read bus


	wire	[4:0]	read_bus_hi_src_oh;	//load pointer /address / addr hi
	wire	[7:0]	read_bus_hi;

	wire	[7:0]	incr4_out;

	wire	[7:0]	read_bus_lo;

	assign addr = { reg8_addr_h_q[3:0], reg8_addr_l_q };


	generate
		genvar gi;
		//instantiate pointer registers in a loop
		for (gi=0; gi < 4; gi = gi + 1) begin : gen_pregs
			reg8 reg_p_h (
				.clk(clk),
				.rst_n(rst_n),
				.D(write_bus_hi),
				.ctl_ld(ld_h[gi]),
				.Q(reg8_p_h_q[gi])
				);
			reg8 reg_p_l (
				.clk(clk),
				.rst_n(rst_n),
				.D(write_bus_lo),
				.ctl_ld(ld_l[gi]),
				.Q(reg8_p_l_q[gi])
				);
		end
	endgenerate

	//address register
	reg8 reg_addr_h (
			.clk(clk),
			.rst_n(rst_n),
			.D(write_bus_hi),
			.ctl_ld(ld_h[LD_H_IX_ADDR]),
			.Q(reg8_addr_h_q)
		);
	reg8 reg_addr_l (
			.clk(clk),
			.rst_n(rst_n),
			.D(write_bus_lo),
			.ctl_ld(ld_l[LD_L_IX_ADDR]),
			.Q(reg8_addr_l_q)
		);

	mux_oh mux_write_bus_hi (
			.sel_oh(write_bus_hi_src_oh),
			.D('{	read_bus_lo,
				incr4_out,
				read_bus_hi
				}),
			.Q(write_bus_hi)
		);
	defparam mux_read_bus_hi.SIZE = 3;


	wire [3:0]	incr4_lo;
	assign incr4_lo = (read_bus_hi[3:0] + 4'd1); 

	//incrementer
	assign incr4_out = { read_bus_hi[7:4], incr4_lo };

	mux_oh mux_read_bus_hi (
			.sel_oh(read_bus_hi_src_oh),
			.D('{
				reg8_addr_h_q,				
				reg8_p_h_q[3],
				reg8_p_h_q[2],
				reg8_p_h_q[1],
				reg8_p_h_q[0]
				}),
			.Q(read_bus_hi)
		);
	defparam mux_read_bus_hi.SIZE = 5;


	//TEST
	reg		state;
	parameter	state_inc_p0_set_addr	= 1'b0;
	parameter	state_ld_op		= 1'b1;


	parameter 	write_bus_hi_src_read_bus_h	= 'b001;
	parameter 	write_bus_hi_src_incr4 		= 'b010;
	parameter 	write_bus_hi_src_read_bus_l	= 'b100;

	assign write_bus_hi_src_oh = 	state == state_inc_p0_set_addr ? write_bus_hi_src_incr4 :
					write_bus_hi_src_read_bus_l;
	assign read_bus_hi_src_oh = 	SEL_H_P0_OH;
	assign ld_h = 			state == state_inc_p0_set_addr 	? SEL_H_P0_OH | SEL_H_ADDR_OH :
					SEL_H_NONE;

	always@(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			state <= state_inc_p0_set_addr;
		else begin
			if (state == state_inc_p0_set_addr)
				state <= state_ld_op;
			else begin
				state <= state_inc_p0_set_addr;
			end
		end
	end

endmodule