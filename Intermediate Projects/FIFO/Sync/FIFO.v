module FIFO_TOP #(parameter WIDTH = 4, DEPTH = 8,ADDRWIDTH=4)
(
input clk,rst,    
input writeEn,readEn, 
input [WIDTH-1:0] writeData,
output reg full,empty, output reg [WIDTH-1:0] readData,
output reg [ADDRWIDTH-1:0] writePtr,readPtr//extra bit

);
   
    reg full_comb,empty_comb;
    reg [ADDRWIDTH-1:0] writePtr_comb,readPtr_comb;//extra bit
    integer memCounter;
    reg [WIDTH-1:0] memory [0:DEPTH-1];
   // reg [ADDRWIDTH-1:0] writePtr,readPtr;//extra bit
    //reg [ADDRWIDTH-1:0] writePtr_comb,readPtr_comb;//extra bit
    
    always @(posedge clk or negedge rst) begin
        if(!rst)
        begin
            for(memCounter=0;memCounter<DEPTH;memCounter=memCounter+1)
            begin
                memory[memCounter]<= 0;

            end
                writePtr<=0;
                readPtr<={1'b1,{(WIDTH-1){1'b0}}};
                full<=0;
                empty<=1;
        end
        
        else
        begin
            
            full<=full_comb;//current
            empty<=empty_comb;//current
            
            if(writeEn&&!full)
            begin
            memory[writePtr[ADDRWIDTH-2:0]]<=writeData;
            writePtr<=writePtr_comb;//current
            
            end
            if(readEn&&!empty)
            begin
            readData<=memory[readPtr[ADDRWIDTH-2:0]];
            readPtr<=readPtr_comb;//current

            end
        end
    end
    always @(*)//next
    begin
    
    if(writeEn&&!full) //apologies (why that doesnt work ? i'll tell you bear with me)
        writePtr_comb = writePtr+1;
    else
        writePtr_comb = writePtr;
    if(readEn&&!empty)/*empty: current*/
        readPtr_comb = readPtr+1;
    else
        readPtr_comb = readPtr;

        full_comb = (writePtr_comb==readPtr_comb);//next
        empty_comb = (writePtr_comb[2:0]==readPtr_comb[2:0])&&(writePtr_comb[3]!=readPtr_comb[3]);//next
    
    end
endmodule
