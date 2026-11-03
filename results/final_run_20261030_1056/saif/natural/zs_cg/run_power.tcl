open_checkpoint "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/netlists_v2/zs_cg/zs_cg_routed.dcp"
read_saif -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/zs_cg/switching_zs_cg_timesim.saif" -strip_path "tb_conv2d_engine_saif_timesim_v2/u_dut"
report_power -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/zs_cg/power_zs_cg_timesim.txt"
report_power -format xml -file "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/zs_cg/power_zs_cg_timesim.xml"
exit
