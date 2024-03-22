module ParityCheck#(parameter DATAWIDTH=8)
    (input wire                 clk,
     input wire                 rst,
     input wire                 done,
     input wire                 deSerializerDn,
     input wire                 parityType,
     input wire                 parityCheckEn,
     input wire                 serIn,
     input wire [DATAWIDTH-1:0] deSerIn,
     output reg                 error,
     output reg                 valid
    );

    reg [DATAWIDTH-1:0]memory;
    reg parityBit;
    reg errorComp;
    reg b;

    always @(posedge clk or negedge rst) begin
    if(!rst)
    begin
        memory<=0;    
        //parityBit<=0;  //why parity bit is register?? 
        error<=0;    
        valid<=0;     
    end
    else
    begin
        if(done)
        begin
          valid<=1'b0;
          //parityBit<=0;
        end
        else if(parityCheckEn)
        begin
          //parityBit<=serIn;
          valid<=1'b1;
          error<=errorComp;
        end
        if(done)
          memory<=0;
        else if(deSerializerDn)
          memory<=deSerIn;
        //error<=errorComp; why error is always updated
    end
    end
    always @(*) begin
      parityBit =serIn;
        b = ^({parityBit,memory});
        if(parityType)
        errorComp=~b;
        else
        errorComp=b;
    end
    
    endmodule