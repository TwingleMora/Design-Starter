module ECLMoore(
    input but_0,but_1,RESET,CLK,output reg UNLOCK 
);
//6 states => number of bits = log2(6)
 reg [2:0]  Current;
 reg [2:0]  Next_Comb;
 parameter  IDLE =0,
            S0   =1,
            S01  =2,
            S010 =3,
            S0101=4,
            S01011=5;
always@(*)
    begin
// Next Logic
Next_Comb=Current;
    if((but_0^but_1)==1)
    begin
        case(Current)
            IDLE:
            if(but_0) //0
            Next_Comb=S0;
            else
            Next_Comb=IDLE;
            S0:
            if(but_0)
            Next_Comb=IDLE;
            else//01
            Next_Comb=S01;
            S01:
            if(but_0)//010
            Next_Comb=S010;
            else
            Next_Comb=IDLE;
            S010:
            if(but_0)
            Next_Comb=IDLE;
            else//0101
            Next_Comb=S0101;
            S0101:
            if(but_0)
            Next_Comb=IDLE;
            else//01011
            Next_Comb=S01011;
            default:
            Next_Comb=Current;
        endcase
        end
    end
always@(*)
    begin
    if(Current==S01011)
    begin
    UNLOCK=1;
    end
    else
    begin
    UNLOCK=0;
    end
    end
always@(posedge CLK or negedge RESET)
    begin
        if(!RESET)
        Current<=IDLE;
        else
        Current<=Next_Comb;

    end
endmodule
