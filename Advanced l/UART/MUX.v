module MUX #(parameter STATEWIDTH = 3)
(
input [STATEWIDTH-1:0]mux_sel,
input start_bit,stop_bit,ser_data,par_bit,
output reg TX_OUT
);
localparam IDLE = 0,
           START= 1,
           DATA=  2,
           PARITY=3,
           STOP = 4;
always @(*) begin
case(mux_sel)
START:
TX_OUT=start_bit;
DATA:
TX_OUT=ser_data;
PARITY:
TX_OUT=par_bit;
STOP:
TX_OUT=stop_bit;
default:
TX_OUT=1;
endcase
end

endmodule