module UART_TB;
    
    //*****************PARMAETERS(CONSTANTS)*********************
    parameter PERIOD1=625,PERIOD2=1250 ;
    parameter DATAWIDTH = 8,OVERSAMPLING=16, DIV1=20,DIV2=10;

    
    //*****************STIMULIS*********************
    reg clk1,clk2,rst;
    reg parEnIn_tb,parTypeIn_tb,dataValidIn_tb;
    reg [DATAWIDTH-1:0] dataInput_tb;
    


    //*****************OUTPUT*********************
    wire [DATAWIDTH-1:0] rx_output;
    wire transmitter_tx,pCheckErrorOut_tb, pCheckValidOut_tb;
    wire rx_done_tb, tx_done_tb,framingError_tb;

    //*****************VARIABLE*********************
    integer tested;
    integer success;
    reg pbit;
    //*****************DUT1(Transmitter)*********************
UART #
(.DATAWIDTH(DATAWIDTH),.OVERSAMPLING(OVERSAMPLING))
uart_transmitter 
(
    .clk(clk1),
    .rst(rst),
    .parityEnable(parEnIn_tb),
    .parityType(parTypeIn_tb),
    .tx_data_valid(dataValidIn_tb),
    .tx_in(dataInput_tb),
    .div(DIV1),
    .tx(transmitter_tx),
    .tx_done(tx_done_tb)
);

//*****************DUT2(Receiver)*********************
UART #
(.DATAWIDTH(DATAWIDTH),.OVERSAMPLING(OVERSAMPLING))
uart_receiver 
(
    .clk(clk2),
    .rst(rst),
    .parityEnable(parEnIn_tb),
    .parityType(parTypeIn_tb),
    .rx(transmitter_tx),
    .rx_out(rx_output),
    .div(DIV2),
    .parityError(pCheckErrorOut_tb),
    .parityErrorValid(pCheckValidOut_tb),
    .rx_done(rx_done_tb),
    .framingError(framingError_tb)
);

//*****************CLOCK GENERATION*********************
always #(PERIOD1/2) clk1=~clk1;
always #(PERIOD2/2) clk2=~clk2;

//*****************TASKS*********************
/*
 * initialization
 * DisplayBitNum
 * DisplayFSMsState
 * DisplaySerializersState
 * DisplayCurrentState
 * DisplayParity
 * DisplayTestError(testNumber)
 * Validate(testNumber)
 * RunCommunicationProtocol
*/
//*****************DISPLAY CURRENT REGISTER VALUE IN RECEIVER & TRANSMITTER*********************
task DisplayCurrentState;
    localparam IDLE =  0,
               START=  1,
               DATA=   2,
               PARITY= 3,
               STOP =  4;
begin

    case(uart_transmitter.txtop.fsm_tx.Current)
    IDLE:
        $display("Transmitter State: IDLE");
        START:
        $display("Transmitter State: START");
        DATA:
        $display("Transmitter State: DATA");
        PARITY:
        $display("Transmitter State: PARITY");
        STOP:
        $display("Transmitter State: STOP");
    endcase 
    case(uart_receiver.rxtop.fsm_rx.Current)
        IDLE:
        $display("Receiver State: IDLE");
        START:
        $display("Receiver State: START");
        DATA:
        $display("Receiver State: DATA");
        PARITY:
        $display("Receiver State: PARITY");
        STOP:
        $display("Receiver State: STOP");
    endcase 

end
endtask

//*****************DISPLAY ERROR MESSAGE (UNMATCH, PARITY ERROR, PARITY GEN/CHE FAILURE)*********************
task DisplayTestError;
input integer testNumber;
    begin
        $display("*************** Test %0d Failed (Unmatched Data) *************",testNumber);
        if(parEnIn_tb&&!pCheckValidOut_tb)
        begin
            $display("*************** Parity Generator & Checker Failed *************");
        end
        if( (pCheckValidOut_tb&&pCheckErrorOut_tb))
        begin
            $display("*************** Parity Error *************");
        end
        $display("\n\n");
    end
endtask




//*****************DISPLAY SERIALIZER AND DESERIALIZER STATE*********************
task DisplaySerializersState;
begin
    if(uart_transmitter.txtop.fsm_tx.Current==0)
    begin
        $display("[IDLE](Transmitter Serializer Output: %b, Transmitter Serializer Internal Memory: %b)",
        uart_transmitter.txtop.serializer.dataOut,
        uart_transmitter.txtop.serializer.memory);
    end
    else
    begin
        $display("(Transmitter Serializer Output: %b, Transmitter Serializer Internal Memory: %b)",
        uart_transmitter.txtop.serializer.dataOut,
        uart_transmitter.txtop.serializer.memory);
    end
    if(uart_receiver.rxtop.fsm_rx.Current==0)
    begin
        $display("[IDLE](Receiver Deserializer Input: %b, Receiver Deserializer Memory: %b)",
        uart_receiver.rxtop.deserializer.dataIn,
        uart_transmitter.rxtop.deserializer.dataOut);
    end
    else
    begin
        $display("(Receiver Deserializer Input: %b, Receiver Deserializer Memory: %b)",
        uart_receiver.rxtop.deserializer.dataIn,
        uart_transmitter.rxtop.deserializer.dataOut);
    end
end
endtask




//*****************DISPLAY ENABLE, DONE IN SERIALIZER & DESERIALIZER + MENTIONING THE CURRENT STATE FOR BOTH*********************
task DisplayFSMsState;
    begin
        if(!uart_transmitter.txtop.fsm_tx.Current&&!uart_receiver.rxtop.fsm_rx.Current)
        begin
            $display("[IDLE](Transmitter Serializer Enable: %b, Serializer Done: %b) | [IDLE](Receiver Deserializer Enable: %b, Deserializer Done: %b)",uart_transmitter.txtop.fsm_tx.serializerEn,
            uart_transmitter.txtop.serializer.SerializerDn,
            uart_receiver.rxtop.fsm_rx.deSerializerEn,
            uart_receiver.rxtop.deserializer.deSerializerDn);
        end
        else if(!uart_transmitter.txtop.fsm_tx.Current&&uart_receiver.rxtop.fsm_rx.Current)
        begin
            $display("[IDLE](Transmitter Serializer Enable: %b, Serializer Done: %b) | (Receiver Deserializer Enable: %b, Deserializer Done: %b)",uart_transmitter.txtop.fsm_tx.serializerEn,
            uart_transmitter.txtop.serializer.SerializerDn,
            uart_receiver.rxtop.fsm_rx.deSerializerEn,
            uart_receiver.rxtop.deserializer.deSerializerDn);
        end
        else if (uart_transmitter.txtop.fsm_tx.Current&&!uart_receiver.rxtop.fsm_rx.Current)
        begin
            $display("(Transmitter Serializer Enable: %b, Serializer Done: %b) | [IDLE](Receiver Deserializer Enable: %b, Deserializer Done: %b)",uart_transmitter.txtop.fsm_tx.serializerEn,
            uart_transmitter.txtop.serializer.SerializerDn,
            uart_receiver.rxtop.fsm_rx.deSerializerEn,
            uart_receiver.rxtop.deserializer.deSerializerDn);
        end
        else
        begin
            $display("(Transmitter Serializer Enable: %b, Serializer Done: %b) | (Receiver Deserializer Enable: %b, Deserializer Done: %b)",uart_transmitter.txtop.fsm_tx.serializerEn,
            uart_transmitter.txtop.serializer.SerializerDn,
            uart_receiver.rxtop.fsm_rx.deSerializerEn,
            uart_receiver.rxtop.deserializer.deSerializerDn);
        end
    end
    
endtask



//*****************DISPLAY TRANSMITTED AND RECEIVED BITS NUMBER *********************
task DisplayBitNum;
begin
    if(uart_receiver.rxtop.fsm_rx.Current==2)
    begin
        $display("receive bit number: %0d",uart_receiver.rxtop.deserializer.ptr);
    end
    if(uart_transmitter.txtop.fsm_tx.Current==2)
    begin
        $display("transfer bit number: %0d",uart_transmitter.txtop.serializer.ptr);
    end
end
endtask

//***************** BAUD INFO *********************************
task display_baudrate;
    begin
        $display("Transmitter CLK: %0.2f Hz, Receiver CLK: %0.2f Hz"
        ,((1.0/PERIOD1)*(10**9))
        ,((1.0/PERIOD2)*(10**9))
        );
        $display("Transmitter Divider: %0d, Receiver Divider: %0d"
        ,DIV1
        ,DIV2);
        $display("Transmitter Baud Rate: %0.3f bits/sec, Receiver Baud Rate: %0.3F bits/sec"
        ,((1.0/(PERIOD1*(DIV1*16)))*(10**9))
        ,((1.0/(PERIOD2*(DIV2*16)))*(10**9))
        );
    end
endtask
//*****************CHECK IF RX_OUT MATCHES TX_OUT*********************
//*****************CHECK ON PARITY MODULES*********************
task Validate;
input integer testnumber;
reg rightPBit;
integer caught_wrong_parity;
integer ferror;
    begin
        caught_wrong_parity=0;
        ferror=0;
        if(parEnIn_tb)
        begin
       /*
        if(!parTypeIn_tb)
        begin
            rightPBit = ^(dataInput_tb);
        end
        else
        begin
            rightPBit = !(^(dataInput_tb));
        end*/
   
    //$display("receiver caught incorrectly parity bit which doesnt represent the transmitted data");// caught it in wrong phase
        if(framingError_tb)
        ferror=1;
        if(pbit!=uart_transmitter.txtop.pCalc.parityBit&&((uart_receiver.rxtop.fsm_rx.Next==4)&&(uart_receiver.rxtop.fsm_rx.Current!=3)))
        begin
            caught_wrong_parity=1;
        end    
        end
        if((dataInput_tb==rx_output)&&uart_receiver.rxtop.fsm_rx.Current==4)
        begin
            //if(!failed)
            //begin
            $display("\n");
            $display("rx_output is: %b, rx_input: %b",rx_output,dataInput_tb);
            
            display_baudrate;
            $display("*************** Test %0d Passed *************",testnumber);
            success=1;
            tested=1;
            $display("\n\n");
        end
        else if((dataInput_tb!=rx_output) && (uart_receiver.rxtop.fsm_rx.Current==4))//4(stop)
        begin
            
            $display("\n");
            display_baudrate;
            if(parEnIn_tb)
            $display("RX caught parity bit is: %b, tx sent parity bit is %b",pbit,uart_transmitter.txtop.pCalc.parityBit);
            if(caught_wrong_parity)
            begin
               
                $display("***** Receiver didn't correctly catch the parity bit,Instead it caught another bit as the parity bit *****");
                $display("***** The parity error calculated from RX: %b and RX parity bit: %b is: %b  *****",rx_output,pbit,uart_receiver.rxtop.pCheck.error);
                
            end
            if(ferror)
            $display("*************** Framing Error ***************");
            $display("***** rx_output is: %b, rx_input: %b *****",rx_output,dataInput_tb);
            DisplayTestError(testnumber);
            tested=1;
            $display("\n\n");
        end


    end
endtask


//*****************CHECK ON PARITY STATE*********************
task DisplayParity;
    begin
        if(parEnIn_tb)
        begin
            if(!parTypeIn_tb)
            begin
                $display("(Transmitter Parity Type: even(%b), Transmitter Parity Memory: %b, Transmitter Parity Bit: %b)",
                uart_transmitter.txtop.pCalc.parityType,
                uart_transmitter.txtop.pCalc.memory,
                uart_transmitter.txtop.pCalc.parityBit);

                $display("(Receiver Parity Type: even(%b), Receiver Parity Memory: %b, Receiver \"Error Valid Flag\": %b, Receiver Error: %b)",
                uart_receiver.rxtop.pCheck.parityType,
                uart_receiver.rxtop.pCheck.memory,
                uart_receiver.rxtop.pCheck.valid,
                uart_receiver.rxtop.pCheck.error);
                if(uart_receiver.rxtop.fsm_rx.Next==4)
                begin
                    pbit = uart_receiver.rxtop.pCheck.parityBit;
                    $display("Receiver's parity bit: %b",pbit);
                end
            end
            else
            begin
                $display("(Transmitter Parity Type: odd(%b), Transmitter Parity Memory: %b, Transmitter Parity Bit: %b)",
                uart_transmitter.txtop.pCalc.parityType,
                uart_transmitter.txtop.pCalc.memory,
                uart_transmitter.txtop.pCalc.parityBit);

                $display("(Receiver Parity Type: odd(%b), Receiver Parity Memory: %b, Receiver \"Error Valid Flag\": %b, Receiver Error: %b)",
                uart_receiver.rxtop.pCheck.parityType,
                uart_receiver.rxtop.pCheck.memory,
                uart_receiver.rxtop.pCheck.valid,
                uart_receiver.rxtop.pCheck.error);
                if(uart_receiver.rxtop.fsm_rx.Next==4)
                begin
                    pbit = uart_receiver.rxtop.pCheck.parityBit;
                    $display("Receiver's parity bit: %b",pbit);
                end
            end
        end
    end
endtask

//*****************INITIALIZER*********************
task Initialization;
    begin
        clk1=0;
        clk2=0;
        rst = 0;
        if(PERIOD1>=PERIOD2)
        #(PERIOD1);
        else
        #(PERIOD2);
        rst =1 ;
    end
endtask

//*****************TEST HANDLER*********************
task RunCommunicationProtocol;
input reg[DATAWIDTH-1:0] data;
input parEnIn;
input parTypeIn;
input integer testNumber;
real periodRatio;
    begin
       
        success=0;
        tested=0;
        parEnIn_tb = parEnIn;
        parTypeIn_tb = parTypeIn;
        dataValidIn_tb = 1;
        dataInput_tb = data;
       #(PERIOD1)
        dataValidIn_tb=0;
        $display("------------------- Test Number: %0d -------------------",testNumber);
        if(parTypeIn==0)
            $display("[Settings] Input Data: %0b, Parity En: %0b, Parity Type: Even(%b)",data,parEnIn,parTypeIn);
        else
            $display("[Settings] Input Data: %0b, Parity En: %0b, Parity Type: Odd(%b)",data,parEnIn,parTypeIn);

        $display("[Settings] Transmitter CLK : %0.2f Hz, Receiver CLK: %0.2f Hz"
        ,((1.0/PERIOD1)*(10**9))
        ,((1.0/PERIOD2)*(10**9)));

        $display("[Settings] Transmitter Divider: %0d, Receiver Divider: %0d"
        ,DIV1
        ,DIV2);
        
        $display("[Settings] Transmitter Baud Rate: %0.2f bits/sec, Receiver Baud Rate: %0.2f bits/sec"
        ,((1.0/(PERIOD1/(DIV1*16)))*(10**9))
        ,((1.0/(PERIOD2/(DIV2*16)))*(10**9)));

        if((PERIOD1*DIV1)>(PERIOD2*DIV2))
        periodRatio = ((PERIOD1*DIV1)/(PERIOD2*DIV2));
        else
        periodRatio=1;
        repeat(13.0*periodRatio)
        begin
            if(!tested)
            begin
                DisplayBitNum;
                DisplaySerializersState;
                DisplayFSMsState;
                DisplayCurrentState;
                DisplayParity;
                Validate(testNumber);

                #(PERIOD2*DIV2*OVERSAMPLING);
            end
        end
        // most of these data is from the receiving UART
        //so sampling using period *div2 *oversampling is better than (period1*div1*oversampling)
        //and in case period2*div2 is slower than period1*div1 then the periodRatio will provide additional time for
        //receiver to change it's process
        //if it's the opposite then the periodRatio
        // will make the loop ends when the transmitter has finished. 
   
        if(!tested)//in case the receiver didn't reach stop state before the test ends
        begin
            if(!success)
            begin
                DisplayTestError(testNumber);
            end
        end
    end
endtask



//*****************TESTBENCH ENTRY POINT*********************
initial 
    begin
        Initialization;
        RunCommunicationProtocol(8'b11011011,1,0,1);
        RunCommunicationProtocol(8'b11110001,1,0,2);
        RunCommunicationProtocol(8'b10000001,0,0,3);
        $stop;
    end

endmodule