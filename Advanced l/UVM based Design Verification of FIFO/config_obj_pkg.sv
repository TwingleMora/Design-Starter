package config_obj_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
class config_obj extends uvm_object;
`uvm_object_utils(config_obj)
virtual FIFO_IF vif;
function new(string name = "config_obj");
   super.new(name);
endfunction
endclass
endpackage