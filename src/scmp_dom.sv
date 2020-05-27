
`define MEM_SIZE 32


module scmp_dom
#(	parameter C_SIZE = 26
)
(
input	wire		clk_50m,
			rst_n,
output  wire	[3:0]	led_n
);

	reg	[7:0]	memory[`MEM_SIZE-1:0];

	reg	[C_SIZE-1:0]	counter;

	reg	[7:0]	cpu_D_i;
	wire		cpu_sb;
	wire		cpu_sa;

	wire	[11:0]	cpu_addr;
	wire	[7:0]	cpu_D_o;
	wire		cpu_f0;
	wire		cpu_f1;
	wire		cpu_f2;

	wire		cpu_ADS_n;
	wire		cpu_RD_n;
	wire		cpu_WR_n;


	always@(posedge clk_50m, negedge rst_n) 
	begin
		if (!rst_n) begin
			counter <= {C_SIZE{1'b1}};
		end 
		else begin
			counter <= counter - { {C_SIZE-1{1'b0}}, 1'b1 };
		end

	end


	scmp cpu
	(
		.rst_n(rst_n),
		.clk(counter[C_SIZE-1]),
		.D_i(cpu_D_i),
		.sb(cpu_sb_i),
		.sa(cpu_sa_i),
		.addr(cpu_addr),
		.D_o(cpu_D_o),
		.f0(cpu_f0),
		.f1(cpu_f1),
		.f2(cpu_f2),

		.ADS_n(cpu_ADS_n),
		.RD_n(cpu_RD_n),
		.WR_n(cpu_WR_n)
	);

	assign led_n	= ~ cpu_addr[11:8];


	//load memory

	initial begin
		$readmemh("../../asm/test.vhx", memory);

	end

	always@(cpu_RD_n) begin
		if (!cpu_RD_n)
			cpu_D_i <= memory[cpu_addr & 'd31];
		else
			cpu_D_i <= 8'bxxxxxxxx;
	end


endmodule