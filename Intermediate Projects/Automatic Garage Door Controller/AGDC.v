module AGDC ( //Automatic Garage Door Controller
    input UP_Max,DN_Max,Activate,CLK,RST,
    output reg UP_M,DN_M
);
    localparam IDLE = 2'b00,
               Mv_Dn = 2'b01,
               Mv_Up = 2'b10 ;
    reg [1:0] Next,Current;
    
    //State Transition
    always@(posedge CLK or negedge RST)
    begin
        if(!RST)
        begin
            Current<=0;
        end
        else
        begin
            Current<=Next;
        end
    end

    //Next State Logic
    always@(*)
    begin
        Next=Current;
        if((UP_Max^DN_Max)==1)
        begin
            case(Current)
            IDLE:
            begin
                if(Activate)
                begin
                    if(UP_Max)
                       Next = Mv_Dn;
                    else// if(DN_Max)
                       Next = Mv_Up;
                end
            end
            Mv_Dn:
            begin
                if(DN_Max)
                Next=IDLE;
            end
            Mv_Up:
            begin
                if(UP_Max)
                Next=IDLE;
            end
            endcase
        end 
    end
    
    
    //Output Logic
    always@(*)
    begin
        case(Current)
        IDLE:
        begin
            UP_M=0;
            DN_M=0;
        end
        Mv_Dn:
        begin
            UP_M=0;
            DN_M=1;
            end
        Mv_Up:
        begin
            UP_M=1;
            DN_M=0;
        end
        default:
        begin
            UP_M=0;
            DN_M=0;
        end
        endcase
    end
    
endmodule
