open_saif "switching_baseline_timesim.saif"
log_saif [get_objects -r /tb_conv2d_engine_saif_timesim/u_dut/*]
run 9687160 ns
close_saif
exit
