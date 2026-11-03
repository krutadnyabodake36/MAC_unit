# ==============================================================================
# File: create_vivado_project.tcl
# Target Board: Invent Logics EDGE Spartan-7 FPGA Development Board
# Target Part: XC7S15-1FTGB196C (50 MHz System Clock)
# Project: Zero-Skipping Low-Power MAC Architecture for Edge AI
#
# Description:
#   Master Vivado Project Generation & Configuration Script.
#   Generates the complete, persistent Vivado IDE project file (mac_zero_skipping.xpr)
#   with all synthesizable SystemVerilog RTL sources, testbenches, physical
#   constraints, and synthesis/implementation runs properly configured.
#
# Usage from Vivado Tcl Console:
#   source scripts/create_vivado_project.tcl
#
# Usage from Windows PowerShell / Command Prompt:
#   vivado -mode batch -source scripts/create_vivado_project.tcl
#   vivado mac_zero_skipping/mac_zero_skipping.xpr &
# ==============================================================================

set project_name "mac_zero_skipping"
set project_dir  "./${project_name}"
set part_name    "xc7s15ftgb196-1"
set top_module   "conv2d_benchmark_top"

puts "=================================================================="
puts " >>> CREATING MASTER VIVADO PROJECT: $project_name <<<"
puts " Target Part  : $part_name (Edge Spartan-7)"
puts " Top Module   : $top_module"
puts " Location     : [file normalize $project_dir]"
puts "=================================================================="

# ------------------------------------------------------------------------------
# 1. Project Initialization
# ------------------------------------------------------------------------------
# Close any currently open project to prevent locking conflicts
if {[catch {current_project}] == 0} {
    close_project
}

# Create persistent Vivado project directory and .xpr
create_project -force $project_name $project_dir -part $part_name

# Target properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib xil_defaultlib [current_project]

# ------------------------------------------------------------------------------
# 2. Add Synthesizable SystemVerilog Design Sources (sources_1)
# ------------------------------------------------------------------------------
puts "\n\[1/5\] Adding Synthesizable RTL Design Sources..."

set rtl_files [list \
    [file normalize "src/mac_baseline.sv"] \
    [file normalize "src/mac_oi.sv"] \
    [file normalize "src/mac_cg.sv"] \
    [file normalize "src/mac_zs.sv"] \
    [file normalize "src/mac_combined.sv"] \
    [file normalize "src/conv2d_serial_baseline.sv"] \
    [file normalize "src/conv2d_serial_oi.sv"] \
    [file normalize "src/conv2d_serial_cg.sv"] \
    [file normalize "src/conv2d_serial_zs.sv"] \
    [file normalize "src/conv2d_serial_combined.sv"] \
    [file normalize "src/conv2d_serial_proposed.sv"] \
    [file normalize "src/conv2d_benchmark_top.sv"] \
    [file normalize "src/conv2d_stress_test_top.sv"] \
    [file normalize "src/uart_rx.sv"] \
    [file normalize "src/uart_tx.sv"] \
]

add_files -norecurse -fileset [get_filesets sources_1] $rtl_files
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sources_1] *.sv]

# Set Top Module for Design Hierarchy
set_property top $top_module [get_filesets sources_1]
update_compile_order -fileset sources_1
puts "  RTL files added successfully. Top module set to: $top_module"

# ------------------------------------------------------------------------------
# 3. Add Physical and Timing Constraints (constrs_1)
# ------------------------------------------------------------------------------
puts "\n\[2/5\] Adding Physical and Timing Constraints..."

set xdc_files [list \
    [file normalize "constrs/edge_s7_uart.xdc"] \
]

add_files -norecurse -fileset [get_filesets constrs_1] $xdc_files
puts "  Constraints added: edge_s7_uart.xdc (50 MHz clock on H11, UART on G1/F2, Reset on J14)"

# ------------------------------------------------------------------------------
# 4. Add Multi-Workload Simulation Testbenches (sim_1)
# ------------------------------------------------------------------------------
puts "\n\[3/5\] Setting up Simulation Filesets..."

set sim_files [list \
    [file normalize "tb/tb_all_ablation_engines.sv"] \
    [file normalize "tb/tb_ablation_mac.sv"] \
    [file normalize "tb/tb_all_workloads.sv"] \
    [file normalize "tb/tb_single_mac.sv"] \
    [file normalize "tb/tb_conv2d_saif.sv"] \
]

add_files -norecurse -fileset [get_filesets sim_1] $sim_files
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sim_1] *.sv]

# Default simulation top: tb_all_ablation_engines (tests all 5 architectures in lockstep)
set_property top tb_all_ablation_engines [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "  Simulation set configured. Default testbench: tb_all_workloads"

# ------------------------------------------------------------------------------
# 5. Configure Synthesis, Implementation & Bitstream Options
# ------------------------------------------------------------------------------
puts "\n\[4/5\] Configuring Implementation & Bitstream Directives..."

# Ensure target SPI flash speed & compression for Spartan-7
set_property STEPS.SYNTH_DESIGN.ARGS.MOREOPTIONS "-generic USE_PROPOSED=1" [get_runs synth_1]

# Bitstream compression & SPI 4x configuration for Edge Spartan-7
set_property BITSTREAM.GENERAL.COMPRESS TRUE [get_runs impl_1]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [get_runs impl_1]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [get_runs impl_1]

# ------------------------------------------------------------------------------
# 6. Helper Tcl Procedures for Vivado Interactive Console
# ------------------------------------------------------------------------------
puts "\n\[5/5\] Registering Workflow Helper Commands..."

# Helper: Build Baseline Bitstream
proc build_baseline_bitstream {} {
    puts ">>> Building Baseline Bitstream (USE_PROPOSED=0)..."
    set_property STEPS.SYNTH_DESIGN.ARGS.MOREOPTIONS "-generic USE_PROPOSED=0" [get_runs synth_1]
    reset_run synth_1
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    file mkdir "bitstreams"
    set bit_src [get_property DIRECTORY [get_runs impl_1]]/conv2d_benchmark_top.bit
    file copy -force $bit_src "bitstreams/conv2d_benchmark_baseline.bit"
    puts ">>> Baseline Bitstream ready: bitstreams/conv2d_benchmark_baseline.bit"
}

# Helper: Build Proposed Bitstream
proc build_proposed_bitstream {} {
    puts ">>> Building Proposed Zero-Skipping Bitstream (USE_PROPOSED=1)..."
    set_property STEPS.SYNTH_DESIGN.ARGS.MOREOPTIONS "-generic USE_PROPOSED=1" [get_runs synth_1]
    reset_run synth_1
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    file mkdir "bitstreams"
    set bit_src [get_property DIRECTORY [get_runs impl_1]]/conv2d_benchmark_top.bit
    file copy -force $bit_src "bitstreams/conv2d_benchmark_proposed.bit"
    puts ">>> Proposed Bitstream ready: bitstreams/conv2d_benchmark_proposed.bit"
}

# Helper: Run Simulation in GUI
proc run_all_sim {} {
    current_fileset -simset [get_filesets sim_1]
    set_property top tb_all_workloads [get_filesets sim_1]
    launch_simulation
}

puts "\n=================================================================="
puts " >>> VIVADO PROJECT CREATED SUCCESSFULLY! <<<"
puts " Project File : [file normalize ${project_dir}/${project_name}.xpr]"
puts " Target Part  : $part_name"
puts " Top Module   : $top_module"
puts ""
puts " AVAILABLE COMMANDS IN THIS VIVADO SESSION:"
puts "   • build_baseline_bitstream  : Synthesize & generate Baseline bitstream"
puts "   • build_proposed_bitstream  : Synthesize & generate Proposed Zero-Skipping bitstream"
puts "   • run_all_sim               : Launch full 4-tier workload testbench simulation"
puts "   • source scripts/program_fpga.tcl : Program attached Spartan-7 board"
puts "=================================================================="
