open_saif "switching_static_sobel_timesim.saif"
log_saif [get_objects -r /tb_conv2d_engine_saif_timesim/u_dut/*]
run 7045240 ns
close_saif
exit
