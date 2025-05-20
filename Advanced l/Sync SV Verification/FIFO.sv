////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(data_in, wr_en, rd_en, clk, rst_n, full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
input [FIFO_WIDTH-1:0] data_in;
input clk, rst_n, wr_en, rd_en;
output reg [FIFO_WIDTH-1:0] data_out;
output reg wr_ack, overflow,underflow;//fault was dectected here
output  full, empty, almostfull, almostempty;
 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_ptr <= 0;
		wr_ack<=0;
		overflow<=0;//fault was dectected here
		data_out<= 0;//fault was dectected here
	end
	else if (wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		overflow <= 0;//fault was dectected here
	end
	else begin 
		wr_ack <= 0; 
		if (full & wr_en)
			overflow <= 1;		
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= 0;
		data_out<= 0;//fault was dectected here
		underflow<=0;//fault was dectected here
	end
	else if (rd_en && count != 0) begin
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		underflow<=0;//fault was dectected here
	end
	else begin 
	if(empty&&rd_en)
	underflow<=1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
		data_out<= 0;//fault was dectected here
	end
	else begin
		if	( ({wr_en, rd_en} == 2'b10) && !full) // if wren=1 and count != 8
			count <= count + 1;
		else if ( ({wr_en, rd_en} == 2'b01) && !empty)// if rden=1 and count != 0
			count <= count - 1;
			else if ({wr_en,rd_en}==2'b11) begin//fault was dectected here
			if(full)
			count <= count-1;
			else if (empty)
			count <= count+1;
			end
	end
end

assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
//assign underflow = (empty && rd_en)? 1 : 0; //fault was dectected here
assign almostfull = (count == FIFO_DEPTH-1)? 1 : 0;//fault was dectected here  
assign almostempty = (count == 1)? 1 : 0;

endmodule