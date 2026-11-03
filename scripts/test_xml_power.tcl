set dcp_file "results/final_run_20261030_1056/saif/baseline_routed.dcp"
set saif_file "results/final_run_20261030_1056/saif/switching_baseline_timesim.saif"
open_checkpoint $dcp_file
read_saif -file $saif_file -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power -format xml -file "results/final_run_20261030_1056/reports/power_test.xml"
report_power -xpe "results/final_run_20261030_1056/reports/power_test.xpe"
exit

