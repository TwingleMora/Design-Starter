`timescale 1ns/1ps
module Counter_TB;

reg [4:0]        IN_TB;
reg              Load_TB;
reg              Up_TB;
reg              Down_TB;
reg              CLK_TB;
wire [4:0]       Counter_TB;
wire             High_TB;
wire             Low_TB;
   
Up_Dn_Counter DUT(
.IN(IN_TB),
.Load(Load_TB),
.Up(Up_TB),
.Down(Down_TB),
.CLK(CLK_TB),
.Counter(Counter_TB),
.High(High_TB),
.Low(Low_TB)
);
always #5 CLK_TB=~CLK_TB;//10ns per cycle (100MHz)

initial
begin
  CLK_TB=0;
  
  //Case1 Load On and Up On and Down On
  Up_TB=1;
  Down_TB=1;
  Load_TB=1;
  IN_TB=5'd25;
  $display("starting case1: Up=%b , Down=%b , Load = %b , In = %d [Time = %g]",Up_TB,Down_TB,Load_TB,IN_TB,$time);
   #10
  
  //Case2 Load Off and Up On and Down On (Testing Saturation + Low Flag)
  Load_TB=0;//load = 0
  Up_TB=1;
  Down_TB=1; 
  $display("starting case2: Up=%b , Down=%b , Load = %b , In = %d [Time = %g]",Up_TB,Down_TB,Load_TB,IN_TB,$time);
  #270 //Counter must decrease(35 times) as 270 / 10 = 27  
  
  //Case3 Load Off and Up On and Down Off (Testing Saturation + Low Flag)
  Down_TB=0;
  Up_TB=1;
  $display("starting case3: Up=%b , Down=%b , Load = %b , In = %d [Time = %g]",Up_TB,Down_TB,Load_TB,IN_TB,$time);
  #350 //Counter must increase(35 times) as 350 / 10 = 27 
  
  //Case 4 Down is On , Load and Up are Off
  Down_TB=1;
  Up_TB=0;
  $display("starting case4: Up=%b , Down=%b , Load = %b , In = %d [Time = %g]",Up_TB,Down_TB,Load_TB,IN_TB,$time);
  #50
  
  //Case 5 Load is On , Up and Down are Off
  Down_TB=0;
  Up_TB=0;
  Load_TB=1;
  IN_TB=5'd10;
  $display("starting case5: Up=%b , Down=%b , Load = %b , In = %d [Time = %g]",Up_TB,Down_TB,Load_TB,IN_TB,$time);
  #50
  
  $stop;
end
endmodule

