module block_gp #(parameter N=5)(
    input  [N-1:0] g,
    input  [N-1:0] p,
    output reg     G,
    output reg     P
);
    integer i;
    reg tmpG, tmpP, prod;

    always @(*) begin
        tmpP = 1'b1;
        for (i=0;i<N;i=i+1)
            tmpP = tmpP & p[i];
        P = tmpP;

        tmpG = 1'b0;
        prod = 1'b1;
        for (i=N-1;i>=0;i=i-1) begin
            tmpG = tmpG | (g[i] & prod);
            prod = prod & p[i];
        end
        G = tmpG;
    end
endmodule