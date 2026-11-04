# Build baseline bitstream with corrected UART pins (RsRx=F2, RsTx=G1)
set part_name "xc7s15ftgb196-1"
set top_module "conv2d_benchmark_top_ablation"
set out_bit "results/final_run_20261030_1056/bitstreams/conv2d_benchmark_baseline_fixed.bit"

read_verilog -sv "src/mac_baseline.sv"
read_verilog -sv "src/conv2d_serial_baseline.sv"
read_verilog -sv "src/uart_rx.sv"
read_verilog -sv "src/uart_tx.sv"
read_verilog -sv "src/conv2d_benchmark_top_ablation.sv"
read_xdc "constrs/edge_s7_uart_fixed.xdc"

synth_design -top $top_module -part $part_name -generic DESIGN_SELECT=0
opt_design
place_design
route_design

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force -bin_file $out_bit

puts "=================================================================="
puts " >>> FIXED BASELINE BITSTREAM GENERATED SUCCESSFULLY <<<"
puts " Output: $out_bit"
puts "=================================================================="
exit 0

