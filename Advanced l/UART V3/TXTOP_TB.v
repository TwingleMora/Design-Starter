module TXTOP_TB;
    localparam DATAWIDTH = 8,OVERSAMPLING=4;
    localparam PERIOD = 10;
    
    reg clk_tb,rst_tb;
    reg parityEnable_tb,parType_tb;
    reg [11:0] DIV=2;
    reg dataValid_tb;
    reg [DATAWIDTH-1:0] tx_input_tb;
    
    wire tx_tb;
    wire tx_done_tb;
    reg[DATAWIDTH-1:0] mData;
    reg[(DATAWIDTH-1)+4:0] mPacket;//start+stop+parity+idle+data
    reg bitPulse;
    reg[DATAWIDTH-1:0] mDataFrame;
    localparam IDLE  = 0,
           START = 1,
           DATA  = 2,
           PARITY = 3,
           STOP    = 4;

    BAUD_RATE_GENERATOR BRGRXTB
        (
        .clk(clk_tb),
        .rst(rst_tb),
        .div(DIV),
        .bclk(bclk)
        );

    TXTOP#(.DATAWIDTH(DATAWIDTH),.OVERSAMPLING(OVERSAMPLING)) txtop_tb
        (
         .clk(clk_tb),
         .rst(rst_tb),
         .bclk(bclk),
         .parEnable(parityEnable_tb),
         .parityType(parType_tb),
         .dataValid(dataValid_tb),
         .tx_out(tx_tb),
         .dataInput(tx_input_tb),
         .tx_done(tx_done_tb)
        );

    task initialization;
        begin
            parType_tb=0;
            rst_tb=0;
            clk_tb=0;
            #(PERIOD)
            rst_tb=1;
        end
    endtask

    task writeData;
        input reg [DATAWIDTH-1:0] dInput;
        input integer parityEn,parityTyp;
        integer passed;
            begin
                $display("Loading Data");
                passed =1;
                mData=0;
                mPacket=0;
                dataValid_tb=1;
                tx_input_tb =dInput;
                parityEnable_tb=parityEn;
                parType_tb = parityTyp;
                mPacket={mPacket[(DATAWIDTH-1)+3:0],tx_tb};
                detectBit;
                #(PERIOD)
                dataValid_tb=0;
                repeat(DIV*OVERSAMPLING*12)
                begin
                    detectBit;
                    $display("dataInput: %b, serializer memory: %b, Current State: %0d, TxOut: %b, Ptr: %b, Serializer Enable: %b, Serializer Done: %b, BAUD_COUNTER: %0d",tx_input_tb,txtop_tb.serializer.memory,txtop_tb.fsm_tx.Current,tx_tb,txtop_tb.serializer.ptr,txtop_tb.fsm_tx.serializerEn,txtop_tb.serializer.SerializerDn,txtop_tb.fsm_tx.BAUD_COUNTER);
                    if(txtop_tb.fsm_tx.BAUD_COUNTER==(OVERSAMPLING))
                    begin

                        if(txtop_tb.fsm_tx.Current)
                        mPacket={mPacket[(DATAWIDTH-1)+3:0],tx_tb};
                        if(txtop_tb.fsm_tx.Current==DATA)
                        begin
                            mData={tx_tb,mData[7:1]};
                            if(txtop_tb.serializer.SerializerDn)
                            begin
                                if(mData!=dInput)
                                begin
                                    passed =0;
                                end
                            end
                            if(parityEnable_tb)
                            begin
                                if(txtop_tb.fsm_tx.Current==DATA&&txtop_tb.fsm_tx.Next==STOP)
                                    passed=0;
                            end
                         end
                    end
                    #(PERIOD);
                end

                $display("The Transfered Data: %b",mData);
                $display("The Transfered Packet: %b",mPacket);
                if(passed)
                $display("*********** Testbench Passed ***********");
                $display("\n\n");
            end

    endtask
    task detectBit;
        begin

            bitPulse=(txtop_tb.fsm_tx.BAUD_COUNTER==(OVERSAMPLING));

        end
    endtask
    always 
    begin
        #(PERIOD/2) clk_tb=~clk_tb;
    end
    initial
    begin
        initialization;
        
        writeData(8'b11001100,0,0);
        writeData(8'b10000001,1,0);
        writeData(8'b10111001,1,0);
        writeData(8'b11101111,1,0);
        $stop;
    end
endmodule