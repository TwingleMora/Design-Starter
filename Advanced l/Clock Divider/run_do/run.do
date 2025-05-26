vlib work
vlog -f sourcefile.txt
vsim -voptargs=+acc work.ClkDivTB
add wave -position insertpoint  \
sim:/ClkDivTB/period \
sim:/ClkDivTB/hp \
sim:/ClkDivTB/i_ref_clk \
sim:/ClkDivTB/i_rst_n \
sim:/ClkDivTB/i_clk_en \
sim:/ClkDivTB/div2 \
sim:/ClkDivTB/div3 \
sim:/ClkDivTB/div4 \
sim:/ClkDivTB/div5 \
sim:/ClkDivTB/div6 \
sim:/ClkDivTB/exp_div2 \
sim:/ClkDivTB/exp_div3 \
sim:/ClkDivTB/exp_div4 \
sim:/ClkDivTB/exp_div5 \
sim:/ClkDivTB/exp_div6 \
sim:/ClkDivTB/test_result

run -all
