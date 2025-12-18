module mult (
	input  signed [24:0] A,
	input  signed [24:0] B,
	output signed [49:0] prod
);

assign prod = A * B;

endmodule