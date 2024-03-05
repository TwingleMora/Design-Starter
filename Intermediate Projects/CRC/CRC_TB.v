`timescale 10ns/1ps
module CRC_TB;
 reg DATA,ACTIVE,CLK,RST;
 wire [7:0] CRC;
 wire Valid;
 reg [7:0] data_h[0:9];
 reg [7:0] ex_data_out_h[0:9];
 parameter operations = 10 ;
CRC_BLOCK crcblk (
    .DATA(DATA),
    .ACTIVE(ACTIVE),
    .CLK(CLK),
    .RST(RST),
    .CRC(CRC),
    .Valid(Valid)
    ); 
 task initialize;
 begin
    $readmemh("DATA_h.txt",data_h);
    $readmemh("Expec_Out_h.txt",ex_data_out_h);
 CLK=0;
 RST=1;
 ACTIVE=0;
 end
 endtask
task reset;
begin
#1
ACTIVE=0;
RST=0;
#9;
RST=1;//change at negative edge is safe
end
endtask
task data_transition;
integer counter,counter2;
begin
   
    for(counter2=0;counter2<operations;counter2=counter2+1)
    begin
        $display("Test %0d",(counter2+1));
        $display("Input Data Value: %h",data_h[counter2]);
        $display("Expected CRC Value: %h",ex_data_out_h[counter2]);
        @(negedge CLK)
    for(counter =0 ;counter<8;counter=counter+1)
    begin
        ACTIVE=1;
          DATA = data_h[counter2][counter];
        @(negedge CLK);
      //  $display("Data bit is: %b @ time: %0g, CRC: %h",DATA,$time,CRC);
    end
    $display("Waiting 8 cycles to process data...");
    $display("CRC Value: %h",ex_data_out_h[counter2]);
    if(CRC==ex_data_out_h[counter2])
    $display("Test %0d Passed\n",(counter2+1));
    else
    $display("Test %0d Failed\n",(counter2+1));
    @(negedge CLK) reset;
    end
    
end
endtask
always #5 CLK=~CLK;
initial
begin
initialize;
reset;
data_transition;
    $stop;
end
endmodule
