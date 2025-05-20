module SVA(FIFO_IF.DUT IF);

a_wr_ack:assert property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.wr_en && (!IF.full)) |=> IF.wr_ack );
c_wr_ack:cover property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.wr_en && (!IF.full)) |=> IF.wr_ack );

a_overflow:assert property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.wr_en && IF.full) |=> IF.overflow );
c_overflow:cover property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.wr_en && IF.full) |=> IF.overflow );

a_underflow:assert property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.rd_en && IF.empty) |=> IF.underflow );
c_underflow:cover property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.rd_en && IF.empty) |=> IF.underflow );
endmodule