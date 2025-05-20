vlib work
vlog +fcover +acc -f source.list
vsim -voptargs=+acc work.tb



onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/IF/FIFO_WIDTH
add wave -noupdate /tb/IF/FIFO_DEPTH
add wave -noupdate /tb/IF/clk
add wave -noupdate /tb/IF/data_in
add wave -noupdate /tb/IF/rst_n
add wave -noupdate /tb/IF/wr_en
add wave -noupdate /tb/IF/rd_en
add wave -noupdate /tb/IF/data_out
add wave -noupdate /tb/IF/wr_ack
add wave -noupdate /tb/IF/overflow
add wave -noupdate /tb/IF/full
add wave -noupdate /tb/IF/empty
add wave -noupdate /tb/IF/almostfull
add wave -noupdate /tb/IF/underflow
add wave -noupdate -color Gold /tb/DUT/wr_ptr
add wave -noupdate -color Gold /tb/DUT/rd_ptr
add wave -noupdate -color Gold /tb/DUT/count
add wave -noupdate -color Salmon /tb/IF/almostempty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {128 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update




run -all
