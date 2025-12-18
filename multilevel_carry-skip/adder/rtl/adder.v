// 5-bit block for carry-skip adder (Level-1 building block)
module csa_block5 (
    input  [4:0] A,
    input  [4:0] B,
    input        cin,
    output [4:0] S,
    output       cout_ripple, // ripple carry-out of this 5-bit block
    output       P_block      // block propagate = AND of bit propagates
);
    wire [4:0] p;

    assign p       = A ^ B;
    assign P_block = &p;

    // 5-bit ripple add
    assign {cout_ripple, S} = A + B + cin;
endmodule


// -------- Level-2: group of 2 blocks (10-bit) --------
module csa_group2x5 (
    input  [9:0]  A,
    input  [9:0]  B,
    input         cin,
    output [9:0]  S,
    output        cout_ripple_group, // ripple carry-out from the LAST block
    output        P_group,           // AND of P_block in this group
    output        cout_group          // group carry-out after group-skip mux
);
    wire [1:0] P;
    wire       cout0, cout1;
    wire [4:0] sum0, sum1;

    wire c1; // carry into block1 (after level-1 skip mux)

    // block0: [4:0]
    csa_block5 u0 (
        .A(A[4:0]), .B(B[4:0]), .cin(cin),
        .S(sum0), .cout_ripple(cout0), .P_block(P[0])
    );

    // Level-1 skip mux: carry into block1
    assign c1 = (P[0] & cin) | (~P[0] & cout0);

    // block1: [9:5]
    csa_block5 u1 (
        .A(A[9:5]), .B(B[9:5]), .cin(c1),
        .S(sum1), .cout_ripple(cout1), .P_block(P[1])
    );

    // group propagate (Level-2)
    assign P_group = &P;

    // "ripple" carry-out of group = cout of last block (with its actual cin=c1)
    assign cout_ripple_group = cout1;

    // Level-2 skip mux: if ALL blocks propagate, group cout = group cin
    assign cout_group = (P_group & cin) | (~P_group & cout_ripple_group);

    assign S[4:0] = sum0;
    assign S[9:5] = sum1;
endmodule


// -------- Level-2: group of 3 blocks (15-bit) --------
module csa_group3x5 (
    input  [14:0] A,
    input  [14:0] B,
    input         cin,
    output [14:0] S,
    output        cout_ripple_group,
    output        P_group,
    output        cout_group
);
    wire [2:0] P;
    wire       cout0, cout1, cout2;
    wire [4:0] sum0, sum1, sum2;

    wire c1, c2; // carries into block1 and block2 (after level-1 skip muxes)

    // block0: [4:0]
    csa_block5 u0 (
        .A(A[4:0]), .B(B[4:0]), .cin(cin),
        .S(sum0), .cout_ripple(cout0), .P_block(P[0])
    );
    assign c1 = (P[0] & cin) | (~P[0] & cout0);

    // block1: [9:5]
    csa_block5 u1 (
        .A(A[9:5]), .B(B[9:5]), .cin(c1),
        .S(sum1), .cout_ripple(cout1), .P_block(P[1])
    );
    assign c2 = (P[1] & c1) | (~P[1] & cout1);

    // block2: [14:10]
    csa_block5 u2 (
        .A(A[14:10]), .B(B[14:10]), .cin(c2),
        .S(sum2), .cout_ripple(cout2), .P_block(P[2])
    );

    assign P_group = &P;

    assign cout_ripple_group = cout2;

    // Level-2 skip mux
    assign cout_group = (P_group & cin) | (~P_group & cout_ripple_group);

    assign S[4:0]    = sum0;
    assign S[9:5]    = sum1;
    assign S[14:10]  = sum2;
endmodule


// -------- Top: 25-bit multilevel carry-skip adder --------
module adder (
    input  signed [24:0] A,
    input  signed [24:0] B,
    output signed [24:0] sum,
    output               overflow
);
    // Group-level carries (Level-2)
    wire Cg0_in, Cg1_in;
    wire Cg0_out, Cg1_out;

    // Group propagate and group ripple cout
    wire Pg0, Pg1;
    wire cout_ripple_g0, cout_ripple_g1;

    wire [9:0]  sum_g0;   // bits [9:0]
    wire [14:0] sum_g1;   // bits [24:10]

    // overall Cin = 0
    assign Cg0_in = 1'b0;

    // Group0: 2 blocks x 5 bits => bits [9:0]
    csa_group2x5 G0 (
        .A(A[9:0]),
        .B(B[9:0]),
        .cin(Cg0_in),
        .S(sum_g0),
        .cout_ripple_group(cout_ripple_g0),
        .P_group(Pg0),
        .cout_group(Cg0_out)
    );

    // Group1 Cin comes from Group0 cout (after Level-2 skip)
    assign Cg1_in = Cg0_out;

    // Group1: 3 blocks x 5 bits => bits [24:10]
    csa_group3x5 G1 (
        .A(A[24:10]),
        .B(B[24:10]),
        .cin(Cg1_in),
        .S(sum_g1),
        .cout_ripple_group(cout_ripple_g1),
        .P_group(Pg1),
        .cout_group(Cg1_out)
    );

    // stitch sums
    assign sum[9:0]    = sum_g0;
    assign sum[24:10]  = sum_g1;

    // signed overflow (two's complement)
    assign overflow =
        ( A[24] &  B[24] & ~sum[24]) |   // + + -> -
        (~A[24] & ~B[24] &  sum[24]);    // - - -> +

endmodule
