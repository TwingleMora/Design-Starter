module CRC_BLOCK (
    input DATA,ACTIVE,CLK,RST,output reg [7:0] CRC,output reg Valid 
);
reg [7:0] CRC_COMB;
reg feedback;
integer counter;
reg [7:0] taps = 8'b01000100;
    always@(*)
    begin
        feedback = DATA^CRC[0];
        //CRC_COMB=>D,CRC=>Q
        CRC_COMB[7]=feedback;
        for(counter=6;counter>=0;counter=counter-1)
        begin
            if(taps[counter]==1)
                begin
                 CRC_COMB[counter] = CRC[counter+1]^feedback;  
                end
            else
                begin
                 CRC_COMB[counter] = CRC[counter+1]; 
                end

        end
        
    end
    always@(posedge CLK or negedge RST)
    begin
        if(!RST)
        begin
            CRC<=8'hD8;
            Valid<=0;
        end
        else
        begin
            if(ACTIVE)
            begin
            CRC<=CRC_COMB;
            Valid<=1;
            end
            else
            Valid<=0;
        end

    end
endmodule
