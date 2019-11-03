
vlib work
vmap work work
vcom -work work "../bram.vhd"
vcom -work work "../bram_block.vhd"
vcom -work work "../matmul.vhd"
vcom -work work "../matmultop.vhd"
vcom -work work "../matmultop_tb.vhd"
vsim +notimingchecks -L work work.matmultop_tb -wlf vsim.wlf
add wave -noupdate -group matmultop_tb
add wave -noupdate -group matmultop_tb -radix hexadecimal /matmultop_tb/*
add wave -noupdate -group matmultop_tb/matmultop_inst
add wave -noupdate -group matmultop_tb/matmultop_inst -radix hexadecimal /matmultop_tb/matmultop_inst/*
add wave -noupdate -group matmultop_tb/matmultop_inst/matmul_inst
add wave -noupdate -group matmultop_tb/matmultop_inst/matmul_inst -radix hexadecimal /matmultop_tb/matmultop_inst/matmul_inst/*
add wave -noupdate -group matmultop_tb/matmultop_inst/x_inst
add wave -noupdate -group matmultop_tb/matmultop_inst/x_inst -radix hexadecimal /matmultop_tb/matmultop_inst/x_inst/*
add wave -noupdate -group matmultop_tb/matmultop_inst/y_inst
add wave -noupdate -group matmultop_tb/matmultop_inst/y_inst -radix hexadecimal /matmultop_tb/matmultop_inst/y_inst/*
add wave -noupdate -group matmultop_tb/matmultop_inst/z_inst
add wave -noupdate -group matmultop_tb/matmultop_inst/z_inst -radix hexadecimal /matmultop_tb/matmultop_inst/z_inst/*
run -all