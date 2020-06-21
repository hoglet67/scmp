`include "scmp_microcode_pla.gen.vh"
// This file was generated with microcode.pl - DO NOT EDIT

module scmp_microcode_pla(
	input	wire	[`SZ_NEXTPC-1:0]	pc,
	output	reg	[`SZ_NEXTPC-1:0]	nextpc,
	output	reg	[`SZ_CONDM-1:0]	condm,
	output	reg	[`SZ_CONDX-1:0]	condx,
	output	reg	[`SZ_BUS-1:0]	bus,
	output	reg	[`SZ_LD_L-1:0]	ld_l,
	output	reg	[`SZ_LD_H-1:0]	ld_h,
	output	reg	[`SZ_RD_L-1:0]	rd_l,
	output	reg	[`SZ_RD_H-1:0]	rd_h,
	output	reg	[`SZ_WR_L-1:0]	wr_l,
	output	reg	[`SZ_WR_H-1:0]	wr_h,
	output	reg	[`SZ_ALU_OP-1:0]	alu_op,
	output	reg	[`SZ_CTL-1:0]	ctl);

reg [`SZ_MCODE-1:0] cur;
assign {nextpc, condm, condx, bus, ld_l, ld_h, rd_l, rd_h, wr_l, wr_h, alu_op, ctl} = cur;
always_comb begin
	case(pc)
		8'd0:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_NUL,	`LD_L_ADDR_PC,	`LD_H_ADDR_PC,	`RD_L_P0,	`RD_H_P0,	`WR_L_ALU,	`WR_H_INCR4,	`ALU_OP_INC,	`CTL_NUL};
		8'd1:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_ADSOP,	`LD_L_NUL,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd2:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_RD,	`LD_L_OP,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd3:	cur =	{	`UCLBL_DECODE-8'd3,	`CONDM_OP2,	`CONDX_OP2,	`BUS_NUL,	`LD_L_NUL,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd4:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_NUL,	`LD_L_ADDR_PC,	`LD_H_ADDR_PC,	`RD_L_P0,	`RD_H_P0,	`WR_L_ALU,	`WR_H_INCR4,	`ALU_OP_INC,	`CTL_NUL};
		8'd5:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_ADSRD,	`LD_L_NUL,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd6:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_RD,	`LD_L_D,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd7:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_NUL,	`LD_L_NUL,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_DECODE};
		8'd8:	cur =	{	`UCLBL_LDI-8'd8,	`CONDM_ADI,	`CONDX_ADI,	`BUS_NUL,	`LD_L_NUL,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd9:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_ADSRD,	`LD_L_NUL,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd10:	cur =	{	`NEXTPC_NEXT,	`CONDM_NUL,	`CONDX_NUL,	`BUS_RD,	`LD_L_D,	`LD_H_NUL,	`RD_L_P0,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		8'd11:	cur =	{	`UCLBL_FETCH,	`CONDM_NUL,	`CONDX_NUL,	`BUS_NUL,	`LD_L_ACC,	`LD_H_NUL,	`RD_L_D,	`RD_H_P0,	`WR_L_RD_L,	`WR_H_RD_H,	`ALU_OP_NUL,	`CTL_NUL};
		default: cur = `SZ_MCODE'd0;	endcase
end
endmodule
