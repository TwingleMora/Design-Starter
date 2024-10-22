package monitor_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_item_pkg::*;
//import config_obj_pkg::*;
class Monitor extends uvm_monitor;
`uvm_component_utils(Monitor)
virtual FIFO_IF IF;
//config_obj c_obj;
Sequence_Item fifo_transaction;

uvm_analysis_port#(Sequence_Item) mon_ap;
function new(string name = "monitor", uvm_component parent = null);

super.new(name,parent);

endfunction


function void build_phase(uvm_phase phase);
super.build_phase(phase);
mon_ap = new("mon_ap",this);


endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever
begin
    fifo_transaction = Sequence_Item::type_id::create("fifo_transaction");
    @(posedge IF.clk)
   fifo_transaction.data_in  = IF.data_in;

   fifo_transaction.rst_n = IF.rst_n;
   
   fifo_transaction.wr_en = IF.wr_en;
   fifo_transaction.rd_en = IF.rd_en;
   

 @(negedge IF.clk) ;
   fifo_transaction.wr_ack = IF.wr_ack;

   fifo_transaction.overflow  = IF.overflow;
   fifo_transaction.underflow = IF.underflow;

   fifo_transaction.data_out = IF.data_out;
   fifo_transaction.full  = IF.full;
   fifo_transaction.empty = IF.empty;

   fifo_transaction.almostfull = IF.almostfull;
   fifo_transaction.almostempty = IF.almostempty;

   fifo_transaction.underflow  = IF.underflow;
   mon_ap.write(fifo_transaction);


// fork
    
//     fifo__coverage.sample_data(fifo_transaction);
//     begin
        
//     fifo_scoreboard.check_data(fifo_transaction);
//     end
// join

    
    //`uvm_info("run_phase","monitor running!",UVM_NONE)
 
end
endtask

endclass


endpackage