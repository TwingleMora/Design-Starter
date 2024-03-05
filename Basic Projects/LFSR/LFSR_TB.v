module LFSR_TB;
    reg clock,reset,out_enable,enable;
    reg [7:0] Seed;
    wire [7:0] LFSR;
    wire Valid,OUT;

    reg [7:0] in_data [0:4];
    reg [7:0] exp_data [0:4];
    integer i=0;
task read_data;
begin 
 $readmemb("Seeds_b.txt",in_data);
 $readmemb("Expec_Out_b.txt",exp_data);
end
endtask

task initialize_data;
begin
 reset  = 1;
 clock = 0;
 out_enable = 0;
 enable = 0;
end
endtask

task reset_data(input integer i);
begin  
$display("Reseting Data\n");
$display("Seed: %b",Seed);
$display("LFSR: %b\n",LFSR);
    reset  = 0;
    Seed   = in_data[i];
    #4   // test bench is cycle or chain the first delay is #4 the last delay is #1 the period is #10    
    reset  = 1;
$display("Seed: %b",Seed);
$display("LFSR: %b\n",LFSR);
end
endtask



task enable_lfsr_10(input integer i);
begin
$display("Enabling LFSR\n");
$display("Enable: %b\n",enable);
reset_data(i);
@(negedge clock)enable=1;
$display("Enable: %b\n",enable);
$display("LFSR: %b\n",LFSR);
repeat(10) @(posedge clock) #1 $display("Clock: %0t, LFSR: %b\n",$time,LFSR);
end
endtask

task test_all_cases;
input integer i;
integer x;
integer success;
begin
//i=0;
x=0;
success=1;
//Do Oper
enable_lfsr_10(i);
if(LFSR == exp_data[i])
$display("LFSR %0d Success",i);
else
$display("LFSR %0d Failed",i);

$display("time: %0t, OUT: %b, exp_data[%0d][%0d]: %b, Valid: %b\n",$time,OUT,i,x,exp_data[i][x],Valid);
@(negedge clock)
enable=0;//(low) // time x
//End
out_enable=1;// same time x

//check out
for(x=0;x<8;x=x+1)
    begin :for_block
            
        @(posedge clock) #1 $display("time: %0t, OUT: %b, exp_data[%0d][%0d]: %b, Valid: %b",$time,OUT,i,x,exp_data[i][x],Valid);
        if(OUT!=exp_data[i][x])
         begin
            success=0;
            //disable for_block;
         end
            //if(exp_data[i][x]==OUT)    
    end
    if(success)
    $display("LFSR Out %0d Success",i);
    else
    $display("LFSR Out %0d Failed",i);
    @(negedge clock)
    //enable=0;(already low)
    out_enable=0;
end

endtask

LFSR _LFSR (
    .clock(clock),
    .reset(reset),
    .out_enable(out_enable),
    .enable(enable),
    .Seed(Seed),
    .LFSR(LFSR),
    .Valid(Valid),
    .OUT(OUT)
);
always #5 clock=~clock;
initial
begin
read_data;
initialize_data;
for(i=0;i<8;i=i+1)
begin
test_all_cases(i);
end
$stop;
end

endmodule
