# Export netlist from test checkpoint
create_project -in_memory -part xc7s15ftgb196-1
add_files [list "src/conv2d_serial_baseline.sv" "src/conv2d_engine_wrapper.sv"]
set_property file_type SystemVerilog [get_files *.sv]
set fp [open "scripts/temp_clk.xdc" w]
puts $fp "create_clock -period 20.000 -name clk \[get_ports clk\]"
close $fp
add_files -fileset constrs_1 "scripts/temp_clk.xdc"

synth_design -top conv2d_engine_wrapper -part xc7s15ftgb196-1 -mode out_of_context -generic DESIGN_SELECT=0
opt_design
place_design
route_design

file mkdir "results/final_run_20261030_1056/saif"
write_checkpoint -force "results/final_run_20261030_1056/saif/baseline_routed.dcp"
write_verilog -mode timesim -sdf_anno true -force "results/final_run_20261030_1056/saif/baseline_timesim.v"
write_sdf -force "results/final_run_20261030_1056/saif/baseline_timesim.sdf"

puts "Exported routed DCP and timesim netlist/SDF!"

