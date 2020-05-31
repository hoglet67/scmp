`include "scmp_alu.vh"
`include "scmp_micrcode.vh"


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
output  wire		f2,

output	wire		ADS_n,
output	wire		RD_n,
output	wire		WR_n

);

	//register load from microcode
	wire	[`SZ_LD_L-1:0]			ld_l;
	wire	[`SZ_LD_H-1:0]			ld_h;

	//register low output wires
	wire	[7:0]				reg8_p_l_q[3:0];
	wire	[7:0]				reg8_addr_l_q;
	wire	[7:0]				reg8_acc_q;
	wire	[7:0]				reg8_ext_q;
	wire	[7:0]				reg8_status_q;
	wire	[7:0]				reg8_D_Q;
	wire	[7:0]				reg8_op_q;
	//status register (registers)
	reg					status_cy;
	reg					status_ov;
	reg					status_ie;
	reg					status_f2;
	reg					status_f1;
	reg					status_f0;
	assign	reg8_status_q = { 
			status_cy, 
			status_ov, 
			sb, 
			sa, 
			status_ie, 
			status_f2, 
			status_f1, 
			status_f0 
			};

	//register hi wires
	wire	[7:0]				reg8_p_h_q[3:0];
	wire	[7:0]				reg8_addr_h_q;

	//low bus read control
	wire	[7:0]				read_bus_lo;
	wire	[`SZ_RD_L-1:0]			read_bus_lo_src_oh;

	//read bus hi control
	wire	[7:0]				read_bus_hi;
	wire	[`SZ_RD_H-1:0]			read_bus_hi_src_oh;	//load pointer /address / addr hi

	//write bus lo control
	wire	[7:0]				write_bus_lo;
	wire	[`SZ_WR_L-1:0]			write_bus_lo_src_oh;

	
	wire	[7:0]				write_bus_hi;
	wire	[`SZ_WR_H-1:0]			write_bus_hi_src_oh;


	wire	[7:0]	incr4_out;

	wire	[`SZ_ALU_OP-1:0]		alu_op;
	wire	[7:0]				alu_Q;
	wire					alu_cy;
	wire					alu_ov;


	scmp_microcode microcode (
		.rst_n(rst_n),
		.clk(clk),
		.op(reg8_op_q),

		.ld_l(ld_l),
		.ld_h(ld_h),
		.rd_l(read_bus_lo_src_oh),
		.rd_h(read_bus_hi_src_oh),
		.wr_l(write_bus_lo_src_oh),
		.wr_h(write_bus_hi_src_oh),
		.alu_op(alu_op),

		.bus_ADS_n(ADS_n),
		.bus_RD_n(RD_n),
		.bus_WR_n(WR_n),
		.bus_F_R(bus_F_R),
		.bus_F_I(bus_F_I),
		.bus_F_D(bus_F_D),
		.bus_F_H(bus_F_H)
	);


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
			if (ld_l[`LD_L_IX_STAT]) begin
				status_cy <= read_bus_lo[7];
				status_ov <= read_bus_lo[6];
				status_ie <= read_bus_lo[3];
				status_f2 <= read_bus_lo[2];
				status_f1 <= read_bus_lo[1];
				status_f0 <= read_bus_lo[0];
			end else if (ld_l[`LD_L_IX_ST_ALU]) begin
				status_cy <= alu_cy;
				status_ov <= alu_ov;
			end
		end
	end



	reg8 reg8_D (
				.clk(clk),
				.rst_n(rst_n),
				.D(D_i),
				.ctl_ld(ld_l[`LD_L_IX_D]),
				.Q(reg8_D_Q)
	);

	reg8 reg8_ACC (
				.clk(clk),
				.rst_n(rst_n),
				.D(read_bus_lo),
				.ctl_ld(ld_l[`LD_L_IX_ACC]),
				.Q(reg8_acc_q)
	);

	reg8 reg8_OP (
				.clk(clk),
				.rst_n(rst_n),
				.D(D_i),
				.ctl_ld(ld_l[`LD_L_IX_OP]),
				.Q(reg8_op_q)
	);


	//TODO: ext reg
	assign reg8_ext_q = 8'd0;

	generate
		genvar gi;
		//instantiate pointer registers in a loop
		for (gi=0; gi < 4; gi = gi + 1) begin : gen_pregs
			reg8 reg_p_h (
				.clk(clk),
				.rst_n(rst_n),
				.D(write_bus_hi),
				.ctl_ld(ld_h[`LD_H_IX_P0 + gi]),
				.Q(reg8_p_h_q[gi])
				);
			reg8 reg_p_l (
				.clk(clk),
				.rst_n(rst_n),
				.D(write_bus_lo),
				.ctl_ld(ld_l[`LD_L_IX_P0 + gi]),
				.Q(reg8_p_l_q[gi])
				);
		end
	endgenerate

	//address register
	reg8 reg_addr_h (
			.clk(clk),
			.rst_n(rst_n),
			.D(write_bus_hi),
			.ctl_ld(ld_h[`LD_H_IX_ADDR]),
			.Q(reg8_addr_h_q)
		);
	reg8 reg_addr_l (
			.clk(clk),
			.rst_n(rst_n),
			.D(write_bus_lo),
			.ctl_ld(ld_l[`LD_L_IX_ADDR]),
			.Q(reg8_addr_l_q)
		);




	//incrementer
	wire [3:0]	incr4_lo;
	assign incr4_lo = (read_bus_hi[3:0] + { {3{1'b0}}, alu_cy }); 
	assign incr4_out = { read_bus_hi[7:4], incr4_lo };


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



	// bus muxes

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
	defparam mux_read_bus_lo.SIZE = `SZ_RD_L;

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
	defparam mux_read_bus_hi.SIZE = `SZ_RD_H;


	mux_oh mux_write_bus_lo (
			.sel_oh(write_bus_lo_src_oh),
			.D('{	
				alu_Q,
				read_bus_lo,
				read_bus_hi
				}),
			.Q(write_bus_lo)
		);
	defparam mux_write_bus_lo.SIZE = `SZ_WR_L;

	mux_oh mux_write_bus_hi (
			.sel_oh(write_bus_hi_src_oh),
			.D('{	read_bus_lo,
				incr4_out,
				read_bus_hi
				}),
			.Q(write_bus_hi)
		);
	defparam mux_write_bus_hi.SIZE = `SZ_WR_H;



	assign	f0 = status_f0;
	assign	f1 = status_f1;
	assign	f2 = status_f2;
	assign  addr = { reg8_addr_h_q[3:0], reg8_addr_l_q };

	assign	D_o = 	!WR_n 	? reg8_D_Q :
			!ADS_n	? { bus_F_H, bus_F_D, bus_F_I, bus_F_R, reg8_addr_h_q[7:4] } :
			{8{1'bz}};


endmodule