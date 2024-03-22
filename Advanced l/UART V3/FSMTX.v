module FSMTX#(parameter OVERSAMPLING = 16)
    (
        input  wire      empty,
        input  wire      baud,
        input  wire      SerializerDn,
        input  wire      parEn,
        input  wire      clk,
        input  wire      rst,
        input  wire      dataValid,
        output reg [2:0] muxSelector,
        output reg       serializerEn,
        output reg       busy,
        output reg       done
    );

    localparam IDLE   = 0,
               START  = 1,
               DATA   = 2,
               PARITY = 3,
               STOP   = 4;
    reg [2:0] Current;
    reg [2:0] Next;
    reg [4:0] BAUD_COUNTER;
    reg [4:0] BAUD_COUNTER_Next; 
    //reg busy;
    always@(posedge clk or negedge rst)
    begin  
    if(!rst)
    begin  
        Current<=0;
        BAUD_COUNTER<=0;
    end   
    else  
    begin 
        Current<=Next;
        BAUD_COUNTER<= BAUD_COUNTER_Next;
    end  
    end  
        
    always @(*) begin
        done=0;
        busy=1;
        muxSelector = Current;
        serializerEn =0;
        if(baud==1)
        BAUD_COUNTER_Next=BAUD_COUNTER+1;
        else
        BAUD_COUNTER_Next=BAUD_COUNTER;
        case(Current)
        IDLE:begin
            busy=0;
            if(dataValid)
            Next = START;
            else
            Next=Current;

                BAUD_COUNTER_Next=0;//starting from 0 to 16 (17)
        end
        START:begin
            if(BAUD_COUNTER==(OVERSAMPLING))
            begin
                BAUD_COUNTER_Next=0;
                Next=DATA;
                serializerEn=1;
            end
            else
            begin
              //  BAUD_COUNTER_Next=BAUD_COUNTER+1;
                Next=Current;
                serializerEn=0;
            end
        end
        DATA:begin

            if(BAUD_COUNTER==(OVERSAMPLING))
            begin
                serializerEn=1;
                BAUD_COUNTER_Next=0;
                if(!SerializerDn)
                begin
                //serializerEn=0;
                Next=Current;
                end
                else
                begin
                serializerEn=0;
                if(parEn)
                Next=PARITY;
                else
                Next=STOP;
                end
            end
            else
            begin
                
                Next=Current;
               //BAUD_COUNTER_Next=BAUD_COUNTER+1;

            end
        end
        PARITY:
        begin
            if(BAUD_COUNTER==(OVERSAMPLING))
            begin
            Next=STOP;
            BAUD_COUNTER_Next=0;
            end
            else
            begin
            Next=Current;
            //BAUD_COUNTER_Next=BAUD_COUNTER+1;    
            end
        end
        STOP:begin
            if(BAUD_COUNTER==(OVERSAMPLING))
            begin
            Next=IDLE;
            done=1;
            BAUD_COUNTER_Next=0;
            end
            else
            begin
            Next=Current;
            //BAUD_COUNTER_Next=BAUD_COUNTER+1;
            end
        end
        default:
        begin
        Next=IDLE;
        busy=0;
        done=0;
        //BAUD_COUNTER_Next=BAUD_COUNTER+1;    
        end
        endcase
    end
    


endmodule