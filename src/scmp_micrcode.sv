import scmp_microcode_pak::*;

module scmp_microcode (

input	logic		rst_n,
input	logic		clk,
input	logic[7:0]	op,
input	logic		zer,
input	logic		neg,

output	LD_L_t		ld_l,
output	LD_H_t		ld_h,
output	RD_L_t		rd_l,
output	RD_H_t		rd_h,
output	WR_L_t		wr_l,
output	WR_H_t		wr_h,
output	ALU_OP_t	alu_op,

output  logic		bus_ADS_n,
output  logic		bus_RD_n,
output  logic		bus_WR_n,

output  logic		bus_F_R,
output  logic		bus_F_I,
output  logic		bus_F_D,
output  logic		bus_F_H


);

	MCODE_PC_t		mc_pc;
	MCODE_PC_t		mc_ret;

	MCODE_t			mcode;
	wire			cond;	// when this is set the NEXT field is ignored and the next uI is invoked
	COND_MASK_t		cond_in;
	NEXTPC_t		op_pc;
	logic			c_jmp;
	logic			c_ea_postinc;	//when set is a post-inc autoindexed

	//jump logic gives a 1 to not return to fetch on jmp, jz, jnz, jp

	assign	c_jmp = 
		(op[3:2] == 2'b01)?~neg:		//jp i.e. !neg
		(op[3:2] == 2'b10)?zer:		//jz
		(op[3:2] == 2'b11)?~zer:
		1'b1;				//always jmp
				
	assign	c_ea_postinc = op[2] & ~neg;

	assign cond_in = { op[7], op[2:0], c_jmp, c_ea_postinc };
	assign cond =| ((cond_in ^ mcode.cond_xor) & mcode.cond_mask);


	always@(posedge clk, negedge rst_n) begin
		if (!rst_n) 
		begin
			mc_pc <= 8'd0;
			mc_ret <= 8'd0;
		end
		else
		begin			
			if (mcode.ctl[CTL_IX_DECODE]) 
				mc_pc <= op_pc;
			else if (mcode.ctl[CTL_IX_RET]) 
				mc_pc <= mc_ret;
			else if (cond) 
				mc_pc <= mc_pc + 8'd1;
			else if (mcode.nextpc == 'd0)
				mc_pc <= 'd0;
			else
				mc_pc <= mc_pc + mcode.nextpc;

			if (mcode.ctl[CTL_IX_CALL])
				mc_ret <= mc_pc + 8'd1;
		end
	end

	scmp_microcode_pla pla (
		.pc(mc_pc),
		.mcode(mcode)
		);

	scmp_microcode_oppc op2pc (
		.op(op),
		.op_pc(op_pc)
		);

	assign { bus_F_H, bus_F_D, bus_F_I, bus_F_R} = mcode.bus[6:3];
	assign { bus_ADS_n, bus_RD_n, bus_WR_n } = ~mcode.bus[2:0];
	assign ld_l = mcode.ld_l;

	assign ld_h = mcode.ld_h;
	assign rd_l = mcode.rd_l;
	assign rd_h = mcode.rd_h;
	assign wr_l = mcode.wr_l;
	assign wr_h = mcode.wr_h;
	assign alu_op = (mcode.ctl[CTL_IX_LOGICOP])?{1'b0,op[5:3]}:mcode.alu_op;

endmodule