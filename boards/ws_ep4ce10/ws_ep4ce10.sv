`timescale 1 ns / 1 ns
`define MEM_SIZE 128

module ws_ep4ce10
#(	parameter C_SIZE = 12,
	SIM = 0
)
(
input			clk_50m,
			rst_n,
			ser_rx,
output  	[3:0]	led_n,
output		[3:0]	disp0_sel,
output  	[7:0]	disp0_seg,
output			ser_tx
);


	logic		clk_1m;
	logic		cpu_clk;
	logic		pll_lock;
	logic		clk_disp;

	logic	[C_SIZE-1:0]	counter		= 'd0;

	logic	[7:0]	cpu_D_i;
	logic		cpu_sb;
	logic		cpu_sa;

	logic	[3:0]	cpu_addr_latched;
	logic	[11:0]	cpu_addr;
	logic	[7:0]	cpu_D_o;
	logic		cpu_f0;
	logic		cpu_f1;
	logic		cpu_f2;

	logic		cpu_ADS_n;
	logic		cpu_RD_n;
	logic		cpu_WR_n;

	logic		cpu_rst_n;

	logic	[7:0]	rom_D_Q;
	logic	[7:0]	ram_D_Q;

	always@(posedge clk_1m) 
	begin
		counter <= counter - { {C_SIZE-1{1'b0}}, 1'b1 };
	end

	assign clk_disp = counter[C_SIZE-1];


	assign	cpu_rst_n = rst_n & pll_lock;

	assign	ser_tx = !cpu_f0;
	assign  cpu_sb_i = ser_rx;
	assign  cpu_sa_i = 1'b0;


	scmp cpu
	(
		.rst_n(cpu_rst_n),
		.clk(cpu_clk),
		.D_i(cpu_D_i),
		.sb(cpu_sb_i),
		.sa(cpu_sa_i),
		.addr(cpu_addr),
		.D_o(cpu_D_o),
		.f0(cpu_f0),
		.f1(cpu_f1),
		.f2(cpu_f2),
		.sin(sin),
		.sout(sout),

		.ADS_n(cpu_ADS_n),
		.RD_n(cpu_RD_n),
		.WR_n(cpu_WR_n)
	);


	always_ff@(posedge cpu_clk)
	begin
		if (!cpu_ADS_n) 
			cpu_addr_latched <= cpu_D_o[3:0];

	end

	mem_rom_sim rom(
		.address({cpu_addr_latched[1],cpu_addr}),
		.q(rom_D_Q),
		.clock(clk_50m)
		);

	mem_ram ram(
		.address({cpu_addr_latched[1],cpu_addr}),
		.q(ram_D_Q),
		.clock(clk_50m),
		.data(cpu_D_o),
		.wren(!cpu_WR_n & cpu_addr_latched[0])
		);


	always_comb begin
		if (!cpu_RD_n)
			if (cpu_addr_latched[0])
				cpu_D_i <= ram_D_Q;
			else
				cpu_D_i <= rom_D_Q;
		else
			cpu_D_i <= 8'bZZZZZZZZ;
	end

	logic	flag_h;
	logic	flag_d;
	logic	flag_i;
	logic	flag_r;

	always@(posedge cpu_clk, negedge rst_n) begin
		if (!rst_n)
			{ flag_h, flag_d, flag_i, flag_r } <= 4'b0000;
		else if (!cpu_ADS_n)
			{ flag_h, flag_d, flag_i, flag_r } <= cpu_D_o[7:4];
	end


	//debug interface
	assign led_n	= ~ { flag_h, flag_d, flag_i, flag_r };

	seg8_4 disp0(
		.clk(clk_disp),
		.nrst(rst_n),
		.number({cpu_addr[7:0], (cpu_WR_n)?cpu_D_i:cpu_D_o}),
		.dot({ flag_h, flag_d, flag_i, flag_r }),
		.sel(disp0_sel),
		.seg(disp0_seg)
	);

	generate
		if (SIM) begin
			//5.45m clock
			initial begin
				forever begin
					#92 cpu_clk <= 1'b1;
					#92 cpu_clk <= 1'b0;
				end
			end

			//1m clock
			initial begin
				forever begin
					#500 clk_1m <= 1'b1;
					#500 clk_1m <= 1'b0;
				end
			end

			//lock
			initial begin
				pll_lock <= 1'b0;
				#1000;
				pll_lock <= 1'b1;
			end
		end else
			pll_main pll(
				.inclk0(clk_50m),
				.c0(cpu_clk),
				.c1(clk_1m),
				.locked(pll_lock)
			);
	endgenerate


endmodule