`timescale 1ns/1ps
module BAUD_RATE_GENERATOR_TB;
parameter PERIOD =10;//10ns 
parameter DIV = 10;//output is high every 10 clock periods   
reg clk_tb,rst_tb;
reg [11:0] div_tb;
wire bclk_tb;
BAUD_RATE_GENERATOR BRGTB(
     .clk(clk_tb),.rst(rst_tb),.div(div_tb), .bclk(bclk_tb)
);
always begin
#(PERIOD/2) clk_tb = ~clk_tb;    
end
task initialization;
begin
    div_tb = DIV;
    clk_tb=0;
    rst_tb=0;
    #(PERIOD)
    rst_tb=1;

end
endtask
task DisplayBClk;
input integer CyclesCount;
begin
    repeat(CyclesCount)
    begin
        @(negedge clk_tb) $display("time: %g, baud generator output: %b",$time,bclk_tb);
    end
end
endtask
initial
begin
initialization;
DisplayBClk(31);
$stop;
end
endmodule