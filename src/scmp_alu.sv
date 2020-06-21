import scmp_microcode_pak::*;

module scmp_alu (
input	ALU_OP_t	op,

input	logic	[7:0]	A,
input	logic	[7:0]	B,
input	logic		Cy_i,
input	logic		Ov_i,

output	logic	[7:0]	res,
output	logic		Cy_o,
output  logic		Ov_o
	);

	
	always_comb begin

		Ov_o <= Ov_i;
		Cy_o <= Cy_i;
		case(op)
			ALU_OP_AND	:	
				res <= A & B;
			ALU_OP_OR	:
				res <= A | B;
			ALU_OP_XOR	:	
				res <= A ^ B;
			ALU_OP_DA	:
				res <= 8'bxxxxxxxx;
			ALU_OP_ADD	:	
				begin
				{ Cy_o, res } <= A + B + { {7{1'b0}}, Cy_i };
				Ov_o <= res[7] ^ A [7];
				end
			ALU_OP_RRL	:	
				{ res, Cy_o } <= { Cy_i, A };
			ALU_OP_INC	:	
				{ Cy_o, res } <= A + 8'd1;
			ALU_OP_DEC	:	
				{ Cy_o, res } <= A - 8'd1;
			default	:
				res <= A;
		endcase

	end

endmodule

	