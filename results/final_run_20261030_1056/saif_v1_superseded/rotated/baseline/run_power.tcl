open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/baseline/baseline_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/baseline/switching_baseline_timesim.saif" -strip_path "tb_conv2d_engine_saif_timesim_rotated/u_dut"
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/baseline/power_baseline_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/baseline/power_baseline_timesim.xml"
exit
