# ==============================================================================
# File: edge_s7_uart_fixed.xdc
# Target Board: Invent Logics EDGE Spartan-7 FPGA Development Board
# Target Device: XC7S15-1FTGB196C
# Verified against Invent Logics EDGE Spartan-7 User Manual & Schematic
# ==============================================================================

# 1. Primary Clock (50 MHz)
set_property -dict { PACKAGE_PIN H11 IOSTANDARD LVCMOS33 } [get_ports -quiet { clk }];
create_clock -period 20.000 -name sys_clk_50mhz -waveform {0.000 10.000} [get_ports -quiet { clk }];

# 2. Synchronous Reset Pushbutton (btnC / SW14)
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports -quiet { btnC }];

# 3. USB-UART Interface (Corrected Pin Mapping from Board Schematic)
#   - RsRx (FPGA RX Input): Connected to FT2232 TXD on Pin F2
#   - RsTx (FPGA TX Output): Connected to FT2232 RXD on Pin G1
set_property -dict { PACKAGE_PIN F2 IOSTANDARD LVCMOS33 } [get_ports -quiet { RsRx }];
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports -quiet { RsTx }];

# 4. Spartan-7 Configuration Directives
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

