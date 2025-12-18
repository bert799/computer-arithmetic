module mult_top (
	input 		  clk,
	input  [24:0] A,
	input  [24:0] B,
	output [49:0] prod
);
	
wire [24:0]	A_in;
wire [24:0]	B_in;
wire [49:0] prod_out;

registerDFF #(.WIDTH(25)) DFF1(.clk(clk), .D(A),        .Q(A_in));
registerDFF #(.WIDTH(25)) DFF2(.clk(clk), .D(B),        .Q(B_in));
registerDFF #(.WIDTH(50)) DFF3(.clk(clk), .D(prod_out), .Q(prod));

mult M1(.A(A_in), .B(B_in), .prod(prod_out));

endmodule