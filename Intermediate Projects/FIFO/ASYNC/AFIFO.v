module AFIFO #(parameter ADDRWIDTH=3,WIDTH=4,DEPTH=8) (
    input clk1,clk2, rst1,rst2,wrEn,rdEn,
    input      [WIDTH-1:0]wrIn,
    output reg [WIDTH-1:0]rdOut,
    output reg full,empty,
    output reg [ADDRWIDTH:0] rdPtr,wrPtr,
    output reg [ADDRWIDTH:0] rdPtrGreyComp,wrPtrGreyComp,
    output reg [ADDRWIDTH:0] syncGRdPtr1,syncGRdPtr2, //at write clock domain
    output reg [ADDRWIDTH:0] syncGWrPtr1,syncGWrPtr2 //at write clock domain
);

function [ADDRWIDTH:0] binaryToGrey;
input [ADDRWIDTH:0] Bin;
integer i;
begin
    binaryToGrey[ADDRWIDTH]= Bin[ADDRWIDTH];
    for (i=0;i<ADDRWIDTH;i=i+1)
    begin
        binaryToGrey[i] = Bin[i]^Bin[i+1];
    end
end   
endfunction
    reg [WIDTH-1:0] memory [0:DEPTH-1];
    reg fullComp,emptyComp;
    //reg [ADDRWIDTH:0] rdPtr,wrPtr;
    reg [ADDRWIDTH:0] rdPtrComp,wrPtrComp;
    //reg [ADDRWIDTH:0] rdPtrGreyComp,wrPtrGreyComp;
    //reg [ADDRWIDTH:0] syncGRdPtr1,syncGRdPtr2; //at write clock domain
    //reg [ADDRWIDTH:0] syncGWrPtr1,syncGWrPtr2; //at write clock domain
    always @(posedge clk1 or negedge rst1) begin
        if(!rst1)
        begin
            wrPtr<=0;                       
            full<=0;                        
            syncGRdPtr1<=binaryToGrey(rdPtr);
            syncGRdPtr2<=binaryToGrey(rdPtr);

        end
        else
        begin
            wrPtr <= wrPtrComp;
            full<=fullComp;
            syncGRdPtr2<=syncGRdPtr1;
            syncGRdPtr1<=rdPtrGreyComp;
            
             if(!full&&wrEn) 
             begin
                memory[wrPtr[ADDRWIDTH-1:0]]<=wrIn;
             end
        end
    end 
    always @(posedge clk2 or negedge rst2) begin
    if(!rst2)
        begin
            rdPtr<={1'b1,{(ADDRWIDTH){1'b0}}};
            empty<=1;
            syncGWrPtr1<=0;
            syncGWrPtr2<=0;
        end
    else
        begin
            empty<=emptyComp;
            rdPtr <= rdPtrComp;
            syncGWrPtr2<=syncGWrPtr1;
            syncGWrPtr1<=wrPtrGreyComp;
            if(!empty&&rdEn) 
             begin
                rdOut<=memory[rdPtr[ADDRWIDTH-1:0]];
             end
        end
    end 
    always @(*) begin
        //full_comp = comp(syncRdPtr2,wrPtrGreyComp)
        
        if(!full&&wrEn) 
        wrPtrComp=wrPtr+1;
        else            
        wrPtrComp=wrPtr;

        if(!empty&&rdEn)
        begin           
        rdPtrComp=rdPtr+1;
        end             
        else            
        rdPtrComp=rdPtr;
        
        wrPtrGreyComp=binaryToGrey(wrPtrComp);
        rdPtrGreyComp=binaryToGrey(rdPtrComp);
        
        emptyComp  = (syncGWrPtr2[ADDRWIDTH-2:0]==rdPtrGreyComp[ADDRWIDTH-2:0])&&(syncGWrPtr2[ADDRWIDTH]!=rdPtrGreyComp[ADDRWIDTH])&&(syncGWrPtr2[ADDRWIDTH-1]!=rdPtrGreyComp[ADDRWIDTH-1]);
        fullComp = (syncGRdPtr2==wrPtrGreyComp);

        //wrPtrGreyComp = grey(wrPtrComp)
        //rdPtrGreyComp = grey(rdPtrComp) 
    end 
endmodule