run 110 ns
open_saif "switching_baseline_timesim.saif"
set dut_scope [lindex [get_scopes -filter {name =~ *u_dut*}] 0]
current_scope $dut_scope
log_saif [get_objects -r *]
run 11448320 ns
close_saif
run 1000 ns
exit
