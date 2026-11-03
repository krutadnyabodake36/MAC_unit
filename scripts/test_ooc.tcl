create_project -in_memory -part xc7s15ftgb196-1

add_files [list \
    "src/conv2d_serial_baseline.sv" \
    "src/conv2d_engine_wrapper.sv" \
]
set_property file_type SystemVerilog [get_files *.sv]

# Clock XDC
set fp [open "scripts/temp_clk.xdc" w]
puts $fp "create_clock -period 20.000 -name clk \[get_ports clk\]"
close $fp
add_files -fileset constrs_1 "scripts/temp_clk.xdc"

# Out-of-context synthesis
synth_design -top conv2d_engine_wrapper -part xc7s15ftgb196-1 -mode out_of_context -generic DESIGN_SELECT=0
opt_design
place_design
route_design

report_utilization -file "results/final_run_20261030_1056/reports/util_wrapper_test.txt"
report_timing_summary -file "results/final_run_20261030_1056/reports/timing_wrapper_test.txt"
puts "\n=================================================================="
puts " SUCCESS: Out-of-context conv2d_engine_wrapper implemented!"
puts "=================================================================="
