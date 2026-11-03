# Zero-Skipping Serial Convolution Engine for Spartan-7 FPGA

[![Target FPGA](https://img.shields.io/badge/FPGA-AMD%20Spartan--7%20XC7S15-red.svg)](https://www.xilinx.com/products/silicon-devices/fpga/spartan-7.html)
[![System Clock](https://img.shields.io/badge/Clock-50.000%20MHz-blue.svg)]()
[![UART Baud](https://img.shields.io/badge/UART-115%2C200%20Baud-green.svg)]()
[![Verification](https://img.shields.io/badge/Verification-36%2F36%20Golden%20PASS-brightgreen.svg)]()

A high-efficiency, hardware-verified 2D convolution ($3 \times 3$) acceleration engine designed for embedded computer vision on AMD/Xilinx Spartan-7 FPGAs. Demonstrates dynamic zero-skipping, operand isolation, clock gating, and hardcoded static scheduling over real-image vision benchmarks.

---

## Key Architectural Innovations

1. **Dynamic Zero-Skipping Datapath (`conv2d_serial_zs`):**
   - Implements a priority-encoded address sequencer that detects zero-valued weights and pixels in real-time.
   - Zero products consume **0 clock cycles**, reducing active arithmetic compute latency from 9 cycles down to active non-zero terms (achieving **1.528x compute speedup** on natural vision workloads).
2. **Fine-Grained Operand Isolation (`conv2d_serial_oi`):**
   - Freezes multiplier input registers via operand-isolation logic whenever either operand is zero, suppressing internal switching activity and dynamic power dissipation.
3. **Sequential Clock Gating (`conv2d_serial_cg`):**
   - Selectively disables accumulator clocking during zero cycles to prevent dynamic power draw.
4. **Combined Architecture (`conv2d_serial_combined`):**
   - Merges zero-skipping, operand isolation, and clock gating simultaneously.
5. **Static Sobel Engine (`conv2d_serial_static_sobel`):**
   - Exploits the fixed structural zeros of the Sobel gradient kernel at synthesis time to implement a dedicated 6-tap datapath (**1.500x speedup**).

---

## Hardware Specifications & Target Board

- **Development Board:** Invent Logics EDGE Spartan-7 Development Board
- **FPGA Part Number:** AMD/Xilinx Spartan-7 `XC7S15-1FTGB196C`
- **System Clock:** 50.000 MHz (20.000 ns Period, Onboard Crystal on Pin `H11`)
- **Host Interface:** USB-UART Serial Bridge @ 115,200 Baud (8-N-1) on Pins `G1` (RX) and `F2` (TX)
- **Reset:** Pushbutton PB1 / SW14 on Pin `J14` (Synchronous Active-High Reset)
- **Resource Footprint (Route Signoff):**
  - Baseline Engine: 301 LUTs, 319 FFs (WNS: +7.291 ns)
  - Zero-Skipping Engine: 357 LUTs, 355 FFs (WNS: +5.481 ns)
  - Static Sobel Engine: 252 LUTs, 290 FFs (WNS: +7.879 ns)

---

## Benchmark Results (44,032 Patches over 4 Images)

Summary of aggregate execution metrics across all 4 benchmark images (`image1.jpg`–`image4.jpg`):

| Architecture Variant | Total Patches | Total Compute Cycles | Mean Cyc/Patch | Skipped Products | Compute Speedup | Mismatches |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`baseline`** | 44,032 | 396,288 | 9.000 | 0 | **1.000x** | 0 |
| **`oi` (Operand Isolation)** | 44,032 | 396,288 | 9.000 | 136,984 | **1.000x** | 0 |
| **`cg` (Clock Gating)** | 44,032 | 396,288 | 9.000 | 136,984 | **1.000x** | 0 |
| **`zs` (Zero-Skipping)** | 44,032 | 259,304 | 5.889 | 136,984 | **1.528x** | 0 |
| **`zs_oi`** | 44,032 | 259,304 | 5.889 | 136,984 | **1.528x** | 0 |
| **`zs_cg`** | 44,032 | 259,304 | 5.889 | 136,984 | **1.528x** | 0 |
| **`oi_cg`** | 44,032 | 396,288 | 9.000 | 136,984 | **1.000x** | 0 |
| **`combined`** | 44,032 | 259,304 | 5.889 | 136,984 | **1.528x** | 0 |
| **`static_sobel`** | 44,032 | 264,192 | 6.000 | 0 | **1.500x** | 0 |

---

## Repository Structure

```
├── constrs/                           # Physical FPGA pin & timing constraints
│   └── edge_s7_uart.xdc               # Pin mapping & 50 MHz clock constraint for EDGE board
├── docs/                              # Technical guides and documentation
│   └── BOARD_DAY.md                   # Complete board execution run sheet & stop rules
├── power/                             # Power and energy characterization suite
│   ├── POWER_PROCEDURE.md             # Experimental procedures for whole-board power measurement
│   ├── run_order.csv                  # Randomized design sequence with baseline drift anchors
│   └── meter_log_template.csv         # Power meter CSV data template
├── results/                           # Authoritative simulation reports & bitstreams
│   └── final_run_20261030_1056/       # Frozen simulation runs, bitstreams, and expected CSVs
│       ├── bitstreams/                # All 9 frozen Spartan-7 bitstreams + MANIFEST.sha256
│       ├── expected/                  # 36 ground-truth expected reply CSVs (396,288 responses)
│       └── FROZEN_SIM_RESULTS_v2.sha256
├── scripts/                           # Production automation & analysis scripts
│   ├── run_all_designs.ps1            # Master automated runner for all 9 variants
│   ├── program_fpga_checked.tcl       # Verified JTAG programming script
│   ├── generate_board_summaries.py    # Automated results aggregator & consistency auditor
│   ├── collect_board_results.py       # Packages deliverables into a timestamped zip archive
│   └── power_log_import.py            # Aligns meter data and computes trapezoidal energy
├── src/                               # SystemVerilog RTL source files (synthesizable)
│   ├── conv2d_serial_baseline.sv      # Baseline sequential Conv2D engine
│   ├── conv2d_serial_zs.sv            # Zero-skipping sequential Conv2D engine
│   ├── conv2d_serial_static_sobel.sv  # Hardcoded 6-tap static Sobel engine
│   ├── conv2d_benchmark_top_ablation.sv # Top-level FPGA wrapper with UART interface
│   ├── uart_rx.sv / uart_tx.sv        # Hardware UART transceiver (CLKS_PER_BIT = 434)
│   └── ...
├── tb/                                # SystemVerilog verification testbenches
│   ├── tb_uart_real_baud_4img.sv      # Full-duplex real-baud UART RTL testbench
│   └── ...
├── fpga_vision_profiler.py            # Host vision profiler & real-time telemetry streamer
├── image1.jpg .. image4.jpg           # Standard benchmark input images
└── README.md                          # This file
```

---

## Quickstart & Execution

### 1. Software Simulation Mode (No Board Required)
To verify the entire 9-design $\times$ 4-image benchmark suite in simulation mode:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_all_designs.ps1 -Sim -NonInteractive
```

### 2. Physical Hardware Execution (On EDGE Spartan-7 Board)
1. Connect micro-USB to port **U9**; set slide switch **SW3** to **USB**; turn board **ON**.
2. Run the automated master suite:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_all_designs.ps1 -Port COM17
```
*(Replace `COM17` with your detected COM port).*

### 3. Packaging Results
```powershell
python scripts/collect_board_results.py
```
Produces `board_results_<DATE_TIME>.zip` with an integrity SHA-256 manifest.
