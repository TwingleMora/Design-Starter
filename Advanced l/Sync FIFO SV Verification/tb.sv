`include "FIFO_IF.sv"
import FIFO_transaction_pkg::*;
module tb;
bit clk;
FIFO_transaction fifo_transaction;

FIFO_IF IF (clk);

FIFO DUT(
    .data_in(IF.data_in), .wr_en(IF.wr_en), .rd_en(IF.rd_en),
    .clk(IF.clk), .rst_n(IF.rst_n), .full(IF.full),
    .empty(IF.empty), .almostfull(IF.almostfull), .almostempty(IF.almostempty),
    .wr_ack(IF.wr_ack), .overflow(IF.overflow), .underflow(IF.underflow),
    .data_out(IF.data_out)
 );

Monitor moniotr(IF);

always #5 clk = ~clk;

initial
begin
clk = 0;

fifo_transaction = new();

fork
    
forever 
begin

@(negedge clk)
   fifo_transaction.randomize();

   IF.data_in =   fifo_transaction.data_in ;
   IF.rst_n   =   fifo_transaction.rst_n ;
   IF.wr_en   =   fifo_transaction.wr_en ;
   IF.rd_en   =   fifo_transaction.rd_en ;
   
  


end

join_none
@(negedge clk)
    IF.rst_n = 0;
@(negedge clk)
    IF.rst_n = 1;
#30000;
moniotr.fifo__coverage.stop();
$stop;
end



endmodule
