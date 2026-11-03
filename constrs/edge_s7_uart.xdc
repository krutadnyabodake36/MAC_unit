# ==============================================================================
# File: edge_s7_uart.xdc
# Target Board: Invent Logics EDGE Spartan-7 FPGA Development Board
# Target Device: XC7S15-1FTGB196C
# Design Top: mac_uart_top
# Clock: 50 MHz Onboard Crystal Oscillator (20.000 ns Period)
# IO Standard: LVCMOS33 (3.3V Digital Logic)
# Pin Mapping Verified: Invent Logics EDGE Spartan-7 User Manual
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Primary Clock Definition & Timing Constraint (50 MHz)
# ------------------------------------------------------------------------------
# Onboard 50 MHz Crystal Oscillator connected to MRCC Pin H11 (Bank 14)
set_property -dict { PACKAGE_PIN H11 IOSTANDARD LVCMOS33 } [get_ports -quiet { clk }];

# 50 MHz Clock: 20.000 ns period, 50% duty cycle (0.000 ns rise, 10.000 ns fall)
create_clock -period 20.000 -name sys_clk_50mhz -waveform {0.000 10.000} [get_ports -quiet { clk }];

# ------------------------------------------------------------------------------
# 2. Synchronous Reset Pushbutton (btnC)
# ------------------------------------------------------------------------------
# Onboard User Push Button SW14 (Drives High '1' when pressed)
# Available push buttons on the EDGE Spartan-7:
#   SW14: J14  <-- Assigned to btnC (Active-High Reset)
#   SW16: J13
#   SW18: J12
#   SW20: J11
#   SW23: L13
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports -quiet { btnC }];

# ------------------------------------------------------------------------------
# 3. USB-UART Interface (On-board FT2232 Serial Bridge)
# ------------------------------------------------------------------------------
# Pin Details for USB UART to Spartan-7 FPGA:
#   - RsRx (FPGA RX): Pin G1 (Receives UART serial data from FT2232 TXD)
#   - RsTx (FPGA TX): Pin F2 (Transmits UART serial data to FT2232 RXD)
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports -quiet { RsRx }];
set_property -dict { PACKAGE_PIN F2 IOSTANDARD LVCMOS33 } [get_ports -quiet { RsTx }];

# ------------------------------------------------------------------------------
# 4. Spartan-7 Configuration Directives
# ------------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
