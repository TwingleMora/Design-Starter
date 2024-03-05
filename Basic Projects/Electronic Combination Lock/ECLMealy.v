module ECLMealy (
    input CLK,RESET,but_0,but_1,output reg UNLOCK
);
    reg       UNLOCK_Comb; 
    reg [2:0] Current;
    reg [2:0] Next;
    localparam IDLE=0,
                S0=1,
                S01=2,
                S010=3,
                S0101=4,
                S01011=5;
always@(posedge CLK or negedge RESET)
begin
 if(!RESET)
 begin
 Current<=0;
 UNLOCK<=0;
 end
 else
 begin
 Current<=Next;
 UNLOCK<=UNLOCK_Comb;
end
end
always@(*)
begin
    //Sel: Current, Out: Next (Feedback)
    Next =Current;
if(but_0^but_1)
begin
case(Current)
IDLE:
begin
if(but_0)
Next=S0;
else
Next=IDLE; 
end
S0:
if(but_1)
Next=S01;
else
Next=IDLE; 
S01:
if(but_0)
Next=S010;
else
Next=IDLE; 
S010:
if(but_1)
Next=S0101;
else
Next=IDLE; 

endcase
end
if(Current==S0101)
begin
    if(but_1)
   UNLOCK_Comb=1; 
   else if(but_0)
   UNLOCK_Comb=0; 

end
else
   UNLOCK_Comb=0;
end
endmodule
