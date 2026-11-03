open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/combined/combined_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/combined/switching_combined_timesim.saif" -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/combined/power_combined_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/combined/power_combined_timesim.xml"
exit
