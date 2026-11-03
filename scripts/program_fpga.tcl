# =============================================================================
# File: program_fpga.tcl
# Description: Automated Vivado Hardware Manager Programming Script
# Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C via FT2232 JTAG)
# =============================================================================

set bit_file "bitstreams/conv2d_benchmark_proposed.bit"
if {[llength $argv] > 0} {
    set bit_file [lindex $argv 0]
}

if {![file exists $bit_file]} {
    puts "ERROR: Bitstream file '$bit_file' not found! Build it first using scripts/build_benchmark.tcl."
    exit 1
}

puts "=================================================================="
puts " >>> PROGRAMMING EDGE SPARTAN-7 FPGA <<<"
puts " Bitstream : $bit_file"
puts "=================================================================="

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

# Select Spartan-7 device (xc7s15)
set device [get_hw_devices xc7s15*]
if {[llength $device] == 0} {
    puts "ERROR: No XC7S15 device detected on JTAG chain. Check USB cable and power switch."
    exit 1
}

current_hw_device [lindex $device 0]
refresh_hw_device [lindex $device 0]

set_property PROGRAM.FILE $bit_file [current_hw_device]
program_hw_devices [current_hw_device]

puts "\n=================================================================="
puts " >>> FPGA PROGRAMMED SUCCESSFULLY! PROCEED TO RUN HIL TEST. <<<"
puts "=================================================================="
exit
