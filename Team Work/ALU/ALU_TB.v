//he want 100khz a period of 10us
//`timescale 10us/1ns//1ns precision
//or
`timescale 1us/1ns
//#1 = 1us
//#0.001 = 1ns
module ALU_TB;
reg  [15:0]  A_TB,B_TB;
reg  [3:0]   ALU_FUN_TB;
reg          CLK_TB;
wire [15:0]  ALU_OUT_TB;
wire         Arith_Flag_TB;//8
wire         Logic_Flag_TB;//4
wire         CMP_Flag_TB;//2
wire         Shift_Flag_TB;//1
wire  [3:0]  Flag ={Arith_Flag_TB,Logic_Flag_TB,CMP_Flag_TB,Shift_Flag_TB};

ALU_16bit _ALU(
.A(A_TB),.B(B_TB),
.ALU_FUN(ALU_FUN_TB),
.CLK(CLK_TB),
.ALU_OUT(ALU_OUT_TB),
.Arith_Flag(Arith_Flag_TB),
.Logic_Flag(Logic_Flag_TB),
.CMP_Flag(CMP_Flag_TB),
.Shift_Flag(Shift_Flag_TB)

);

always #5 CLK_TB = ~CLK_TB;

reg [15:0] old_o;
reg old_a_f;
reg old_l_f;
reg old_c_f;
reg old_s_f;
reg old_flag;
initial
begin
  CLK_TB=0;
  //---------------
  //case1
  A_TB=4;
  B_TB=3;
  ALU_FUN_TB=0;
  
  #10;
  if((ALU_OUT_TB==7)&&(Flag==8))
    $display("Test1 Passed\n");
  else
    $display("Test1 Failed\n");
  //------------------
  //case2
  A_TB=4;
  B_TB=3;
  ALU_FUN_TB=1;
  
  #10;
  if((ALU_OUT_TB==1)&&(Flag==8))
    $display("Test2 Passed\n");
  else
    $display("Test2 Failed\n");
  //------------
  //case3
  A_TB=4;
  B_TB=3;
  ALU_FUN_TB=2;
  
  #10;
  if((ALU_OUT_TB==12)&&(Flag==8))
    $display("Test3 Passed\n");
  else
    $display("Test3 Failed\n");
  //-------------------
  //case4
  A_TB=6;
  B_TB=2;
  ALU_FUN_TB=3;
  #10;
  if((ALU_OUT_TB==3)&&(Flag==8))
    $display("Test4 Passed\n");
  else
    $display("Test4 Failed\n");
  //-----------------
  //case5
  A_TB=16'b111;
  B_TB=16'b110;
  ALU_FUN_TB=4;
  #10;
  if((ALU_OUT_TB==16'b110)&&(Flag==4))
    $display("Test5 Passed\n");
  else
    $display("Test5 Failed\n");
//----------
//case6
  A_TB=16'b111;
  B_TB=16'b110;
  ALU_FUN_TB=5;
  #10;
  if((ALU_OUT_TB==3'b111)&&(Flag==4))
    $display("Test6 Passed\n");
  else
    $display("Test6 Failed\n");
  //---------
  //case7
  A_TB=16'b111;
  B_TB=16'b110;
  ALU_FUN_TB=6;
  #10;
  if((ALU_OUT_TB=={{13{1'b1}},3'b001})&&(Flag==4))
    $display("Test7 Passed\n");
  else
    $display("Test7 Failed\n");
  //-----------
  //case8
  A_TB=16'b1010;
  B_TB=16'b1000;
  ALU_FUN_TB=7;//nor
  #10;
  if((ALU_OUT_TB=={{12{1'b1}},{4'b0101}})&&(Flag==4))
    $display("Test8 Passed\n");
  else
    $display("Test8 Failed\n");
  //-------------
  //case9
  A_TB=16'b111;
  B_TB=16'b110;
  ALU_FUN_TB=8;//xor
  #10;
  if((ALU_OUT_TB==16'b001)&&(Flag==4))
    $display("Test9 Passed\n");
  else
    $display("Test9 Failed\n");
  //----------
  //case10
  A_TB=16'b111;
  B_TB=16'b110;
  ALU_FUN_TB=9;//xnor
  #10;
  if((ALU_OUT_TB=={~13'b0,3'b110})&&(Flag==4))//{13{1'b1}},3'b110}
    $display("Test10 Passed\n");
  else
    $display("Test10 Failed\n");
  //------
  //case11_1
  A_TB=16'b111;
  B_TB=16'b111;
  ALU_FUN_TB=10;//equal
  #10;
  if((ALU_OUT_TB==1)&&(Flag==2))
    $display("Test11_1 Passed\n");
  else
    $display("Test11_1 Failed\n");
  //------
  //case11_2
  A_TB=16'b111;
  B_TB=16'b101;
  ALU_FUN_TB=10;//equal
  #10;
  if((ALU_OUT_TB==0)&&(Flag==2))
    $display("Test11_2 Passed\n");
  else
    $display("Test11_2 Failed\n");
  //---------
  //case12_1
  A_TB=16'b111;
  B_TB=16'b110;
  ALU_FUN_TB=11;//greater than
  #10;
  if((ALU_OUT_TB==2)&&(Flag==2))
    $display("Test12_1 Passed\n");
  else
    $display("Test12_1 Failed\n");
  //---------
  //case12_2
  A_TB=16'b111;
  B_TB=16'b111;
  ALU_FUN_TB=11;//greater than
  #10;
  if((ALU_OUT_TB==0)&&(Flag==2))
    $display("Test12_2 Passed\n");
  else
    $display("Test12_2 Failed\n");
  
  //---------
  //case13_1
  A_TB=16'b110;
  B_TB=16'b111;
  ALU_FUN_TB=12;//less than
  #10;
  if((ALU_OUT_TB==3)&&(Flag==2))
    $display("Test13_1 Passed\n");
  else
    $display("Test13_1 Failed\n");
 //---------
  //case13_2
  A_TB=16'b111;
  B_TB=16'b111;
  ALU_FUN_TB=12;//less than
  #10;
  if((ALU_OUT_TB==0)&&(Flag==2))
    $display("Test13_2 Passed\n");
  else
    $display("Test13_2 Failed\n");
  
  //----------
  //case14
  A_TB=16'b111;
  //B_TB=16'b110;
  ALU_FUN_TB=13;
  #10;
  if((ALU_OUT_TB=='b011)&&(Flag==1))//3'b011 != xxxxxxxxx011, ALU_OUT_TB==4'bx011
    $display("Test14 Passed\n");// mabroooooooooooooook
  else
    $display("Test14 Failed\n");
  //--------------
  
  //case15
  A_TB=16'b111;
  //B_TB=16'b110;
  ALU_FUN_TB=14;
  #10;
  if((ALU_OUT_TB==16'b1110)&&(Flag==1))
    $display("Test15 Passed\n");
  else
    $display("Test15 Failed\n");
  //----------

  old_o = ALU_OUT_TB;
  old_a_f = Logic_Flag_TB;
  old_l_f = CMP_Flag_TB;
  old_c_f = CMP_Flag_TB;
  old_s_f = Shift_Flag_TB;
  old_flag = {old_a_f,old_l_f,old_c_f,old_s_f};

  //case16
  A_TB=16'b111;
  B_TB=16'b110;
  ALU_FUN_TB=15;
  #10;
  if((ALU_OUT_TB==old_o)&&(Flag==old_flag))
    $display("Test16 Passed\n");
  else
    $display("Test16 Failed\n");
  //------------
  $stop;
  
end

endmodule
