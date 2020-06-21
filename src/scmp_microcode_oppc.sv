import scmp_microcode_pak::*;

module scmp_microcode_oppc (
input	logic	[7:0]		op,
output	NEXTPC_t		op_pc
);
	
	always_comb begin
		if (op[6:3] == 4'b1000)
			op_pc <= UCLBL_LD;
		else
			op_pc <= UCLBL_FETCH;
	end
endmodule