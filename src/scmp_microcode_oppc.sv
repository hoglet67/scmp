import scmp_microcode_pak::*;

module scmp_microcode_oppc (
input	logic	[7:0]		op,
output	NEXTPC_t		op_pc
);
	
	always_comb begin
		if (op[7:0] == 8'b00000001)
			op_pc <= UCLBL_XAE;
		else if (op[7:3] == 5'b11001 & op[2:0] != 3'b100)
			op_pc <= UCLBL_ST;
		else if (op[7:6] == 2'b11)
			op_pc <= UCLBL_LD;	//2 byte load/logical instructions
		else if (op[7:6] == 2'b01 && op[2:0] == 3'b000)
			op_pc <= UCLBL_LDE;	//1 byte load/logical instructions with E
		else if (op[7:2] == 6'b101010)
			op_pc <= UCLBL_ILD;
		else if (op[7:2] == 6'b101110)
			op_pc <= UCLBL_DLD;
		else if (op[7:4] == 4'b1001)
			op_pc <= UCLBL_JMP;
		else if (op[7:2] == 6'b001100)
			op_pc <= UCLBL_XPAL;
		else if (op[7:2] == 6'b001101)
			op_pc <= UCLBL_XPAH;
		else
			op_pc <= UCLBL_FETCH;
	end
endmodule