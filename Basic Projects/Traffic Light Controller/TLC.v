module TLC (
    input CLK,RST,TA,TB,output reg [1:0] LA,LB
);
    localparam S0 = 2'b00,
               S1 = 2'b01,
               S2 = 2'b11,
               S3 = 2'b10;
    localparam Red    = 2'b00,
               Yellow = 2'b01,
               Green  = 2'b11;
    
reg [1:0] Current, Next;

always @(posedge CLK or negedge RST) 
begin
 if(!RST)
 begin
 Current<=S0;
 end
 else
 begin
 Current<=Next;
 end 

end    
always @(*) begin
    //default value for next in case it's value is missing in one of these case
        Next=Current;
    case(Current)
    S0:
    begin
        if(!TA)
        Next=S1;

    end
    S1:
    begin
        Next=S2;
    end
    S2:
    begin
        if(!TB)
        Next=S3;
    end
    S3:
    begin
         Next=S0;
    end
    default:// is used when there is missing condition
    begin
        Next=Current;
    end
    endcase
end
always @(*) begin
    case(Current)
    S0:
    begin
        LA = Green;
        LB = Red;
    end
    S1:
    begin
        LA = Yellow;
        LB = Red;
    end
    S2:
    begin
        LA = Red;
        LB = Green;
    end
    S3:
    begin
        LA = Red;
        LB = Yellow;
    end
    endcase
end

endmodule