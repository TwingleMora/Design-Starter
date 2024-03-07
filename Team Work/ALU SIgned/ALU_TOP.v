module ALU_TOP#(parameter WIDTH =16)(
input wire  signed [WIDTH-1:0] A,
input wire  signed [WIDTH-1:0] B,
input wire         [3:0]       ALU_FUN,
input wire                     CLK,
input wire                     RST,

output wire  signed [2*WIDTH-1:0] Arith_OUT,
output wire                       Carry_OUT,
output wire                       Arith_Flag,

output wire  signed [WIDTH-1:0] Logic_OUT,
output wire                     Logic_Flag,

output wire  signed [WIDTH-1:0] CMP_OUT,
output wire                     CMP_Flag,

output wire  signed [WIDTH-1:0] SHIFT_OUT,
output wire                     SHIFT_Flag
);
wire Arith_Enable;
wire Logic_Enable;
wire CMP_Enable;
wire SHIFT_Enable;

Decoder D
(
.ALU_FUN(ALU_FUN[3:2]),
.Arith_Enable(Arith_Enable),
.Logic_Enable(Logic_Enable),
.CMP_Enable(CMP_Enable),
.SHIFT_Enable(SHIFT_Enable)
);

ARITHMETIC_UNIT #(.WIDTH(WIDTH)) AU
(
.A(A),
.B(B),
.ALU_FUN(ALU_FUN[1:0]),
.CLK(CLK),
.RST(RST),
.Arith_Enable(Arith_Enable),
.Arith_OUT(Arith_OUT),
.Carry_OUT(Carry_OUT),
.Arith_Flag(Arith_Flag)
);

Logic_UNIT #(.WIDTH(WIDTH)) LU
(
.A(A),
.B(B),
.ALU_FUN(ALU_FUN[1:0]),
.CLK(CLK),
.RST(RST),
.Logic_Enable(Logic_Enable),
.Logic_OUT(Logic_OUT),
.Logic_Flag(Logic_Flag)
);

SHIFT_UNIT #(.WIDTH(WIDTH)) SU
(
.A(A),
.B(B),
.ALU_FUN(ALU_FUN[1:0]),
.CLK(CLK),
.RST(RST),
.SHIFT_Enable(SHIFT_Enable),
.SHIFT_OUT(SHIFT_OUT),
.SHIFT_Flag(SHIFT_Flag)
);

CMP_UNIT#(.WIDTH(WIDTH)) CU
(
.A(A),
.B(B),
.ALU_FUN(ALU_FUN[1:0]),
.CLK(CLK),
.RST(RST),
.CMP_Enable(CMP_Enable),
.CMP_OUT(CMP_OUT),
.CMP_Flag(CMP_Flag)
);

endmodule
