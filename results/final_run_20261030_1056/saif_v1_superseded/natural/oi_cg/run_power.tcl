open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/oi_cg/oi_cg_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/oi_cg/switching_oi_cg_timesim.saif" -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/oi_cg/power_oi_cg_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/oi_cg/power_oi_cg_timesim.xml"
exit
