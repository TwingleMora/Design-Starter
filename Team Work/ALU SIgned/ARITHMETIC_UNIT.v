module ARITHMETIC_UNIT #(parameter WIDTH=16)
(
input wire  signed [WIDTH-1:0] A,
input wire  signed [WIDTH-1:0] B,
input wire         [1:0]       ALU_FUN,
input wire                     CLK,
input wire                     RST,
input wire                     Arith_Enable,

output reg  signed [2*WIDTH-1:0] Arith_OUT,
output reg                       Carry_OUT,
output reg                       Arith_Flag
);
reg  signed [2*WIDTH-1:0] Arith_OUT_COMB;
wire                      Arith_Flag_COMB;
reg                       Carry_OUT_COMB;


assign Arith_Flag_COMB = Arith_Enable;

always@(posedge CLK or negedge RST)
begin
 if(!RST)
   begin
     Arith_OUT<=0;
     Carry_OUT<=0;
     Arith_Flag<=0;
   end
  else
    begin
     Arith_OUT<=Arith_OUT_COMB;
     Carry_OUT<=Carry_OUT_COMB;
     Arith_Flag<=Arith_Flag_COMB;
    end
end

always@(*)
begin
  //Arith_OUT_COMB=0;
  
 if(Arith_Enable)
  begin
   
    case(ALU_FUN)
     2'b00:
      begin
         //Arith_OUT_COMB[WIDTH:0] = A+B;
           Arith_OUT_COMB = A+B;
         //Carry_OUT_COMB = |(Arith_OUT_COMB[2*WIDTH-1:WIDTH]);
           Carry_OUT_COMB = Arith_OUT_COMB[WIDTH];
      end
     2'b01:
      begin
           Arith_OUT_COMB = A-B;
       //  Arith_OUT_COMB[WIDTH:0] = A-B;
       //  Carry_OUT_COMB = |(Arith_OUT_COMB[2*WIDTH-1:WIDTH]);
           Carry_OUT_COMB = Arith_OUT_COMB[WIDTH];
      end
     2'b10:
      begin
       	  Arith_OUT_COMB = A*B;
           Carry_OUT_COMB = |(Arith_OUT_COMB[2*WIDTH-1:WIDTH]);
      end
     2'b11:
      begin
           Arith_OUT_COMB = A/B;
           Carry_OUT_COMB=0;
          //Arith_OUT_COMB[WIDTH-1:0] = A/B;
          //Carry_OUT_COMB = |(Arith_OUT_COMB[2*WIDTH-1:WIDTH]);
      end
    endcase
  end
  else
    begin
      
      
    end
end


endmodule

