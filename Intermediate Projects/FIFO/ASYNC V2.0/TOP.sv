
module Bin2Grey
#(parameter WIDTH = 5)
(
input  logic [WIDTH-1:0] BinAddr,
output logic [WIDTH-1:0] GryAddr
);

// logic [WIDTH-1:0] BinAddr;

always @(*) begin
    GryAddr[WIDTH-1] = BinAddr[WIDTH-1];
    for(int x = WIDTH-2; x>=0; x=x-1)
    begin
        GryAddr[x] = BinAddr[x+1] ^ BinAddr[x];
    end

end

/* initial 
begin
    BinAddr = 0;
    #1;
    $display("Bin Addr: %b, GreyAddr: %b",BinAddr, GryAddr);
    repeat(31)
    begin
        BinAddr = BinAddr +1;   
        #1;
        $display("Bin Addr: %b, GreyAddr: %b",BinAddr, GryAddr);
    end
    $stop;
end */
endmodule


module Synchronizer #(parameter WIDTH = 5)
(
    input  logic  clk, rst,
    input  logic [WIDTH-1:0] D,
    output logic [WIDTH-1:0] Q
);
reg [WIDTH-1:0] FF;
    always@(posedge clk or negedge rst)
    begin
        if(!rst)
        begin
            FF<=0;
            Q<=0;
        end
        else
        begin
            FF<=D;
            Q<=FF;
        end
    end
endmodule

module TOP #(parameter WIDTH = 5) 
(
input  logic          WrClk,
input  logic          RdClk,
input  logic          WrRst,
input  logic          RdRst,

input  logic [31:0]   DataIn,
input  logic          WrEn,

input  logic          RdEn,

output logic [31:0]   DataOut,
output logic          Full, 
output logic          Empty,
output logic          OverFlow, //write valid (0: valid, 1: invalid)
output logic          UnderFlow //read valid (0: valid, 1: invalid)
);
    logic [WIDTH-2:0] WrAddr, RdAddr;

    logic [31:0] mem [2**(WIDTH-1)];

    logic [WIDTH-1:0] WrCounter, RdCounter;
    logic [WIDTH-1:0] NextWrCounter, NextRdCounter;

    assign WrAddr = WrCounter[WIDTH-2:0];
    assign RdAddr = RdCounter[WIDTH-2:0];
    

    logic NextFull, NextEmpty, NextOverFlow, NextUnderFlow;

    //Write Sequential Logic
    always@(posedge WrClk or negedge WrRst)
    begin
        if(!WrRst)
        begin
            WrCounter <= 0;
            Full <= 0;
            OverFlow <= 0;
        end
        else 
        begin
            if(WrEn && !Full)
            begin
                mem[WrAddr] <= DataIn;
            end

            Full <= NextFull;
            OverFlow <= NextOverFlow;
            WrCounter <= NextWrCounter;
            
        end
    end


    always@(posedge RdClk or negedge RdRst)
    begin
        if(!RdRst)
        begin
            RdCounter <= 0;
            Empty <= 1;
            UnderFlow <= 0;
        end
        else 
        begin
            if(RdEn && !Empty)
            begin
                DataOut <= mem[RdAddr];
            end
            Empty <= NextEmpty;
            UnderFlow <= NextUnderFlow;
            RdCounter <= NextRdCounter;
            
        end
    end

    //Convert From Binary to Grey Code
    logic [WIDTH-1:0] WrGry;
    logic [WIDTH-1:0] RdGry;

    logic [WIDTH-1:0] SyncWrGry;
    logic [WIDTH-1:0] SyncRdGry;

    Bin2Grey WR_B2G(.BinAddr(NextWrCounter), .GryAddr(WrGry));
    Bin2Grey RD_B2G(.BinAddr(NextRdCounter), .GryAddr(RdGry));

    Synchronizer WR_SYNC (.clk(RdClk), .rst(RdRst), .D(WrGry), .Q(SyncWrGry));
    Synchronizer RD_SYNC (.clk(WrClk), .rst(WrRst), .D(RdGry), .Q(SyncRdGry));

    //Write Logic
    always@(*)
    begin
       
        if(WrEn&&!Full)
        begin
             NextWrCounter = WrCounter + 1;
        end
        else
        begin
             NextWrCounter = WrCounter;
        end

        if(WrEn&&Full)
        begin
            NextOverFlow <= 1;
        end
        else
        begin
            NextOverFlow<= 0;
        end
        NextFull = ({WrGry[WIDTH-1], WrGry[WIDTH-2]} == {~SyncRdGry[WIDTH-1], ~SyncRdGry[WIDTH-2]}) && (WrGry[WIDTH-3:0] == SyncRdGry[WIDTH-3:0]);
    end

    //Read Logic
    always@(*)
    begin
        if(RdEn&&!Empty)
        begin
            NextRdCounter = RdCounter + 1;
        end
        else
        begin
            NextRdCounter = RdCounter;
        end

        if(RdEn&&Empty)
        begin
            NextUnderFlow <= 1;
        end
        else
        begin
            NextUnderFlow <= 0;
        end
        //Comparator
        NextEmpty = (RdGry == SyncWrGry);
    end

endmodule