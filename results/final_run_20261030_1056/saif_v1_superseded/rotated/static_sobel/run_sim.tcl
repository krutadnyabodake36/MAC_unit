open_saif "switching_static_sobel_timesim.saif"
set dut_scope [lindex [get_scopes -filter {name =~ *u_dut*}] 0]
current_scope $dut_scope
log_saif [get_objects -r *]
run 7045240 ns
close_saif
exit
