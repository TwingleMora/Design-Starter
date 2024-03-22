module Serializer#(parameter DATAWIDTH=8)
    (input clk, rst, dataValid, serializerEn, input[DATAWIDTH-1:0] dataIn, output reg dataOut, output SerializerDn);
    localparam PTRWIDTH = $clog2(DATAWIDTH)+1;
reg [DATAWIDTH-1:0] memory;
reg [PTRWIDTH-1:0] ptr;
always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
    memory<=0;
    dataOut<=0;
    ptr<=0;
    end
    else
    begin
        
        if(dataValid)
        begin
            memory<=dataIn;
            ptr<=0;
        end
        else if(serializerEn)
        begin
            ptr<=ptr+1;
            {memory,dataOut}<={memory,dataOut}>>1;
        end
        /*else if(SerializerDn)
        begin
            ptr<=0;
        end*/
    end
end
assign SerializerDn = (ptr==DATAWIDTH);
endmodule