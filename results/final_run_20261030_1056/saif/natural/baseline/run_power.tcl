open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/netlists_v2/baseline/baseline_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/baseline/switching_baseline_timesim.saif" -strip_path "tb_conv2d_engine_saif_timesim_v2/u_dut"
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/baseline/power_baseline_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/baseline/power_baseline_timesim.xml"
exit
