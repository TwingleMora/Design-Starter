//  31:25   24:20   19:15    14:12  11:7      6:0
// [ imm ] [ rs2 ] [ rs1 ] [  f3  ] [rd/imm] [ op ]
// [func7] [ rs2 ] [ rs1 ] [  f3  ] [ rd ]   [ op ]


//f7(5) => Instr[30]
//f3    => Instr[14:12]
//rs1   => Instr[19:15]
//rs2   => Instr[24:20]
//rd    => Instr[11:7]
//op    => Instr[6:0]

//imm[31:0] = { {20{Instr[31]}}, Instr[31]/Instr[7], Instr[30:25], Instr[24:20]/Instr[11:8], Instr[7]/0 }
//immL = { {20{Instr[31]}}, Instr[31], Instr[30:25], Instr[24:20], Instr[7] }
//immS = { {20{Instr[31]}}, Instr[31], Instr[30:25], Instr[11:8],  Instr[7] }
//immB = { {20{Instr[31]}}, Instr[7], Instr[30:25],  Instr[11:8],  0 }
//immJ   { {12{Instr[31]}}, Instr[19:2], Instr[20] ,Instr[30:21],  0 }


//add  0000000 rs2 rs1 000  rd   0110011
//sub  0100000 rs2 rs1 000  rd   0110011
//or   0000000 rs2 rs1 110  rd   0110011
//slt  0000000 rs2 rs1 010  rd   0110011
//addi imm[11:0]         rs1 000  rd   0010011
//lw   imm[11:0]         rs1 010  rd   0000011
//sw   imm[11:5]     rs2 rs1 010  imm  0100011
//beq  imm[12,10:5]     rs2 rs1 000  imm[4:1,11]  1100011 
//jal imm[20] imm[10:1] imm[11] imm[19:12]  rd   1101111



`define W 31

module ALU
(
    input             [2:0] ALUControl,
    input      signed [`W:0] SrcA,
    input      signed [`W:0] SrcB,
    output reg signed [`W:0] ALUResult,
    output            [`W:0] Zero
);

assign Zero = (ALUResult==0);

always@(*)
begin
    case(ALUControl)
    'b000:ALUResult = SrcA + SrcB;
    'b001:ALUResult = SrcA - SrcB;
    'b010:ALUResult = SrcA | SrcB;
    'b011:ALUResult = (SrcA<SrcB);
    default:ALUResult=0;
    endcase

end


endmodule

module ResultMux(
    input      [1:0] resultSrc,
    input      [`W:0] ALUResult,
    input      [`W:0] ReadData,
    input      [`W:0] PCPlus4,
    output reg [`W:0] Result
);
always @(*) begin
    case(resultSrc)
    'b00: Result = ALUResult;
    'b01: Result = ReadData;
    'b11: Result = PCPlus4;
    default: Result = ALUResult;
    endcase
end
endmodule

module ALUSrcMux(
    input             ALUSrc,
    input      [`W:0] RF_B,
    input      [`W:0] ImmExt,
    output reg [`W:0] SrcB
);
always @(*) 
begin
    if (ALUSrc)
        SrcB = ImmExt;
    else
        SrcB = RF_B;

end

endmodule

module PCSrcMux(
    input             PCSrc,
    input      [`W:0] PCPlus4,
    input      [`W:0] PCTarget,
    output reg [`W:0] PCNext
);
always @(*) 
begin
    if (PCSrc)
        PCNext = PCTarget;
    else
        PCNext = PCPlus4;

end

endmodule


module Extend (
    input       [`W:0] Instr,//[31:7]
    input       [1:0]  ImmSrc,
    output  reg signed [`W:0] ImmExt 
);

always@(*)
begin

//ImmExt = Instr;
//inst20 = {20{Instr[31]}}

case(ImmSrc)
2'b00: ImmExt= { {20{Instr[31]}}, Instr[31], Instr[30:25], Instr[24:20]};
2'b01: ImmExt= { {20{Instr[31]}}, Instr[31], Instr[30:25], Instr[11:8],  Instr[7]};
2'b10: 
begin
ImmExt= {{20{Instr[31]}}, Instr[7], Instr[30:25],  Instr[11:8], 1'b0};
end
2'b11:
begin
 ImmExt= { {12{Instr[31]}}, Instr[19:12], Instr[20] , Instr[30:21], 1'b0};
end
endcase

end

endmodule

module RegisterFile
(
input               clk,rst,
input       [4:0]   A1,A2,A3,
input       [`W:0]  WD3,
input               WE3,
output      [`W:0]  RD1,RD2
);

reg [`W:0] File [0:31];
assign RD1 = File[A1];
assign RD2 = File[A2];


integer i;
always@(*)
begin
    File[0] <= 0;
end
always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        for(i=0;i<32;i=i+1)
        begin
            File[i] <= 0;
        end
    end
    else if (WE3)
    begin
        if(A3!=0)
        File[A3] <= WD3;
    end
end
endmodule

module ProgramCounter
(
    input               clk,rst,
    input       [`W:0]  PCNext,
    output reg  [`W:0]  PC
);
always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        PC<=0;
    end
    else
    begin
        PC<=PCNext;
    end
end

endmodule

module InstrMemory
(
    input         rst,
    input  [`W:0] A,
    output [`W:0] RD
);
localparam MAX = 100 ;
reg [`W:0] InstrMemory [0:MAX-1];

assign RD = InstrMemory[A];

integer i;
always@(negedge rst)
begin
    if(!rst)
    begin
        for (i=0;i<MAX;i=i+1)
        begin
            InstrMemory[i] <= 0;
        end
    end
end


endmodule





module DataMemory
(
    input         clk, rst,
    input         WE,
    input  [`W:0] A,
    input  [`W:0] WD,
    output [`W:0] RD
);
localparam MAX = 100 ;
reg [`W:0] DataMemory  [0:MAX-1];
integer i;

assign RD = DataMemory[A];

always@(posedge clk, negedge rst)
begin
    if(!rst)
    begin
        for (i=0;i<MAX;i=i+1)
        begin
            DataMemory[i] <= 0;
        end
    end
    else if(WE)
    begin
        DataMemory[A] <=WD;
    end
end



endmodule

module ControlUnit(
input [6:0] op,
input [2:0] f3,
input       f5,
input       Zero,
output wire PCSrc,//X

output reg RegWrite,//x
output reg MemWrite,//X
output reg ALUSrc,//X
output reg [1:0] resultSrc,
output reg [1:0] ImmSrc,//X
output reg [2:0] ALUControl
);
//op
localparam rtype = 7'b0110011,
           lw    = 7'b0000011,
           sw    = 7'b0100011,
           beq   = 7'b1100011,
           addi  = 7'b0010011,
           jal   = 7'b1101111;
//aluop
localparam ADD = 2'b00,
           SUB    = 2'b01,
           RTYPE    = 2'b10;
//f3
localparam add_sub  = 3'b000,
           _or      = 3'b110,
           slt      = 3'b010;
//f7
localparam add      = 1'b0,
           sub      = 1'b1;


reg Jump;            
reg Branch;//X
reg [1:0] ALUOP;
assign PCSrc = (Zero & Branch) | Jump;
//                    0123                     012
//          RegWrite ImmSrc ALUSrc MemWrite ResultSrc Branch ALUOp Jump
//add            1       00     0       0        00       0      10     0  
//sub            1       00     0       0        00       0      10     0
//or             1       00     0       0        00       0      10     0
//slt            1       00     0       0        00       0      10     0

//lw             1       00     1       0        01       0      00     0
//sw             0       01     1       1        00       0      00     0   
//beq            0       10     0       0        00       1      01     0   

always@(*)
begin
        RegWrite= 0;
        ImmSrc= 2'b00;
        ALUSrc= 0;
        MemWrite= 0;
        resultSrc= 00;
        Branch= 0;
        ALUOP= 2'b00;
        Jump= 0;
    case(op)
    rtype:
    begin
        RegWrite= 1;
        ImmSrc= 2'b00;
        ALUSrc= 0;
        MemWrite= 0;
        resultSrc= 00;
        Branch= 0;
        ALUOP= 2'b10;
        Jump= 0;
    end
    lw:
    begin
        RegWrite= 1;
        ImmSrc= 2'b00;
        ALUSrc= 1;
        MemWrite= 0;
        resultSrc= 01;
        Branch= 0;
        ALUOP= 2'b00;
        Jump= 0;
    end
    sw:
    begin
        RegWrite= 0;
        ImmSrc= 2'b01;
        ALUSrc= 1;
        MemWrite= 1;
        resultSrc= 00;
        Branch= 0;
        ALUOP= 2'b00;
        Jump= 0;
    end
    beq:
    begin
        RegWrite= 0;
        ImmSrc= 2'b10;
        ALUSrc= 0;
        MemWrite= 0;
        resultSrc= 00;
        Branch= 1;
        ALUOP= 2'b01;
        Jump= 0;
    end
    addi:
    begin
        RegWrite= 1;
        ImmSrc= 2'b00;
        ALUSrc= 1;
        MemWrite= 0;
        resultSrc= 00;
        Branch= 0;
        ALUOP= 2'b00;
        Jump= 0;   
    end
    jal:
    begin
        RegWrite= 1;
        ImmSrc= 2'b11;
        ALUSrc= 1;
        MemWrite= 0;
        resultSrc= 11;
        Branch= 0;
        ALUOP= 2'b00;
        Jump= 1;   

    end
    endcase

    ALUControl=3'b000;
    case(ALUOP)
    ADD:ALUControl = 3'b000;
    SUB:ALUControl = 3'b001;
    RTYPE:
    begin
    case(f3)
    add_sub:
    begin
        case(f5)
        add:ALUControl = 3'b000;
        sub:ALUControl = 3'b001;
        endcase
    end
    _or:ALUControl = 3'b010;
    slt:ALUControl = 3'b011;
    endcase
    end
    endcase
end

/*
    'b000:ALUResult = SrcA + SrcB;
    'b001:ALUResult = SrcA - SrcB;
    'b010:ALUResult = SrcA | SrcB;
    'b011:ALUResult = (SrcA<SrcB);
*/

//add 0000000 rs2 rs1 000  rd   0110011
//sub 0100000 rs2 rs1 000  rd   0110011
//or  0000000 rs2 rs1 110  rd   0110011
//slt 0000000 rs2 rs1 010  rd   0110011

//addi imm         rs1 000  rd   0010011
//lw   imm         rs1 010  rd   0000011

//sw  imm     rs2 rs1 010  imm  0100011  

//beq imm     rs2 rs1 000  imm  1100011




endmodule

module RV32I (
    input clk,rst
);

//Instruction
wire[`W:0] Instr;


//Extent
wire signed [`W:0] ImmExt;






//Program Counter
wire [`W:0] PCPlus4;
wire [`W:0] PCTarget;
wire [`W:0] PCNext;
wire [`W:0] PC;



//Data Memory


wire [`W:0] ReadData;

//ALU
wire [`W:0] ALUResult;


//Register File


wire [`W:0] Result;

//------------ -------------------
wire [`W:0] SrcA;
wire [`W:0] SrcB;
wire [`W:0] RF_B;

//===============================
wire PCSrc;//X

wire RegWrite;//x
wire MemWrite;//X
wire ALUSrc;//X
wire [1:0] resultSrc;
wire [1:0] ImmSrc;//X

wire [2:0] ALUControl;
wire Zero;//X



assign PCPlus4  = PC + 4;
assign PCTarget = PC + ImmExt;


ControlUnit CU(.op(Instr[6:0]),
.f3(Instr[14:12]),
.f5(Instr[30]),
.Zero(Zero),
.PCSrc(PCSrc),//X
.ALUControl(ALUControl),
.RegWrite(RegWrite),//x
.MemWrite(MemWrite),//X
.ALUSrc(ALUSrc),//X
.resultSrc(resultSrc),
.ImmSrc(ImmSrc)//X
);

PCSrcMux pcSrcMux(.PCSrc(PCSrc), .PCPlus4(PCPlus4), .PCTarget(PCTarget), .PCNext(PCNext));

ProgramCounter programCounter (.clk(clk),.rst(rst),.PCNext(PCNext),.PC(PC));



InstrMemory IM
(
    .rst(rst),
    .A(PC),
    .RD(Instr)
);

DataMemory DM
(
    .clk(clk), .rst(rst),
    .WE(MemWrite),
    .A(ALUResult),
    .WD(RF_B),
    .RD(ReadData)
);


ALU alu(
    .ALUControl(ALUControl),//3bits
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUResult(ALUResult),
    .Zero(Zero)
);

ResultMux resultMux(
.resultSrc(resultSrc),
.ALUResult(ALUResult),
.ReadData(ReadData),
.PCPlus4(PCPlus4),
.Result(Result)
);

ALUSrcMux aluSrcMux(
    .ALUSrc(ALUSrc),
    .RF_B(RF_B),
    .ImmExt(ImmExt),
    .SrcB(SrcB)
);



Extend extend(
    .Instr(Instr[31:0]),//[31:7]
    .ImmSrc(ImmSrc),//2bits
    .ImmExt(ImmExt) 
);

RegisterFile RF
(
.clk(clk),.rst(rst),
.A1(Instr[19:15]),.A2(Instr[24:20]),.A3(Instr[11:7]),
.WD3(Result),
.WE3(RegWrite),
.RD1(SrcA),.RD2(RF_B)
);
    
endmodule


