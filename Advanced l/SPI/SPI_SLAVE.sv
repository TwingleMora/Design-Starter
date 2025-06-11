module SPI_SLAVE #(parameter SPI_MODE = 0)
(


    //TX
    input  wire         i_SLAVE_TX_VALID,
    input  wire [7:0]   i_SLAVE_TX_BYTE,
    output reg          o_SLAVE_TX_READY,

    //RX
    output  reg         o_SLAVE_RX_VALID,
    output  reg [7:0]   o_SLAVE_RX_BYTE,

    //SPI
    input  reg          i_SLAVE_SPI_MOSI,
    output wire         o_SLAVE_SPI_MISO,
    input  reg          i_SLAVE_SPI_SCLK,
    input  reg          i_SLAVE_SPI_CS_n
);

localparam CPHA = (SPI_MODE == 1||SPI_MODE == 3)? 1'b1 : 1'b0;
localparam CPOL = (SPI_MODE == 2||SPI_MODE == 3)? 1'b1 : 1'b0;


logic   [3:0]   r_EDGE_COUNT;
logic   [7:0]   r_SHIFT_REG;
logic           r_SAMPLE;

logic [3:0] r_POS_EDGE_COUNT;
logic [3:0] r_NEG_EDGE_COUNT;




assign o_SLAVE_SPI_MISO = (~i_SLAVE_SPI_CS_n)? r_SHIFT_REG[0]:1'bZ; 
assign r_EDGE_COUNT = r_POS_EDGE_COUNT + r_NEG_EDGE_COUNT;

// assign o_SLAVE_SPI_MISO = t_SPI_MISO;


/*
SPI_SLAVE_MODE
0: (CPOL = 0, CPHA = 0): sample posedge, shift negedge: start earlier than sclk needs CS_n negedge to load data from application
1: (CPOL = 0, CPHA = 1): sample negedge, shift posedge: start earlier than sclk needs CS_n negedge to load data from application
2: (CPOL = 1, CPHA = 0): sample negedge, shift posedge: end later than sclk needs CS_n posedge to shift last bit
3: (CPOL = 1, CPHA = 1): sample posedge, shift negedge  end later than sclk needs CS_n posedge to shift last bit
*/

// always@(negedge i_SLAVE_SPI_CS_n)
// begin
//      o_SLAVE_SPI_MISO <= i_SLAVE_TX_BYTE[0];
// end
            //EXPORT LOGIC
            always@(*)
            begin
                o_SLAVE_RX_BYTE = {i_SLAVE_SPI_MOSI, r_SHIFT_REG[7:1]};
                
                if(r_EDGE_COUNT == 14 + CPHA) begin
                    o_SLAVE_RX_VALID = 1;
                end
                else begin
                    o_SLAVE_RX_VALID = 0;
                end
            end
            //LOAD LOGIC
            always@(*)
            begin
                if(r_EDGE_COUNT == 0) begin 
                    o_SLAVE_TX_READY = 1;
                end    
                else begin
                    o_SLAVE_TX_READY = 0;
                end
            end



            always@(posedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n) begin
                if(i_SLAVE_SPI_CS_n) begin
                    r_POS_EDGE_COUNT<=0;   
                end  
                else begin
                    r_POS_EDGE_COUNT <= r_POS_EDGE_COUNT + 1;
                end
            end

            always@(negedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n) begin             
                if(i_SLAVE_SPI_CS_n) begin  
                    r_NEG_EDGE_COUNT <= 0;
                end
                else begin
                    r_NEG_EDGE_COUNT <= r_NEG_EDGE_COUNT + 1;
                    if(r_EDGE_COUNT == 15) begin
                        r_POS_EDGE_COUNT <= 0;
                        r_NEG_EDGE_COUNT <= 0;
                    end
                end
            end

//CPOL
generate
    if(CPHA==0) begin //add additional logic for "continous burst" case
            if(CPOL==0) 
            begin
                //Shift
                always@(negedge i_SLAVE_SPI_SCLK, posedge i_SLAVE_SPI_CS_n) 
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                        if(i_SLAVE_TX_VALID) begin
                            r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                        end
                        else begin
                            r_SHIFT_REG <= 0;
                        end
                    end
                    else begin   
                        if(r_EDGE_COUNT == 15) begin //comes after last sample ... means comes after extract
                            if(i_SLAVE_TX_VALID) begin 
                                r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                            end
                        end
                        else begin
                        r_SHIFT_REG <= {r_SAMPLE, r_SHIFT_REG[7:1]};
                        end

                    end
                end

                //Sample
                always@(posedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n)
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                         
                    end
                    else begin
                        r_SAMPLE <= i_SLAVE_SPI_MOSI;
                         
                    end
                end

                `ifndef SYNTHESIS
                always @(i_SLAVE_SPI_CS_n)
                    if (i_SLAVE_SPI_CS_n) assign r_SHIFT_REG = i_SLAVE_TX_BYTE;
                    else  deassign r_SHIFT_REG;
                `endif


            end


/////-------------------------------------------------------------------------------

            else if(CPOL==1) 
            begin
                //Shift
                always@(posedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n) 
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                        if(i_SLAVE_TX_VALID) begin
                            r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                        end
                    end
                    else 
                    begin   
                         if(r_EDGE_COUNT == 15) begin
                            if(i_SLAVE_TX_VALID) begin
                                r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                            end
                        end
                        else begin
                            r_SHIFT_REG <= {r_SAMPLE, r_SHIFT_REG[7:1]};
                        end
                    end
                end
                
                //Sample
                always@(negedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n)
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                        
                         
                    end
                    else begin
                        r_SAMPLE <= i_SLAVE_SPI_MOSI;
                    end
                end

                `ifndef SYNTHESIS
                always @(i_SLAVE_SPI_CS_n)
                    if (i_SLAVE_SPI_CS_n) assign r_SHIFT_REG = i_SLAVE_TX_BYTE;
                    else  deassign r_SHIFT_REG;
                `endif

                
            end
    end

/////----------------------------------------------------------------------
/////----------------------------------------------------------------------

   else if(CPHA==1) begin
            if(CPOL==0) 
            begin
                //Shift
                always@(posedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n) 
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                        /* 
                            if(i_SLAVE_TX_VALID) begin
                                r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                            end 
                        */    
                    end
                    else begin   
                        r_SHIFT_REG <= {r_SAMPLE, r_SHIFT_REG[7:1]};
                        if(r_EDGE_COUNT==0) begin
                            if(i_SLAVE_TX_VALID) begin
                                r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                            end
                        end
                    end
                end

                //Sample
                always@(negedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n)
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                         
                    end
                    else begin
                        r_SAMPLE <= i_SLAVE_SPI_MOSI;
                    end
                end
            end

/////-------------------------------------------------------------------------------

            else begin
                //Shift
                always@(negedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n) 
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                        /* 
                            if(i_SLAVE_TX_VALID) begin
                                r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                            end 
                        */    
                    end
                    else begin   
                        r_SHIFT_REG <= {r_SAMPLE, r_SHIFT_REG[7:1]};
                        if(r_EDGE_COUNT==0) begin /*******/ //after 15 you get 0
                            if(i_SLAVE_TX_VALID) begin
                                r_SHIFT_REG <= i_SLAVE_TX_BYTE;
                            end
                        end
                    end
                end
                
                //Sample
                always@(posedge i_SLAVE_SPI_SCLK or posedge i_SLAVE_SPI_CS_n)
                begin
                    if(i_SLAVE_SPI_CS_n) begin
                         
                    end
                    else begin
                        r_SAMPLE <= i_SLAVE_SPI_MOSI;
                    end
                end
            end
   end 
endgenerate

endmodule