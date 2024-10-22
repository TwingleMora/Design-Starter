vlib work
vlog +fcover +cover +define+sva +acc -f source.list -covercells
vsim -voptargs=+acc -cover work.TOP

coverage save report.ucdb -onexit -du FIFO

add wave -noupdate /TOP/IF/clk
add wave -noupdate /TOP/IF/data_in
add wave -noupdate /TOP/IF/rst_n
add wave -noupdate /TOP/IF/wr_en
add wave -noupdate /TOP/IF/rd_en
add wave -noupdate /TOP/IF/data_out
add wave -noupdate /TOP/IF/wr_ack
add wave -noupdate /TOP/IF/overflow
add wave -noupdate /TOP/IF/full
add wave -noupdate /TOP/IF/empty
add wave -noupdate /TOP/IF/almostfull
add wave -noupdate /TOP/IF/almostempty
add wave -noupdate /TOP/IF/underflow
add wave -noupdate /TOP/DUT/count
add wave -noupdate -expand -group Coverage /TOP/DUT/c_wr_ptr
add wave -noupdate -expand -group Coverage /TOP/DUT/c_rd_ptr
add wave -noupdate -expand -group Coverage /TOP/DUT/c_count_up
add wave -noupdate -expand -group Coverage /TOP/DUT/c_count_down
add wave -noupdate -expand -group Coverage /TOP/DUT/sva/c_wr_ack
add wave -noupdate -expand -group Coverage /TOP/DUT/sva/c_overflow
add wave -noupdate -expand -group Coverage /TOP/DUT/sva/c_underflow
add wave -noupdate -expand -group Assertions /TOP/DUT/a_reset
add wave -noupdate -expand -group Assertions /TOP/DUT/a_full
add wave -noupdate -expand -group Assertions /TOP/DUT/a_empty
add wave -noupdate -expand -group Assertions /TOP/DUT/a_almostfull
add wave -noupdate -expand -group Assertions /TOP/DUT/a_almostempty
add wave -noupdate -expand -group Assertions /TOP/DUT/a_wr_ptr
add wave -noupdate -expand -group Assertions /TOP/DUT/a_rd_ptr
add wave -noupdate -expand -group Assertions /TOP/DUT/a_count_up
add wave -noupdate -expand -group Assertions /TOP/DUT/a_count_down
add wave -noupdate -expand -group Assertions /TOP/DUT/sva/a_wr_ack
add wave -noupdate -expand -group Assertions /TOP/DUT/sva/a_overflow
add wave -noupdate -expand -group Assertions /TOP/DUT/sva/a_underflow
run -all
add wave -position insertpoint  \
sim:/TOP/DUT/count
coverage exclude -du FIFO -togglenode rst_n
#vcover report report.ucdb -details -annotate -all -output coverage_report.txt