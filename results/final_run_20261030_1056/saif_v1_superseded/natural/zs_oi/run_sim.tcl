open_saif "switching_zs_oi_timesim.saif"
log_saif [get_objects -r /tb_conv2d_engine_saif_timesim/u_dut/*]
run 6947480 ns
close_saif
exit
