`timescale 1us/1ns
module ALU_TOP_TB;
integer CASE=0;

parameter WIDTH=16;

reg signed [WIDTH-1:0] RESULT;
reg signed [WIDTH-1:0] A;
reg signed [WIDTH-1:0] B;
reg         [3:0]       ALU_FUN;
reg                     CLK;
reg                     RST;

wire  signed [2*WIDTH-1:0] Arith_OUT;
wire                       Carry_OUT;
wire                       Arith_Flag;

wire  signed [WIDTH-1:0] Logic_OUT;
wire                     Logic_Flag;

wire  signed [WIDTH-1:0] CMP_OUT;
wire                     CMP_Flag;

wire  signed [WIDTH-1:0] SHIFT_OUT;
wire                     SHIFT_Flag;
wire         [3:0]       Flags;
assign Flags = {Arith_Flag,Logic_Flag,CMP_Flag,SHIFT_Flag};//8,4,2,1

ALU_TOP#(.WIDTH(WIDTH)) AT
(
  .A(A),
  .B(B),
  .ALU_FUN(ALU_FUN),
  .CLK(CLK),
  .RST(RST),

  .Arith_OUT(Arith_OUT),
  .Carry_OUT(Carry_OUT),
  .Arith_Flag(Arith_Flag),

  .Logic_OUT(Logic_OUT),
  .Logic_Flag(Logic_Flag),

  .CMP_OUT(CMP_OUT),
  .CMP_Flag(CMP_Flag),

  .SHIFT_OUT(SHIFT_OUT),
  .SHIFT_Flag(SHIFT_Flag)
);

//wire  Arith_OUT_HI = Arith_OUT[2*WIDTH - 1,WIDTH];
wire signed [WIDTH-1:0]Arith_OUT_LO = Arith_OUT[WIDTH - 1:0];
//2 phases write -> execute -> display -> write
integer counter =0;
always 
begin 
if(counter%2==0)
#4 CLK=~CLK;
else
#6 CLK=~CLK;
counter=counter+1;
end
//$display("A = %0d") 
initial 
begin
CLK = 0;
RST=1;
#10
//Start Testing
//------------------------------------------- 1
CASE=CASE+1;
A=-4;
B=-5;
ALU_FUN =0;

#10//execute @posedge clk 
RESULT=-9;
$display("*** TEST CASE %0d -- Additon -- NEG + NEG ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Additon %0d + %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Additon %0d + %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 2
CASE=CASE+1;
A=4;
B=-5;
ALU_FUN=0;

#10
RESULT=-1;
$display("*** TEST CASE %0d -- Additon -- POS + NEG ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Additon %0d + %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Additon %0d + %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);

//-------------------------------------------
//------------------------------------------- 3
CASE=CASE+1;
A=-4;
B=5;
ALU_FUN=0;
#10
RESULT=1;
$display("*** TEST CASE %0d -- Additon -- NEG + POS ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Additon %0d + %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Additon %0d + %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 4
CASE=CASE+1;
A=15;
B=20;//.
ALU_FUN=0;
#10
RESULT=35;
$display("*** TEST CASE %0d -- Additon -- POS + POS ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Additon %0d + %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Additon %0d + %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 5
CASE=CASE+1;
A=-10;
B=-15;
ALU_FUN=1;
#10
RESULT=5;
$display("*** TEST CASE %0d -- Subtraction -- NEG - NEG ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Subtraction %0d - %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Subtraction %0d - %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,-1);
//-------------------------------------------
//------------------------------------------- 6
CASE=CASE+1;
A=20;
B=-10;
ALU_FUN=1;
#10
RESULT=30;
$display("*** TEST CASE %0d -- Subtraction -- POS - NEG ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Subtraction %0d + %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Subtraction %0d + %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 7
CASE=CASE+1;
A=-4;
B=5;
ALU_FUN=1;
#10
RESULT=-9;
$display("*** TEST CASE %0d -- Subtraction -- NEG - POS ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Subtraction %0d - %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Subtraction %0d - %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 8
CASE=CASE+1;
A=15;
B=5;
ALU_FUN=1;
#10
RESULT=10;
$display("*** TEST CASE %0d -- Subtraction -- POS - POS ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Subtraction %0d - %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Subtraction %0d - %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 9
CASE=CASE+1;
A=-10;
B=-10;
ALU_FUN=2;
#10
RESULT=100;
$display("*** TEST CASE %0d -- Multiplication -- NEG * NEG ***\n",CASE);
if(Arith_OUT==RESULT&&Flags==8)
$display("Multiplication %0d * %0d IS PASSED = %0d\n",A,B,Arith_OUT);
else
$display("Multiplication %0d * %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 10
CASE=CASE+1;
A=10;
B=-5;
ALU_FUN=2;
#10
RESULT=-50;
$display("*** TEST CASE %0d -- Multiplication -- POS * NEG ***\n",CASE);
if(Arith_OUT==RESULT&&Flags==8)
$display("Multiplication %0d * %0d IS PASSED = %0d\n",A,B,Arith_OUT);
else
$display("Multiplication %0d * %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 11
CASE=CASE+1;
A=-4;
B=5;
ALU_FUN=2;
#10
RESULT=-20;
$display("*** TEST CASE %0d -- Multiplication -- NEG * POS ***\n",CASE);
if(Arith_OUT==RESULT&&Flags==8)
$display("Multiplication %0d * %0d IS PASSED = %0d\n",A,B,Arith_OUT);
else
$display("Multiplication %0d * %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 12
CASE=CASE+1;
A=32760;
B=2;
ALU_FUN=2;
#10
RESULT=0;
$display("*** TEST CASE %0d -- Multiplication -- POS * POS ***\n",CASE);
if(Arith_OUT==65520&&Flags==8)
$display("Multiplication %0d * %0d IS PASSED = %0d\n",A,B,Arith_OUT);
else
$display("Multiplication %0d * %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT,65520);
//-------------------------------------------
//------------------------------------------- 13
CASE=CASE+1;
A=-4;
B=-2;
ALU_FUN=3;
#10
RESULT=2;
$display("*** TEST CASE %0d -- Division -- NEG / NEG ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Division %0d / %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Division %0d / %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 14
CASE=CASE+1;
A=10;
B=-2;
ALU_FUN=3;
#10
RESULT=-5;
$display("*** TEST CASE %0d -- Division -- POS / NEG ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Division %0d / %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Division %0d / %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 15
CASE=CASE+1;
A=-20;
B=10;
ALU_FUN=3;
#10
RESULT=-2;
$display("*** TEST CASE %0d -- Division -- NEG / POS ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Division %0d + %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Division %0d + %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 16
CASE=CASE+1;
A=100;
B=4;
ALU_FUN=3;
#10
RESULT=25;
$display("*** TEST CASE %0d -- Division -- POS / POS ***\n",CASE);
if(Arith_OUT_LO==RESULT&&Flags==8)
$display("Division %0d / %0d IS PASSED = %0d\n",A,B,Arith_OUT_LO);
else
$display("Division %0d / %0d IS Failed (ARITH_OUT(%0d) != THE_RESULT(%0d))\n",A,B,Arith_OUT_LO,RESULT);
//-------------------------------------------
//------------------------------------------- 17
CASE=CASE+1;
A='b101;
B='b111;
ALU_FUN=4;
#10
RESULT='b101; 
$display("*** TEST CASE %0d -- Logical -- AND ***\n",CASE);
if(Logic_OUT==RESULT&&Flags==4)
$display("AND %b(%0d) & %b(%0d) IS PASSED = %0b\n",A,A,B,B,Logic_OUT);
else
$display("AND %b(%0d) & %b(%0d) IS Failed (LOGIC_OUT(%0d) != THE_RESULT(%0d))\n",A,A,B,B,Logic_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 18
CASE=CASE+1;
A='b1001;
B='b1100;
ALU_FUN=6;
#10
RESULT={{(WIDTH-4){1'b1}},{4'b0111}};
$display("*** TEST CASE %0d -- Logical -- NAND ***\n",CASE);
if(Logic_OUT==RESULT&&Flags==4)
$display("NAND ~(%b(%0d) & %b(%0d)) IS PASSED = %0b\n",A,A,B,B,Logic_OUT);
else
$display("NAND ~(%b(%0d) & %b(%0d)) IS Failed (LOGIC_OUT(%0d) != THE_RESULT(%0d))\n",A,A,B,B,Logic_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 19
CASE=CASE+1;
A='b1001;
B='b1100;
ALU_FUN=5;
#10
RESULT=16'b1101;
$display("*** TEST CASE %0d -- Logical -- OR ***\n",CASE);
if(Logic_OUT==RESULT&&Flags==4)
$display("OR %b(%0d) | %b(%0d) IS PASSED = %0b\n",A,A,B,B,Logic_OUT);
else
$display("OR %b(%0d) | %b(%0d) IS Failed (LOGIC_OUT(%0d) != THE_RESULT(%0d))\n",A,A,B,B,Logic_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 20
CASE=CASE+1;
A='b1001;
B='b1100;
ALU_FUN=7;
#10
RESULT={{(WIDTH-4){1'b1}},{4'b0010}};
$display("*** TEST CASE %0d -- Logical -- NOR ***\n",CASE);
if(Logic_OUT==RESULT&&Flags==4)
$display("NOR ~(%b(%0d) | %b(%0d)) IS PASSED = %0b\n",A,A,B,B,Logic_OUT);
else
$display("NOR %b(%0d) | %b(%0d) IS Failed (LOGIC_OUT(%0d) != THE_RESULT(%0d))\n",A,A,B,B,Logic_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 21
CASE=CASE+1;
A=45;
B=45;
ALU_FUN=9;
#10
RESULT=1;
$display("*** TEST CASE %0d -- Comparison -- == ***\n",CASE);
if(CMP_OUT==RESULT&&Flags==2)
$display("Comparison %0d == %0d IS PASSED = %0d\n",A,B,CMP_OUT);
else
$display("Comparison %0d == %0d IS Failed (CMP_OUT(%0d) != THE_RESULT(%0d))\n",A,B,CMP_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 22
CASE=CASE+1;
A=1;
B=-1;
ALU_FUN=10;
#10
RESULT=2;
$display("*** TEST CASE %0d -- Comparison -- > ***\n",CASE);
if(CMP_OUT==RESULT&&Flags==2)
$display("Comparison %0d > %0d IS PASSED = %0d\n",A,B,CMP_OUT);
else
$display("Comparison %0d > %0d IS Failed (CMP_OUT(%0d) != THE_RESULT(%0d))\n",A,B,CMP_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 23
CASE=CASE+1;
A=-4;
B=10;
ALU_FUN=11;
#10
RESULT=3;
$display("*** TEST CASE %0d -- Comparison -- < ***\n",CASE);
if(CMP_OUT==RESULT&&Flags==2)
$display("Comparison %0d < %0d IS PASSED = %0d\n",A,B,CMP_OUT);
else
$display("Comparison %0d < %0d IS Failed (CMP_OUT(%0d) != THE_RESULT(%0d))\n",A,B,CMP_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 24
CASE=CASE+1;
A='b1001;
B='b1100;
ALU_FUN=12;
#10
RESULT=16'b0100;
$display("*** TEST CASE %0d -- Shift -- A>>1 ***\n",CASE);
if(SHIFT_OUT==RESULT&&Flags==1)
$display("Shift %b(%0d) >> 1 IS PASSED = %b(%0d)\n",A,A,SHIFT_OUT,SHIFT_OUT);
else
$display("Shift %b(%0d) >> 1 IS IS Failed (SHIFT_OUT(%0d) != THE_RESULT(%0d))\n",A,A,SHIFT_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 25
CASE=CASE+1;
A='b1001;
B='b1100;
ALU_FUN=13;
#10
RESULT=16'b10010;
$display("*** TEST CASE %0d -- Shift -- A<<1 ***\n",CASE);
if(SHIFT_OUT==RESULT&&Flags==1)
$display("Shift %b(%0d) << 1 IS PASSED = %b(%0d)\n",A,A,SHIFT_OUT,SHIFT_OUT);
else
$display("Shift %b(%0d) << 1 IS IS Failed (SHIFT_OUT(%0d) != THE_RESULT(%0d))\n",A,A,SHIFT_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 26
CASE=CASE+1;
A='b1001;
B='b1100;
ALU_FUN=14;
#10
RESULT=16'b0110;
$display("*** TEST CASE %0d -- Shift -- B>>1 ***\n",CASE);
if(SHIFT_OUT==RESULT&&Flags==1)
$display("Shift %b(%0d) >> 1 IS PASSED = %b(%0d)\n",B,B,SHIFT_OUT,SHIFT_OUT);
else
$display("Shift %b(%0d) >> 1 IS IS Failed (SHIFT_OUT(%0d) != THE_RESULT(%0d))\n",B,B,SHIFT_OUT,RESULT);
//-------------------------------------------
//------------------------------------------- 27
CASE=CASE+1;
A='b1001;
B='b1100;
ALU_FUN=15;
#10
RESULT=5'b11000;
$display("*** TEST CASE %0d -- Shift -- B<<1 ***\n",CASE);
if(SHIFT_OUT==RESULT&&Flags==1)
$display("Shift %b(%0d) << 1 IS PASSED = %b(%0d)\n",A,A,SHIFT_OUT,SHIFT_OUT);
else
$display("Shift %b(%0d) << 1 IS IS Failed (SHIFT_OUT(%0d) != THE_RESULT(%0d))\n",A,A,SHIFT_OUT,RESULT);
//------------------------------------------- 
//------------------------------------------- 28
CASE=CASE+1;
A=-4;
B=-5;
ALU_FUN=8;
#10
RESULT=0;
$display("*** TEST CASE %0d -- NOP -- ***\n",CASE);
if(CMP_OUT==RESULT&&Flags==2)
$display("NOP Works!");
else
$display("NOP has Failed!");
//-------------------------------------------
#10
RESULT=0;
$stop;
end

endmodule
/*
o Signed Arithmetic Addition: A is Negative & B is Negative
o Signed Arithmetic Addition: A is Positive & B is Negative
o Signed Arithmetic Addition: A is Negative & B is Positive
o Signed Arithmetic Addition: A is Positive & B is Positive
o Signed Arithmetic Subtraction: A is Negative & B is Negative
o Signed Arithmetic Subtraction: A is Positive & B is Negative
o Signed Arithmetic Subtraction: A is Negative & B is Positive
o Signed Arithmetic Subtraction: A is Positive & B is Positive
o Signed Arithmetic Multiplication: A is Negative & B is Negative
o Signed Arithmetic Multiplication: A is Positive & B is Negative
o Signed Arithmetic Multiplication: A is Negative & B is Positive
o Signed Arithmetic Multiplication: A is Positive & B is Positive
o Signed Arithmetic Division: A is Negative & B is Negative
o Signed Arithmetic Division: A is Positive & B is Negative
o Signed Arithmetic Division: A is Negative & B is Positive
o Signed Arithmetic Division: A is Positive & B is Positive
o Logical Operations (AND, NAND, OR, NOR)
o Compare Operations (Equal, Greater, Less)
o Shift Operations (A shift right, A shift left, B shift right, B shift left)
o NOP

*/
