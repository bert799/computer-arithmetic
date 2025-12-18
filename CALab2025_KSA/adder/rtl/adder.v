module adder (
    input  signed [24:0] A,
    input  signed [24:0] B,
    output signed [24:0] sum,
    output               overflow
);

    // Generate and propagate creation
    wire [24:0] g0, p0;
    assign g0 = A & B;   // generate
    assign p0 = A ^ B;   // propagate

    // stage1: Distance 1
    wire [24:0] g1, p1;
    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : STAGE1
            if (i == 0) begin
                assign g1[i] = g0[i];
                assign p1[i] = p0[i];
            end else begin
                assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
                assign p1[i] = p0[i] & p0[i-1];
            end
        end
    endgenerate

    // stage2: Distance 2
    wire [24:0] g2, p2;
    generate
        for (i = 0; i < 25; i = i + 1) begin : STAGE2
            if (i < 2) begin
                assign g2[i] = g1[i];
                assign p2[i] = p1[i];
            end else begin
                assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
                assign p2[i] = p1[i] & p1[i-2];
            end
        end
    endgenerate

    // stage3: Distance 4
    wire [24:0] g3, p3;
    generate
        for (i = 0; i < 25; i = i + 1) begin : STAGE3
            if (i < 4) begin
                assign g3[i] = g2[i];
                assign p3[i] = p2[i];
            end else begin
                assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
                assign p3[i] = p2[i] & p2[i-4];
            end
        end
    endgenerate

    // stage4: Distance 8
    wire [24:0] g4, p4;
    generate
        for (i = 0; i < 25; i = i + 1) begin : STAGE4
            if (i < 8) begin
                assign g4[i] = g3[i];
                assign p4[i] = p3[i];
            end else begin
                assign g4[i] = g3[i] | (p3[i] & g3[i-8]);
                assign p4[i] = p3[i] & p3[i-8];
            end
        end
    endgenerate

    // stage5: Distance 16
    wire [24:0] g5, p5;
    generate
        for (i = 0; i < 25; i = i + 1) begin : STAGE5
            if (i < 16) begin
                assign g5[i] = g4[i];
                assign p5[i] = p4[i];
            end else begin
                assign g5[i] = g4[i] | (p4[i] & g4[i-16]);
                assign p5[i] = p4[i] & p4[i-16];
            end
        end
    endgenerate

    // Calculate all carries
    wire [25:0] c;
    assign c[0] = 1'b0;     // no outer carry

    generate
        for (i = 0; i < 25; i = i + 1) begin : CARRY_GEN
            assign c[i+1] = g5[i];
        end
    endgenerate

    // Calculate the sum
    wire [24:0] ks_sum;
    generate
        for (i = 0; i < 25; i = i + 1) begin : SUM_GEN
            assign ks_sum[i] = p0[i] ^ c[i];
        end
    endgenerate

    // Output the sum
    assign sum = ks_sum;
    assign overflow = (A[24] & B[24] & ~sum[24]) |(~A[24] & ~B[24] & sum[24]);

endmodule
