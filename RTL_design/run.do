vlib work

vlog Spartan6_DSP48A1.v reg_mux.v DSP_tb.v

vsim -voptargs=+acc DSP_tb

add wave *

run -all

#quit -sim
