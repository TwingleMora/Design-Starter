module MUX
(
 input  wire [2:0] selector,
 input  wire       start,
 input  wire       data,
 input  wire       parity,
 input  wire       stop,
 input  wire       idle,
 output reg        tx_out
 );
localparam IDLE   = 0,
           START  = 1,
           DATA   = 2,
           PARITY = 3,
           STOP   = 4;
           
always@(*)
begin
    case(selector)
    IDLE:
    tx_out=idle;
    START:
    tx_out=start;
    DATA:
    tx_out=data;
    PARITY:
    tx_out=parity;
    STOP:
    tx_out=stop;
    default:
    tx_out=idle;
    endcase
end

endmodule