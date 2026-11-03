open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/baseline/baseline_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/baseline/switching_baseline_timesim.saif" -strip_path "tb_conv2d_engine_part_c_saif/u_dut"
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/baseline/power_baseline_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/baseline/power_baseline_timesim.xml"
exit
