
vlib work
vmap work work
vcom -work work "../fifo.vhd"
vcom -work work "../Canny_Edge_Detection.vhd"
vcom -work work "../sobel_detect.vhd"
vcom -work work "../edge_detect.vhd"
vcom -work work "../edge_detect_tb.vhd"
vsim +notimingchecks -L work work.edge_detect_tb -wlf vsim.wlf
add wave -noupdate -group edge_detect_tb
add wave -noupdate -group edge_detect_tb -radix hexadecimal /edge_detect_tb/*
add wave -noupdate -group edge_detect_tb/edge_detect_inst 
add wave -noupdate -group edge_detect_tb/edge_detect_inst  -radix hexadecimal /edge_detect_tb/edge_detect_inst/*
add wave -noupdate -group edge_detect_tb/edge_detect_inst/gray_scale
add wave -noupdate -group edge_detect_tb/edge_detect_inst/gray_scale -radix hexadecimal /edge_detect_tb/edge_detect_inst/gray_scale/*
add wave -noupdate -group edge_detect_tb/edge_detect_inst/sobel_detection
add wave -noupdate -group edge_detect_tb/edge_detect_inst/sobel_detection -radix hexadecimal /edge_detect_tb/edge_detect_inst/sobel_detection/*
add wave -noupdate -group edge_detect_tb/edge_detect_inst/a_fifo
add wave -noupdate -group edge_detect_tb/edge_detect_inst/a__fifo -radix hexadecimal /edge_detect_tb/edge_detect_inst/a_fifo/*
add wave -noupdate -group edge_detect_tb/edge_detect_inst/b_fifo
add wave -noupdate -group edge_detect_tb/edge_detect_inst/b_fifo -radix hexadecimal /edge_detect_tb/edge_detect_inst/b_fifo/*
add wave -noupdate -group edge_detect_tb/edge_detect_inst/c_fifo
add wave -noupdate -group edge_detect_tb/edge_detect_inst/c_fifo -radix hexadecimal /edge_detect_tb/edge_detect_inst/c_fifo/*
run -all