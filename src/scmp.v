module scmp
(
input	wire		clk,
input	wire		rst_n,
output  wire	[11:0]	addr
);

	reg	[7:0]	p_l	[3:0];	//pointer low
	reg	[7:0]	p_h	[3:0];	//pointer hi
	reg	[7:0]	addr_h;
	reg	[7:0]	addr_l;

	wire	[4:0]	ld_h_oh;	//load pointer /address / addr hi

	parameter	rd_h_addr 	= 5'b10000;
	parameter	rd_h_p0 	= 5'b01000;
	parameter	rd_h_p1 	= 5'b00100;
	parameter	rd_h_p2 	= 5'b00010;
	parameter	rd_h_p3 	= 5'b00001;


	wire	[7:0]	write_bus_hi;
	wire	[2:0]	write_bus_hi_src_oh;
	parameter	write_bus_hi_src_read_bus_l	= 3'b100;
	parameter	write_bus_hi_src_incr4		= 3'b010;
	parameter	write_bus_hi_src_read_bus_h	= 3'b001;

	wire	[4:0]	read_bus_hi_src_oh;	//load pointer /address / addr hi
	wire	[7:0]	read_bus_hi;

	wire	[7:0]	incr4_out;

	wire	[7:0]	read_bus_lo;

	assign addr = { addr_h[3:0], addr_l };

	//write_bus_high to register loader
	always@(posedge clk, negedge rst_n)
	begin
		if (!rst_n) begin
			p_l[0] <= 8'd0;
			p_l[1] <= 8'd0;
			p_l[2] <= 8'd0;
			p_l[3] <= 8'd0;

			p_h[0] <= 8'd0;
			p_h[1] <= 8'd0;
			p_h[2] <= 8'd0;
			p_h[3] <= 8'd0;

			addr_h <= 8'd0;
			addr_l <= 8'd0;

		end
		else begin
			if (ld_h_oh[4]) begin
				addr_h <= write_bus_hi;
			end
			if (ld_h_oh[3]) begin
				p_h[0] <= write_bus_hi;
			end
			if (ld_h_oh[2]) begin
				p_h[1] <= write_bus_hi;
			end
			if (ld_h_oh[1]) begin
				p_h[2] <= write_bus_hi;
			end
			if (ld_h_oh[0]) begin
				p_h[3] <= write_bus_hi;
			end
		end
	end

	//write bus high source multiplexer
	//TODO: default?
	assign write_bus_hi =
		write_bus_hi_src_oh == write_bus_hi_src_read_bus_l ? read_bus_lo :
		write_bus_hi_src_oh == write_bus_hi_src_read_bus_h ? read_bus_hi :
		write_bus_hi_src_oh == write_bus_hi_src_incr4 ? incr4_out :
		{8{1'bx}};

	wire [3:0]	incr4_lo;

	assign incr4_lo = (read_bus_hi[3:0] + 4'd1); 

	//incrementer
	assign incr4_out = { read_bus_hi[7:4], incr4_lo };

	//read bus high source multiplexer
	//TODO: default? redundant oh slot!
	assign read_bus_hi =
		read_bus_hi_src_oh == rd_h_addr ? addr_h :
		read_bus_hi_src_oh == rd_h_p0 ? p_h[0] :
		read_bus_hi_src_oh == rd_h_p0 ? p_h[1] :
		read_bus_hi_src_oh == rd_h_p0 ? p_h[2] :
		p_h[3];

	//TEST

	reg		state;
	parameter	state_inc_p0	= 1'b0;
	parameter	state_p0_addr	= 1'b1;

	assign write_bus_hi_src_oh = 	state == state_inc_p0 ? write_bus_hi_src_incr4 :
					state == state_p0_addr ? write_bus_hi_src_read_bus_h :
					write_bus_hi_src_read_bus_l;
	assign read_bus_hi_src_oh = rd_h_p0;
	assign ld_h_oh = rd_h_p0;

	always@(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			state <= state_inc_p0;
		else begin
			if (state == state_inc_p0)
				state <= state_p0_addr;
			else begin
				state <= state_inc_p0;
			end
		end
	end

endmodule