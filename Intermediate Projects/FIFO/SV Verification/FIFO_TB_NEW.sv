// Code your testbench here
// or browse Examples
localparam WIDTH = 8;
localparam DEPTH = 32;
localparam NEG_EDGE = 1;
class Transaction;

rand logic        WrEn; 
rand logic        RdEn;
rand logic [WIDTH-1:0] DataIn;
	 logic		  Rst;


logic [WIDTH-1:0] DataOut;
logic [WIDTH-1:0] DataOutReg;
  
logic        Full; 
logic        Empty;

  constraint write
  {
    WrEn dist {1:=80,0:=0};
  };


endclass

module FIFO_TB;
int passed=0, failed =0;

 

localparam COUNTER_WIDTH = $clog2(DEPTH)+1;
localparam PTR_WIDTH = $clog2(DEPTH);

bit          clk; 
logic        rst;
logic        WrEn; 
logic        RdEn;
  logic [WIDTH-1:0] DataIn;
  logic [WIDTH-1:0] DataOut;
logic        Full; 
logic        Empty;

always #4 clk = ~clk;

  Sync_fifo_task#(.DEPTH(DEPTH), .DATA_WIDTH(WIDTH)) DUT (.clk(clk), .rst(rst), .WrEn(WrEn), .RdEn(RdEn), .DataIn(DataIn), .comb_DataOut(DataOut), .Full(Full), .Empty(Empty));


task Drive;
    Transaction t;
  t = new();

  rst = (0&&NEG_EDGE)||(1&&~NEG_EDGE);
  @(posedge clk)
  rst = !((0&&NEG_EDGE)||(1&&~NEG_EDGE));

    forever begin
        @(posedge clk)
        t.randomize();
        WrEn <= t.WrEn;
        RdEn <= t.RdEn;
        DataIn <= t.DataIn;
    end

endtask


task Monitor;
Transaction t;
t = new();
forever
begin
@(posedge clk);
t.DataIn = DataIn;
t.WrEn = WrEn;
t.RdEn = RdEn;
t.Rst  = rst;
 
@(negedge clk);
t.DataOut = DataOut;
t.Full = Full;
t.Empty = Empty;
Scoreboard(t);
end

endtask

  reg [WIDTH-1:0] mem [$];
bit ExpFull, ExpEmpty;
bit PreFull, PreEmpty;
//reg [31:0] ExpDataOut = 0;
//or
  reg [WIDTH-1:0] ExpDataOut;
  reg [WIDTH-1:0] ExpDataOutReg;
  task Scoreboard(Transaction t); 
  bit write;
  bit read;
  bit data_valid;
    
  
  data_valid  = ~t.Empty;
 
    
  write = 0;
  read = 0;
  //you can't set 
    PreFull = (mem.size() == 2**(PTR_WIDTH));
    PreEmpty = (mem.size() == 0);
    //here (as @ this point the memory size has increase or decreased)

    if((~t.Rst&& NEG_EDGE) || (t.Rst&& ~NEG_EDGE) ) begin
    mem.delete();
    ExpDataOutReg = 0;
    ExpEmpty = 1;
  end
  else begin
  begin
    if(t.WrEn)
    begin
      if(mem.size()<2**(PTR_WIDTH)) begin
        	write = 1;
        $display("Writeeee: %b", write);
      end
      
    end
     
  
    if(t.RdEn)
    begin
        if(mem.size()>0)
          begin
                ExpDataOutReg = ExpDataOut;
    			
				read = 1;
          end 
    end
    end
  end
  

    
  if(write) begin
    mem.push_back(t.DataIn);	
  end 
  if(read) begin
    mem.pop_front();
  end
    ExpDataOut = mem[0];  //whether it's read or not Expected Data is always mem[0] 

  

    ExpFull = (mem.size() == 2**(PTR_WIDTH));
    ExpEmpty = (mem.size() == 0);
  


	

    //$display("\n\n==========START============");
  	//DisplayDUT(t);
    //DisplayMEM();
      //DisplayDUT(t);
      //DisplayMEM();    

   assert(t.DataOut === ExpDataOut)
    begin
      //$display("Data Passed.");
       passed++;
    end
    else
    begin
      $error("Data Failed.");
      failed++;

      //$stop;
    end
    
    assert(t.Empty === ExpEmpty)
    begin
      //$display("Empty Passed.");
        passed++;
    end
    else
    begin
      $error("Empty Failed.");
        failed++;
      //DisplayDUT(t);
      //DisplayMEM();
      //$stop;
    end
    
    assert(t.Full === ExpFull)
    begin
      //$display("Full Passed.");
        passed++;
    end
    else
    begin
      $error("Full Failed.");
        failed++;
      //DisplayDUT(t);
      //DisplayMEM();
      //$stop;
    end
  

    //$display("\n==========END============");
endtask

  task DisplayMEM(int is_reg=1);
   $display("\nTB:");
    foreach(mem[i])
        begin
            $display("%h", mem[i]);
        end
    $display("Expected Output: %h", ExpDataOut);
    $display("Expected Output Reg: %h", ExpDataOutReg);
    //case(is_reg)
  	//	0: $display("Expected Output: %h", ExpDataOut);
    //  	1: $display("Expected Output Reg: %h", ExpDataOutReg);
    //endcase
  endtask
  

  task DisplayDUT(Transaction t);
     $display("DUT: ");
     $display("Mem Size: %d",mem.size());
     $display("Full: %b, Empty %b:", t.Full, t.Empty);
	 $display("Wr En: %b, Rd En %b:", t.WrEn, t.RdEn);
    foreach(DUT.mem[i])
    begin
      if(DUT.WrAddr[4:0] == i && DUT.RdAddr[4:0] == i)
        $display("%h <- (WrPtr) (RdPtr) [DataIn: %h | DataOut: %h]",DUT.mem[i], t.DataIn, t.DataOut);
      else if(DUT.WrAddr[4:0] == i)
        $display("%h <- (WrPtr) [DataIn: %h]",DUT.mem[i], t.DataIn);
      else if(DUT.RdAddr[4:0] == i)
        $display("%h <- (RdPtr) [DataOut: %h]",DUT.mem[i], t.DataOut);
        else 
            $display("%h", DUT.mem[i]);
    end

endtask

initial
begin
    fork
        Drive();
        Monitor();
    join_none
    #10000;
    $display("Passed: %d, Failed: %d", passed, failed);
    $stop;
end

endmodule
