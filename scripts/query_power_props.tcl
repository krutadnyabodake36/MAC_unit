open_checkpoint results/final_run_20261030_1056/saif/baseline_routed.dcp
read_saif -file results/final_run_20261030_1056/saif/switching_baseline_timesim.saif -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power
set cell [get_cells gen_engine.u_core]
puts "CELL PROPERTIES:"
report_property $cell
exit

