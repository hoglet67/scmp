module scmp_dom
#(	parameter C_SIZE = 26
)
(
input	wire		clk_50m,
			rst_n,
output  wire	[3:0]	led_n
);


	reg	[C_SIZE-1:0]	counter;
	wire	[11:0]		addr_l;

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
		.addr(addr_l)
	);

	assign led_n	= ~ addr_l[3:0];


endmodule