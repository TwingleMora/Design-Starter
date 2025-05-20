package FIFO_coverage_pkg;
import FIFO_transaction_pkg::*;

class FIFO_coverage;
FIFO_transaction F_cvg_txn;

//virtual FIFO_IF F_cvg_txn;
/*
 logic wr_ack, overflow;
 logic full, empty, almostfull, almostempty, underflow; 
*/
covergroup cg;
option.per_instance = 1;
wr_en_cp: coverpoint F_cvg_txn.wr_en;
rd_en_cp: coverpoint F_cvg_txn.rd_en;

wr_ack_cp: coverpoint F_cvg_txn.wr_ack;

overflow_cp: coverpoint F_cvg_txn.overflow;
underflow_cp: coverpoint F_cvg_txn.underflow;

full_cp: coverpoint F_cvg_txn.full;
empty_cp: coverpoint F_cvg_txn.empty;

almostfull_cp: coverpoint F_cvg_txn.almostfull;
almostempty_cp: coverpoint F_cvg_txn.almostempty;

wr__rd__ack: cross wr_en_cp,rd_en_cp,wr_ack_cp;

wr__rd__overflow:cross wr_en_cp,rd_en_cp,overflow_cp;
wr__rd__underflow:cross wr_en_cp,rd_en_cp,underflow_cp;

wr__rd__full:cross wr_en_cp,rd_en_cp,full_cp;
wr__rd__empty:cross wr_en_cp,rd_en_cp,empty_cp;


wr__rd__almostfull:cross wr_en_cp,rd_en_cp,almostfull_cp;
wr__rd__almostempty:cross wr_en_cp,rd_en_cp,almostempty_cp;


endgroup

function new();
cg= new();
endfunction

function void sample_data(FIFO_transaction F_txn);
F_cvg_txn = F_txn;
cg.sample();
endfunction

function void stop();
cg.stop();
endfunction


endclass


endpackage