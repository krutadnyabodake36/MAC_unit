# Apply timesim SAIF to routed design and report power
set dcp_file "results/final_run_20261030_1056/saif/baseline_routed.dcp"
set saif_file "results/final_run_20261030_1056/saif/switching_baseline_timesim.saif"
set rpt_file "results/final_run_20261030_1056/reports/power_saif_baseline_timesim.txt"

puts "=================================================================="
puts " >>> APPLYING TIMESIM SAIF TO ROUTED BASELINE DESIGN <<<"
puts " Checkpoint : $dcp_file"
puts " SAIF file  : $saif_file"
puts " Report     : $rpt_file"
puts "=================================================================="

open_checkpoint $dcp_file

read_saif -file $saif_file -strip_path tb_conv2d_engine_saif_timesim/u_dut

report_power -hier all -file $rpt_file

puts "\n=================================================================="
puts " >>> SAIF POWER REPORT GENERATED SUCCESSFULLY <<<"
puts "=================================================================="

