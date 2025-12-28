/*module adder (
	input  signed [24:0] A,
	input  signed [24:0] B,
	output signed [24:0] sum,
	output               overflow
);

 assign sum = A+B;
 assign overflow = (A[24] & B[24] & ~sum[24]) | (~A[24] & ~B[24] & sum[24]);

endmodule
*/

module adder (
    input  signed [24:0] A,
    input  signed [24:0] B,
    output signed [24:0] sum,
    output               overflow
);

    // ripple-carry adder
    wire [25:0] c;  
    assign c[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : RCA
            assign sum[i]   = A[i] ^ B[i] ^ c[i];
            assign c[i+1] = (A[i] & B[i]) | (A[i] & c[i]) | (B[i] & c[i]);
        end
    endgenerate

    
    assign overflow = c[24] ^ c[25];

endmodule
