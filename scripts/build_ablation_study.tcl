# =============================================================================
# File: build_ablation_study.tcl
# Description: Out-of-Context Synthesis, Implementation, Timing & Power Analysis
#              for the Complete Single MAC Ablation Suite on Spartan-7:
#                1. mac_baseline (Control / No Low-Power Techniques)
#                2. mac_oi       (Only Operand Isolation)
#                3. mac_cg       (Only Clock Gating)
#                4. mac_combined (Combined Operand Isolation + Clock Gating)
#
# Target Part: xc7s15ftgb196-1 (Invent Logics EDGE Spartan-7 @ 50 MHz)
# =============================================================================

set part_name "xc7s15ftgb196-1"
file mkdir "reports"

set ablation_designs [list "mac_baseline" "mac_oi" "mac_cg" "mac_combined"]

foreach des $ablation_designs {
    puts "\n=================================================================="
    puts " >>> ABLATION RUN: $des <<<"
    puts " Target Device: $part_name | Frequency: 50 MHz (20.0 ns)"
    puts "=================================================================="

    create_project -in_memory -part $part_name
    add_files [list "src/${des}.sv"]
    set_property file_type SystemVerilog [get_files *.sv]

    # Synthesis in Out-of-Context mode
    synth_design -top $des -part $part_name -mode out_of_context

    # Primary 50 MHz Clock Constraint (20.000 ns)
    create_clock -period 20.000 -name clk [get_ports clk]

    # Run physical implementation for post-route metrics
    opt_design
    place_design
    route_design

    # Generate Reports
    report_utilization -file "reports/utilization_ablation_${des}.txt"
    report_timing_summary -max_paths 10 -file "reports/timing_ablation_${des}.txt"
    report_power -hier all -file "reports/power_ablation_${des}.txt"

    puts " +++ DONE: Saved reports for: $des"
    close_project
}

puts "\n=================================================================="
puts " >>> ABLATION STUDY SYNTHESIS & ROUTING COMPLETE <<<"
puts "=================================================================="
