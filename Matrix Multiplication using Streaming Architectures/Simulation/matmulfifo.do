
vlib work
vmap work work
vcom -work work "../fifo.vhd"
vcom -work work "../matmulfifo.vhd"
vcom -work work "../matmulfifotop.vhd"
vcom -work work "../fifo_multiply_top_tb.vhd"
vsim +notimingchecks -L work work.fifo_multiply_top_tb -wlf matmulfifo_sim.wlf
add wave -noupdate -group fifo_multiply_top_tb
add wave -noupdate -group fifo_multiply_top_tb -radix hexadecimal /fifo_multiply_top_tb/*
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst -radix hexadecimal /fifo_multiply_top_tb/matmulfifotop_inst/*
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/matmulfifo_inst
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/matmulfifo_inst -radix hexadecimal /fifo_multiply_top_tb/matmulfifotop_inst/matmulfifo/*
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/a_fifo
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/a__fifo -radix hexadecimal /fifo_multiply_top_tb/matmulfifotop_inst/a_fifo/*
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/b_fifo
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/b_fifo -radix hexadecimal /fifo_multiply_top_tb/matmulfifotop_inst/b_fifo/*
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/c_fifo
add wave -noupdate -group fifo_multiply_top_tb/matmulfifotop_inst/c_fifo -radix hexadecimal /fifo_multiply_top_tb/matmulfifotop_inst/c_fifo/*
run -all