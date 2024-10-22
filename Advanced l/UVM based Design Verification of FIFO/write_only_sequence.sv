package write_only_sequence_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "Sequence_Item.sv"
import sequence_item_pkg::*;
class Write_Only_Sequence extends uvm_sequence #(Sequence_Item);
`uvm_object_utils(Write_Only_Sequence)
//Sequence_Item seq_item;
function new(string name = "Write_Only_Sequence");
super.new(name);
endfunction

task body;
//seq_item = Sequence_Item::type_id::create("seq_item");

repeat(1000)
begin
Sequence_Item seq_item;
seq_item = Sequence_Item::type_id::create("seq_item");
start_item(seq_item);
seq_item.rst_n = 1;
assert (seq_item.randomize());
seq_item.wr_en=1; 
seq_item.rd_en=0;
finish_item(seq_item);
end

endtask

endclass
endpackage