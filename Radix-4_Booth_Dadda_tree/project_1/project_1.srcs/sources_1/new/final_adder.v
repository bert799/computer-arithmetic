module final_adder(
    input  signed [49:0] A,
    input  signed [49:0] B,
    output signed [49:0] P
);
    assign P = A + B;
endmodule
