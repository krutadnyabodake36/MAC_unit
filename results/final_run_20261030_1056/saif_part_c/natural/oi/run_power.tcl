open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/netlists_v2/oi/oi_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/natural/oi/switching_oi_timesim.saif" -strip_path "tb_conv2d_engine_part_c_saif_v2/u_dut"
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/natural/oi/power_oi_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/natural/oi/power_oi_timesim.xml"
exit
