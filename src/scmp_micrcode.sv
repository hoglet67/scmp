
`define MCODE_BITS	11

`define SZ_NEXT		8
	//goto 0
`define	NEXTPC_START	`SZ_NEXT'b00000000
	//add 1
`define	NEXTPC_NEXT		`SZ_NEXT'b00000001	

//	
`define SZ_BUS		3
`define	BUS_NUL		3'b000
`define BUS_ADS		3'b100
`define BUS_RD		3'b010
`define BUS_WR		3`b001

`define SZ_LD		1
`define LD_NUL		1'b0
`define LD_OP		1'b1


module scmp_microcode (

input	wire		rst_n,
input	wire		clk,
input	wire[7:0]	op,

output	wire		ld_op,

output  wire		bus_ADS_n,
output  wire		bus_RD_n,
output  wire		bus_WR_n


);

	parameter	MCODE_BITS = 'd8;

	reg	[7:0]	mc_pc;
	reg	[7:0]	mc_ret;

	//these are "special", others are a signed displacement

	reg	[`SZ_NEXT-1:0]	cur_nxtpc;
	reg	[`SZ_BUS-1:0]	cur_bus;
	reg	[`SZ_LD-1:0]	cur_ld;


	always@(posedge clk, negedge rst_n) begin
		if (!rst_n)
			mc_pc <= 8'd0;
		else begin
			if (cur_nxtpc == 'd0)
				mc_pc <= 8'd0;
			else
				mc_pc <= mc_pc + cur_nxtpc;
		end
	end


	always_comb begin

		case (mc_pc)
			//increment address/p0
			'd0	: 		{cur_bus, cur_ld, cur_nxtpc} = {	`BUS_NUL,	`LD_NUL,	`NEXTPC_NEXT	};
			'd1	: 		{cur_bus, cur_ld, cur_nxtpc} = {	`BUS_ADS,	`LD_NUL,	`NEXTPC_NEXT	};
			'd2	: 		{cur_bus, cur_ld, cur_nxtpc} = {	`BUS_RD,	`LD_OP,		`NEXTPC_NEXT	};
			'd3	: 		{cur_bus, cur_ld, cur_nxtpc} = {	`BUS_NUL,	`LD_NUL,	-`SZ_NEXT'd3	};
			default : 	{cur_bus, cur_ld, cur_nxtpc} = {	`BUS_NUL,	`LD_NUL,	`NEXTPC_START	};
		endcase
	end

	assign {bus_ADS_n, bus_RD_n, bus_WR_n } = ~cur_bus;
	assign {ld_op} = cur_ld;


endmodule