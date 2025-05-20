interface FIFO_IF(input bit clk); 
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    
    logic [FIFO_WIDTH-1:0] data_in;
    logic rst_n;
    logic wr_en, rd_en;


    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow; 
    

    
endinterface //

