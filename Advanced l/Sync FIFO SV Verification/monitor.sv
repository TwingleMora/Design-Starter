`include "FIFO_IF.sv"
import FIFO_coverage_pkg::*;
import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;

module Monitor(FIFO_IF IF);
FIFO_coverage fifo__coverage;
FIFO_transaction fifo_transaction;
FIFO_scoreboard fifo_scoreboard;

initial
begin
fifo_transaction = new();    
fifo__coverage = new();
fifo_scoreboard = new();
forever begin
   @(negedge IF.clk) 
   fifo_transaction.data_in  = IF.data_in;
   fifo_transaction.data_out = IF.data_out;

   fifo_transaction.rst_n = IF.rst_n;
   
   fifo_transaction.wr_en = IF.wr_en;
   fifo_transaction.rd_en = IF.rd_en;
   
   fifo_transaction.wr_ack = IF.wr_ack;

   fifo_transaction.overflow  = IF.overflow;
   fifo_transaction.underflow = IF.underflow;

   fifo_transaction.full  = IF.full;
   fifo_transaction.empty = IF.empty;

   fifo_transaction.almostfull = IF.almostfull;
   fifo_transaction.almostempty = IF.almostempty;

   fifo_transaction.underflow  = IF.underflow;
fork
    
    fifo__coverage.sample_data(fifo_transaction);
    begin
    @(posedge IF.clk)
    @(negedge IF.clk)
    fifo_scoreboard.check_data(fifo_transaction);
    end
join

end


end

endmodule
