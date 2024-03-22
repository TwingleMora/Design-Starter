module UART #(
    parameter DATAWIDTH = 8,OVERSAMPLING=16
) (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   parityEnable,
    input  wire                   parityType,
    input  wire                   tx_data_valid,
    input  wire  [DATAWIDTH-1:0]  tx_in,
    input  wire                   rx,
	input  wire  [11:0]           div,
    output wire  [DATAWIDTH-1:0]  rx_out,
    output wire                   tx,
    output wire                   parityError,
    output wire                   parityErrorValid,
    output wire                   tx_busy,
    output wire                   rx_busy,
    output wire                   rx_done,
    output wire                   framingError,
    output wire                   tx_done
);
    

BAUD_RATE_GENERATOR BRG
(.clk(clk),.rst(rst),.div(div), .bclk(bclk_wire));

TXTOP#(.DATAWIDTH(DATAWIDTH),.OVERSAMPLING(OVERSAMPLING+1)) txtop
    (
     .clk(clk),
     .rst(rst),
     .parEnable(parityEnable),
     .parityType(parityType),
     .dataValid(tx_data_valid),
     .tx_out(tx),
     .dataInput(tx_in),
     .busy(tx_busy),
     .bclk(bclk_wire),
     .tx_done(tx_done)
    );

    RXTOP#(.DATAWIDTH(DATAWIDTH),.OVERSAMPLING(OVERSAMPLING+1)) rxtop
    (
              .clk(clk),
              .rst(rst),
              .parEnable(parityEnable)
              ,.parityType(parityType)
              ,.rx_in(rx),
              .rx_out(rx_out)
              ,.pCheckError(parityError),
              .pCheckValid(parityErrorValid),
              .busy(rx_busy),
              .rx_done(rx_done),
              .bclk(bclk_wire),
              .framingError(framingError)
    );
endmodule