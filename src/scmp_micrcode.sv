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

	wire	[`SZ_NEXT-1:0]			cur_nxtpc;
	wire	[`SZ_BUS-1:0]			cur_bus;
	wire	[`SZ_COND-1:0]			cur_cond_mask;
	wire	[`SZ_COND-1:0]			cur_cond_xor;
//	wire	[`SZ_LD_L-1:0]			cur_ld_l;
//	wire	[`SZ_LD_H-1:0]			cur_ld_h;
//	wire	[`SZ_RD_L-1:0]			cur_rd_l;
//	wire	[`SZ_RD_H-1:0]			cur_rd_h;
//	wire	[`SZ_WR_L-1:0]			cur_wr_l;
//	wire	[`SZ_WR_H-1:0]			cur_wr_h;
//	wire	[`SZ_ALU_OP-1:0]		cur_alu_op;

	wire							cond;	// when this is set the NEXT field is ignored and the next uI is invoked
	wire							cond_in;

	assign cond_in = { op[7] };
	assign cond =| ((cond_in ^ cur_cond_xor) & cur_cond_mask);


	always@(posedge clk, negedge rst_n) begin
		if (!rst_n)
			mc_pc <= 8'd0;
		else begin
			if (cond) 
				mc_pc <= mc_pc + 8'd1;
			else if (cur_nxtpc == 'd0)
				mc_pc <= 8'd0;
			else
				mc_pc <= mc_pc + cur_nxtpc;
		end
	end


	always_comb begin

		case (mc_pc)
			//increment address/p0
			// p0,addr = p0+1
			'd0	: 		cur = {	`NEXTPC_NEXT,	`COND_NUL,	`BUS_NUL,	`LD_L_ADDR_PC	,	`LD_H_ADDR_PC,	`RD_L_P0,	`RD_H_P0,	`WR_L_ALU,	`WR_H_INCR4, 	`ALU_OP_INC	};
			// address cycle, with r, i flags
			'd1	: 		cur = {	`NEXTPC_NEXT,	`COND_NUL,	`BUS_ADSOP,	`LD_L_NONE		,	`LD_H_NONE,		`RD_L_NONE,	`RD_H_NONE,	`WR_L_NUL,	`WR_H_NUL,		`ALU_OP_NUL	};
			// read cycle, load result into opcode reg
			'd2	: 		cur = {	`NEXTPC_NEXT,	`COND_NUL,	`BUS_RD,	`LD_L_OP		,	`LD_H_NONE,		`RD_L_NONE,	`RD_H_NONE,	`WR_L_NUL,	`WR_H_NUL,		`ALU_OP_NUL	};
			// decode top bit of opcode
			'd3	: 		cur = {	`SZ_NEXT'd4,	`COND_OP2,	`BUS_NUL,	`LD_L_NONE		,	`LD_H_NONE,		`RD_L_P0,	`RD_H_NONE,	`WR_L_NUL,	`WR_H_NUL,		`ALU_OP_NUL	};
			// increment address for next fetch
			'd4	: 		cur = {	`NEXTPC_NEXT,	`COND_NUL,	`BUS_NUL,	`LD_L_ADDR_PC	,	`LD_H_ADDR_PC,	`RD_L_P0,	`RD_H_P0,	`WR_L_ALU,	`WR_H_INCR4, 	`ALU_OP_INC	};
			// address cycle, with r flag
			'd5	: 		cur = {	`NEXTPC_NEXT,	`COND_NUL,	`BUS_ADSRD,	`LD_L_NONE		,	`LD_H_NONE,		`RD_L_NONE,	`RD_H_NONE,	`WR_L_NUL,	`WR_H_NUL,		`ALU_OP_NUL	};
			// read cycle into D register
			'd6	: 		cur = {	`NEXTPC_NEXT,	`COND_NUL,	`BUS_RD,	`LD_L_D			,	`LD_H_NONE,		`RD_L_NONE,	`RD_H_NONE,	`WR_L_NUL,	`WR_H_NUL,		`ALU_OP_NUL	};
			// decode cycle
			'd7	: 		cur = {	`NEXTPC_START,	`COND_NUL,	`BUS_NUL,	`LD_L_NONE		,	`LD_H_NONE,		`RD_L_NONE,	`RD_H_NONE,	`WR_L_NUL,	`WR_H_NUL,		`ALU_OP_NUL	};
			default : 	cur = {	`NEXTPC_START,	`COND_NUL,	`BUS_NUL,	`LD_L_NONE		,	`LD_H_NONE,		`RD_L_NONE,	`RD_H_NONE,	`WR_L_NUL,	`WR_H_NUL,		`ALU_OP_NUL	};
		endcase
	end

	assign { cur_nxtpc, cur_cond_mask, cur_cond_xor, cur_bus, ld_l, ld_h, rd_l, rd_h, wr_l, wr_h, alu_op } = cur;
	assign { bus_F_H, bus_F_D, bus_F_I, bus_F_R} = cur_bus[6:3];
	assign { bus_ADS_n, bus_RD_n, bus_WR_n } = ~cur_bus[2:0];



endmodule