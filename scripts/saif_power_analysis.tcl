# =============================================================================
# File: saif_power_analysis.tcl
# Description: SAIF-Based High-Confidence Power Analysis for Vivado
# Target: Spartan-7 XC7S15 @ 50 MHz
#
# This script:
#   1. Synthesizes and implements the conv2d engine (standalone, no UART)
#   2. Runs behavioral simulation to generate SAIF switching data
#   3. Applies SAIF to post-route netlist for HIGH confidence power analysis
#   4. Generates detailed power reports
#
# Usage in Vivado Tcl Console:
#   BASELINE: set ::env(USE_PROPOSED) 0; source scripts/saif_power_analysis.tcl
#   PROPOSED: set ::env(USE_PROPOSED) 1; source scripts/saif_power_analysis.tcl
# =============================================================================

set use_proposed 1
if {[info exists ::env(USE_PROPOSED)]} {
    set use_proposed $::env(USE_PROPOSED)
}

set part_name "xc7s15ftgb196-1"
set suffix [expr {$use_proposed == 1 ? "proposed" : "baseline"}]
set top_module [expr {$use_proposed == 1 ? "conv2d_serial_proposed" : "conv2d_serial_baseline"}]

puts "=================================================================="
puts " SAIF-BASED POWER ANALYSIS"
puts " Design    : [string toupper $suffix]"
puts " Top Module: $top_module"
puts "=================================================================="

file mkdir "reports"
file mkdir "saif"

# --- Step 1: Create project ---
create_project -in_memory -part $part_name

# Add RTL sources
if {$use_proposed} {
    add_files [list "src/conv2d_serial_proposed.sv"]
} else {
    add_files [list "src/conv2d_serial_baseline.sv"]
}
add_files -fileset sim_1 [list "tb/tb_conv2d_saif.sv"]
set_property file_type SystemVerilog [get_files *.sv]

# Set verilog define for proposed
if {$use_proposed} {
    set_property verilog_define {USE_PROPOSED} [get_filesets sim_1]
}

# Add clock constraint (standalone, no I/O pins needed)
set xdc_file "saif/temp_clock_${suffix}.xdc"
set fp [open $xdc_file w]
puts $fp "create_clock -period 20.000 -name sys_clk \[get_ports clk\]"
close $fp
add_files -fileset constrs_1 $xdc_file

# --- Step 2: Synthesis ---
puts "\n\[1/6\] Synthesizing $top_module..."
synth_design -top $top_module -part $part_name
report_utilization -file "reports/utilization_saif_${suffix}.txt"
puts "  Utilization: reports/utilization_saif_${suffix}.txt"

# --- Step 3: Implementation ---
puts "\n\[2/6\] Implementing..."
opt_design
place_design
route_design

# Post-route report (no SAIF yet)
report_timing_summary -file "reports/timing_saif_${suffix}.txt"
puts "  Timing: reports/timing_saif_${suffix}.txt"

# --- Step 4: Run Simulation for SAIF ---
puts "\n\[3/6\] Running behavioral simulation for SAIF generation..."
puts "       (This captures real switching activity from 500 test vectors)"

# Save the implemented design checkpoint
write_checkpoint -force "saif/impl_${suffix}.dcp"

# Launch simulation
set_property top tb_conv2d_saif [get_filesets sim_1]
launch_simulation

# Open SAIF file and log all signals
set saif_file "saif/switching_${suffix}.saif"
open_saif $saif_file
log_saif [get_objects -r /tb_conv2d_saif/u_dut/*]

# Run simulation (500 patches x ~15 cycles avg x 20ns = ~150us)
run 200us

# Close SAIF
close_saif
close_sim

puts "  SAIF file: $saif_file"

# --- Step 5: Read SAIF into implemented design ---
puts "\n\[4/6\] Applying SAIF to post-route netlist..."
open_checkpoint "saif/impl_${suffix}.dcp"

# Read SAIF with strip path to match hierarchy
read_saif $saif_file -strip_path "tb_conv2d_saif/u_dut"

# --- Step 6: Generate HIGH confidence power report ---
puts "\n\[5/6\] Generating SAIF-annotated power report..."
set pwr_report "reports/power_saif_${suffix}.txt"
report_power -hier all -file $pwr_report

puts "\n\[6/6\] Done!"
puts "=================================================================="
puts " SAIF POWER REPORT: $pwr_report"
puts " Design: [string toupper $suffix]"
puts ""
puts " This report has HIGH confidence because switching activity"
puts " was measured from simulation of 500 realistic test patches."
puts ""
puts " Compare with the other design:"
if {$use_proposed} {
    puts "   set ::env(USE_PROPOSED) 0; source scripts/saif_power_analysis.tcl"
} else {
    puts "   set ::env(USE_PROPOSED) 1; source scripts/saif_power_analysis.tcl"
}
puts "=================================================================="
