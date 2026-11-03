open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/netlists_v2/zs/zs_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/natural/zs/switching_zs_timesim.saif" -strip_path "tb_conv2d_engine_part_c_saif_v2/u_dut"
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/natural/zs/power_zs_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif_part_c/natural/zs/power_zs_timesim.xml"
exit
