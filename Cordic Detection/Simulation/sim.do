
vlib work
vmap work work
vcom -work work "../fifo.vhd"
vcom -work work "../cordic.vhd"
vcom -work work "../cordic_stage.vhd"
vcom -work work "../cordic_top.vhd"
vcom -work work "../cordic_top_tb.vhd"
vsim +notimingchecks -L work work.cordic_top_tb -wlf vsim.wlf
add wave -noupdate -group cordic_top_tb
add wave -noupdate -group cordic_top_tb -radix hexadecimal /cordic_top_tb/*
add wave -noupdate -group cordic_top_tb/tb_inst 
add wave -noupdate -group cordic_top_tb/tb_inst  -radix hexadecimal /cordic_top_tb/tb_inst/*
add wave -noupdate -group cordic_top_tb/tb_inst/cordic_main
add wave -noupdate -group cordic_top_tb/tb_inst/cordic_main -radix hexadecimal /cordic_top_tb/tb_inst/cordic_main/*
add wave -noupdate -group cordic_top_tb/tb_inst/in_fifo
add wave -noupdate -group cordic_top_tb/tb_inst/in_fifo -radix hexadecimal /cordic_top_tb/tb_inst/in_fifo/*
add wave -noupdate -group cordic_top_tb/tb_inst/sin_fifo
add wave -noupdate -group cordic_top_tb/tb_inst/sin_fifo -radix hexadecimal /cordic_top_tb/tb_inst/sin_fifo/*
add wave -noupdate -group cordic_top_tb/tb_inst/cosine_fifo
add wave -noupdate -group cordic_top_tb/tb_inst/cosine_fifo -radix hexadecimal /cordic_top_tb/tb_inst/cosine_fifo/*
run -all