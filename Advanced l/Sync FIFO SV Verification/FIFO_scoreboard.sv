package FIFO_scoreboard_pkg;

import FIFO_transaction_pkg::*;
class FIFO_scoreboard;
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


function new();
count_ref=0;


endfunction

function void reference_model(FIFO_transaction trans);

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


function void check_data(FIFO_transaction trans);

reference_model(trans);


assert(trans.data_out === data_out_ref);
//assert(trans.wr_ack === wr_ack_ref);//xxxxx
//assert(trans.overflow === overflow_ref);
//assert(trans.full === full_ref);
//assert(trans.empty === empty_ref);// xxx
//assert(trans.almostfull === almostfull_ref);
//assert(trans.almostempty === almostempty_ref);// xxx
//assert(underflow_ref === trans.underflow);/// xxxx


endfunction



endclass



endpackage
