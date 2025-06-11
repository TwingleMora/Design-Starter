import enum_x::*;
//READY is rd_en;
//Add ready to be asserted when state is IDLE;
module SPI_MASTER#(parameter SPI_MODE = 0, parameter CLKS_PER_HALF_BIT = 2)(
    input  wire          i_master_clk,
    input  wire          i_master_rst_n,

    //TX
    input  wire          i_MASTER_TX_VALID,
    input  wire [7:0]    i_MASTER_TX_BYTE,
    output reg           o_MASTER_TX_READY,

    //RX
    output  reg          o_MASTER_RX_VALID,
    output  reg [7:0]    o_MASTER_RX_BYTE,


    output wire          o_MASTER_SPI_MOSI,
    input  wire          i_MASTER_SPI_MISO,
    output reg           o_MASTER_SPI_SCLK,
    output reg           o_MASTER_SPI_CS_n
);



reg [7:0]                           r_SHIFT_REG;
reg                                 r_SAMPLE;
reg [3:0]                           r_EDGE_COUNT;
reg [$clog2(CLKS_PER_HALF_BIT)-1:0] r_CLK_COUNT;


wire CPHA = (SPI_MODE == 1||SPI_MODE == 3)? 1'b1 : 1'b0;
wire CPOL = (SPI_MODE == 2||SPI_MODE == 3)? 1'b1 : 1'b0;


STATE current;
STATE next;

// Sample => [7|6|5|4|3|2|1|0] => MOSI >> 1
// {Sample, MOSI}
assign o_MASTER_SPI_MOSI = r_SHIFT_REG[0];

   /////////////////////////////////////////////
  ///////////FSM Current & Next ///////////////
 /////////////////////////////////////////////
always@(posedge i_master_clk or negedge i_master_rst_n) begin
    if(!i_master_rst_n) begin
        current <= IDLE;                        
    end
    else begin
        current <= next;                        
    end
end
always@(*)
begin
    next = current;
    case(current)
    IDLE:begin
        if(i_MASTER_TX_VALID)
        begin
        case(CPHA)
        0: begin
                next = START;
        end
        1: begin
                next = PHASE1;
        end
        endcase
        end
    end
    PHASE1: begin
        if(r_CLK_COUNT == CLKS_PER_HALF_BIT-1)
            next = START;
    end
    START: begin
        if(r_CLK_COUNT == CLKS_PER_HALF_BIT-1)
            next = SAMPLE;
    end

    SAMPLE: begin
        if(r_CLK_COUNT == CLKS_PER_HALF_BIT-1) 
        begin
            if((r_EDGE_COUNT == 15) && (CPHA == 0)) begin
                case(i_MASTER_TX_VALID) 
                1'b0: next = PHASE2;
                1'b1: next = START;
                endcase
        
            
            end
            else if((r_EDGE_COUNT == 0) && (CPHA == 1)) begin //Philosophy: After Zero comes START
                case(i_MASTER_TX_VALID) 
                1'b0: next = IDLE;
                1'b1: next = START;
                endcase
            end
            else begin
                next = SHIFT;
            end
        end
    end

    SHIFT: begin
        if(r_CLK_COUNT == CLKS_PER_HALF_BIT-1) 
        begin
            next = SAMPLE;
        end
    end
    PHASE2: begin
        if(r_CLK_COUNT == CLKS_PER_HALF_BIT-1) begin
            next = IDLE;
        end
    end


    
    endcase
end



always@(posedge i_master_clk or negedge i_master_rst_n) begin
    if(!i_master_rst_n) begin
        r_EDGE_COUNT    <= 0;
        r_CLK_COUNT     <= 0;
        o_MASTER_SPI_SCLK      <= CPOL; 
    end
    else begin

        //EDGE_COUNT
        if(next == IDLE || current == IDLE)
        begin
            r_EDGE_COUNT <= 0;
        end        
        else begin
            if(r_CLK_COUNT == CLKS_PER_HALF_BIT - 1)
            begin
                r_EDGE_COUNT <= r_EDGE_COUNT + 1;
            end
        end

        //CLK_COUNT
        if(next == IDLE || current == IDLE) begin
            r_CLK_COUNT <= 0;
        end
        else
        begin
            if(r_CLK_COUNT == CLKS_PER_HALF_BIT - 1)
            begin
                r_CLK_COUNT <= 0;
            end
            else 
            begin
                r_CLK_COUNT <= r_CLK_COUNT + 1;
            end
        end

        //SPI_SCLK
        if(next == IDLE || current == IDLE) begin
            o_MASTER_SPI_SCLK <= CPOL;
        end
        else begin
            if(r_CLK_COUNT == CLKS_PER_HALF_BIT - 1) begin
                o_MASTER_SPI_SCLK <= ~o_MASTER_SPI_SCLK;
            end
        end
    end 
end

always@(posedge i_master_clk or negedge i_master_rst_n)
begin
    if(!i_master_rst_n) begin
        o_MASTER_SPI_CS_n <= 1;
    end
    else begin
        case(next) 
        IDLE: begin
            o_MASTER_SPI_CS_n <= 1;
        end
        START: begin
            o_MASTER_SPI_CS_n <= 0;
        end
        endcase
    end

end



always@(posedge i_master_clk or negedge i_master_rst_n)
begin
    if(!i_master_rst_n) begin
        r_SHIFT_REG     <= 0;
        r_SAMPLE        <= 0;
    end
    else begin
        case(next)
           ////////////////////////////////
          //////////////LOAD//////////////
         ////////////////////////////////
         // In Slave we use either the first edge if it's a shift edge(CPHA = 1) or last edge if it's also a shift edge (CPHA = 0)
        START: 
        begin
            if(current!= START)//
                r_SHIFT_REG <= i_MASTER_TX_BYTE;
        end
        SAMPLE:
        begin
            if(current!= SAMPLE)//??
                r_SAMPLE <= i_MASTER_SPI_MISO;
        end
        SHIFT:
        begin
            if(current!= SHIFT)//??
            r_SHIFT_REG <= {r_SAMPLE, r_SHIFT_REG[7:1]};  //[new ... |old]
        end

        endcase
    end    
end

always @(*) begin //READY_LOAD
    o_MASTER_TX_READY = 0;
    case(next)
    START: begin
        if(current != next) begin
            o_MASTER_TX_READY = 1;
        end
    end
    endcase

end
always@(posedge i_master_clk or negedge i_master_rst_n) begin
    if(!i_master_rst_n)
    begin
        o_MASTER_RX_BYTE <= 0;
        o_MASTER_RX_VALID <= 0; //WR_EN

        
    end
    else begin
        o_MASTER_TX_READY <= 0;
        o_MASTER_RX_VALID <= 1'b0;
        
        case(next)        
        IDLE: begin     
        end             
        SAMPLE: begin //EXPORT (LAST SAMPLE) ... We don't register the last bit ...
            case(CPHA)  
            1'b0: begin 
                if(current != next) begin
                    if(r_EDGE_COUNT == 14) 
                    begin //CPHA + 0                                          
                        o_MASTER_RX_BYTE  <= {i_MASTER_SPI_MISO, r_SHIFT_REG[7:1]}; // Last i_MASTER_SPI_MISO is the MSB   
                        o_MASTER_RX_VALID <= 1'b1;                                                         
                    end                                                                        
                end                                                                                    
            end                                                                                          
            1'b1: begin                                                                                  
                if(current != next) begin
                    if(r_EDGE_COUNT == 15) 
                    begin //CPHA + 1
                        o_MASTER_RX_BYTE  <= {i_MASTER_SPI_MISO, r_SHIFT_REG[7:1]};                                  
                        o_MASTER_RX_VALID <= 1'b1;                                                         
                    end
                end
            end
            endcase
        end
        endcase
    end

end






endmodule