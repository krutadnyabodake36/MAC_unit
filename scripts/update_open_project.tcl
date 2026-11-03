# ==============================================================================
# File: update_open_project.tcl
# Target Board: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
#
# Description:
#   Run this script directly inside your open Vivado GUI Tcl Console to
#   automatically fix all missing file warnings, remove obsolete files,
#   add the updated RTL sources from 'src/', set the correct top module,
#   and configure the target part to the EDGE Spartan-7.
#
# How to run in Vivado:
#   In the Tcl Console at the bottom of the Vivado window, type or paste:
#     source C:/Users/Krutadnye/Downloads/Projects/MAC/scripts/update_open_project.tcl
# ==============================================================================

set proj_dir "C:/Users/Krutadnye/Downloads/Projects/MAC"

puts "=================================================================="
puts " >>> UPDATING VIVADO PROJECT: REMOVING OLD FILES & ADDING NEW <<<"
puts " Project Root : $proj_dir"
puts "=================================================================="

# ------------------------------------------------------------------------------
# 1. Remove all obsolete/unavailable files from sources_1, sim_1, constrs_1
# ------------------------------------------------------------------------------
# Remove by availability status
set unavailable_files [get_files -filter {IS_AVAILABLE == 0}]
if {[llength $unavailable_files] > 0} {
    puts "Removing [llength $unavailable_files] stale/unavailable file(s)..."
    catch { remove_files $unavailable_files }
}

# Also explicitly remove old legacy file names if present in project
set old_names [list \
    "conv2d_3x3_proposed.sv" \
    "conv2d_line_buffer.sv" \
    "mac_3x3_top.sv" \
    "mac_cg.sv" \
    "mac_oi.sv" \
    "tb_mac_3x3_top.sv" \
]
foreach old_f $old_names {
    set matched [get_files -quiet $old_f]
    if {[llength $matched] > 0} {
        puts "  - Removing legacy file: $old_f"
        catch { remove_files $matched }
    }
}

# ------------------------------------------------------------------------------
# 2. Add all updated synthesizable SystemVerilog RTL files from src/
# ------------------------------------------------------------------------------
puts "\nAdding current SystemVerilog RTL sources from src/..."
set rtl_files [list \
    "$proj_dir/src/mac_baseline.sv" \
    "$proj_dir/src/mac_combined.sv" \
    "$proj_dir/src/conv2d_serial_baseline.sv" \
    "$proj_dir/src/conv2d_serial_proposed.sv" \
    "$proj_dir/src/conv2d_benchmark_top.sv" \
    "$proj_dir/src/conv2d_stress_test_top.sv" \
    "$proj_dir/src/uart_rx.sv" \
    "$proj_dir/src/uart_tx.sv" \
]

add_files -norecurse -fileset [get_filesets sources_1] $rtl_files
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sources_1] *.sv]

# ------------------------------------------------------------------------------
# 3. Add physical and timing constraints from constrs/
# ------------------------------------------------------------------------------
puts "\nAdding physical constraints..."
set xdc_file "$proj_dir/constrs/edge_s7_uart.xdc"
if {[file exists $xdc_file]} {
    add_files -norecurse -fileset [get_filesets constrs_1] $xdc_file
}

# ------------------------------------------------------------------------------
# 4. Add verification testbenches to simulation set (sim_1)
# ------------------------------------------------------------------------------
puts "\nAdding testbenches to sim_1..."
set sim_files [list \
    "$proj_dir/tb/tb_all_workloads.sv" \
    "$proj_dir/tb/tb_single_mac.sv" \
    "$proj_dir/tb/tb_conv2d_saif.sv" \
]
add_files -norecurse -fileset [get_filesets sim_1] $sim_files
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sim_1] *.sv]

# ------------------------------------------------------------------------------
# 5. Set Top Modules & Compile Order
# ------------------------------------------------------------------------------
puts "\nSetting top modules..."

# Synthesis / Implementation Top Module
set_property top conv2d_benchmark_top [get_filesets sources_1]
update_compile_order -fileset sources_1

# Simulation Top Module (covers all 4 designs across 3 workloads)
set_property top tb_all_workloads [get_filesets sim_1]
update_compile_order -fileset sim_1

# ------------------------------------------------------------------------------
# 6. Configure Target Device & Bitstream Directives
# ------------------------------------------------------------------------------
puts "\nConfiguring target device: xc7s15ftgb196-1 (EDGE Spartan-7)..."
set_property part xc7s15ftgb196-1 [current_project]

catch {
    set_property BITSTREAM.GENERAL.COMPRESS TRUE [get_runs impl_1]
    set_property BITSTREAM.CONFIG.CONFIGRATE 33 [get_runs impl_1]
    set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [get_runs impl_1]
}

puts "\n=================================================================="
puts " >>> VIVADO PROJECT SUCCESSFULLY UPDATED & SYNCHRONIZED! <<<"
puts " Target Part    : xc7s15ftgb196-1 (EDGE Spartan-7)"
puts " Top Module     : conv2d_benchmark_top"
puts " Simulation Top : tb_all_workloads"
puts " Constraints    : edge_s7_uart.xdc"
puts " Status         : Ready for Synthesis, Simulation, or Bitstream Generation"
puts "=================================================================="
