module Logic_UNIT #(parameter WIDTH=16)
(
input wire  signed [WIDTH-1:0] A,
input wire  signed [WIDTH-1:0] B,
input wire         [1:0]       ALU_FUN,
input wire                     CLK,
input wire                     RST,
input wire                     Logic_Enable,

output reg  signed [WIDTH-1:0] Logic_OUT,
output reg                     Logic_Flag
);
reg signed [WIDTH-1:0] Logic_OUT_COMB;
wire                   Logic_Flag_COMB;

assign Logic_Flag_COMB = Logic_Enable;

always@(posedge CLK or negedge RST)
begin
 if(!RST)
  begin
     Logic_OUT<=0;
     Logic_Flag<=0;
  end
 else
  begin
     Logic_OUT<=Logic_OUT_COMB;
     Logic_Flag<=Logic_Flag_COMB;
  end
end

always@(*)
begin
  Logic_OUT_COMB=0;
 if(Logic_Enable)
  begin
    case(ALU_FUN)
     2'b00:
      begin
              Logic_OUT_COMB = A&B;
      end
     2'b01:
      begin
             
              Logic_OUT_COMB = A|B;
      end
     2'b10:
      begin
              Logic_OUT_COMB = ~(A&B);// in tb for nor {~1'b0,1010};
      end
     2'b11:
      begin
              Logic_OUT_COMB = ~(A|B);
      end
    endcase
  end
  
end
endmodule
