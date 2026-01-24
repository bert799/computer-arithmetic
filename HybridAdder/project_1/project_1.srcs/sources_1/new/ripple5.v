module ripple5(
    input  [4:0] g,
    input  [4:0] p,
    input        cin,
    output reg [4:0] sum
);
    integer i;
    reg carry;

    always @(*) begin
        carry = cin;
        for (i=0;i<5;i=i+1) begin
            sum[i] = p[i] ^ carry;
            carry  = g[i] | (p[i] & carry);
        end
    end
endmodule