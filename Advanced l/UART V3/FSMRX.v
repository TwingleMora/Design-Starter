module FSMRX#(parameter OVERSAMPLING = 16)
    (
    input  wire     baud,
    input  wire     deSerializerDn,
    input  wire     parEn,
    input  wire     clk,
    input  wire     rst,
    input  wire     dataIn,
    output reg      deSerializerEn,
    output reg      done,
    output reg      parityCheckEn,
    output reg      busy,
    output reg      framingError
    );
    
    localparam IDLE  = 0,
    START = 1,
    DATA  = 2,
    PARITY = 3,
    STOP    = 4;
    reg [2:0] Current;
    reg [2:0] Next;
    reg [4:0] BAUD_COUNTER;
    reg [4:0] BAUD_COUNTER_Next; 
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

    always @(*) 
    begin
        framingError=0;
        busy=1;
        done=0;
        deSerializerEn= 0;
        parityCheckEn = 0;
        if(baud==1)
            BAUD_COUNTER_Next=BAUD_COUNTER+1;
        else
            BAUD_COUNTER_Next=BAUD_COUNTER;
        
        case(Current)
            IDLE:begin
                busy=0;
                if(!dataIn)
                    Next = START;
                else
                    Next=Current;

                BAUD_COUNTER_Next=0;//starting from 0 to 16 (17)
            end
            START:begin
                if(BAUD_COUNTER==(OVERSAMPLING)/2)
                begin
                    BAUD_COUNTER_Next=0;
                    Next=DATA;
                    //deSerializerEn=1;
                end
                else
                begin
                    //BAUD_COUNTER_Next=BAUD_COUNTER+1;
                    Next=Current;
                    //deSerializerEn=0;
                end
            end
            DATA:begin
                if(deSerializerDn)
                begin
                    //serializerEn=0;
                    BAUD_COUNTER_Next=0;
                    deSerializerEn=0;
                if(parEn)
                begin
                    Next=PARITY;
                    
                end
                else
                    Next=STOP;
                    
                end
            
                else if(BAUD_COUNTER==(OVERSAMPLING))
                begin
                    deSerializerEn=1;
                    BAUD_COUNTER_Next=0;
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
                    parityCheckEn=1;
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
                    done = 1;//will be one for one cycle (and then Current<=Next)
                    //all of these not registered signal are held at their value 
                    //until Current<=Next
                    BAUD_COUNTER_Next=0;
                    if(!dataIn)
                    framingError=1;
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
                framingError=0;
                done=0;
                //BAUD_COUNTER_Next=BAUD_COUNTER+1;    
            end
        endcase
    end
    


endmodule