package coverage_pkg;
`include "uvm_macros.svh"
import sequence_item_pkg::*;
import uvm_pkg::*;
class Coverage extends uvm_component;
`uvm_component_utils(Coverage)
uvm_analysis_export #(Sequence_Item) cov_export;
uvm_tlm_analysis_fifo #(Sequence_Item) cov_fifo;
Sequence_Item F_cvg_txn;

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

wr__rd__ack: cross wr_en_cp,rd_en_cp,wr_ack_cp
{
    ignore_bins ign_ack_without_wr = binsof(wr_en_cp) intersect {0} && binsof(wr_ack_cp) intersect{1};
}

wr__rd__overflow:cross wr_en_cp,rd_en_cp,overflow_cp
{
    ignore_bins ign_overflow_without_wr = binsof(wr_en_cp) intersect {0} && binsof(overflow_cp) intersect{1};
}

wr__rd__underflow:cross wr_en_cp,rd_en_cp,underflow_cp
{
    ignore_bins ign_underflow_without_rd = binsof(rd_en_cp) intersect {0} && binsof(underflow_cp) intersect{1};
}

wr__rd__full:cross wr_en_cp,rd_en_cp,full_cp
{
    ignore_bins ign_full_without_wr = binsof(wr_en_cp) intersect {0} && binsof(full_cp) intersect{1};
    ignore_bins ign_full_with_wr_rd = binsof(wr_en_cp) intersect {1} && binsof(rd_en_cp) intersect {1} && binsof(full_cp) intersect{1};
}
wr__rd__empty:cross wr_en_cp,rd_en_cp,empty_cp
{
        ignore_bins ign_empty_without_rd = binsof(rd_en_cp) intersect {0} && binsof(empty_cp) intersect{1};
        ignore_bins ign_empty_with_wr_rd = binsof(wr_en_cp) intersect {1} && binsof(rd_en_cp) intersect {1} && binsof(empty_cp) intersect{1};
}


wr__rd__almostfull:cross wr_en_cp,rd_en_cp,almostfull_cp;
wr__rd__almostempty:cross wr_en_cp,rd_en_cp,almostempty_cp;


endgroup

//CG cg;

function new (string name = "coverage",uvm_component parent = null);
super.new(name,parent);
cg = new();
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
    cov_export = new("cov_export", this);
    cov_fifo = new ("cov_fifo",this);
endfunction

function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    cov_export.connect(cov_fifo.analysis_export);

endfunction


task run_phase(uvm_phase phase);
super.run_phase(phase);

forever
begin
    cov_fifo.get(F_cvg_txn);
    cg.sample();

end

endtask
endclass
endpackage