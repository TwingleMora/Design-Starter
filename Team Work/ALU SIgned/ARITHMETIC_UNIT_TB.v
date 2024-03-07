module ARITHMETIC_UNIT_TB;
integer CASE=0;
parameter WIDTH = 16;
 reg  signed [WIDTH-1:0] A;
 reg  signed [WIDTH-1:0] B;
 reg         [1:0]       ALU_FUN;
 reg                     CLK;
 reg                     RST;
 reg                     Arith_Enable;

 wire  signed [2*WIDTH-1:0] Arith_OUT;
 wire                       Carry_OUT;
 wire                       Arith_Flag;

ARITHMETIC_UNIT #(.WIDTH(WIDTH))AU(.A(A),.B(B),.ALU_FUN(ALU_FUN),.CLK(CLK),.RST(RST),.Arith_Enable(Arith_Enable),.Arith_OUT(Arith_OUT),.Carry_OUT(Carry_OUT),.Arith_Flag(Arith_Flag));

always #5 CLK = ~CLK;

initial 
begin
  Arith_Enable=1;
  CLK =0;
  RST=0;
  #1
  RST=1;
  #10;
  $display("Arith Flag is %b, Carry Out is %b, Arith_OUT is %0d,",Arith_Flag,Carry_OUT,$signed(Arith_OUT[WIDTH-1:0]));
  ALU_FUN = 0;
  A=4;
  B=5;
  #10
  $display("Arith Flag is %b, Carry Out is %b, Arith_OUT is %0d,",Arith_Flag,Carry_OUT,$signed(Arith_OUT[WIDTH-1:0])); 
  ALU_FUN = 1;
  A=4;
  B=5;
  #10
  $display("Arith Flag is %b, Carry Out is %b, Arith_OUT is %0d,",Arith_Flag,Carry_OUT,$signed(Arith_OUT[WIDTH-1:0])); 
  ALU_FUN = 2;
  A=-1;
  B=-1;
  #10
  $display("Arith Flag is %b, Carry Out is %b, Arith_OUT is %0d,",Arith_Flag,Carry_OUT,(Arith_OUT));
  ALU_FUN = 3;
  A=-4;
  B=2;
  #10
  $display("Arith Flag is %b, Carry Out is %b, Arith_OUT is %0d,",Arith_Flag,Carry_OUT,$signed(Arith_OUT[WIDTH-1:0]));  
  $stop;
end

endmodule
