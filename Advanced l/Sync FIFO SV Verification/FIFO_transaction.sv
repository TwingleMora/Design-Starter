package FIFO_transaction_pkg;
    

class FIFO_transaction;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    int WR_EN_ON_DIST;
    int RD_EN_ON_DIST;

    rand logic [FIFO_WIDTH-1:0] data_in;
    rand logic rst_n;
    rand logic wr_en, rd_en;


    logic [FIFO_WIDTH-1:0] data_out;
    
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow; 


function new(int RD_EN_ON_DIST=30, int WR_EN_ON_DIST=70);
    
    this.RD_EN_ON_DIST = RD_EN_ON_DIST;
    this.WR_EN_ON_DIST = WR_EN_ON_DIST;
    
endfunction

constraint cons {
    rst_n dist{1'b1:=98, 1'b0:=2};
    wr_en dist{1'b1:=WR_EN_ON_DIST,1'b0:=100-WR_EN_ON_DIST};
    rd_en dist{1'b1:=RD_EN_ON_DIST,1'b0:=100-RD_EN_ON_DIST};
};


endclass

endpackage