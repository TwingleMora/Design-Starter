module Up_Dn_Counter(

input     wire  [4:0]       IN,
input     wire              Load,
input     wire              Up,
input     wire              Down,
input     wire              CLK,
output    reg   [4:0]       Counter,
output    reg               High,
output    reg               Low   );

reg[4:0] Counter_D;
reg High_D,Low_D;


always@(*)
 begin
  
  if(Load)
    Counter_D = IN;
  else if(Down  &&  !Low)// until it's Down && Low = 1
    Counter_D = Counter - 1;
  else if(Up  &&  !High  &&  !Down)// so at 0 this will work if i dont put !Down
    Counter_D = Counter + 1;
  else //if(!(DOWN&&!LOW)&&!(UP&&!HIGH&&!DOWN)) if[(DOWN*LOWBar)Bar * (UP*HIGHBar*DOWNBar)Bar ] 
    Counter_D = Counter;    
  
  
  if(Counter_D  ==  31)
    High_D  = 1;
  else
    High_D=0;
  if(Counter_D  ==  0)
     Low_D  = 1;
  else
     Low_D  = 0;
 
 end
 
always@(posedge CLK)
 begin
  
   High <=  High_D;
   Low  <=  Low_D;
   Counter  <=  Counter_D;
 
 end
 
endmodule