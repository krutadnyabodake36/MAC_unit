# ==============================================================================
# Script: scripts/read_sysmon.tcl
# Target Board: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C)
# Description: Reads on-chip XADC / System Monitor telemetry via Vivado Hardware Manager.
#              Appends timestamped readings to power/sysmon_log.csv.
# Status: [UNTESTED ON HARDWARE]
# Notice: Values are "monitor-grade, not accuracy-grade"; NO energy or power claim
#         may be derived from them.
# ==============================================================================

set log_file "power/sysmon_log.csv"

# Ensure target directory exists
file mkdir "power"

# Create header if file does not exist
if {![file exists $log_file]} {
    set fh [open $log_file "w"]
    puts $fh "timestamp_iso,temperature_c,vccint_v,vccaux_v,vccbram_v,status"
    close $fh
}

set timestamp [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%SZ" -gmt 1]
set temp_val "NA"
set vccint_val "NA"
set vccaux_val "NA"
set vccbram_val "NA"
set read_status "NOT_CONNECTED"

catch {
    open_hw_manager
    connect_hw_server -url localhost:3121 -allow_non_jtag
    open_hw_target

    set dev [get_hw_devices xc7s15_0]
    current_hw_device $dev
    refresh_hw_device -update_hw_probes false $dev

    set sysmon [get_hw_sysmons -of_objects $dev]
    if {[llength $sysmon] > 0} {
        refresh_hw_sysmon $sysmon
        catch { set temp_val [get_property TEMPERATURE $sysmon] }
        catch { set vccint_val [get_property VCCINT $sysmon] }
        catch { set vccaux_val [get_property VCCAUX $sysmon] }
        catch { set vccbram_val [get_property VCCBRAM $sysmon] }
        set read_status "OK"
    } else {
        set read_status "NO_SYSMON_FOUND"
    }
} err_msg

# Append row to CSV
set fh [open $log_file "a"]
puts $fh "$timestamp,$temp_val,$vccint_val,$vccaux_val,$vccbram_val,$read_status"
close $fh

puts "\[SYSMON READ\] Time: $timestamp | Temp: $temp_val C | VCCINT: $vccint_val V | Status: $read_status"

