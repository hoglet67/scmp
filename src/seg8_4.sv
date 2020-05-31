module seg8_4(
	input clk,
	input nrst,
	input [15:0] number,
	input [3:0] dot,
	output reg [3:0] sel,
	output [7:0] seg	
);

reg [3:0] 	data;
reg 		data_dot;
reg [31:0] 	count1;

always@(posedge clk, negedge nrst)
begin
	if(!nrst) begin
		sel <= 4'b1000;
	end
	else if(sel == 4'b0001) begin
		sel <= 4'b1000;
	end
	else begin
		sel <= sel >> 1;
	end
end

always@(*)
begin
	case(sel)
		4'b0001: data = number[3:0];
		4'b0010: data = number[7:4];
		4'b0100: data = number[11:8];
		4'b1000: data = number[15:12];
		default: data = 0;
	endcase

	case(sel)
		4'b0001: data_dot = dot[0];
		4'b0010: data_dot = dot[1];
		4'b0100: data_dot = dot[2];
		4'b1000: data_dot = dot[3];
		default: data_dot = 1'b0;
	endcase

end

seg_8 output_seg(
	.dot(data_dot),
	.data(data),
	.seg(seg)
);

endmodule