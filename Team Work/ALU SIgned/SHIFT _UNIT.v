// Write your modules here!
module SHIFT_UNIT#(parameter WIDTH=4)
(
input wire  signed [WIDTH-1:0] A,
input wire  signed [WIDTH-1:0] B,
input wire         [1:0]       ALU_FUN,
input wire                     CLK,
input wire                     RST,
input wire                     SHIFT_Enable,

output reg  signed [WIDTH-1:0] SHIFT_OUT,
output reg                       SHIFT_Flag
);
reg  signed [WIDTH-1:0] SHIFT_OUT_COMB;
wire                     SHIFT_Flag_COMB;
assign SHIFT_Flag_COMB = SHIFT_Enable;

always@(posedge CLK or negedge RST)
begin
 if(!RST)
  begin
     SHIFT_OUT<=0;
     SHIFT_Flag<=0;
  end
 else
  begin
     SHIFT_OUT<=SHIFT_OUT_COMB;
     SHIFT_Flag<=SHIFT_Flag_COMB;
  end
end

always@(*)
begin
  SHIFT_OUT_COMB=0;
 if(SHIFT_Enable)
  begin
    case(ALU_FUN)
     2'b00:
      begin
            SHIFT_OUT_COMB=A>>>1;
      end
     2'b01:
      begin
            SHIFT_OUT_COMB=A<<<1;
      end
     2'b10:
      begin
              SHIFT_OUT_COMB=B>>>1;
      end
     2'b11:
      begin
              SHIFT_OUT_COMB=B<<<1;
      end
    endcase
  end
 
end
endmodule



