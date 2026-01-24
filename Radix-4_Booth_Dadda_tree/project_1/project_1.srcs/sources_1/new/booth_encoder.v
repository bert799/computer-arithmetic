module booth_encoder(
    input  signed [24:0] A,
    input  signed [24:0] B,
    output reg signed [49:0] PP
);
    integer i;
    reg signed [25:0] Bext;
    reg signed [49:0] acc;

    always @(*) begin
        Bext = {B,1'b0};
        acc  = 50'sd0;

        for (i=0;i<25;i=i+1) begin
            case ({Bext[i+1], Bext[i]})
                2'b01: acc = acc + (A <<< i);
                2'b10: acc = acc - (A <<< i);
                default: ;
            endcase
        end

        PP = acc;
    end
endmodule
