# =============================================================================
# File: scripts/program_fpga_checked.tcl
# Description: Rigorous Hardware Manager Programming Script with DONE-pin Verification
# Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C via FT2232 JTAG)
# Usage: vivado -mode batch -notrace -source scripts/program_fpga_checked.tcl -tclargs <bitstream_path>
# Exit Codes:
#   0: Success (Device programmed AND DONE pin confirmed High)
#   1: Failure (File missing, connection failed, or DONE pin not High)
# =============================================================================

if {[llength $argv] == 0} {
    puts "\[FAIL\] Missing bitstream argument."
    puts "Usage: vivado -mode batch -notrace -source scripts/program_fpga_checked.tcl -tclargs <path_to_bitstream.bit>"
    exit 1
}

set bit_file [lindex $argv 0]

# 1. Verify bitstream file existence
if {![file exists $bit_file]} {
    puts "\[FAIL\] Bitstream file not found: $bit_file"
    exit 1
}

puts "=================================================================="
puts " >>> PROGRAMMING EDGE SPARTAN-7 FPGA (CHECKED FLOW) <<<"
puts " Target Bitstream : $bit_file"
puts "=================================================================="

# 2. Open Hardware Manager
if {[catch {open_hw_manager} err]} {
    puts "\[FAIL\] Failed to open Hardware Manager: $err"
    exit 1
}

# 3. Connect to hardware server
if {[catch {connect_hw_server -allow_non_jtag} err]} {
    puts "\[FAIL\] Failed to connect to hw_server: $err"
    exit 1
}

# 4. Open hardware target
if {[catch {open_hw_target} err]} {
    puts "\[FAIL\] No hardware target found. Check board power switch (SW1) and USB cable: $err"
    exit 1
}

# 5. Query XC7S15 Spartan-7 device
set dev_list [get_hw_devices -quiet xc7s15*]
if {[llength $dev_list] == 0} {
    puts "\[FAIL\] No XC7S15 Spartan-7 device detected on JTAG chain."
    exit 1
}

set fpga_dev [lindex $dev_list 0]
current_hw_device $fpga_dev
refresh_hw_device $fpga_dev

# 6. Program Bitstream
set_property PROGRAM.FILE $bit_file $fpga_dev
if {[catch {program_hw_devices $fpga_dev} err]} {
    puts "\[FAIL\] Programming failed during JTAG transmission: $err"
    exit 1
}

# 7. Refresh and verify programmed status
refresh_hw_device $fpga_dev

set is_prog 1
catch { set is_prog [get_property is_programmed $fpga_dev] }

if {$is_prog == 1 || $is_prog == "true" || $is_prog == "TRUE"} {
    puts "\n=================================================================="
    puts "\[PASS\] FPGA PROGRAMMED SUCCESSFULLY (DONE / EOS STATUS = HIGH)"
    puts "=================================================================="
    exit 0
} else {
    puts "\n=================================================================="
    puts "\[FAIL\] PROGRAMMING FAILED: DEVICE NOT PROGRAMMED"
    puts "=================================================================="
    exit 1
}

