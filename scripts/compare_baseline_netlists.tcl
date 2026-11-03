set pilot_dcp "results/final_run_20261030_1056/saif/natural/baseline/baseline_routed.dcp"
set rerun_dcp "results/final_run_20261030_1056/saif/natural_rerun/baseline/baseline_routed.dcp"

set fp [open "results/final_run_20261030_1056/saif/baseline_netlists_comparison.txt" w]

puts $fp "=== BASELINE PILOT NETLIST CELL COUNTS ==="
open_checkpoint $pilot_dcp
set cells_pilot [get_cells -hierarchical]
puts $fp "Total cells: [llength $cells_pilot]"
report_property [current_design] -file "results/final_run_20261030_1056/saif/pilot_design_props.txt"
report_utilization -file "results/final_run_20261030_1056/saif/pilot_util.txt"

# Group by ref_name
set ref_counts_pilot [dict create]
foreach c $cells_pilot {
    set ref [get_property REF_NAME $c]
    dict incr ref_counts_pilot $ref
}
dict for {k v} $ref_counts_pilot {
    puts $fp "  $k: $v"
}
close_project

puts $fp "\n=== BASELINE RERUN NETLIST CELL COUNTS ==="
open_checkpoint $rerun_dcp
set cells_rerun [get_cells -hierarchical]
puts $fp "Total cells: [llength $cells_rerun]"
report_property [current_design] -file "results/final_run_20261030_1056/saif/rerun_design_props.txt"
report_utilization -file "results/final_run_20261030_1056/saif/rerun_util.txt"

set ref_counts_rerun [dict create]
foreach c $cells_rerun {
    set ref [get_property REF_NAME $c]
    dict incr ref_counts_rerun $ref
}
dict for {k v} $ref_counts_rerun {
    puts $fp "  $k: $v"
}
close_project

close $fp
puts "Cell count comparison complete!"
exit

