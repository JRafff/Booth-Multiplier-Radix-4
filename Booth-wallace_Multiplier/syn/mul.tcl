#SCRIPT FOR SPEEDING UP and RECORDING the MULTIPLIER SYNTHESIS#
analyze -library WORK -format vhdl {constants.vhd}
analyze -library WORK -format vhdl {fa.vhd}
analyze -library WORK -format vhdl {ha.vhd}
analyze -library WORK -format vhdl {rca_generic.vhd}
analyze -library WORK -format vhdl {IV.vhd}
analyze -library WORK -format vhdl {ND2_GENERIC.vhd}
analyze -library WORK -format vhdl {mux21_generic.vhd}
analyze -library WORK -format vhdl {CSB.vhd}
analyze -library WORK -format vhdl {PG_block.vhd}
analyze -library WORK -format vhdl {pg_network.vhd}
analyze -library WORK -format vhdl {G_block.vhd}
analyze -library WORK -format vhdl {SUM_GENERATOR.vhd}
analyze -library WORK -format vhdl {CarryGen.vhd}
analyze -library WORK -format vhdl {P4_ADDER.vhd}
analyze -library WORK -format vhdl {MUX5to1.vhd}
analyze -library WORK -format vhdl {ENC_BOOTH.vhd}
analyze -library WORK -format vhdl {BOOTHMUL.vhd}

elaborate BOOTHMUL -architecture STRUCTURAL 

# first compilation, without constraints #
compile

# reporting riming and power after the first synthesis without constraints #
report_timing > mul-timing-no-opt.txt
report_area > mul-area-no-opt.txt
report_power > mul-power-no-opt.txt

set_max_delay 2 -from [all_inputs] -to [all_outputs]
# optimize

compile -map_effort high
# save report

report_timing > mul-timing-opt.txt
report_area > mul-area-opt.txt
report_power > mul-power-opt.txt

#  Esportazione della Netlist 
write -hierarchy -format vhdl -output BOOTHMUL_netlist.vhd
