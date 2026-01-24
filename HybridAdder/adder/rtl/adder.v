module adder (
    input  signed [24:0] A,
    input  signed [24:0] B,
    output signed [24:0] sum,
    output               overflow
);

    localparam WIDTH = 25;
    localparam BLOCK = 5;
    localparam NB    = 5; // number of blocks

    // bit-level generate / propagate
    wire [24:0] g, p;
    genvar i;
    generate
        for (i=0;i<25;i=i+1) begin
            assign g[i] = A[i] & B[i];
            assign p[i] = A[i] ^ B[i];
        end
    endgenerate

    // block-level G/P
    wire [NB-1:0] Gblk, Pblk;

    genvar b;
    generate
        for (b=0;b<NB;b=b+1) begin : GP_BLOCK
            block_gp #(BLOCK) GP (
                .g (g[b*BLOCK +: BLOCK]),
                .p (p[b*BLOCK +: BLOCK]),
                .G (Gblk[b]),
                .P (Pblk[b])
            );
        end
    endgenerate

    // block carry lookahead
    wire [NB:0] C;
    assign C[0] = 1'b0;

    generate
        for (b=0;b<NB;b=b+1) begin
            assign C[b+1] = Gblk[b] | (Pblk[b] & C[b]);
        end
    endgenerate

    // carry-select sums
    generate
        for (b=0;b<NB;b=b+1) begin : SUM_BLOCK
            wire [BLOCK-1:0] sum0, sum1;

            ripple5 ADD0 (.g(g[b*BLOCK +: BLOCK]), .p(p[b*BLOCK +: BLOCK]),
                          .cin(1'b0), .sum(sum0));
            ripple5 ADD1 (.g(g[b*BLOCK +: BLOCK]), .p(p[b*BLOCK +: BLOCK]),
                          .cin(1'b1), .sum(sum1));

            assign sum[b*BLOCK +: BLOCK] =
                C[b] ? sum1 : sum0;
        end
    endgenerate

    // signed overflow (unchanged)
    assign overflow =
        ( A[24] &  B[24] & ~sum[24]) |
        (~A[24] & ~B[24] &  sum[24]);

endmodule