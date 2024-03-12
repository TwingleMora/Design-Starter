`timescale 1us/1ns
module TXTOP_TB;
parameter DATAWIDTH=8,PTRWIDTH=4,STATEWIDTH = 3;
localparam PERIOD = 8.68;
reg clk,rst;
reg [DATAWIDTH-1:0] P_DATA;
reg DATA_VALID;
reg PAR_EN,PAR_TYP;
wire TX_OUT,Busy;   


TXTOP #(
    .DATAWIDTH(DATAWIDTH),.PTRWIDTH(PTRWIDTH),.STATEWIDTH(STATEWIDTH)
)
tx
(
.clk(clk),.rst(rst),
.P_DATA(P_DATA),
.DATA_VALID(DATA_VALID),
.PAR_EN(PAR_EN),.PAR_TYP(PAR_TYP),
.TX_OUT(TX_OUT),.Busy(Busy)   
);
task initialize;
begin
    $display("Initializaton..");
    clk=0;
    rst=1;
    $display("clk: %b, rst: %b",clk,rst);
    #(1)
    rst=0;
    $display("after 1 time unit, clk: %b, rst: %b",clk,rst);
    #(PERIOD-1)
    $display("\nposedge (%0g)",$time);
    $display("clk: %b, rst: %b",clk,rst);
    rst=1;

end
endtask
task displayState;
        localparam IDLE =  0,
             START=  1,
             DATA=   2,
             PARITY= 3,
             STOP =  4;
begin
case(tx.fsm.mux_sel)
  IDLE:
   $display("State: IDLE");
   START:
   $display("State: START");
   DATA:
   $display("State: DATA");
   PARITY:
   $display("State: PARITY");
   STOP:
   $display("State: STOP");
 endcase 
end
endtask
task displayFSMOutputs;
begin
    $display("FSM[OUT](Ser_EN: %b)",tx.fsm.ser_en);
end
endtask
task displaySeriValues;
begin
    $display("SERI[OUT](seri_data: %b), SERI(memory: %b), SERI[OUT](Ser_Done: %b)",tx.seri.ser_data,tx.seri.memory,tx.seri.ser_done);
end
endtask
task writeData;
input integer testNumber;
input [DATAWIDTH-1:0] In;
input ParEn,ParTyp;
begin
$display("------------------- Test Number: %0d -------------------",testNumber);
$display("[Settings] Input Data: %0b, Parity En: %0b, Parity Type: %0b",In,ParEn,ParTyp);
$display("Setting Input Data ");
P_DATA = In;
displayState;
displayFSMOutputs;
displaySeriValues;
#(PERIOD);
$display("\nposedge (%0g)",$time);
$display("Setting Data Valid Signal & Parity");
DATA_VALID=1;
$display("DATA_VALID: %b",DATA_VALID);
PAR_EN=ParEn;
PAR_TYP=ParTyp;
displayState;
displayFSMOutputs;
displaySeriValues;
#(PERIOD);
$display("\nposedge (%0g)",$time);
$display("Clearing Data Valid Signal ");
DATA_VALID=0;
$display("DATA_VALID: %b",DATA_VALID);
displayState;
displayFSMOutputs;
displaySeriValues;
repeat(15)
begin
#(PERIOD);
$display("\nposedge (%0g)",$time);
displayState;
displayFSMOutputs;
displaySeriValues;
$display("TX Is: %b",TX_OUT);
end
$display("\n\n\n");
end
endtask
always #(PERIOD/2) clk = ~clk;
initial
begin
initialize;
writeData(1,'b11001100,1,0);
writeData(2,'b11110101,1,1);
writeData(3,'b10000101,1,1);
$stop;
end
endmodule