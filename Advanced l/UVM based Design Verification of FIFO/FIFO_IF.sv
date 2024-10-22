interface FIFO_IF(input bit clk); 
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    
    logic [FIFO_WIDTH-1:0] data_in;
    logic rst_n;
    logic wr_en, rd_en;


    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow; 
    
   // modport TB (input clk, output data_in, output rst_n, output wr_en, output rd_en);
    //modport Monitor (input clk, input rst_n, input data_in, input wr_en, input rd_en, input data_out, input wr_ack, input overflow, input full, input empty, input almostfull, input almostempty, input underflow);
    modport DUT (input clk, input rst_n, input data_in, input wr_en, input rd_en, output data_out, wr_ack,  overflow,  full,  empty,  almostfull,  almostempty, underflow);

    
endinterface //

