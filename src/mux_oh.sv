module mux_oh 
#(	parameter SIZE = 3, WIDTH = 8)
(
input	wire	[SIZE-1:0]	sel_oh,
input	wire	[WIDTH-1:0]	D[SIZE-1:0],
output	reg	[WIDTH-1:0]	Q
);

	always_comb begin
		
		Q <= {WIDTH{1'bx}};
		for (integer gi = 0; gi < SIZE; gi = gi + 1) begin
			if (sel_oh[gi])
				Q <= D[gi];
		end
	end
endmodule