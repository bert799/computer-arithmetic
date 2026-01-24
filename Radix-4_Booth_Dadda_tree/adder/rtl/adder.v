module adder (
	input  signed [24:0] A,
	input  signed [24:0] B,
	output signed [24:0] sum,
	output               overflow
);

 assign sum = A+B;
 assign overflow = (A[24] & B[24] & ~sum[24]) | (~A[24] & ~B[24] & sum[24]);

endmodule