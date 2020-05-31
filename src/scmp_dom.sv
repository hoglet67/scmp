
`define MEM_SIZE 32


module scmp_dom
#(	parameter C_SIZE = 26,
	SIM = 0
)
(
input	wire		clk_50m,
			rst_n,
output  wire	[3:0]	led_n,
output	wire	[3:0]	disp0_sel,
output  wire	[7:0]	disp0_seg
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

	wire cpu_clk;

	assign cpu_clk = counter[C_SIZE-1];

	scmp cpu
	(
		.rst_n(rst_n),
		.clk(cpu_clk),
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



	//load memory

	initial begin
		if (SIM)
			$readmemh("../../asm/test.vhx", memory);
		else
			$readmemh("../asm/test.vhx", memory);

	end

	always@(cpu_RD_n) begin
		if (!cpu_RD_n)
			cpu_D_i <= memory[cpu_addr & 'd31];
		else
			cpu_D_i <= 8'b11111111;
	end

	reg	flag_h;
	reg	flag_d;
	reg	flag_i;
	reg	flag_r;

	always@(posedge cpu_clk, negedge rst_n) begin
		if (!rst_n)
			{ flag_h, flag_d, flag_i, flag_r } <= 4'b0000;
		else if (!cpu_ADS_n)
			{ flag_h, flag_d, flag_i, flag_r } <= cpu_D_o[7:4];
	end


	//debug interface
	assign led_n	= ~ { flag_h, flag_d, flag_i, flag_r };

	seg8_4 disp0(
		.clk(counter[14]),
		.nrst(rst_n),
		.number({cpu_addr[7:0], cpu_D_i}),
		.dot({ flag_h, flag_d, flag_i, flag_r }),
		.sel(disp0_sel),
		.seg(disp0_seg)
	);



endmodule