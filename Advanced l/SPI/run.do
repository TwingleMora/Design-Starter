vlib work
vlog -f source.list
vsim -voptargs=+acc work.TOP_TB

add wave -noupdate -expand -group MASTER_GLOBAL /TOP_TB/i_master_clk
add wave -noupdate -expand -group MASTER_GLOBAL /TOP_TB/i_master_rst_n
add wave -noupdate -expand -group MASTER_TX /TOP_TB/i_MASTER_TX_VALID
add wave -noupdate -expand -group MASTER_TX /TOP_TB/i_MASTER_TX_BYTE
add wave -noupdate -expand -group MASTER_TX /TOP_TB/o_MASTER_TX_READY
add wave -noupdate -expand -group MASTER_RX /TOP_TB/o_MASTER_RX_VALID
add wave -noupdate -expand -group MASTER_RX /TOP_TB/o_MASTER_RX_BYTE
add wave -noupdate -expand -group SLAVE_TX /TOP_TB/i_SLAVE_TX_VALID
add wave -noupdate -expand -group SLAVE_TX /TOP_TB/i_SLAVE_TX_BYTE
add wave -noupdate -expand -group SLAVE_TX /TOP_TB/o_SLAVE_TX_READY
add wave -noupdate -expand -group SLAVE_RX /TOP_TB/o_SLAVE_RX_VALID
add wave -noupdate -expand -group SLAVE_RX /TOP_TB/o_SLAVE_RX_BYTE
add wave -noupdate -expand -group SPI_INTF /TOP_TB/SPI_MOSI
add wave -noupdate -expand -group SPI_INTF /TOP_TB/SPI_MISO
add wave -noupdate -expand -group SPI_INTF /TOP_TB/SPI_SCLK
add wave -noupdate -expand -group SPI_INTF /TOP_TB/SPI_CS_n
add wave -noupdate -expand -group 1 /TOP_TB/i_M_BYTES
add wave -noupdate -expand -group 1 /TOP_TB/i_M_VALIDS
add wave -noupdate -expand -group 1 /TOP_TB/o_S_BYTES
add wave -noupdate -expand -group 2 /TOP_TB/i_S_BYTES
add wave -noupdate -expand -group 2 /TOP_TB/o_M_BYTES

run -all