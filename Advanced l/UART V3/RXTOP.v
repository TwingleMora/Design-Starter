module RXTOP#(parameter DATAWIDTH=8,OVERSAMPLING=16)
    (
    input clk, rst, parEnable, parityType, rx_in,
    input bclk,
    output [DATAWIDTH-1:0] rx_out,
    output wire pCheckError,
    output wire pCheckValid,
    output wire busy,
    output wire rx_done,
    output wire framingError
    );
    //Internal Signals
    wire [2:0]muxSelector_wire;
    wire deSerializerDn_wire;
    wire fsm_deSerializerEn_wire;
    wire fsm_parity_check_en_wire;

 
    //Mealy Finite State Machine
    FSMRX#(.OVERSAMPLING(OVERSAMPLING)) fsm_rx
        (
        .baud(bclk),
        .deSerializerDn(deSerializerDn_wire),
        .parEn(parEnable),
        .clk(clk),
        .rst(rst),
        .dataIn(rx_in),
        .deSerializerEn(fsm_deSerializerEn_wire),
        .done(rx_done),
        .parityCheckEn(fsm_parity_check_en_wire),
        .busy(busy),
        .framingError(framingError)
        );
     
     //Converts series data to parallel data
    Deserializer#(.DATAWIDTH(DATAWIDTH)) deserializer
        (
        .clk(clk),
        .rst(rst),
        .deSerializerEn(fsm_deSerializerEn_wire),
        .dataIn(rx_in),
        .done(rx_done),
        .dataOut(rx_out),
        .deSerializerDn(deSerializerDn_wire)
        );
     
     //check if the transmitted parity bit matches the received data parity bit
    ParityCheck#(.DATAWIDTH(DATAWIDTH)) pCheck
        (.clk(clk),
        .rst(rst),
        .done(rx_done),
        .deSerializerDn(deSerializerDn_wire),
        .parityType(parityType),
        .parityCheckEn(fsm_parity_check_en_wire),
        .serIn(rx_in),
        .deSerIn(rx_out),
        .error(pCheckError),
        .valid(pCheckValid));

        
   
        
endmodule