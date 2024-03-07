module ALU_16bit(
input wire  [15:0]  A,B,
input wire  [3:0]   ALU_FUN,
input wire          CLK,
output  reg [15:0]  ALU_OUT,
output  reg         Arith_Flag,
output  reg         Logic_Flag,
output  reg         CMP_Flag,
output  reg         Shift_Flag
);
reg  [15:0] ALU_OUT_C;
reg         Arith_Flag_C;
reg         Logic_Flag_C;
reg         CMP_Flag_C;
reg         Shift_Flag_C;
always@(posedge CLK)
begin
        Arith_Flag<=Arith_Flag_C;
        Logic_Flag<=Logic_Flag_C;
        CMP_Flag<=CMP_Flag_C;
        Shift_Flag<=Shift_Flag_C;
        ALU_OUT<=ALU_OUT_C;
end
always@(*)
begin
  Arith_Flag_C=1'b0;
  Logic_Flag_C=1'b0;
  CMP_Flag_C=1'b0;
  Shift_Flag_C=1'b0;
  //ALU_OUT= 1'b0;
  case(ALU_FUN)
    4'b0000:
      begin
        ALU_OUT_C= A+B;
        Arith_Flag=1'b1;
      end
     4'b0001:
      begin
        ALU_OUT_C= A-B;
        Arith_Flag=1'b1;
      end
     4'b0010:
      begin
        ALU_OUT_C= A*B;
        Arith_Flag=1'b1;
      end
     4'b0011:
      begin
        ALU_OUT_C= A/B;
        Arith_Flag=1'b1;
      end
     4'b0100:
      begin
        ALU_OUT_C= A&B;
        Logic_Flag=1'b1;
      end
     4'b0101:
      begin
        ALU_OUT_C= A|B;
        Logic_Flag=1'b1;
      end
     4'b0110:
      begin
        ALU_OUT_C= ~(A&B);
        Logic_Flag=1'b1;
      end
     4'b0111:
      begin
        ALU_OUT_C= ~(A|B);
        Logic_Flag=1'b1;
      end
     4'b1000:
      begin
        ALU_OUT_C= A^B;
        Logic_Flag=1'b1;
      end
     4'b1001:
      begin
        ALU_OUT_C= ~(A^B);
        Logic_Flag=1'b1;
      end
     4'b1010:
      begin
        ALU_OUT_C= (A==B)?1:0;
        CMP_Flag_C=1'b1;
      end
     4'b1011:
      begin
        ALU_OUT_C= (A>B)?2:0;
        CMP_Flag_C=1'b1;
      end
     4'b1100:
      begin
        ALU_OUT_C= (A<B)?3:0;
        CMP_Flag_C=1'b1;
      end
     4'b1101:
      begin
        ALU_OUT_C= A>>1;
        Shift_Flag_C=1'b1;
      end
     4'b1110:
      begin
        ALU_OUT_C= A<<1;
        Shift_Flag_C=1'b1;
      end
     4'b1111:
      begin
        Arith_Flag_C=Arith_Flag;
        Logic_Flag_C=Logic_Flag;
        CMP_Flag_C=CMP_Flag;
        Shift_Flag_C=Shift_Flag;
        ALU_OUT_C= ALU_OUT;
      end
     endcase
end

endmodule
