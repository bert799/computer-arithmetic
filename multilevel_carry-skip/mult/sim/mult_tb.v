module mult_tb;

reg  [24:0] a,b;
reg  [49:0] pIdeal;
wire [49:0] p;

reg [24:0] in1 [0:499999];
reg [24:0] in2 [0:499999];
reg [49:0] outIdeal [0:499999];

integer f;
integer i;

localparam period = 5;

mult M1(.A(a), .B(b), .prod(p));

initial begin
   $readmemh("RTLin1_mult.txt",in1);
   $readmemh("RTLin2_mult.txt",in2);
   $readmemh("RTLoutIdeal_mult.txt",outIdeal);

   f = $fopen("../../../../../mult/sim/output_mult.txt","w");

   for (i=0; i<500000; i = i + 1) begin
      a = in1[i];
      b = in2[i];
      pIdeal = outIdeal[i];
      #period;
      $fwrite(f, "in1 = %h, in2 = %h, prodIdeal = %h, prod = %h", a, b, pIdeal, p);
      if (p !== pIdeal) begin
         $fwrite(f, "    ERROR");
         $write("in1 = %h, in2 = %h, outIdeal = %h, out = %h   =============== ERROR \n", a, b, pIdeal, p);
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