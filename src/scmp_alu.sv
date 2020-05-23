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
			`SCMP_ALU_ADD	:	
				begin
				{ Cy_o, res } <= A + B + { {7{1'b0}}, Cy_i };
				Ov_o <= res[7] ^ A [7];
				end
			`SCMP_ALU_RRL	:	
				{ res, Cy_o } <= { Cy_i, A };
			`SCMP_ALU_OR	:
				res <= A | B;
			`SCMP_ALU_AND	:	
				res <= A & B;
			`SCMP_ALU_XOR	:	
				res <= A ^ B;
			`SCMP_ALU_INC	:	
				{ Cy_o, res } <= A + 8'd1;
			`SCMP_ALU_DEC	:	
				{ Cy_o, res } <= A - 8'd1;
			default	:
				res <= A;
		endcase

	end

endmodule

	