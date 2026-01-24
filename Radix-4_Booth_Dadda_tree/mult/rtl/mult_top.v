module mult_top(
    input  clk,
    input  signed [24:0] A,
    input  signed [24:0] B,
    output reg signed [49:0] P
);

    // Input registers
    reg signed [24:0] A_r;
    reg signed [24:0] B_r;

    // Combinational datapath
    wire signed [49:0] PP;
    wire signed [49:0] S;
    wire signed [49:0] C;
    wire signed [49:0] P_comb;

    // Register inputs
    always @(posedge clk) begin
        A_r <= A;
        B_r <= B;
    end

    booth_encoder BOOTH (
        .A(A_r),
        .B(B_r),
        .PP(PP)
    );

    dadda_tree DADDA (
        .PP(PP),
        .S(S),
        .C(C)
    );

    hybrid_adder #(.WIDTH(50), .BLOCK(5)) ADD (
        .A(S),
        .B(C),
        .S(P_comb)
    );


    // Register output
    always @(posedge clk) begin
        P <= P_comb;
    end

endmodule

