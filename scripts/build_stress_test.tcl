# =============================================================================
# File: build_stress_test.tcl
# Description: Build stress test bitstreams for board-level power measurement
# Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
#
# Usage from Vivado Tcl Console:
#   Baseline:  set ::env(USE_PROPOSED) 0; source scripts/build_stress_test.tcl
#   Proposed:  set ::env(USE_PROPOSED) 1; source scripts/build_stress_test.tcl
# =============================================================================

set use_proposed 1
if {[info exists ::env(USE_PROPOSED)]} {
    set use_proposed $::env(USE_PROPOSED)
}

set part_name  "xc7s15ftgb196-1"
set top_module "conv2d_stress_test_top"
set suffix     [expr {$use_proposed == 1 ? "proposed" : "baseline"}]

puts "=================================================================="
puts " >>> STRESS TEST BITSTREAM BUILD (Board-Level Power Measurement) <<<"
puts " Design : [expr {$use_proposed == 1 ? "PROPOSED (Zero-Skipping)" : "BASELINE (Standard)"}]"
puts "=================================================================="

file mkdir "bitstreams"
file mkdir "reports"
create_project -in_memory -part $part_name

add_files [list \
    "src/conv2d_serial_baseline.sv" \
    "src/conv2d_serial_proposed.sv" \
    "src/conv2d_stress_test_top.sv" \
]
set_property file_type SystemVerilog [get_files *.sv]

# Minimal XDC: only clk, btnC, and one output (RsTx as anti-optimization)
add_files -fileset constrs_1 [list "constrs/edge_s7_uart.xdc"]

# Synthesis
puts "\n[1/5] Synthesis..."
synth_design -top $top_module -part $part_name -generic USE_PROPOSED=$use_proposed
report_utilization -file "reports/utilization_stress_${suffix}.txt"

# Implementation
puts "\n[2/5] Optimization + Placement..."
opt_design
place_design

puts "\n[3/5] Routing..."
route_design

# Reports
puts "\n[4/5] Reports..."
report_timing_summary -max_paths 10 -file "reports/timing_stress_${suffix}.txt"
report_power -hier all -file "reports/power_stress_${suffix}.txt"

# Bitstream
set bit_file "bitstreams/stress_test_${suffix}.bit"
puts "\n[5/5] Bitstream: $bit_file"
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force -bin_file $bit_file

puts "\n=================================================================="
puts " >>> STRESS TEST BITSTREAM COMPLETE: $bit_file <<<"
puts " Program FPGA, wait 10s, read USB power meter."
puts "=================================================================="
