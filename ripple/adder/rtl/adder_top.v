module adder_top (
	input 		  clk,
	input  [24:0] A,
	input  [24:0] B,
	output [24:0] sum,
	output        overflow
);
	
wire [24:0]	A_in;
wire [24:0]	B_in;
wire [24:0] sum_out;
wire        overflow_out;

registerDFF #(.WIDTH(25)) DFF1(.clk(clk), .D(A),            .Q(A_in) 	);
registerDFF #(.WIDTH(25)) DFF2(.clk(clk), .D(B),            .Q(B_in) 	);
registerDFF #(.WIDTH(25)) DFF3(.clk(clk), .D(sum_out),      .Q(sum)	 	);
registerDFF #(.WIDTH(1))  DFF4(.clk(clk), .D(overflow_out), .Q(overflow));

adder a1(.A(A_in), .B(B_in), .sum(sum_out), .overflow(overflow_out));

endmodule