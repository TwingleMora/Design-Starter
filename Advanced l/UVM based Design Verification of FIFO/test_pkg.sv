
package test_pkg;
`include "uvm_macros.svh"

//`include "main_sequence.sv"
//`include "reset_sequence.sv"

import uvm_pkg::*;
import env_pkg::*;

 import reset_sequence_pkg::*;
 import write_only_sequence_pkg::*;
 import   read_only_sequence_pkg::*;
 import   write_read_sequence_pkg::*;
 import   random_sequence_pkg::*;
 import config_obj_pkg::*;




class Test extends uvm_test;
`uvm_component_utils(Test)
    config_obj c_obj;
    Env env;
    Reset_Sequence reset_seq;
    Write_Only_Sequence wos;
    Read_Only_Sequence ros;
    Write_Read_Sequence wrs;
    Random_Sequence rs;

  

    function new(string name = "Test", uvm_component parent = null);
        super.new(name,parent);
    endfunction //new()




    function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    c_obj = config_obj::type_id::create("config_obj");

    if(!uvm_config_db#(virtual FIFO_IF)::get(this,"","IF",c_obj.vif))
    begin
        `uvm_fatal("build_phase","Test - Unable to get the virtual interface")
    end
    uvm_config_db#(config_obj)::set(this,"*","agent_config_obj",c_obj);
    env = Env::type_id::create("Env",this);

    reset_seq = Reset_Sequence::type_id::create("reset_seq",this);
    wos = Write_Only_Sequence::type_id::create("wos",this);
    ros = Read_Only_Sequence::type_id::create("ros",this);
    wrs = Write_Read_Sequence::type_id::create("wrs",this);
    rs =  Random_Sequence::type_id::create("rs",this);

   
    endfunction

    task run_phase(uvm_phase phase);
     super.run_phase(phase);
     phase.raise_objection(this);
/*
wos.start(env.agent.sqr);
ros.start(env.agent.sqr);
wrs.start(env.agent.sqr);
rs.start(env.agent.sqr);

*/

  //   #100; `uvm_info("run_phase","start reset sequence!",UVM_NONE)
    reset_seq.start(env.agent.sqr);
   //  #100; `uvm_info("run_phase","start main sequence!",UVM_NONE)
     wos.start(env.agent.sqr);
   //  #100; `uvm_info("run_phase","start main sequence!",UVM_NONE)
     ros.start(env.agent.sqr);     
    // #100; `uvm_info("run_phase","start main sequence!",UVM_NONE)
     wrs.start(env.agent.sqr);     
    // #100; `uvm_info("run_phase","start main sequence!",UVM_NONE)
     rs.start(env.agent.sqr);
     phase.drop_objection(this);
    endtask
endclass //className extends superClass



endpackage

