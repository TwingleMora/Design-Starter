import enum_x::*;
module TOP_TB;

/////////////MASTER////////////////
    bit       i_master_clk;
    bit       i_master_rst_n;

    //TX
    bit         i_MASTER_TX_VALID;
    bit [7:0]   i_MASTER_TX_BYTE;
    logic         o_MASTER_TX_READY;

    //RX
    logic         o_MASTER_RX_VALID;
    logic [7:0]   o_MASTER_RX_BYTE;



/////////////SLAVE////////////////
    //TX
    bit           i_SLAVE_TX_VALID;
    bit [7:0]     i_SLAVE_TX_BYTE;
    logic         o_SLAVE_TX_READY;

    //RX
    logic         o_SLAVE_RX_VALID;
    logic [7:0]   o_SLAVE_RX_BYTE;



    //SPI
    logic          SPI_MOSI;
    logic          SPI_MISO;
    logic          SPI_SCLK;
    logic          SPI_CS_n;


SPI_MASTER #(.SPI_MODE(0), .CLKS_PER_HALF_BIT(2)) SPI_MASTER_DUT
(
    .i_master_clk(i_master_clk),
    .i_master_rst_n(i_master_rst_n),

    //TX
    .i_MASTER_TX_VALID(i_MASTER_TX_VALID),
    .i_MASTER_TX_BYTE(i_MASTER_TX_BYTE),
    .o_MASTER_TX_READY(o_MASTER_TX_READY),

    //RX
    .o_MASTER_RX_VALID(o_MASTER_RX_VALID),
    .o_MASTER_RX_BYTE(o_MASTER_RX_BYTE),


    .o_MASTER_SPI_MOSI(SPI_MOSI),
    .i_MASTER_SPI_MISO(SPI_MISO),
    .o_MASTER_SPI_SCLK(SPI_SCLK),
    .o_MASTER_SPI_CS_n(SPI_CS_n)
);

SPI_SLAVE #(.SPI_MODE(0)) SPI_SLAVE_DUT
(


    //TX
    .i_SLAVE_TX_VALID(i_SLAVE_TX_VALID),
    .i_SLAVE_TX_BYTE (i_SLAVE_TX_BYTE),
    .o_SLAVE_TX_READY(o_SLAVE_TX_READY),

    //RX
    .o_SLAVE_RX_VALID(o_SLAVE_RX_VALID),
    .o_SLAVE_RX_BYTE (o_SLAVE_RX_BYTE),

    //SPI
    .i_SLAVE_SPI_MOSI(SPI_MOSI),
    .o_SLAVE_SPI_MISO(SPI_MISO),
    .i_SLAVE_SPI_SCLK(SPI_SCLK),
    .i_SLAVE_SPI_CS_n(SPI_CS_n)
);


always #5 i_master_clk = ~i_master_clk;

logic [7:0] i_M_BYTES  [4] = '{8'hAA, 8'hBB, 8'h01, 8'hCC/* , 8'h00 */}; //'{} vs {} initialization vs concatenation
logic       i_M_VALIDS [4] = '{1, 1, 0, 1/* , 1 */}; //'{} vs {} initialization vs concatenation

logic [7:0] o_M_BYTES [4] = '{8'h00, 8'h00, 8'h00, 8'h00}; //'{} vs {} initialization vs concatenation

logic [7:0] i_S_BYTES [4] = '{8'hDD, 8'hEE, 8'h02, 8'hFF}; //'{} vs {} initialization vs concatenation
logic [7:0] o_S_BYTES [4] = '{8'h00, 8'h00, 8'h00, 8'h00}; //'{} vs {} initialization vs concatenation


task master_driver;
int x,z;
x = 0;
z = 0;
/* repeat(3) */ begin
fork
    begin
        forever begin
@(posedge i_master_clk)
i_MASTER_TX_BYTE  <= i_M_BYTES[x];
i_MASTER_TX_VALID <= i_M_VALIDS[x];
        end
    end
    begin
        forever begin
@(posedge o_MASTER_TX_READY);
x++;
@(posedge i_master_clk);
i_MASTER_TX_VALID <= i_M_VALIDS[x];
i_MASTER_TX_BYTE <= i_M_BYTES[x];

        end
    end
    begin
        forever begin
            wait(SPI_MASTER_DUT.current==START);
            $display("STARTTTTT");
            wait(SPI_MASTER_DUT.current==IDLE);
            $display("IDLEEEEE AFTER START");
            i_M_VALIDS[x] = 1;
            @(posedge i_master_clk);
            i_MASTER_TX_VALID <= i_M_VALIDS[x];
            i_MASTER_TX_BYTE <= i_M_BYTES[x];
            @(posedge SPI_SCLK);
        end
    end
    begin
        forever begin
@(posedge o_MASTER_RX_VALID)
@(posedge i_master_clk)
o_M_BYTES[z] <= o_MASTER_RX_BYTE;
z++;
        end
    end
join
end

endtask


task slave_driver;
int y;
int q;
y = 0;
q = 0;
repeat(3) begin
i_SLAVE_TX_BYTE <= i_S_BYTES[y];
i_SLAVE_TX_VALID <= 1;
@(negedge SPI_CS_n)
fork
    begin
        forever begin
wait(o_SLAVE_TX_READY)
@(posedge SPI_SCLK)
y++;
i_SLAVE_TX_VALID <= 1;
i_SLAVE_TX_BYTE <= i_S_BYTES[y];
@(negedge SPI_SCLK);
        end
    end
    begin
         forever begin
@(posedge o_SLAVE_RX_VALID)
o_S_BYTES[q] <= o_SLAVE_RX_BYTE; 
q++;
         end
    end
join
end
endtask

initial begin
i_master_rst_n <= 0;
@(posedge i_master_clk)
i_master_rst_n <= 1;

fork
    master_driver;
    slave_driver;
join_none
#3000;
$stop;

end

endmodule