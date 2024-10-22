
package sequence_item_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
class Sequence_Item extends uvm_sequence_item;
    `uvm_object_utils(Sequence_Item)
    
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    int WR_EN_ON_DIST;
    int RD_EN_ON_DIST;

    logic rst_n;
    rand logic [FIFO_WIDTH-1:0] data_in;
    rand logic wr_en, rd_en;


    logic [FIFO_WIDTH-1:0] data_out;
    
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow; 




    function new(string name = "Sequence_Item",int RD_EN_ON_DIST=30, int WR_EN_ON_DIST=70);
    super.new(name);    
    this.RD_EN_ON_DIST = RD_EN_ON_DIST;
    this.WR_EN_ON_DIST = WR_EN_ON_DIST;
    endfunction

    
constraint cons {
   // rst_n dist{1'b1:=98, 1'b0:=2};
    wr_en dist{1'b1:=WR_EN_ON_DIST,1'b0:=100-WR_EN_ON_DIST};
    rd_en dist{1'b1:=RD_EN_ON_DIST,1'b0:=100-RD_EN_ON_DIST};
};
        
    // function string convert2string();
    // return $sformatf("%s reset = %b, serial_in= %b, direction= %b, mode=%b, datain= %b, dataout= %b",super.convert2string(),reset,serial_in,direction,mode, datain, dataout);
    // endfunction

endclass
endpackage