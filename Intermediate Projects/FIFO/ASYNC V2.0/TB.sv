class Transaction;

rand logic [31:0] DataIn;
rand logic        WrEn;
rand logic        WrRst;

rand logic        RdEn;
rand logic        RdRst;

logic Full, Empty;
logic OverFlow, UnderFlow;
logic [31:0] DataOut;




function void print();
    $display("DataIn: %d, WrEn: %b, DataOut: %d, RdEn: %b, Full: %b, Empty: %b, OverFlow: %b, UnderFlow: %b",DataIn, WrEn, DataOut, RdEn, Full, Empty, OverFlow, UnderFlow);
endfunction
endclass



module TB;
localparam MAX = 16;
bit          WrClk;
bit          RdClk;

logic [31:0] DataIn;
logic        WrEn;
logic        WrRst;

logic [31:0] DataOut;
logic        RdEn;
logic        RdRst;

logic Full, Empty;
logic OverFlow; //write valid (0: valid, 1: invalid)
logic UnderFlow;//read valid (0: valid, 1: invalid)

//Clock Generation
always #5 WrClk = ~WrClk;
always #10 RdClk = ~RdClk;


//DUT
TOP DUT (
    .WrClk(WrClk),
    .RdClk(RdClk),
    .DataIn(DataIn),
    .WrEn(WrEn),
    .WrRst(WrRst),
    .DataOut(DataOut),
    .RdEn(RdEn),
    .RdRst(RdRst),
    .Full(Full),
    .Empty(Empty), 
    .OverFlow(OverFlow),
    .UnderFlow(UnderFlow)
    );


task WrDrive(bit auto = 1, bit WrEnP = 0);
Transaction t;
t = new();
DataIn <= 0;
WrEn <= 0;
WrRst <= 0;
#1;

forever 
begin
    @(posedge WrClk);
    if(auto)
    begin
        t.randomize();
        WrEn <= t.WrEn;
    end
    else
    begin
        WrEn <= WrEnP;
    end
    DataIn <= t.DataIn;
    WrRst <= 1;

    if($time >= 250)
    begin
        auto = 0;
        WrEnP = 0;
    end
end

endtask

task RdDrive;
Transaction t;
t = new();
//DataIn <= 0;
RdEn  <= 0;
RdRst <= 0;
#1;
forever 
begin    
    @(posedge RdClk);
    t.randomize();
    //DataIn <= t.DataIn;
    RdRst <= 1;
    RdEn <= t.RdEn;
end
endtask

task WrMonitor;
Transaction t;
t = new();
forever
begin
    @(posedge WrClk)
    t.DataIn = DataIn;
    t.WrEn = WrEn;
    t.WrRst = WrRst;
    @(negedge WrClk)
    Scoreboard(t, 1'b1);
end
endtask

task RdMonitor;
Transaction t;
t = new();
forever
begin
    @(posedge RdClk)
    t.RdEn = RdEn;
    t.RdRst = RdRst;
    @(negedge RdClk)
    t.DataOut = DataOut;
    Scoreboard(t, 1'b0);
end
endtask


reg [31:0] mem [$];
task Scoreboard(Transaction t, bit W_R);
    logic [31:0] ExpDataOut;
    logic ExpFull, ExpEmpty, ExpOverFlow, ExpUnderFlow;
    ExpFull = 0;
    ExpEmpty = 0;

    ExpOverFlow =0;
    ExpUnderFlow = 0;

    case (W_R)
    1'b1:
    begin
    
        if(t.WrEn==1'b1)
        begin
            if(mem.size()<MAX)
            begin
                mem.push_back(t.DataIn);
            end
            else //>= MAX
            begin
                ExpOverFlow = 1'b1;
            end
        end

    end
    1'b0:
    begin
        if(t.RdEn==1'b1)
        begin
            if(mem.size()>0)
            begin
                ExpDataOut = mem.pop_front();
            end
            else //<= 0
            begin
                ExpUnderFlow = 1'b1;
            end
        end
    end

    endcase

    if(mem.size()==MAX)
    begin
        ExpFull = 1'b1;
    end
    if(mem.size() == 0)
    begin
        ExpEmpty = 1'b1;
    end 

    $display("===========Start==========");
    if(Full === ExpFull)
        $display("Full is Succeeded");
    else
    begin
        $error("Full is Failed");
        //$stop;
    end
    if(Empty === ExpEmpty)
        $display("Empty is Succeeded");
    else
    begin
        $error("Empty is Failed");
        //$stop;
    end
    if(DataOut === ExpDataOut)
        $display("DataOut is Succeeded");
    else
    begin
        $error("DataOut is Failed");
        $stop;
    end
    $display("Exp Memory");
    print2();

    $display("\nOriginal Memory");
    print();
    $display("===========STOP==========\n");
endtask
task print2();
foreach(mem[i])
begin
    $display("%h", mem[i]);
end
endtask

task print();
foreach(DUT.mem[i])
begin
    if(DUT.WrAddr == i && DUT.RdAddr == i)
      $display("%h <- (WrPtr) (RdPtr) [Output: %h] | [Data In: %h]", DUT.mem[i], DataOut, DataIn);
    else if(DUT.WrAddr == i)
        $display("%h <- (WrPtr) [Data In: %h]", DUT.mem[i], DataIn);
    else if(DUT.RdAddr == i)
        $display("%h <- (RdPtr) [Output: %h]", DUT.mem[i], DataOut);
    else
        $display("%h", DUT.mem[i]);
end
$display("Full: %b, Empty: %b",Full, Empty);
$display("WrEn: %b, RdEn: %b",WrEn, RdEn);
endtask

initial 
begin
    fork
        
        WrDrive();
        
        RdDrive();

        WrMonitor();
        RdMonitor();

    join_none
    #600;
    $error("finished");
    $stop;


end



endmodule
