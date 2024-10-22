package read_only_sequence_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "Sequence_Item.sv"
import sequence_item_pkg::*;
class Read_Only_Sequence extends uvm_sequence #(Sequence_Item);
`uvm_object_utils(Read_Only_Sequence)

function new(string name = "Read_Only_Sequence");
super.new(name);
endfunction

task body;


repeat(2000)
begin
Sequence_Item seq_item;
seq_item = Sequence_Item::type_id::create("seq_item");
start_item(seq_item);
seq_item.rst_n = 1;
assert (seq_item.randomize());
seq_item.wr_en=0; 
seq_item.rd_en=1;
finish_item(seq_item);
end


endtask

endclass
endpackage