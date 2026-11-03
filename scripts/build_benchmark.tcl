# =============================================================================
# File: build_benchmark.tcl
# Description: Automated Vivado Batch Flow for Serial Conv2D Benchmark
# Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
# Design: conv2d_benchmark_top — Serial Conv2D with Hardware Cycle Counter
#
# Usage from Vivado Tcl Console:
#   set ::env(DESIGN_SELECT) 0; source scripts/build_benchmark.tcl   # 0: Baseline
#   set ::env(DESIGN_SELECT) 1; source scripts/build_benchmark.tcl   # 1: Only OI
#   set ::env(DESIGN_SELECT) 2; source scripts/build_benchmark.tcl   # 2: Only CG
#   set ::env(DESIGN_SELECT) 3; source scripts/build_benchmark.tcl   # 3: Only ZS
#   set ::env(DESIGN_SELECT) 4; source scripts/build_benchmark.tcl   # 4: Combined Full
# =============================================================================

# --- Configuration ---
set design_sel 4
if {[info exists ::env(DESIGN_SELECT)]} {
    set design_sel $::env(DESIGN_SELECT)
} elseif {[info exists ::env(USE_PROPOSED)]} {
    set design_sel [expr {$::env(USE_PROPOSED) == 1 ? 4 : 0}]
}

switch $design_sel {
    0 { set suffix "baseline"; set desc "BASELINE (Standard)" }
    1 { set suffix "oi";       set desc "ONLY OPERAND ISOLATION" }
    2 { set suffix "cg";       set desc "ONLY CLOCK GATING" }
    3 { set suffix "zs";       set desc "ONLY ZERO-SKIPPING" }
    4 { set suffix "combined"; set desc "COMBINED FULL ARCHITECTURE" }
    default { set suffix "baseline"; set desc "BASELINE (Standard)" }
}

set part_name  "xc7s15ftgb196-1"
set top_module "conv2d_benchmark_top"

puts "=================================================================="
puts " >>> SERIAL CONV2D BENCHMARK BITSTREAM BUILD <<<"
puts " Target Part   : $part_name"
puts " Top Module    : $top_module"
puts " Design Select : $design_sel ($desc)"
puts " Suffix        : $suffix"
puts "=================================================================="

# --- Create Directories ---
file mkdir "bitstreams"
file mkdir "reports"

# --- Create In-Memory Project ---
create_project -in_memory -part $part_name

# --- Add RTL Sources ---
add_files [list \
    "src/uart_rx.sv" \
    "src/uart_tx.sv" \
    "src/conv2d_serial_baseline.sv" \
    "src/conv2d_serial_oi.sv" \
    "src/conv2d_serial_cg.sv" \
    "src/conv2d_serial_zs.sv" \
    "src/conv2d_serial_combined.sv" \
    "src/conv2d_benchmark_top.sv" \
]
set_property file_type SystemVerilog [get_files *.sv]

# --- Add Physical Constraints ---
add_files -fileset constrs_1 [list "constrs/edge_s7_uart.xdc"]

# --- Step 1: Synthesis ---
puts "\n\[1/5\] Running Synthesis..."
synth_design -top $top_module -part $part_name -generic DESIGN_SELECT=$design_sel

# Post-synthesis utilization report
report_utilization -file "reports/utilization_benchmark_${suffix}.txt"
puts "  Utilization report: reports/utilization_benchmark_${suffix}.txt"

# --- Step 2: Optimization + Placement ---
puts "\n\[2/5\] Running Logic Optimization and Placement..."
opt_design
place_design

# --- Step 3: Routing ---
puts "\n\[3/5\] Running Routing..."
route_design

# --- Step 4: Post-Route Reports ---
puts "\n\[4/5\] Generating Post-Route Reports..."
report_timing_summary -max_paths 10 -file "reports/timing_benchmark_${suffix}.txt"
report_power -hier all -file "reports/power_benchmark_${suffix}.txt"
puts "  Timing report: reports/timing_benchmark_${suffix}.txt"
puts "  Power report : reports/power_benchmark_${suffix}.txt"

# --- Step 5: Bitstream Generation ---
set bit_file "bitstreams/conv2d_benchmark_${suffix}.bit"
puts "\n\[5/5\] Writing Bitstream: $bit_file..."
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force -bin_file $bit_file

puts "\n=================================================================="
puts " >>> BITSTREAM GENERATED SUCCESSFULLY! <<<"
puts " File: $bit_file"
puts " Design: [string toupper $suffix]"
puts ""
puts " NEXT STEPS:"
puts "   1. Open Hardware Manager in Vivado (or source scripts/program_fpga.tcl)"
puts "   2. Program the FPGA with: $bit_file"
puts "   3. Run Synthetic Benchmark: python run_benchmark.py --design $suffix"
puts "   4. Run Real-Image Profiler: python fpga_vision_profiler.py your_image.png --design $suffix"
puts "=================================================================="
