package sequencer_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "Sequence_Item.sv"
import sequence_item_pkg::*;
class Sequencer extends uvm_sequencer#(Sequence_Item);
`uvm_component_utils(Sequencer)
function new(string name = "Sequencer",uvm_component parent = null);
super.new(name,parent);
endfunction

endclass

endpackage