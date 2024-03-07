module RAM_TB;
parameter ADDR_WIDTH=4,
          MEMORY_DEPTH=8,
          MEM_WIDTH=16;

    reg                   WrEn;
    reg                   RdEn;
    reg                   Clk;
    reg                   Rst;
    reg  [ADDR_WIDTH-1:0]              Address;
    reg  [MEM_WIDTH-1:0]          	   WrData;  
    wire [MEM_WIDTH-1:0]               RdData;
    
RAM#
(
      	   .ADDR_WIDTH(ADDR_WIDTH),
          .MEMORY_DEPTH(MEMORY_DEPTH),
          .MEM_WIDTH(MEM_WIDTH)
)
RAM_0
(

    .WrEn(WrEn),
    .RdEn(RdEn),
    .Clk(Clk),
    .Rst(Rst),
    .Address(Address),
    .WrData(WrData),  
    .RdData(RdData)

);
always #5 Clk =~Clk;

initial 
begin
Clk=1;
Rst=1;
RdEn=0;
#2
Rst=0;
ADDR_WIDTH=5;
#2
Rst=1;
Address = 0;
WrEn    = 1;
WrData  = 5;
#11
$display("Data %b has been written in address[%h], {WrEn,RdEn}={%b,%b}",WrData,Address,WrEn,RdEn);
Address=2;
WrEn=1;
WrData=10;
#15
$display("Data %b has been written in address[%h], {WrEn,RdEn}={%b,%b}",WrData,Address,WrEn,RdEn);
Address=3;
WrEn=1;
WrData=25;
#15
$display("Data %b has been written in address[%h], {WrEn,RdEn}={%b,%b}",WrData,Address,WrEn,RdEn);
Address=0;
WrEn=0;
RdEn=1;
#15
$display("The data stored in address[%h] Is %b, {WrEn,RdEn}={%b,%b}",Address,RdData,WrEn,RdEn);
Address=1;
#15
$display("The data stored in address[%h] Is %b, {WrEn,RdEn}={%b,%b}",Address,RdData,WrEn,RdEn);
Address=2;
#15
$display("The data stored in address[%h] Is %b, {WrEn,RdEn}={%b,%b}",Address,RdData,WrEn,RdEn);
Address=3;
#15
$display("The data stored in address[%h] Is %b, {WrEn,RdEn}={%b,%b}",Address,RdData,WrEn,RdEn);
$stop;


end
endmodule
