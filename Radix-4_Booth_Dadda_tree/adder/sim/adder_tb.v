module adder_tb;

reg  [24:0] a,b;
reg  [24:0] sIdeal;
reg         overflowIdeal;
wire [24:0] s;
wire        overflow;

reg [24:0] in1 [0:499999];
reg [24:0] in2 [0:499999];
reg [25:0] outIdeal [0:499999];

integer f;
integer i;

localparam period = 5;

adder A1(.A(a), .B(b), .sum(s), .overflow(overflow));

initial begin
   $readmemh("RTLin1_adder.txt",in1);
   $readmemh("RTLin2_adder.txt",in2);
   $readmemh("RTLoutIdeal_adder.txt",outIdeal);

   f = $fopen("../../../../../adder/sim/output_adder.txt","w");

   for (i=0; i<500000; i = i + 1) begin
      a = in1[i];
      b = in2[i];
      {overflowIdeal, sIdeal} = outIdeal[i];
      #period;
      $fwrite(f, "in1 = %h, in2 = %h, sumIdeal = %h, sum = %h", a, b, sIdeal, s);
      if ({overflow,s} !== {overflowIdeal,sIdeal}) begin
         $fwrite(f, "    ERROR");
         $write("in1 = %h, in2 = %h, outIdeal = %h, out = %h   =============== ERROR \n", a, b, {overflowIdeal,sIdeal}, {overflow,s});
         $fclose(f);
         $finish;
      end
      $fwrite(f, "\n");
      $fflush(f);
   end
   $write("Simulation finished =============== SUCCES\n");
   $fclose(f);
end

endmodule