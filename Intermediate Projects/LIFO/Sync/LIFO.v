module LIFO #(
    parameter MEMWIDTH=4,MEMDEPTH=8,ADDRWIDTH=3
) (
    input clk,rst,rdEn,wrEn,
    input [MEMWIDTH-1:0] dataIn,
    output reg full,empty,
    output reg [MEMWIDTH-1:0]dataOut,
    output reg [ADDRWIDTH:0] ptr,ptrRead,ptrComp,
    output reg fullComb,emptyComp
);
reg [MEMWIDTH-1:0] memory  [0:MEMDEPTH-1];
reg fullx,emptyx;
//reg fullComb,emptyComp;
//reg [ADDRWIDTH:0] ptr,ptrRead,ptrComp;
integer i;
    always @(posedge clk or negedge rst) begin
        if(!rst)
        begin
          for(i=0;i<MEMDEPTH;i=i+1)
          memory[i]<=0;  
         
            ptr<=0;
            ptrRead<=0;
            full<=0;
            empty<=1;
        end
        else
        begin
        //assigning
        //full<=(ptr==(MEMDEPTH-1));
        //empty<=(ptr==0);
        full<=fullComb;
        empty<=emptyComp;
        fullx<=full;
        emptyx<=empty;
        ptrRead<=ptr;
        //@clk posedge
        //if(!fullComb&&!emptyComp)
        ptr<=ptrComp;
        if(wrEn&&!rdEn&&!fullx)
        begin
        memory[ptr[ADDRWIDTH-1:0]]<=dataIn;
       // if(!fullComb)
     //   ptr<=ptrComp;
        end
        else if(!wrEn&&rdEn&&!emptyx)
        begin
        dataOut<=memory[ptrRead[ADDRWIDTH-1:0]];
      //  if(!emptyComp)
      //  ptr<=ptrComp;
        //ptrRead<=ptr;
        end
        end
    end
    always @(*) begin
        //next logic
        if(wrEn&&!rdEn&&!full)
        ptrComp=ptr+1;
        else if(!wrEn&&rdEn&&!empty)
        ptrComp=ptr-1;
        else
        ptrComp=ptr;
        //fullComb = (ptrComp==MEMDEPTH);
        //emptyComp = (ptrComp=={(ADDRWIDTH+1){1'b1}});
        fullComb = (ptrComp==MEMDEPTH-1);
        emptyComp = (ptrComp == 0);
    end
endmodule