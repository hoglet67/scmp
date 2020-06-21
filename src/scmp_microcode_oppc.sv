`include "scmp_micrcode.vh"

module scmp_microcode_oppc (
input	wire	[7:0]		op,
output	reg	[`SZ_NEXTPC:0]	op_pc
);
	
	always_comb begin
		if (op[6:3] == 4'b1000)
			op_pc <= `UCLBL_LD;
		else
			op_pc <= `UCLBL_FETCH;
	end
endmodule