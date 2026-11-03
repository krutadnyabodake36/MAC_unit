# =============================================================================
# File: scripts/apply_saif_pilot.tcl
# Description: Apply SAIF to routed baseline design and generate power report
# =============================================================================

set dcp_file "results/final_run_20261030_1056/saif/baseline_routed.dcp"
set saif_file "results/final_run_20261030_1056/saif/switching_baseline.saif"
set rpt_file "results/final_run_20261030_1056/reports/power_saif_baseline.txt"

puts "=================================================================="
puts " >>> APPLYING SAIF TO ROUTED BASELINE DESIGN <<<"
puts " Checkpoint : $dcp_file"
puts " SAIF file  : $saif_file"
puts " Report     : $rpt_file"
puts "=================================================================="

open_checkpoint $dcp_file

# Apply SAIF with strip_path
read_saif -file $saif_file -strip_path tb_conv2d_engine_saif/u_dut

# Report power with full hierarchy
report_power -hier all -file $rpt_file

puts "\n=================================================================="
puts " >>> SAIF POWER REPORT GENERATED SUCCESSFULLY <<<"
puts "=================================================================="

