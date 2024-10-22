`define W 32
module tb;
reg clk,rst;

always #5 clk = ~clk;
localparam INC = 4;
RV32I rv32i(.clk(clk),.rst(rst));
reg [`W:0] assembly [0:100];

integer i;
task automatic load_program(input string program_name);
    string file_name;


    file_name = {program_name,".txt"};
    
    $readmemh(file_name, assembly);
    
    @(negedge clk)
    rst=0;
    #1;
    rst=1;
    
    $display("\nLoading Program...");
    for (i=0;i<100;i=i+1)
    begin
        if(assembly[i]==0)
        break;

        rv32i.IM.InstrMemory[i*INC] = assembly[i];
    end
    $display("Program Name: %s",program_name);
    
    forever
    begin    
        @(negedge clk);
        if(rv32i.PC==8)
        begin
            $display("Operand A: %d, Operand B: %d",rv32i.RF.File[1],rv32i.RF.File[2]);
            
        end
        if(rv32i.RF.File[7]==1)
        begin
            $display("Result(x6) = %d",rv32i.RF.File[6]);
            break;
        end
    end
    $display("Quitting Program...\n");
    #50;

endtask

initial begin
clk=0;

load_program("multiplier1");
load_program("multiplier2");
load_program("multiplier3");

load_program("divider1");
load_program("divider2");
load_program("divider3");

    
#100
$stop;


end


endmodule