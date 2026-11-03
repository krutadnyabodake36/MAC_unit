# =============================================================================
# File: scripts/build_final_run_8var.tcl
# Description: Automated Vivado Batch Flow for 8-Configuration Ablation
# Uses conv2d_benchmark_top_ablation as top module
# Writes directly to results/final_run_20261030_1056/{reports,bitstreams}/
# Generates hierarchical utilization to prove engine instantiation
# =============================================================================

set design_sel 5
if {[info exists ::env(DESIGN_SELECT)]} {
    set design_sel $::env(DESIGN_SELECT)
}

switch $design_sel {
    0 { set suffix "baseline"; set desc "BASELINE" }
    1 { set suffix "oi";       set desc "ONLY OPERAND ISOLATION" }
    2 { set suffix "cg";       set desc "ONLY CLOCK GATING" }
    3 { set suffix "zs";       set desc "ONLY ZERO-SKIPPING" }
    4 { set suffix "combined"; set desc "COMBINED FULL ARCHITECTURE" }
    5 { set suffix "zs_oi";    set desc "ZERO-SKIPPING + OPERAND ISOLATION" }
    6 { set suffix "zs_cg";    set desc "ZERO-SKIPPING + CLOCK GATING" }
    7 { set suffix "oi_cg";    set desc "OPERAND ISOLATION + CLOCK GATING" }
    default { set suffix "baseline"; set desc "BASELINE" }
}

set part_name   "xc7s15ftgb196-1"
set top_module  "conv2d_benchmark_top_ablation"
set out_dir     "results/final_run_20261030_1056"
set rpt_dir     "$out_dir/reports"
set bit_dir     "$out_dir/bitstreams"

file mkdir $rpt_dir
file mkdir $bit_dir

puts "=================================================================="
puts " >>> 8-VARIANT SYNTHESIS & IMPLEMENTATION <<<"
puts " Target Part   : $part_name"
puts " Top Module    : $top_module"
puts " Design Select : $design_sel ($desc)"
puts " Suffix        : $suffix"
puts " Reports Dir   : $rpt_dir"
puts " Bitstream Dir : $bit_dir"
puts "=================================================================="

create_project -in_memory -part $part_name

add_files [list \
    "src/uart_rx.sv" \
    "src/uart_tx.sv" \
    "src/conv2d_serial_baseline.sv" \
    "src/conv2d_serial_oi.sv" \
    "src/conv2d_serial_cg.sv" \
    "src/conv2d_serial_zs.sv" \
    "src/conv2d_serial_zs_oi.sv" \
    "src/conv2d_serial_zs_cg.sv" \
    "src/conv2d_serial_oi_cg.sv" \
    "src/conv2d_serial_combined.sv" \
    "src/conv2d_benchmark_top_ablation.sv" \
]
set_property file_type SystemVerilog [get_files *.sv]
add_files -fileset constrs_1 [list "constrs/edge_s7_uart.xdc"]

# 1. Synthesis
puts "\n\[1/5\] Running Synthesis for $suffix (DESIGN_SELECT=$design_sel)..."
synth_design -top $top_module -part $part_name -generic DESIGN_SELECT=$design_sel

report_utilization -file "$rpt_dir/utilization_benchmark_${suffix}.txt"
report_utilization -hierarchical -file "$rpt_dir/utilization_hierarchical_${suffix}.txt"

# 2. Optimization + Placement
puts "\n\[2/5\] Running Logic Optimization and Placement..."
opt_design
place_design

# 3. Routing
puts "\n\[3/5\] Running Routing..."
route_design

# 4. Post-Route Reports
puts "\n\[4/5\] Generating Post-Route Reports..."
report_timing_summary -max_paths 10 -file "$rpt_dir/timing_benchmark_${suffix}.txt"
report_power -hier all -file "$rpt_dir/power_benchmark_${suffix}.txt"

# 5. Bitstream Generation
set bit_file "$bit_dir/conv2d_benchmark_${suffix}.bit"
puts "\n\[5/5\] Writing Bitstream: $bit_file..."
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force -bin_file $bit_file

puts "\n=================================================================="
puts " >>> $suffix BUILD COMPLETED SUCCESSFULLY! <<<"
puts " Bitstream: $bit_file"
puts "=================================================================="

