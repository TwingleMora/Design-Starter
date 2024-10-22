
//`include "shift_reg_if.sv"
//`include "shift_reg.v"
//`include "test_pkg.sv"
`include "uvm_macros.svh"
import test_pkg::*;
import uvm_pkg::*;


module TOP();
bit clk=0;
FIFO_IF IF(clk);
FIFO DUT(
    IF.DUT
 );

 bind DUT SVA sva(IF);


always  begin
    #5 clk <= ~clk;
end

initial begin
 
    uvm_config_db#(virtual FIFO_IF)::set(uvm_root::get(),"*","IF",IF);
    //uvm_config_db#(virtual shift_reg_if)::set(uvm_root::get(),"uvm_test_top","IF",srif);
    run_test("Test");   
end

endmodule
