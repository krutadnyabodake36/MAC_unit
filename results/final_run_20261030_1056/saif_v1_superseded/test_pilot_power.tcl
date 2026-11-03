open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/baseline_routed.dcp"
read_saif -file "switching_baseline_timesim.saif" -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/reports/power_saif_baseline_pilot.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/reports/power_saif_baseline_pilot.xml"
exit
