
package scoreboard_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_item_pkg::*;
class Scoreboard extends uvm_scoreboard;
`uvm_component_utils(Scoreboard)

uvm_analysis_export#(Sequence_Item) sb_export;
uvm_tlm_analysis_fifo#(Sequence_Item) sb_fifo;
Sequence_Item fifo_transaction;

   localparam FIFO_WIDTH = 16;
   localparam FIFO_DEPTH = 8;
   localparam max_fifo_addr = $clog2(FIFO_DEPTH);
    
    
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref; 

    logic [max_fifo_addr-1:0] wr_ptr_ref;    
    logic [max_fifo_addr-1:0] rd_ptr_ref;    
    logic [max_fifo_addr:0] count_ref;


    logic [FIFO_WIDTH-1 : 0] mem_ref [FIFO_DEPTH];

	int failed = 0;
	int passed = 0;


function new(string name = "Scoreboard", uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
sb_export = new("sb_export",this);
sb_fifo   = new("sb_fifo",  this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
sb_export.connect(sb_fifo.analysis_export);


endfunction

function void reference_model(Sequence_Item trans);
	if (!trans.rst_n) begin
		wr_ptr_ref = 0;
		wr_ack_ref=0;
		overflow_ref=0;//fault was dectected here
		data_out_ref= 0;//fault was dectected here
	end
	else if (trans.wr_en && count_ref < 8) begin
		mem_ref[wr_ptr_ref] = trans.data_in;
		wr_ack_ref = 1;
		wr_ptr_ref = wr_ptr_ref + 1;
		overflow_ref = 0;//fault was dectected here
	end
	else begin 
		wr_ack_ref = 0; 
		if (full_ref & trans.wr_en)
			overflow_ref = 1;
		else
			overflow_ref = 0;			
	end


    if (!trans.rst_n) begin
		rd_ptr_ref = 0;
		data_out_ref= 0;//fault was dectected here
		underflow_ref=0;//fault was dectected here
	end
	else if (trans.rd_en && count_ref != 0) begin
		data_out_ref = mem_ref[rd_ptr_ref];
		rd_ptr_ref = rd_ptr_ref + 1;
		underflow_ref=0;//fault was dectected here
	end
	else begin 
	if(empty_ref&&trans.rd_en)
		underflow_ref=1;
	else
		underflow_ref=0;
	end


    if (!trans.rst_n) begin
		count_ref = 0;
		data_out_ref= 0;//fault was dectected here
	end
	else begin
		if	( ({trans.wr_en, trans.rd_en} == 2'b10) && !full_ref) // if wren=1 and count_ref != 8
			count_ref = count_ref + 1;
		else if ( ({trans.wr_en, trans.rd_en} == 2'b01) && !empty_ref)// if rden=1 and count_ref != 0
			count_ref = count_ref - 1;
			else if ({trans.wr_en,trans.rd_en}==2'b11) begin//fault was dectected here
			if(full_ref)
			count_ref = count_ref-1;
			else if (empty_ref)
			count_ref = count_ref+1;
			end
	end

 full_ref = (count_ref == FIFO_DEPTH)? 1 : 0;
 empty_ref = (count_ref == 0)? 1 : 0;
 almostfull_ref = (count_ref == FIFO_DEPTH-1)? 1 : 0; //fault was dectected here  
 almostempty_ref = (count_ref == 1)? 1 : 0;

//assign underflow_ref = (empty_ref && rd_en)? 1 : 0; //fault was dectected here

endfunction


function void check_data(Sequence_Item trans);

reference_model(trans);


assert(trans.data_out === data_out_ref && trans.wr_ack === wr_ack_ref && trans.overflow === overflow_ref && trans.full === full_ref && trans.empty === empty_ref && trans.almostfull === almostfull_ref
&& trans.almostempty === almostempty_ref && underflow_ref === trans.underflow)
begin
	passed++;
end
else
begin
$error("test failed!");
	failed++;
end



endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
    sb_fifo.get(fifo_transaction);
    check_data(fifo_transaction); 
end
endtask

function void phase_ready_to_end(uvm_phase phase);
super.phase_ready_to_end(phase);
$display("No. Of Passed Cases: %d, No. Of Failed Cases: %d",passed,failed);

endfunction

endclass

endpackage