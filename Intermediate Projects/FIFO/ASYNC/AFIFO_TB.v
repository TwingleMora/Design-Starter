module FIFO_TB;
parameter WIDTH=4, DEPTH=8, ADDRWIDTH=4;
reg clk1,clk2,rst1,rst2;    
reg writeEn,readEn; 
reg [WIDTH-1:0] writeData;
wire full,empty;
wire [WIDTH-1:0] readData;
wire [ADDRWIDTH-1:0] writePtr,readPtr;//extra bit
/*
FIFO_TOP #(.WIDTH(WIDTH), .DEPTH(DEPTH),.ADDRWIDTH(ADDRWIDTH)) fifo 
(
.clk(clk),.rst(rst),    
.writeEn(writeEn),.readEn(readEn), 
.writeData(writeData),
.full(full),.empty(empty),.readData(readData),
.writePtr(writePtr),.readPtr(readPtr)
);*/
AFIFO #(.WIDTH(WIDTH), .DEPTH(DEPTH),.ADDRWIDTH(ADDRWIDTH-1)) fifo 
(
.clk1(clk1),.rst1(rst1),.clk2(clk2),.rst2(rst2),    
.wrEn(writeEn),.rdEn(readEn), 
.wrIn(writeData),
.full(full),.empty(empty),.rdOut(readData),
.wrPtr(writePtr),.rdPtr(readPtr)
);
//Test Write Only
//Test Read Only
//Test The Two Together

task initialize;
begin
clk1 =0;//clk =1 will make posedge 
rst1 =0;
clk2 =0;
rst2 =0;
#10 rst1 =1;
rst2 =1;
writeEn =0;
readEn=0;
writeData=0;
end
endtask
reg [WIDTH-1:0]in_data[DEPTH-1:0];// = {'h1,'h2,'h3,'h4,'h5,'h6,'h7,'hF};
task display;
integer counter2;
begin
for(counter2 =0;counter2<DEPTH;counter2=counter2+1)
    begin
        if(writePtr[ADDRWIDTH-2:0]==counter2&&readPtr[ADDRWIDTH-2:0]==counter2)
    $display("Memory[%0d]: %0h (writePtr is Here!) (readPtr is Here!)",counter2,fifo.memory[counter2]);
        else if((writePtr[ADDRWIDTH-2:0]==counter2&&readPtr[ADDRWIDTH-2:0]!=counter2))
    $display("Memory[%0d]: %0h (writePtr is Here!) ",counter2,fifo.memory[counter2]);
        else if((writePtr[ADDRWIDTH-2:0]!=counter2&&readPtr[ADDRWIDTH-2:0]==counter2))
    $display("Memory[%0d]: %0h                     (readPtr is Here!) ",counter2,fifo.memory[counter2]);
        else 
    $display("Memory[%0d]: %0h",counter2,fifo.memory[counter2]);
    end
    $display("Full: %b ,Empty: %b",full,empty);
    $display("\n\n");
end
endtask

task write;
input integer display_bool;
input integer writing_times;
integer counter;
begin
    counter=0;

for (counter=0;counter<writing_times;counter=counter+1)
begin
   
    writeData = in_data[counter%8];
    $display("writing %h to address(%0d)[writePtr] ",writeData,writePtr[ADDRWIDTH-2:0]);
    $display("waiting for clock pos edge...");
    #10;
    if(display_bool)
    display;
    $display("\n\n");
end
end
endtask

task read;
input integer display_bool;
input integer writing_times;
integer counter,counter2;
begin
    counter=0;counter2=0;
for (counter=0;counter<writing_times;counter=counter+1)
begin
   
    $display("accessing address(%0d)[readPtr] in fifo",readPtr[ADDRWIDTH-2:0]);
    $display("waiting for clock pos edge to copy the read value to Read Register...");
    #10;
    $display("Read Register: %0h",readData);
    if(display_bool)
    display;
    $display("\n\n");
end

end
endtask
task read_write;
input integer display_bool;
input integer writing_times;
integer counter;
begin
    counter=0;

for (counter=0;counter<writing_times;counter=counter+1)
begin
   
    writeData = in_data[counter%8];
     $display("accessing address(%0d)[readPtr] in fifo",readPtr[ADDRWIDTH-2:0]);
    $display("writing %h to address(%0d)[writePtr] ",writeData,writePtr[ADDRWIDTH-2:0]);
    $display("waiting for clock pos edge...");
    #10;
     $display("Read Register: %0h",readData);
    if(display_bool)
    display;
    $display("\n\n");
end
end
endtask
always #5 clk1=~clk1;
always #10 clk2=~clk2;
initial
begin
    initialize;
in_data[0] ='h1;
in_data[1]='h2;
in_data[2]='h3;
in_data[3]='h4;
in_data[4]='h5;
in_data[5]='h6;
in_data[6]='h7;
in_data[7]='hF;

$display("writing only");
 //   @(negedge clk1)
    readEn=0;
    writeEn=1;
    write(1,DEPTH);
$display("reading only");
// @(negedge clk)
    readEn=1;
    writeEn=0;
    read(1,DEPTH*2);
$display("read and write");
//  @(negedge clk)
    writeEn=1;
    readEn=0;

in_data[0] ='hf;
in_data[1]='he;
in_data[2]='hd;
in_data[3]='hc;
in_data[4]='hb;
in_data[5]='ha;
in_data[6]='h9;
in_data[7]='h7;

$display("Start Writing for 2 times");
    write(1,2);
    readEn =1;
    read_write(1,DEPTH*3);
$stop; 
end
endmodule