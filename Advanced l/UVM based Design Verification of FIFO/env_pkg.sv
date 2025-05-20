

package env_pkg;


`include "uvm_macros.svh"
import uvm_pkg::*;
import agent_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;

//import driver_pkg::*;


class Env extends uvm_env;
`uvm_component_utils(Env)

Agent agent;
Scoreboard sb;
Coverage cov;
function new(string name = "Env",uvm_component parent = null );
super.new(name,parent);

endfunction
function void build_phase(uvm_phase phase);
super.build_phase(phase);
agent = Agent::type_id::create("agent",this);
sb = Scoreboard::type_id::create("sb",this);
cov = Coverage::type_id::create("cov",this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);

agent.agt_ap.connect(sb.sb_export);
agent.agt_ap.connect(cov.cov_export);

endfunction

endclass
endpackage