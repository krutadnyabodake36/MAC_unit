open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/zs/zs_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/zs/switching_zs_timesim.saif" -strip_path "tb_conv2d_engine_saif_timesim_rotated/u_dut"
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/zs/power_zs_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/rotated/zs/power_zs_timesim.xml"
exit
