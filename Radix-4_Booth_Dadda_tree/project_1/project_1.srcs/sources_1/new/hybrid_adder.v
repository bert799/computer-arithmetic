module hybrid_adder #(
    parameter WIDTH = 25,
    parameter BLOCK = 5
)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    output [WIDTH-1:0] S
);

    localparam NB = (WIDTH+BLOCK-1)/BLOCK;

    wire [WIDTH-1:0] p, g;
    wire [NB:0] Cb;

    assign Cb[0] = 1'b0;

    genvar i;
    generate
        for (i=0;i<WIDTH;i=i+1) begin
            assign p[i] = A[i] ^ B[i];
            assign g[i] = A[i] & B[i];
        end
    endgenerate

    // Block generate / propagate
    wire [NB-1:0] Pb;
    wire [NB-1:0] Gb;

    genvar b;
    generate
        for (b=0;b<NB;b=b+1) begin : BLK
            wire [BLOCK-1:0] pb = p[b*BLOCK +: BLOCK];
            wire [BLOCK-1:0] gb = g[b*BLOCK +: BLOCK];

            assign Pb[b] = &pb;

            assign Gb[b] =
                gb[BLOCK-1] |
                (pb[BLOCK-1] & gb[BLOCK-2]) |
                (pb[BLOCK-1] & pb[BLOCK-2] & gb[BLOCK-3]) |
                (pb[BLOCK-1] & pb[BLOCK-2] & pb[BLOCK-3] & gb[BLOCK-4]) |
                (pb[BLOCK-1] & pb[BLOCK-2] & pb[BLOCK-3] & pb[BLOCK-4] & gb[0]);
        end
    endgenerate

    generate
        for (b=0;b<NB;b=b+1)
            assign Cb[b+1] = Gb[b] | (Pb[b] & Cb[b]);
    endgenerate

    // Ripple inside blocks
    integer bi;
    integer k;
    reg [WIDTH-1:0] sum;
    reg carry;

    always @(*) begin
        for (bi=0; bi<NB; bi=bi+1) begin
            carry = Cb[bi];
            for (k=0; k<BLOCK; k=k+1) begin
                if (bi*BLOCK + k < WIDTH) begin
                    sum[bi*BLOCK + k] = p[bi*BLOCK + k] ^ carry;
                    carry = g[bi*BLOCK + k] | (p[bi*BLOCK + k] & carry);
                end
            end
        end
    end

    assign S = sum;

endmodule