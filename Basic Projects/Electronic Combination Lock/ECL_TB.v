module ECL_TB;
 reg CLK,RESET,but_0,but_1;
 wire UNLOCK;

 ECLMoore ecl(
    .CLK(CLK),.RESET(RESET),.but_0(but_0),.but_1(but_1),.UNLOCK(UNLOCK)
);
always #5 CLK=~CLK;
task initialize;
begin
    CLK=0;
    RESET=1;
    but_0=0;
    but_1=0;
end
endtask
task reset;
begin
#5
RESET=0;
#5;
RESET=1;
end
endtask
task press_buttons;
input [0:4]but_0s;
input [0:4]but_1s;
integer counter;
begin
    for(counter =0;counter<5;counter=counter+1)
    begin
        but_0=but_0s[counter];
        but_1=but_1s[counter];
        #10;
    end 
end
endtask
initial
begin
    initialize;
    reset;
press_buttons(5'b10100,5'b01011);
$stop;
end
endmodule
