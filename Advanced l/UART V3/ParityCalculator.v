module ParityCalculator#(parameter DATAWIDTH=8)
(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 dataValid,
    input  wire                 parityType,
    input  wire [DATAWIDTH-1:0] dataIn,
    output reg                  parityBit
);

reg [DATAWIDTH-1:0]memory;
reg b;

always @(posedge clk or negedge rst) begin
if(!rst)
memory<=0;
else
begin
    if(dataValid)
        memory<=dataIn; 
end
end
always @(*) 
begin
    b = ^(memory);
    if(parityType)
        parityBit=~b;
    else
        parityBit=b;
end
endmodule