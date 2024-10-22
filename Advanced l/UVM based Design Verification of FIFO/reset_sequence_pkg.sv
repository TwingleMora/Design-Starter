package reset_sequence_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "Sequence_Item.sv"
import sequence_item_pkg::*;
class Reset_Sequence extends uvm_sequence #(Sequence_Item);
`uvm_object_utils(Reset_Sequence)
Sequence_Item seq_item;
function new(string name = "Reset_Sequence");
super.new(name);
endfunction

task body;
seq_item = Sequence_Item::type_id::create("seq_item");

repeat(1)
begin
start_item(seq_item);
seq_item.rst_n =0;
seq_item.data_in=0;
seq_item.wr_en=0; 
seq_item.rd_en=0;
finish_item(seq_item);
end

endtask

endclass
endpackage