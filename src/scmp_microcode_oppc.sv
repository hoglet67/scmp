import scmp_microcode_pak::*;

module scmp_microcode_oppc (
input	logic	[7:0]		op,
output	NEXTPC_t		op_pc,
output	logic			op_dly
);
	

	always_comb begin
		op_dly <= 1'b0;
		if (op[7:0] == 8'b00000000)
			op_pc <= UCLBL_HALT;
		else if (op[7:0] == 8'b10001111) 
		begin
			op_pc <= UCLBL_DLY;
			op_dly <= 1'b1;
		end
		else if (op[7:0] == 8'b00000001)
			op_pc <= UCLBL_XAE;
		else if (op[7:3] == 5'b11001 & op[2:0] != 3'b100)
			op_pc <= UCLBL_ST;
		else if (op[7:3] == 5'b11101)
			op_pc <= UCLBL_DAD;	//2 byte decimal add
		else if (op[7:3] == 5'b11110)
			op_pc <= UCLBL_ADD;	//2 byte decimal add
		else if (op[7:3] == 5'b11111)
			op_pc <= UCLBL_CAD;	//2 byte decimal add
		else if (op[7:6] == 2'b11)
			op_pc <= UCLBL_LD;	//2 byte load/logical instructions
		else if (op[7:0] == 8'b01101000)
			op_pc <= UCLBL_DAE;	//1 byte decimal add (EXT)
		else if (op[7:0] == 8'b01110000)
			op_pc <= UCLBL_ADE;	//1 byte decimal add (EXT)
		else if (op[7:0] == 8'b01111000)
			op_pc <= UCLBL_CAE;	//1 byte decimal add (EXT)
		else if (op[7:6] == 2'b01 && op[2:0] == 3'b000)
			op_pc <= UCLBL_LDE;	//1 byte load/logical instructions with EXT
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
		else if (op[7:2] == 6'b001111)
			op_pc <= UCLBL_XPPC;
		else if (op[7:1] == 7'b0000001)
			op_pc <= UCLBL__CL;
		else if (op[7:1] == 7'b0000010)
			op_pc <= UCLBL__IE;
		else if (op[7:0] == 8'b00000110)
			op_pc <= UCLBL_CSA;
		else if (op[7:0] == 8'b00000111)
			op_pc <= UCLBL_CAS;
		else if (op[7:0] == 8'b00001000)
			op_pc <= UCLBL_NOP;
		else if (op[7:0] == 8'b00011001)
			op_pc <= UCLBL_SIO;
		else if (op[7:0] == 8'b00011100)
			op_pc <= UCLBL_SR;
		else if (op[7:0] == 8'b00011101)
			op_pc <= UCLBL_SRL;
		else if (op[7:0] == 8'b00011110)
			op_pc <= UCLBL_RR;
		else if (op[7:0] == 8'b00011111)
			op_pc <= UCLBL_RRL;
		else
			op_pc <= UCLBL_FETCH;
	end
endmodule