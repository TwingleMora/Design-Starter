////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_IF.DUT IF);

//(IF.data_in, IF.wr_en, IF.rd_en, IF.clk, IF.rst_n, IF.full, IF.empty, IF.almostfull, IF.almostempty, IF.wr_ack, IF.overflow, IF.underflow, IF.data_out);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
// input [FIFO_WIDTH-1:0] IF.data_in;
// input IF.clk, IF.rst_n, IF.wr_en, IF.rd_en;
// output reg [FIFO_WIDTH-1:0] IF.data_out;
// output reg IF.wr_ack, IF.overflow,IF.underflow;//fault was dectected here
// output  IF.full, IF.empty, IF.almostfull, IF.almostempty;
 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge IF.clk or negedge IF.rst_n) begin
	if (!IF.rst_n) begin
		wr_ptr <= 0;
		IF.wr_ack<=0;
		IF.overflow<=0;//fault was dectected here
		IF.data_out<= 0;//fault was dectected here
	end
	else if (IF.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= IF.data_in;
		IF.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		IF.overflow <= 0;//fault was dectected here
	end
	else begin 
		IF.wr_ack <= 0; 
		if (IF.full && IF.wr_en)
			IF.overflow <= 1;	
		else
			IF.overflow <= 0;	//no wr en
	end
end

always @(posedge IF.clk or negedge IF.rst_n) begin
	if (!IF.rst_n) begin
		rd_ptr <= 0;
		IF.data_out<= 0;//fault was dectected here
		IF.underflow<=0;//fault was dectected here
	end
	else if (IF.rd_en && count != 0) begin
		IF.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		IF.underflow<=0;//fault was dectected here
	end
	else begin 
	if(IF.empty&&IF.rd_en)
		IF.underflow<=1;
	else
		IF.underflow<=0; // no rd en
	end
end

always @(posedge IF.clk or negedge IF.rst_n) begin
	if (!IF.rst_n) begin
		count <= 0;
		IF.data_out<= 0;//fault was dectected here
	end
	else begin
		if	( ({IF.wr_en, IF.rd_en} == 2'b10) && !IF.full) // if wren=1 and count != 8
			count <= count + 1;
		else if ( ({IF.wr_en, IF.rd_en} == 2'b01) && !IF.empty)// if rden=1 and count != 0
			count <= count - 1;
			else if ({IF.wr_en,IF.rd_en}==2'b11) begin//fault was dectected here
			if(IF.full)
			count <= count-1;
			else if (IF.empty)
			count <= count+1;
			end
	end
end

assign IF.full = (count == FIFO_DEPTH)? 1 : 0;
assign IF.empty = (count == 0)? 1 : 0;
//assign IF.underflow = (IF.empty && IF.rd_en)? 1 : 0; //fault was dectected here
assign IF.almostfull = (count == FIFO_DEPTH-1)? 1 : 0;//fault was dectected here  
assign IF.almostempty = (count == 1)? 1 : 0;
`ifdef sva
always_comb begin 
	if(!IF.rst_n)
	begin
		a_reset: assert final(count==0&&!IF.wr_ack&&!IF.overflow&&!IF.underflow);
	end
	a_full: assert final(IF.full == ( (count == FIFO_DEPTH)? 1'b1 : 1'b0 ) );
	a_empty: assert final(IF.empty == ( (count == 1'b0)? 1'b1 : 1'b0 ) );
	a_almostfull: assert final (IF.almostfull == ((count == FIFO_DEPTH-1'b1)? 1'b1 : 1'b0));//fault was dectected here  
    a_almostempty:assert final (IF.almostempty == ((count == 1'b1)? 1'b1 : 1'b0) );
end


a_wr_ptr: assert property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.wr_en && count < FIFO_DEPTH) |=> (wr_ptr == $past(wr_ptr)+1'b1));
c_wr_ptr: cover property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.wr_en && count < FIFO_DEPTH) |=> (wr_ptr == $past(wr_ptr)+1'b1));

a_rd_ptr: assert property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.rd_en && count != 0) |=> (rd_ptr == $past(rd_ptr) +1'b1) );
c_rd_ptr: cover property (@(posedge IF.clk) disable iff(!IF.rst_n) (IF.rd_en && count != 0) |=> (rd_ptr == $past(rd_ptr) +1'b1) );

a_count_up:  assert property (@(posedge IF.clk) disable iff(!IF.rst_n) (( ({IF.wr_en, IF.rd_en} == 2'b10) && !IF.full)||(({IF.wr_en,IF.rd_en}==2'b11)&&(IF.empty)))|=>(count == $past(count) +1'b1));
c_count_up:  cover property (@(posedge IF.clk) disable iff(!IF.rst_n) (( ({IF.wr_en, IF.rd_en} == 2'b10) && !IF.full)||(({IF.wr_en,IF.rd_en}==2'b11)&&(IF.empty)))|=>(count == $past(count) +1'b1));

a_count_down:  assert property (@(posedge IF.clk) disable iff(!IF.rst_n) (( ({IF.wr_en, IF.rd_en} == 2'b01) && !IF.empty)||(({IF.wr_en,IF.rd_en}==2'b11)&&(IF.full)))|=>(count == $past(count) -1'b1));
c_count_down:  cover property (@(posedge IF.clk) disable iff(!IF.rst_n) (( ({IF.wr_en, IF.rd_en} == 2'b01) && !IF.empty)||(({IF.wr_en,IF.rd_en}==2'b11)&&(IF.full)))|=>(count == $past(count) -1'b1));


`endif

endmodule
//output reg IF.wr_ack, IF.overflow,IF.underflow;//fault was dectected here
//output  IF.full, IF.empty, IF.almostfull, IF.almostempty;xx