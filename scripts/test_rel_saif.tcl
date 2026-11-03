open_saif "switching_test.saif"
log_saif [get_objects -r /tb_conv2d_engine_saif_timesim/u_dut/*]
run 1000 ns
close_saif
exit

