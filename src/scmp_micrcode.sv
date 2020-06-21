`include "scmp_micrcode.vh"


module scmp_microcode (

input	wire		rst_n,
input	wire		clk,
input	wire[7:0]	op,

output	wire[`SZ_LD_L-1:0]		ld_l,
output	wire[`SZ_LD_H-1:0]		ld_h,
output	wire[`SZ_RD_L-1:0]		rd_l,
output	wire[`SZ_RD_H-1:0]		rd_h,
output	wire[`SZ_WR_L-1:0]		wr_l,
output	wire[`SZ_WR_H-1:0]		wr_h,
output	wire[`SZ_ALU_OP-1:0]	alu_op,

output  wire		bus_ADS_n,
output  wire		bus_RD_n,
output  wire		bus_WR_n,

output  wire		bus_F_R,
output  wire		bus_F_I,
output  wire		bus_F_D,
output  wire		bus_F_H


);

	reg		[7:0]					mc_pc;
	reg		[7:0]					mc_ret;

	//these are "special", others are a signed displacement

	reg 	[`SZ_MCODE-1:0]			cur;

	wire	[`SZ_NEXTPC-1:0]		cur_nxtpc;
	wire	[`SZ_BUS-1:0]			cur_bus;
	wire	[`SZ_CONDM-1:0]			cur_cond_mask;
	wire	[`SZ_CONDX-1:0]			cur_cond_xor;
	wire	[`SZ_CTL-1:0]			cur_ctl;
//	wire	[`SZ_LD_L-1:0]			cur_ld_l;
//	wire	[`SZ_LD_H-1:0]			cur_ld_h;
//	wire	[`SZ_RD_L-1:0]			cur_rd_l;
//	wire	[`SZ_RD_H-1:0]			cur_rd_h;
//	wire	[`SZ_WR_L-1:0]			cur_wr_l;
//	wire	[`SZ_WR_H-1:0]			cur_wr_h;
//	wire	[`SZ_ALU_OP-1:0]		cur_alu_op;

	wire							cond;	// when this is set the NEXT field is ignored and the next uI is invoked
	wire							cond_in;

	wire	[`SZ_NEXTPC-1:0]		op_pc;

	assign cond_in = { op[7] };
	assign cond =| ((cond_in ^ cur_cond_xor) & cur_cond_mask);


	always@(posedge clk, negedge rst_n) begin
		if (!rst_n)
			mc_pc <= 8'd0;
		else begin
			if (cur_ctl[`CTL_IX_DECODE]) 
				mc_pc <= op_pc;
			else if (cond) 
				mc_pc <= mc_pc + 8'd1;
			else if (cur_nxtpc == 'd0)
				mc_pc <= 8'd0;
			else
				mc_pc <= mc_pc + cur_nxtpc;
		end
	end

	scmp_microcode_pla pla (
		.pc(mc_pc),
		.nextpc(cur_nxtpc),
		.condm(cur_cond_mask),
		.condx(cur_cond_xor),
		.bus(cur_bus),
		.ld_l(ld_l),
		.ld_h(ld_h),
		.rd_l(rd_l),
		.rd_h(rd_h),
		.wr_l(wr_l),
		.wr_h(wr_h),
		.alu_op(alu_op),
		.ctl(cur_ctl)
		);

	scmp_microcode_oppc op2pc (
		.op(op),
		.op_pc(op_pc)
		);

	assign { bus_F_H, bus_F_D, bus_F_I, bus_F_R} = cur_bus[6:3];
	assign { bus_ADS_n, bus_RD_n, bus_WR_n } = ~cur_bus[2:0];

endmodule