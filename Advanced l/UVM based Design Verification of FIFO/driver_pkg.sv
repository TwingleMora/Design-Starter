
package driver_pkg;
`include "uvm_macros.svh"
//`include "Sequence_Item.sv"
import sequence_item_pkg::*;
import uvm_pkg::*;
class Driver extends uvm_driver #(Sequence_Item);
`uvm_component_utils(Driver)
virtual FIFO_IF IF;
//config_obj c_obj;
Sequence_Item fifo_transaction;
function new(string name = "Driver", uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
//c_obj = config_obj::type_id::create("config_obj");

endfunction


function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
//vif = c_obj.vif;
endfunction


task run_phase(uvm_phase phase);
super.run_phase(phase);
   IF.data_in =   0 ;
   IF.rst_n   =   0 ;
   IF.wr_en   =   0 ;
   IF.rd_en   =   0 ;
forever begin
fifo_transaction = Sequence_Item::type_id::create("fifo_transaction");
seq_item_port.get_next_item(fifo_transaction);
@(negedge IF.clk)
   //fifo_transaction.randomize();

   IF.data_in =   fifo_transaction.data_in ;
   IF.rst_n   =   fifo_transaction.rst_n ;
   IF.wr_en   =   fifo_transaction.wr_en ;
   IF.rd_en   =   fifo_transaction.rd_en ;
   
//@(negedge vif.clk)
seq_item_port.item_done();

//`uvm_info("run_phase","driver running!",UVM_NONE)
//$display("%s",seq_item.convert2string());
    
end
endtask

endclass
endpackage

