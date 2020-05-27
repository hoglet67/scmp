`include "scmp_alu.vh"

module scmp_alu (
input	wire	[3:0]	op,

input	wire	[7:0]	A,
input	wire	[7:0]	B,
input	wire		Cy_i,
input	wire		Ov_i,

output	reg	[7:0]	res,
output	reg		Cy_o,
output  reg		Ov_o
	);

	
	always_comb begin

		Ov_o <= Ov_i;
		Cy_o <= Cy_i;
		case(op)
			`ALU_OP_ADD	:	
				begin
				{ Cy_o, res } <= A + B + { {7{1'b0}}, Cy_i };
				Ov_o <= res[7] ^ A [7];
				end
			`ALU_OP_RRL	:	
				{ res, Cy_o } <= { Cy_i, A };
			`ALU_OP_OR	:
				res <= A | B;
			`ALU_OP_AND	:	
				res <= A & B;
			`ALU_OP_XOR	:	
				res <= A ^ B;
			`ALU_OP_INC	:	
				{ Cy_o, res } <= A + 8'd1;
			`ALU_OP_DEC	:	
				{ Cy_o, res } <= A - 8'd1;
			default	:
				res <= A;
		endcase

	end

endmodule

	