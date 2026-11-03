create_project -in_memory -part xc7s15ftgb196-1
add_files [list \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_baseline.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_oi.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_cg.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_zs.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_zs_oi.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_zs_cg.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_oi_cg.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_combined.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_serial_static_sobel.sv" \
    "C:/Users/Krutadnye/Downloads/Projects/MAC/src/conv2d_engine_wrapper.sv" \
]
set_property file_type SystemVerilog [get_files *.sv]
add_files -fileset constrs_1 "C:/Users/Krutadnye/Downloads/Projects/MAC/scripts/temp_clk.xdc"

synth_design -top conv2d_engine_wrapper -part xc7s15ftgb196-1 -mode out_of_context -generic DESIGN_SELECT=1
opt_design
place_design
route_design

write_checkpoint -force "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/oi/oi_routed.dcp"
write_verilog -mode timesim -sdf_anno true -force "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/oi/oi_timesim.v"
write_sdf -force "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/saif/natural/oi/oi_timesim.sdf"
exit
