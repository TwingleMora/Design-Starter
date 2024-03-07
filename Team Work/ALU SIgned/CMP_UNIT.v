module CMP_UNIT#(parameter WIDTH=16)
(
input wire  signed [WIDTH-1:0] A,
input wire  signed [WIDTH-1:0] B,
input wire         [1:0]       ALU_FUN,
input wire                     CLK,
input wire                     RST,
input wire                     CMP_Enable,

output reg  signed [WIDTH-1:0]   CMP_OUT,
output reg                       CMP_Flag
);
reg  signed [WIDTH-1:0] CMP_OUT_COMB;
wire                    CMP_Flag_COMB;
assign CMP_Flag_COMB =  CMP_Enable;

always@(posedge CLK or negedge RST)
begin
 if(!RST)
  begin
     CMP_OUT<=0;
     CMP_Flag<=0;
  end
 else
  begin
     CMP_OUT<=CMP_OUT_COMB;
     CMP_Flag<=CMP_Flag_COMB;
  end
end

always@(*)
begin
  CMP_OUT_COMB=0;
 if(CMP_Enable)
  begin
    case(ALU_FUN)
     2'b00:
      begin
            //NOP
      end
     2'b01:
      begin
              if(A==B)
              CMP_OUT_COMB = 1;
      end
     2'b10:
      begin
              if(A>B)
              CMP_OUT_COMB = 2;
      end
     2'b11:
      begin
              if(A<B)
              CMP_OUT_COMB = 3;
      end
    endcase
  end
  
end
endmodule


