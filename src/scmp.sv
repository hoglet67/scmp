`include "scmp_alu.vh"


module scmp
(
input	wire		clk,
input	wire		rst_n,
input	wire	[7:0]	D_i,
input	wire		sb,
input	wire		sa,

output  wire	[11:0]	addr,
output	wire	[7:0]	D_o,
output  wire		f0,
output  wire		f1,
output  wire		f2
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

	wire	[7:0]	reg8_acc_q;
	wire	[7:0]	reg8_ext_q;

	//status register (registers)
	reg		status_cy;
	reg		status_ov;
	reg		status_ie;
	reg		status_f2;
	reg		status_f1;
	reg		status_f0;

	wire	[7:0]	reg8_status_q;

	assign	f0 = status_f0;
	assign	f1 = status_f1;
	assign	f2 = status_f2;

	assign	reg8_status_q = { status_cy, status_ov, sb, sa, status_ie, status_f2, status_f1, status_f0 };

	wire		ld_status_alu;
	wire		ld_status_rd_l;

	
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

	parameter	LD_L_P0		= 9'b000000001;
	parameter	LD_L_P1		= 9'b000000010;
	parameter	LD_L_P2		= 9'b000000100;
	parameter	LD_L_P3		= 9'b000001000;
	parameter	LD_L_ADDR	= 9'b000010000;
	parameter	LD_L_ACC	= 9'b000100000;
	parameter	LD_L_EXT	= 9'b001000000;
	parameter	LD_L_STAT	= 9'b010000000;
	parameter	LD_L_D		= 9'b100000000;
	parameter	LD_L_NONE	= 9'b000000000;

	wire	[7:0]	write_bus_hi;
	wire	[2:0]	write_bus_hi_src_oh;

	parameter	WR_H_IX_RD_H	= 'd0;	// loop back from high read bus
	parameter	WR_H_IX_RD_INC4	= 'd1;	// incrementer
	parameter	WR_H_IX_RD_L	= 'd2;	// low read bus

	parameter 	WR_H_RD_H	= 3'b001;
	parameter 	WR_H_INCR4	= 3'b010;
	parameter 	WR_H_RD_L	= 3'b100;

	wire	[4:0]	read_bus_hi_src_oh;	//load pointer /address / addr hi
	wire	[7:0]	read_bus_hi;

	wire	[7:0]	incr4_out;

	wire	[7:0]	write_bus_lo;
	wire	[2:0]	write_bus_lo_src_oh;
	parameter	WR_L_IX_RD_H	= 'd0;
	parameter	WR_L_IX_RD_L	= 'd1;
	parameter	WR_L_IX_ALU	= 'd2;

	parameter	WR_L_RD_H	= 3'b001;
	parameter	WR_L_RD_L	= 3'b010;
	parameter	WR_L_ALU	= 3'b100;

	wire	[7:0]	read_bus_lo;
	wire	[8:0]	read_bus_lo_src_oh;
	parameter	RD_LO_SRC_IX_PO		= 'd0;	
	parameter	RD_LO_SRC_IX_P1		= 'd1;	
	parameter	RD_LO_SRC_IX_P2		= 'd2;	
	parameter	RD_LO_SRC_IX_P3		= 'd3;	
	parameter	RD_LO_SRC_IX_ADDR	= 'd4;	
	parameter	RD_LO_SRC_IX_ACC	= 'd5;	
	parameter	RD_LO_SRC_IX_EXT	= 'd6;	
	parameter	RD_LO_SRC_IX_STATUS	= 'd7;	
	parameter	RD_LO_SRC_IX_D		= 'd8;	

	parameter	RD_LO_SRC_PO		= 9'b000000001;	
	parameter	RD_LO_SRC_P1		= 9'b000000010;	
	parameter	RD_LO_SRC_P2		= 9'b000000100;	
	parameter	RD_LO_SRC_P3		= 9'b000001000;	
	parameter	RD_LO_SRC_ADDR		= 9'b000010000;	
	parameter	RD_LO_SRC_ACC		= 9'b000100000;	
	parameter	RD_LO_SRC_EXT		= 9'b001000000;	
	parameter	RD_LO_SRC_STATUS	= 9'b010000000;	
	parameter	RD_LO_SRC_D		= 9'b100000000;	

	wire	[7:0]	reg8_D_Q;

	wire	[3:0]	alu_op;
	wire	[7:0]	alu_Q;
	wire		alu_cy;
	wire		alu_ov;


	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			status_cy <= 1'b0;
			status_ov <= 1'b0;
			status_ie <= 1'b0;
			status_f2 <= 1'b0;
			status_f1 <= 1'b0;
			status_f0 <= 1'b0;
		end
		else begin
			if (ld_status_rd_l) begin
				status_cy <= read_bus_lo[7];
				status_ov <= read_bus_lo[6];
				status_ie <= read_bus_lo[3];
				status_f2 <= read_bus_lo[2];
				status_f1 <= read_bus_lo[1];
				status_f0 <= read_bus_lo[0];
			end else if (ld_status_alu) begin
				status_cy <= alu_cy;
				status_ov <= alu_ov;
			end
		end
	end


	mux_oh mux_read_bus_lo (
			.sel_oh(read_bus_lo_src_oh),
			.D('{	
				reg8_D_Q,
				reg8_status_q,
				reg8_ext_q,
				reg8_acc_q,
				reg8_addr_l_q,
				reg8_p_l_q[3],
				reg8_p_l_q[2],
				reg8_p_l_q[1],
				reg8_p_l_q[0]
				}),
			.Q(read_bus_lo)
		);
	defparam mux_read_bus_lo.SIZE = 9;

	mux_oh mux_write_bus_lo (
			.sel_oh(write_bus_lo_src_oh),
			.D('{	
				alu_Q,
				read_bus_lo,
				read_bus_hi
				}),
			.Q(write_bus_lo)
		);
	defparam mux_read_bus_lo.SIZE = 9;



	assign addr = { reg8_addr_h_q[3:0], reg8_addr_l_q };

	reg8 reg8_D (
				.clk(clk),
				.rst_n(rst_n),
				.D(D_i),
				.ctl_ld(ld_D),
				.Q(reg8_D_Q)
	);

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
	assign incr4_lo = (read_bus_hi[3:0] + { {3{1'b0}}, alu_cy }); 

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

	scmp_alu alu (
		.op(alu_op),
		.A(read_bus_lo),
		.B(reg8_D_Q),
		.Cy_i(status_cy),
		.Ov_i(status_ov),
		.res(alu_Q),
		.Cy_o(alu_cy),
		.Ov_o(alu_ov)
	);




	//TEST
	reg		state;
	parameter	state_inc_p0_set_addr	= 1'b0;
	parameter	state_ld_op		= 1'b1;

	assign write_bus_hi_src_oh = 	state == state_inc_p0_set_addr ? WR_H_INCR4 :
					WR_H_RD_L;
	assign read_bus_hi_src_oh = 	SEL_H_P0_OH;
	assign ld_h = 			state == state_inc_p0_set_addr 	? SEL_H_P0_OH | SEL_H_ADDR_OH :
					SEL_H_NONE;
	assign ld_l = 			state == state_inc_p0_set_addr 	? LD_L_ADDR | LD_L_P0 :
					LD_L_NONE;
	assign alu_op	=		state == state_inc_p0_set_addr ? `SCMP_ALU_INC :
					`SCMP_ALU_DEC;

	assign read_bus_lo_src_oh =	state == state_inc_p0_set_addr ? RD_LO_SRC_PO :
					RD_LO_SRC_ACC;
	assign write_bus_lo_src_oh =	state == state_inc_p0_set_addr ? WR_L_ALU :
					WR_L_ALU;

	assign	ld_status_alu = 1'b0;
	assign	ld_status_rd_l = 1'b0;



	always@(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			state <= state_inc_p0_set_addr;
		else begin
			if (state == state_inc_p0_set_addr)
				state <= state_ld_op;
			else
				state <= state_inc_p0_set_addr;
		end
	end

	assign D_o = reg8_D_Q;


endmodule