module RXTOP_TB;

    localparam DATAWIDTH = 8,OVERSAMPLING=16;
    localparam PERIOD = 10;
    reg clk_tb,rst_tb;
    reg parityEnable_tb;
    reg parType_tb;
    reg [((DATAWIDTH-1)+3)+1:0]the_input;
    reg rx_tb;
    reg [11:0] DIV;
    wire[DATAWIDTH-1:0] rx_out_tb;
    wire pCheckErrorOut_tb, pCheckValidOut_tb;
    wire rx_done;
    wire framingError_tb;
    localparam IDLE  = 0,
           START = 1,
           DATA  = 2,
           PARITY = 3,
           STOP    = 4;
           
        BAUD_RATE_GENERATOR BRGRXTB
           (
            .clk(clk_tb),.rst(rst_tb),.div(DIV),.bclk(bclk)
           );

        RXTOP#(.DATAWIDTH(DATAWIDTH),.OVERSAMPLING(OVERSAMPLING)) rxtop_tb
            (
             .bclk(bclk),.clk(clk_tb), .rst(rst_tb), .parEnable(parityEnable_tb),.parityType(parType_tb), .rx_in(rx_tb),
              .rx_out(rx_out_tb),.pCheckError(pCheckErrorOut_tb),.pCheckValid(pCheckValidOut_tb),.rx_done(rx_done),.framingError(framingError_tb)
            );
        task initialization;
            begin
                DIV=2;
                parType_tb=0;
                rst_tb=0;
                clk_tb=0;
                #(PERIOD)
                rst_tb=1;
            end
        endtask

        task sendData;
            input reg [((DATAWIDTH-1)+3)+1:0] dInput;
            input integer parityEn,parityTyp;
            reg[DATAWIDTH-1:0] mMemory;
            integer i;
            
            begin
                parityEnable_tb=parityEn;
                parType_tb = parityTyp;
                the_input=(dInput);
               $display("Input Is: %b",dInput);
               for(i=((DATAWIDTH-1)+3)+1;i>=0;i=i-1)
               begin
                $display("index is: %0d of %b is %b",((DATAWIDTH-1)+3)-i,dInput,dInput[i]);
                rx_tb =dInput[i];
                displayTestbenchData;
                
               end
               rx_tb=1;//idle state until the transmitter sent the next packet
            end
            endtask
            task displayTestbenchData;
              begin
                repeat(DIV*OVERSAMPLING)
                begin
                    #(PERIOD);
                    $display("Done: %b, Deserializer memory: %b, Current State: %0d, TxIn: %b, Ptr: %b, Deserializer Enable: %b, Deserializer Done: %b, BAUD_COUNTER: %0d",
                    rxtop_tb.fsm_rx.done,rxtop_tb.deserializer.dataOut,rxtop_tb.fsm_rx.Current,
                    rx_tb,rxtop_tb.deserializer.ptr,rxtop_tb.fsm_rx.deSerializerEn,
                    rxtop_tb.deserializer.deSerializerDn,rxtop_tb.fsm_rx.BAUD_COUNTER);
                    if(rxtop_tb.fsm_rx.done)
                    begin
                        $display("my memory: %b",rx_out_tb);
                    end
              
                end
                
            end
            endtask
    
        always #(PERIOD/2) clk_tb=~clk_tb;
        initial
        begin
            initialization;
            sendData(12'b101100110111,1,0);//11001101 10110011
            sendData(12'b101000000111,0,0);//10000001 10000001
            sendData(12'b101011100111,0,0);//10111001 10011101
            sendData(12'b101110111111,0,0);//11101111 11110111
            $stop;
        end
endmodule