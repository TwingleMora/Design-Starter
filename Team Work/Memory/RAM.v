module RAM#(
parameter ADDR_WIDTH=4,
          MEMORY_DEPTH=8,
          MEM_WIDTH=16
          )
(

    input  wire                   WrEn,
    input  wire                   RdEn,
    input  wire                   Clk,
    input  wire                   Rst,
    input  wire  [ADDR_WIDTH-1:0]            Address,
    input  wire  [MEM_WIDTH-1:0]          	WrData,  
    output reg   [MEM_WIDTH-1:0]             RdData

);
  integer x;

  // 2D Array
  reg [MEM_WIDTH-1:0] memory [MEMORY_DEPTH-1:0];        

  always @(posedge Clk or negedge Rst) 
	  begin
        if(!Rst)
        begin
          for (x =0;x<MEMORY_DEPTH;x=x+1)
            begin
              memory[x]<=0;
            end
        end
        else if (WrEn) 
		  begin
              memory[Address] <= WrData;
		  end
        else if (RdEn)
          begin
              RdData <= memory[Address]; 
          end
       end

endmodule