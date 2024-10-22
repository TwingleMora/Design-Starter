package agent_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;

import sequence_item_pkg::*;
import driver_pkg::*;
import monitor_pkg::*;
import config_obj_pkg::*;
import sequencer_pkg::*;


class Agent extends uvm_agent;
`uvm_component_utils(Agent)
config_obj c_obj;
Sequencer sqr;
Driver driver;
Monitor monitor;
uvm_analysis_port #(Sequence_Item) agt_ap;
function new(string name = "Agent", uvm_component parent = null);
super.new(name,parent);
endfunction


function void build_phase(uvm_phase phase);
super.build_phase(phase);
sqr = Sequencer::type_id::create("sqr" ,this);
if(!uvm_config_db#(config_obj)::get(this,"","agent_config_obj",c_obj))//got from
begin
`uvm_fatal("build_phase","Driver - Unable to get the config object")
end

driver = Driver::type_id::create("driver",this);
monitor = Monitor::type_id::create("monitor",this);
agt_ap = new("agt_ap",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
endtask

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
driver.seq_item_port.connect(sqr.seq_item_export);
monitor.IF = c_obj.vif;
driver.IF = c_obj.vif;
monitor.mon_ap.connect(agt_ap);

endfunction




endclass


endpackage

