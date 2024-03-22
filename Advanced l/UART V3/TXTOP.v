module TXTOP#(parameter DATAWIDTH=8,OVERSAMPLING=16)
    (
    input  wire                   clk, 
    input  wire                   rst,
    input  wire                   parEnable,
    input  wire                   dataValid,
    input  wire                   parityType,
    input  wire  [DATAWIDTH-1:0]  dataInput,
    input  wire                   bclk,
    output wire                   tx_out,
    output wire                   busy,
    output wire                   tx_done
    );
    //Internal Signals
     wire [2:0]muxSelector_wire;
     wire SerializerDn_wire;
     wire serializerEn_wire;
     wire data_mux_wire;
   
     //Mealy FSM 
     FSMTX#(.OVERSAMPLING(OVERSAMPLING)) fsm_tx
        (
         .baud(bclk),
         .SerializerDn(SerializerDn_wire),
         .parEn(parEnable),
         .clk(clk),
         .rst(rst),
         .dataValid(dataValid), 
         .muxSelector(muxSelector_wire),
         .serializerEn(serializerEn_wire),
         .busy(busy),
         .done(tx_done)
         );

      //Converts parallel (8bits/cycle) data to serial(1bits/cycle)
     Serializer#(.DATAWIDTH(DATAWIDTH)) serializer
        (
        .clk(clk),
        .rst(rst),
        .dataValid(dataValid),
        .serializerEn(serializerEn_wire),
        .dataIn(dataInput),
        .dataOut(data_mux_wire),
        .SerializerDn(SerializerDn_wire)
        );

      //Calculates parity bit (Input: tx_input_data)
     ParityCalculator#(.DATAWIDTH(DATAWIDTH)) pCalc
        (
        .clk(clk),
        .rst(rst),
        .parityType(parityType),
        .dataValid(dataValid),
        .dataIn(dataInput),
        .parityBit(parity_mux_wire)
        );

      //Mux selelctor is FSM current state(IDLE,START,DATA,PARITY,STOP)
     MUX mux
        (
        .selector(muxSelector_wire),
        .start(1'b0),
        .data(data_mux_wire),
        .parity(parity_mux_wire),
        .stop(1'b1),
        .idle(1'b1),
        .tx_out(tx_out));
endmodule