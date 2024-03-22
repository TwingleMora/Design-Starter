module Deserializer#(parameter DATAWIDTH=8)
    (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 deSerializerEn,
    input  wire                 dataIn,
    input  wire                 done,
    output wire                 deSerializerDn,
    output reg  [DATAWIDTH-1:0] dataOut
    );
    localparam PTRWIDTH = $clog2(DATAWIDTH)+1;

reg [PTRWIDTH-1:0] ptr;
always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        dataOut<=0;
        ptr<=0;
    end
    else
    begin
        
        if(done)
        begin
            dataOut<=0;
            ptr<=0;
        end
        else if(deSerializerEn)
        begin

            ptr<=ptr+1;
            dataOut<={dataIn,dataOut[7:1]};
        
        end
    end
end
assign deSerializerDn = (ptr==DATAWIDTH);
endmodule