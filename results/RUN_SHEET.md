# COMPLETE 9-CONFIGURATION PHYSICAL FPGA BOARD EXECUTION RUN SHEET

This run sheet contains the instructions for evaluating **all 9 architectural configurations** (8 ablation variants + 1 static Sobel baseline) on the physical **Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)** development board.

> **CRITICAL EXECUTION RULES:**
> 1. **Zero Expected Numbers:** No theoretical, predicted, or target numbers are included in this run sheet.
> 2. **Fresh Bitstreams Only:** Use **ONLY** the 9 fresh bitstreams built in this run located in `results/final_run_20261030_1056/bitstreams/`.
> 3. **Power-Cycle Between Bitstreams:** Between programming different variants, power-cycle the board (switch SW1 off, wait 3 seconds, switch on) to ensure all internal FPGA registers and FTDI UART buffers reset cleanly.
> 4. **Halt Condition:** If any UART timeout (>30 seconds) or error banner occurs, STOP, record the exact terminal message, and do not proceed to the next image until diagnosed.
> 5. **CLI Syntax Note:** In `fpga_vision_profiler.py`, the image path is a **positional argument** (e.g. `python fpga_vision_profiler.py image1.jpg ...`). Do NOT pass `--image image1.jpg` as this raises an `argparse` error. Furthermore, `--design` valid choices are `['auto', 'baseline', 'oi', 'cg', 'zs', 'combined', 'zs_oi', 'zs_cg', 'oi_cg', 'proposed']`. For `static_sobel`, use `--design auto` to avoid argparse choice rejection.

---

## 0. Pre-Flight Setup: Identify Host COM Port

Run in PowerShell:
```powershell
powershell -Command "Get-CimInstance Win32_SerialPort | Select-Object DeviceID, Description"
```
Or check **Device Manager** -> **Ports (COM & LPT)** for the USB-Serial bridge.  
*(Substitute `<COM_PORT>` below with your detected port, e.g., `COM17`).*

---

## 1. Bitstream-to-Module Mapping Table

| Variant # | Design Name | Target Bitstream (`results/final_run_20261030_1056/bitstreams/`) | Instantiated Engine | Notes / Workload Scope |
|:---:|---|---|---|---|
| **1** | `baseline` | `conv2d_benchmark_baseline.bit` | `conv2d_serial_baseline` | Standard 9-cycle dense baseline |
| **2** | `oi` | `conv2d_benchmark_oi.bit` | `conv2d_serial_oi` | Operand Isolation only |
| **3** | `cg` | `conv2d_benchmark_cg.bit` | `conv2d_serial_cg` | Clock Gating only |
| **4** | `zs` | `conv2d_benchmark_zs.bit` | `conv2d_serial_zs` | Zero Skipping only |
| **5** | `zs_oi` | `conv2d_benchmark_zs_oi.bit` | `conv2d_serial_zs_oi` | Zero Skipping + Operand Isolation |
| **6** | `zs_cg` | `conv2d_benchmark_zs_cg.bit` | `conv2d_serial_zs_cg` | Zero Skipping + Clock Gating |
| **7** | `oi_cg` | `conv2d_benchmark_oi_cg.bit` | `conv2d_serial_oi_cg` | Operand Isolation + Clock Gating |
| **8** | `combined` | `conv2d_benchmark_combined.bit` | `conv2d_serial_combined` | Full dynamic pipeline (ZS + OI + CG) |
| **9** | `static_sobel` | `conv2d_benchmark_static_sobel.bit` | `conv2d_serial_static_sobel` | Fixed 6-tap static schedule (Sobel-X only) |

---

## 2. Standard Execution Flow per Variant

For each of the variants above, execute Steps 2.1 through 2.4:

### 2.1 Power-Cycle & Program Bitstream
```powershell
# Toggle physical power switch off -> wait 3s -> on
vivado -mode batch -source scripts/program_fpga.tcl -tclargs results/final_run_20261030_1056/bitstreams/conv2d_benchmark_<design>.bit
```
* **Success Check:** Confirm console displays `FPGA PROGRAMMED SUCCESSFULLY!`.

### 2.2 Sanity Run (Small 32x32 Image)
Run a quick sanity check before launching full images (positional image argument):
```powershell
python fpga_vision_profiler.py image1.jpg --size 32 --port <COM_PORT> --design <design> --session sanity_<design>
```
* Confirm that output displays `[REPORT] Success! Edge feature map reconstructed`.

### 2.3 Full Workload Execution across Real Images
Run each image into its dedicated session folder (positional image argument; for `static_sobel`, pass `--design auto`):
```powershell
python fpga_vision_profiler.py image1.jpg --port <COM_PORT> --design <design> --session hil_image1
python fpga_vision_profiler.py image2.jpg --port <COM_PORT> --design <design> --session hil_image2
python fpga_vision_profiler.py image3.jpg --port <COM_PORT> --design <design> --session hil_image3
python fpga_vision_profiler.py image4.jpg --port <COM_PORT> --design <design> --session hil_image4
```
*(Note: For `static_sobel`, run ONLY on Sobel workloads; dense/ReLU workloads are not applicable).*

### 2.4 Artifacts Generated per Run
Each command automatically generates:
- `results/hil_<image>/profile_<design>.json`
- `results/hil_<image>/<design>_edge.png`

---

## 3. Post-Run Submission Checklist

For each variant and image executed:
- [ ] Terminal stdout banner printed by `fpga_vision_profiler.py` (including execution time, FPS, hardware cycles, skips).
- [ ] Generated JSON profile: `results/hil_<image>/profile_<design>.json`.
- [ ] Generated output image: `results/hil_<image>/<design>_edge.png`.
- [ ] Date, time, and bitstream file used.
- [ ] Run verification script:
  ```powershell
  python scripts/compare_board_vs_sim.py
  ```

---

## 4. Physical Power Measurement Procedure (USB Meter or Current Shunt)

> **CRITICAL RESOLUTION LIMITATION NOTE:**
> Due to the 115,200 baud UART bottleneck (2.0833 ms transfer per patch) vs 50 MHz core computation (200-260 ns per patch), the active computation duty cycle of the Spartan-7 engine is approximately **0.0125% (~0.01%)**. 
> This low duty cycle dilutes core dynamic power consumption (1.9 to 3.1 mW) to less than $0.38\,\mu\text{W}$ on the external 5.0V USB power rail, completely submerged beneath the $>150\text{ mW}$ quiescent draw of board regulators, LEDs, and the FTDI USB-UART transceiver. Commercial USB inline power meters (0.5-1 mW resolution) cannot resolve or distinguish sub-milliwatt core dynamic differences.
> Core dynamic energy comparisons must rely on post-implementation gate-level SAIF switching vector extraction in Vivado `report_power`.

If using an inline USB power analyzer (e.g. UM25C, MakerHawk, or shunt ammeter on the 5V / VCC rail):
1. **Quiescent (Idle) Power:**
   - Immediately after programming the bitstream, before running Python scripts.
   - Record Idle Voltage $V_{\text{idle}}$ (V) and Idle Current $I_{\text{idle}}$ (mA).
   - Compute $P_{\text{idle}} = V_{\text{idle}} \times I_{\text{idle}}$ (mW).
2. **Active (Running) Power:**
   - Start a continuous back-to-back loop:
     ```powershell
     python fpga_vision_profiler.py image1.jpg --port <COM_PORT> --design <design> --session power_test
     ```
   - Observe the stabilized average Active Current $I_{\text{active}}$ (mA) during UART streaming and computation.
   - Record Active Voltage $V_{\text{active}}$ (V).
   - Compute $P_{\text{active}} = V_{\text{active}} \times I_{\text{active}}$ (mW).
3. **Dynamic Power Delta:**
   - Compute $P_{\text{dyn}} = P_{\text{active}} - P_{\text{idle}}$ (mW).
   - Record values per variant in your lab notebook.

---

## 5. Critical Board Telemetry Limitations & Measurement Constraints

When interpreting physical board measurements, the following hardware telemetry limitations must be accounted for:

1. **UART Communication Bottleneck Dominates Wall-Clock Time:**
   - The FPGA board communicates via a 115,200 baud UART bridge using standard 8-N-1 framing (10 bits per byte).
   - Ingesting an 18-byte request frame (9 weights + 9 pixels) takes:
     $$\frac{18\text{ bytes} \times 10\text{ bits/byte}}{115,200\text{ baud}} = 1.5625\text{ ms per patch (1,562,500 ns)}.$$
   - Receiving the 6-byte reply frame (4 bytes `conv_out` + 1 byte `compute_cycles` + 1 byte `skip_count`) takes:
     $$\frac{6\text{ bytes} \times 10\text{ bits/byte}}{115,200\text{ baud}} = 0.5208\text{ ms per patch (520,833 ns)}.$$
   - Total round-trip transmission latency is $2.0833\text{ ms per patch}$ (~480 patches/sec maximum).
   - In contrast, the Spartan-7 silicon hardware execution at 50 MHz requires only 200–260 ns per patch (10–13 clock cycles).
   - The UART transfer alone is $\sim 6,000\times$ slower than the FPGA computation, meaning end-to-end execution time is entirely I/O bound.
   - Host-level wall-clock timers (`time.time()`) measure serial transport and operating system buffering; true silicon compute time must be read strictly from the hardware cycle telemetry registers (`compute_cycles`).

2. **Absence of Dedicated Core Rail Current Telemetry:**
   - The Invent Logics EDGE Spartan-7 development board does NOT feature an on-board I2C current shunt monitor dedicated to the internal $V_{\text{CCINT}}$ (1.0V) core supply rail.
   - External USB inline meters measure total 5.0V board input power, which includes:
     - FTDI USB-UART transceiver chip
     - On-board 3.3V and 1.0V linear/switching voltage regulators
     - Power and status LEDs
     - FPGA device static/quiescent power
   - The internal core dynamic power of the convolution engine itself is a fraction of the total board power and is submerged beneath board-level thermal drift and USB transceiver switching noise on external 5V meters.
   - Silicon dynamic energy comparisons must rely on post-implementation gate-level SAIF switching vector extraction in Vivado `report_power` for core-isolated rail precision.

3. **Bit-Exact Numerical Verification Scope:**
   - In the board top modules (`conv2d_benchmark_top_ablation.sv` and `conv2d_benchmark_top.sv`), input operands are deserialized into registers and remain completely stable for hundreds of microseconds before `eng_start` is strobed.
   - The corrected wrapper (`conv2d_engine_wrapper_v2.sv`) introduces a 1-cycle settling pipeline before `core_start`, ensuring exact parity with board timing and eliminating boundary register race conditions.

---

## 6. Board Measurement Plan with Corrected Wrapper & UART Timing Protocol

### 6.1 Architecture Timing & Clock Cycles
With the corrected wrapper (`conv2d_engine_wrapper_v2.sv`), operand settling adds a 1-cycle registration stage prior to core compute assertion:
- **Baseline, OI, CG, OI_CG (Dense / Fixed 9-Tap):**
  - External start pulse: 1 cycle
  - Input settling & alignment: 1 cycle
  - Serial computation (taps 0–8): 9 cycles
  - Output registration & done strobe: 1 cycle
  - Return to idle: 1 cycle
  - **Total Wall Cycles per Patch:** Exactly **13 cycles** (260.0 ns @ 50 MHz).
- **Static Sobel (Fixed 6-Tap Schedule):**
  - External start pulse: 1 cycle
  - Input settling & alignment: 1 cycle
  - Serial computation (taps 0, 2, 3, 5, 6, 8): 6 cycles
  - Output registration & done strobe: 1 cycle
  - Return to idle: 1 cycle
  - **Total Wall Cycles per Patch:** Exactly **10 cycles** (200.0 ns @ 50 MHz).
- **Zero-Skipping Family (ZS, ZS_OI, ZS_CG, Combined):**
  - External start pulse: 1 cycle
  - Input settling & alignment: 1 cycle
  - Active non-zero taps computation: $K$ cycles ($0 \le K \le 9$)
  - Output registration & done strobe: 1 cycle
  - Return to idle: 1 cycle
  - **Total Wall Cycles per Patch:** $4 + K$ cycles (variable per patch depending on data sparsity).

### 6.2 UART Frame Protocol
- **Baud Rate:** 115,200 baud, 8 data bits, no parity, 1 stop bit (8-N-1).
- **Request Packet (18 Bytes transmitted from Host PC to FPGA):**
  - Byte 0..8: Kernel weights $w_0$ through $w_8$ (signed 8-bit integers).
  - Byte 9..17: Receptive field pixels $p_0$ through $p_8$ (signed 8-bit integers, $x - 128$).
- **Response Packet (6 Bytes transmitted from FPGA to Host PC):**
  - Byte 0..3: Convolution output `conv_out` (signed 32-bit integer, Big-Endian).
  - Byte 4: Compute cycles `compute_cycles` (unsigned 8-bit integer, reporting core compute latency).
  - Byte 5: Skipped cycles `skip_count` (unsigned 8-bit integer, reporting number of zero taps bypassed).

### 6.3 Board Physical Power Measurement Procedure
*(No expected or predicted power figures are assumed or listed).*
1. **Instrument Calibration:** Connect an inline digital power analyzer (or calibrated digital multimeter on the board 5.0V DC input) between the host USB power port and the EDGE Spartan-7 board.
2. **Quiescent (Static) Baseline:**
   - Program the target bitstream using Vivado Hardware Manager.
   - Allow the FPGA to settle for 60 seconds with no UART traffic.
   - Record quiescent voltage $V_{\text{idle}}$ and current $I_{\text{idle}}$.
3. **Active Workload Execution:**
   - Stream the 44,032 real image patches continuously via `fpga_vision_profiler.py`.
   - Measure and record average active voltage $V_{\text{active}}$ and current $I_{\text{active}}$ over the full execution.
4. **Hardware Telemetry Retrieval:**
   - Verify that all 44,032 response packets are received without framing errors.
   - Extract the hardware cycle counts and skip counts reported in the 6-byte packets to compute the true silicon execution time.
