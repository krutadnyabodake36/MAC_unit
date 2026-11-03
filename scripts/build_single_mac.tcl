# =============================================================================
# File: build_single_mac.tcl
# Description: Out-of-Context Synthesis & Timing Analysis for Single MAC Units
# Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C) / Artix-7
# Designs:
#   1. mac_baseline (Standard Baseline Single MAC)
#   2. mac_combined (Proposed Zero-Skipping Single MAC)
#
# Usage in Vivado:
#   vivado -mode batch -source scripts/build_single_mac.tcl
# =============================================================================

set part_name "xc7s15ftgb196-1"
file mkdir "reports"

set designs [list "mac_baseline" "mac_combined"]

foreach des $designs {
    puts "=================================================================="
    puts " >>> SYNTHESIZING SINGLE MAC: $des <<<"
    puts " Target Part: $part_name"
    puts "=================================================================="

    create_project -in_memory -part $part_name
    add_files [list "src/${des}.sv"]
    set_property file_type SystemVerilog [get_files *.sv]

    # Out-of-Context synthesis with 100 MHz target clock (10 ns)
    synth_design -top $des -part $part_name -mode out_of_context

    # Create virtual clock for timing report
    create_clock -period 10.000 -name clk [get_ports clk]

    # Generate Reports
    set suffix [expr {$des == "mac_combined" ? "proposed" : "baseline"}]
    report_utilization -file "reports/utilization_single_${suffix}.txt"
    report_timing_summary -max_paths 10 -file "reports/timing_single_${suffix}.txt"

    puts "  [DONE] Utilization: reports/utilization_single_${suffix}.txt"
    puts "  [DONE] Timing     : reports/timing_single_${suffix}.txt"

    close_project
}

puts "\n=================================================================="
puts " >>> SINGLE MAC BENCHMARK COMPLETE <<<"
puts "=================================================================="
