module Decoder
(
input wire         [1:0]       ALU_FUN,

output wire                       Arith_Enable,
output wire                       Logic_Enable,
output wire                       CMP_Enable,
output wire                       SHIFT_Enable
);
reg [3:0]enables ;
assign  Arith_Enable= enables[3];
assign  Logic_Enable= enables[2];
assign  CMP_Enable= enables[1];
assign  SHIFT_Enable= enables[0];


always@(*)
begin
  case (ALU_FUN)
    2'b00: enables=8;
    2'b01: enables=4;
    2'b10: enables=2;
    2'b11: enables=1;
  endcase
end
endmodule

