vlib work
vmap work work
vcom -work work ../constants.vhd
vcom -work work ../components.vhd
vcom -work work ../fuctions.vhd
vcom -work work ../fifo.vhd
vcom -work work ../multiply.vhd
vcom -work work ../addsub.vhd
vcom -work work ../read_iq.vhd
vcom -work work ../gain.vhd
vcom -work work ../fir.vhd
vcom -work work ../fir_decimated.vhd
vcom -work work ../fir_complex.vhd
vcom -work work ../iir.vhd
vcom -work work ../demod.vhd
vcom -work work ../radio.vhd
vcom -work work ../testbench.vhd
vsim +notimingchecks -L work work.radio_tb -wlf vsim.wlf

add wave -noupdate -group radio_tb
add wave -noupdate -group radio_tb -radix hexadecimal /radio_tb/*
add wave -noupdate -group radio_tb/tb_inst 
add wave -noupdate -group radio_tb/tb_inst  -radix hexadecimal /radio_tb/tb_inst/*
add wave -noupdate -group radio_tb/tb_inst/fifo_read
add wave -noupdate -group radio_tb/tb_inst/fifo_read -radix hexadecimal /radio_tb/tb_inst/fifo_read/*
add wave -noupdate -group radio_tb/tb_inst/read_inst
add wave -noupdate -group radio_tb/tb_inst/read_inst -radix hexadecimal /radio_tb/tb_inst/read_inst/*
add wave -noupdate -group radio_tb/tb_inst/i_buffer
add wave -noupdate -group radio_tb/tb_inst/i_buffer -radix hexadecimal /radio_tb/tb_inst/i_buffer/*
add wave -noupdate -group radio_tb/tb_inst/q_buffer
add wave -noupdate -group radio_tb/tb_inst/q_buffer -radix hexadecimal /radio_tb/tb_inst/q_buffer/*
add wave -noupdate -group radio_tb/tb_inst/i_filter
add wave -noupdate -group radio_tb/tb_inst/i_filter -radix hexadecimal /radio_tb/tb_inst/i_filter/*
add wave -noupdate -group radio_tb/tb_inst/q_filter
add wave -noupdate -group radio_tb/tb_inst/q_filter -radix hexadecimal /radio_tb/tb_inst/q_filter/*
add wave -noupdate -group radio_tb/tb_inst/right_channel_buffer
add wave -noupdate -group radio_tb/tb_inst/right_channel_buffer -radix hexadecimal /radio_tb/tb_inst/right_channel_buffer/*
add wave -noupdate -group radio_tb/tb_inst/right_low_buffer
add wave -noupdate -group radio_tb/tb_inst/right_low_buffer -radix hexadecimal /radio_tb/tb_inst/right_low_buffer/*
add wave -noupdate -group radio_tb/tb_inst/left_channel_buffer
add wave -noupdate -group radio_tb/tb_inst/left_channel_buffer -radix hexadecimal /radio_tb/tb_inst/left_channel_buffer/*
add wave -noupdate -group radio_tb/tb_inst/left_band_buffer
add wave -noupdate -group radio_tb/tb_inst/left_band_buffer -radix hexadecimal /radio_tb/tb_inst/left_band_buffer/*
add wave -noupdate -group radio_tb/tb_inst/pre_pilot_buffer
add wave -noupdate -group radio_tb/tb_inst/pre_pilot_buffer -radix hexadecimal /radio_tb/tb_inst/pre_pilot_buffer/*
add wave -noupdate -group radio_tb/tb_inst/pilot_filtered_buffer
add wave -noupdate -group radio_tb/tb_inst/pilot_filtered_buffer -radix hexadecimal /radio_tb/tb_inst/pilot_filtered_buffer/*
add wave -noupdate -group radio_tb/tb_inst/pilot_squared_buffer
add wave -noupdate -group radio_tb/tb_inst/pilot_squared_buffer -radix hexadecimal /radio_tb/tb_inst/pilot_squared_buffer/*
add wave -noupdate -group radio_tb/tb_inst/pilot_buffer
add wave -noupdate -group radio_tb/tb_inst/pilot_buffer -radix hexadecimal /radio_tb/tb_inst/pilot_buffer/*
add wave -noupdate -group radio_tb/tb_inst/left_multiplied_buffer
add wave -noupdate -group radio_tb/tb_inst/left_multiplied_buffer -radix hexadecimal /radio_tb/tb_inst/left_multiplied_buffer/*
add wave -noupdate -group radio_tb/tb_inst/left_low_buffer
add wave -noupdate -group radio_tb/tb_inst/left_low_buffer -radix hexadecimal /radio_tb/tb_inst/left_low_buffer/*
add wave -noupdate -group radio_tb/tb_inst/left_emph_buffer
add wave -noupdate -group radio_tb/tb_inst/left_emph_buffer -radix hexadecimal /radio_tb/tb_inst/left_emph_buffer/*
add wave -noupdate -group radio_tb/tb_inst/right_emph_buffer
add wave -noupdate -group radio_tb/tb_inst/right_emph_buffer -radix hexadecimal /radio_tb/tb_inst/right_emph_buffer/*
add wave -noupdate -group radio_tb/tb_inst/left_deemph_buffer
add wave -noupdate -group radio_tb/tb_inst/left_deemph_buffer -radix hexadecimal /radio_tb/tb_inst/left_deemph_buffer/*
add wave -noupdate -group radio_tb/tb_inst/right_deemph_buffer
add wave -noupdate -group radio_tb/tb_inst/right_deemph_buffer -radix hexadecimal /radio_tb/tb_inst/right_deemph_buffer/*
add wave -noupdate -group radio_tb/tb_inst/left_gain_buffer
add wave -noupdate -group radio_tb/tb_inst/left_gain_buffer -radix hexadecimal /radio_tb/tb_inst/left_gain_buffer/*
add wave -noupdate -group radio_tb/tb_inst/right_gain_buffer
add wave -noupdate -group radio_tb/tb_inst/right_gain_buffer -radix hexadecimal /radio_tb/tb_inst/right_gain_buffer/*

run -all