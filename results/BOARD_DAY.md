# Spartan-7 FPGA Board Day Execution Run Sheet (Section R)

**Target Hardware:** Invent Logics EDGE Spartan-7 Development Board  
**Target FPGA Device:** AMD/Xilinx Spartan-7 XC7S15-1FTGB196C  
**System Clock:** 50.000 MHz (20.000 ns Period, Onboard Crystal on Pin H11)  
**Host Interface:** USB-UART Bridge @ 115,200 Baud (8-N-1)  
**Host Environment:** Windows PowerShell, Python 3.10+, Vivado 2026.1  
**Hardware Readiness Verdict:** **CONDITIONAL GO until the user confirms the pin table**  

---

## 1. Physical Hardware Setup & Pre-Flight Checklist

### 1.1 Pinout & Board Controls Verification Table (L1)
Confirm the following physical connections on the Invent Logics EDGE Spartan-7 board against the board user manual before powering on:

| Function | RTL Port Name | XDC Location Line | IO Standard | Board Pin & Hardware Component | Polarity / Notes |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **50 MHz Clock** | `clk` | [`edge_s7_uart.xdc#L15`](file:///c:/Users/Krutadnye/Downloads/Projects/MAC/constrs/edge_s7_uart.xdc#L15) | `LVCMOS33` | **Pin H11** (Bank 14 MRCC) | Direct Crystal Oscillator (no PLL/MMCM) |
| **Pushbutton Reset** | `btnC` | [`edge_s7_uart.xdc#L30`](file:///c:/Users/Krutadnye/Downloads/Projects/MAC/constrs/edge_s7_uart.xdc#L30) | `LVCMOS33` | **Pin J14** (Pushbutton PB1 / SW14) | **Active-High** (LEFT button) |
| **FPGA UART RX** | `RsRx` | [`edge_s7_uart.xdc#L38`](file:///c:/Users/Krutadnye/Downloads/Projects/MAC/constrs/edge_s7_uart.xdc#L38) | `LVCMOS33` | **Pin G1** (From FT2232 TXD) | 115,200 baud, 8-N-1 (Idle High) |
| **FPGA UART TX** | `RsTx` | [`edge_s7_uart.xdc#L39`](file:///c:/Users/Krutadnye/Downloads/Projects/MAC/constrs/edge_s7_uart.xdc#L39) | `LVCMOS33` | **Pin F2** (To FT2232 RXD) | 115,200 baud, 8-N-1 (Idle High) |

### 1.2 Reset Logic & Polarity Confirmation
In both top-level modules (`src/conv2d_benchmark_top_ablation.sv#L100-L110` and `src/conv2d_benchmark_top_static.sv#L101-L111`), the reset synchronizer is implemented as:
```verilog
logic rst_sync1, rst_sync2;
always_ff @(posedge clk) begin
    rst_sync1 <= btnC;
    rst_sync2 <= rst_sync1;
end
wire rst = rst_sync2;
```
> [!IMPORTANT]
> **Reset is asserted HIGH when `btnC` is 1.** On the EDGE Spartan-7 board, pushbutton **PB1 / SW14 (the LEFT button on Pin J14)** drives a logic '1' when depressed. Pressing PB1 resets the UART and MAC datapath synchronously.

### 1.3 Critical Switch and Button Precautions
- **DO NOT PRESS SW1 (`PROG_B`):** Pushbutton SW1 is the FPGA PROG pin. Pressing SW1 clears the FPGA SRAM configuration memory and drops the programmed bitstream!
- **Slide Switch SW3 Position:** Set onboard slide switch **SW3** to **USB** mode to draw power from the host USB port (or **EXT** if powering from 5.0V bench supply on terminal J1).
- **DONE LED D1:** After programming via JTAG, verify that the green **DONE LED (D1)** illuminates solid. If D1 does not illuminate, the FPGA is not configured.

### 1.4 Identify the Host COM Port
In PowerShell, identify the virtual serial COM port assigned to the onboard FTDI / Silicon Labs bridge:
```powershell
Get-PnpDevice -Class Ports -PresentOnly | Select-Object FriendlyName, InstanceId
```
*(Default in examples below is `COM17`. Replace with your assigned port).*

---

## 2. UART Timing Arithmetic & Execution Duration Expectations

> [!NOTE]
> **No fixed execution time promise is made.** The host operating system's USB polling latency, FTDI driver latency timer, and kernel scheduling will govern the actual round-trip wall-clock time on hardware. The first real image run will establish the baseline duration on your specific host PC.

### 2.1 Pure Transfer Arithmetic Lower Bound (Derivation)
At 115,200 baud with standard 8-N-1 framing (1 start bit, 8 data bits, 1 stop bit = 10 bits/byte), the physical serial line transfer speed is:
$$\text{Line Byte Period} = \frac{10\text{ bits}}{115,200\text{ bits/s}} = 86.8056\,\mu\text{s/byte}$$

For each 3x3 patch:
- **Host $\to$ FPGA Request:** 18 bytes (9 weights + 9 pixels) $= 18 \times 86.8056\,\mu\text{s} = 1.5625\text{ ms}$
- **FPGA Internal Compute:** $120\text{ ns to } 220\text{ ns}$ ($0.00012\text{ ms to } 0.00022\text{ ms}$)
- **FPGA $\to$ Host Reply:** 6 bytes (4-byte sum, 1-byte cycles, 1-byte skips) $= 6 \times 86.8056\,\mu\text{s} = 0.5208\text{ ms}$
- **Total Pure Serial Transfer Time Per Patch:**
  $$T_{\text{pure\_patch}} = 24\text{ bytes} \times 86.8056\,\mu\text{s} \approx 2.0833\text{ ms/patch}$$

### Pure Transfer Arithmetic Lower Bounds Across Workloads:
| Workload Image | Aspect-Preserved Size | Patch Count | Pure Serial Transfer Lower Bound [DERIVED] |
| :--- | :---: | :---: | :---: |
| **image1.jpg** | $91 \times 128$ | 11,648 | **24.267 seconds** |
| **image2.jpg** | $128 \times 96$ | 12,288 | **25.600 seconds** |
| **image3.jpg** | $128 \times 72$ | 9,216 | **19.200 seconds** |
| **image4.jpg** | $85 \times 128$ | 10,880 | **22.667 seconds** |
| **Full 4-Image Suite** | — | **44,032** | **91.733 seconds (1.53 minutes)** |

*(Note: The default Windows FTDI latency timer is 16 ms. If left at default, host receive buffering may add delay. Reducing the latency timer to 1 ms in Windows Device Manager $\to$ COM Port Properties $\to$ Advanced enables near line-rate transfer).*

---

## 3. Strict Stop Rules (Halt Execution Immediately)

If any condition in the following table occurs, **STOP IMMEDIATELY, SAVE ALL LOGS, AND DO NOT RETRY SILENTLY**:

| Stop Rule Trigger | Condition / Error Signature | Mandatory Action |
| :--- | :--- | :--- |
| **Bitstream Hash Mismatch** | `run_all_designs.ps1` reports `[FAIL] Bitstream hash mismatch!`. | **HALT.** Do not program an unverified bitstream. |
| **JTAG Programming Failure** | Vivado returns non-zero exit code or `DONE_PIN != 1`. | Check USB cable, power switch, and JTAG connector. Retry once. If failed a second time, **HALT**. |
| **UART Communication Timeout** | Host profiler receives fewer than 6 bytes within 10.0 seconds. | **HALT.** Check COM port assignment and baud rate (115,200). Partial data is quarantined to `interrupted_<time>/`. |
| **Counter Anomaly** | `static_sobel` reports cycles $\ne 6$ or skips $\ne 0$; `baseline` reports cycles $\ne 9$. | **HALT.** Structural counter violation indicates RTL or clocking defect. |
| **Arithmetic Mismatch** | Output sum, cycle count, or skip count does not match frozen expected CSV. | **HALT.** Partial run files are quarantined into `interrupted_<time>/`. Preserve `console.log`. |

---

## 4. Master Hardware Execution Workflow (Step-by-Step)

### Step 1: Priority Run — Image 3 on Baseline and Static Sobel (L6)
Because all 17 SDF timing simulation anomalies occurred in Image 3 (due to carry chain simulation model transient evaluation), **run Image 3 FIRST** for `baseline` and `static_sobel` to verify that real hardware multipliers settle cleanly without carry evaluation artifacts:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_all_designs.ps1 -Port COM17 -Designs @("baseline", "static_sobel") -Images @("image3.jpg")
```
Verify that `compare.json` reports `status: "PASS"` with 0 sum mismatches and 0 differing pixels.

### Step 2: Full 9-Design Benchmark Run (L3)
Execute the complete, automated benchmark across all 9 architectural variants and 4 benchmark images:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_all_designs.ps1 -Port COM17
```
**Interactive Prompt Between Designs:**
- Press `[Enter]` to configure the FPGA via JTAG and run the 4 images.
- Press `[S]` to skip the current design.
- Press `[Q]` to safely abort execution.

---

## 5. Whole-Board Power and Energy Procedure Summary (Section O)

1. **Setup Selection:**
   - **Setup A (Inline USB Meter):** Insert USB power meter between host PC and port U9 with SW3 on USB.
   - **Setup B (Bench Supply):** Connect 5.000V regulated supply to J1 with SW3 on EXT.
2. **Thermal Stabilization:** Warm up board for 10 minutes in idle after programming before logging.
3. **Run Profile per Design & Image:**
   - 60 seconds Idle (configured, no UART traffic)
   - Active Run (profiler streaming image patches)
   - 60 seconds Idle (post-run cooldown)
4. **Randomized Run Order & Drift Anchoring (`power/run_order.csv`):**
   - Fixed random seed: `20261101`.
   - `baseline` is measured first (Run 1), middle (Run 7), and last (Run 13) to quantify ambient temperature and regulator thermal drift.
   - `zs` is measured with 3 independent repetitions.
5. **Strict Uncertainty Rule (O3):**
   - Active-to-active comparison only (never active vs idle).
   - Any difference between two designs that is smaller than meter resolution or smaller than baseline-to-baseline thermal drift is reported as **UNRESOLVED**, and no engine-level power claim is made from board data. SAIF switching activity remains the authoritative engine-level power estimate.
6. **Import Power Data:**
   ```powershell
   python scripts/power_log_import.py --meter-csv power/meter_log.csv --run-log <RESULTS_DIR>/logs/board_run_log.csv --out-dir <RESULTS_DIR>/power
   ```

---

## 6. Directory Structure of Deliverables (Section N)

All deliverables from a testing campaign are stored exclusively inside a timestamped tree:
```
board_results_<YYYYMMDD_HHMM>/
├── README.md                          (Operation counts, derived formulas, [NOT MEASURABLE] list)
├── run_metadata.json                  (Host OS, Python, Vivado, COM port, FTDI latency timer)
├── manifest.sha256                    (Integrity SHA-256 hashes of every file in the tree)
├── image1/ ... image4/
│   ├── input/                         (Original image, image SHA-256, 9 expected reply CSVs)
│   ├── baseline/ ... static_sobel/    (One folder per architectural design)
│   │   ├── raw_telemetry.csv          (Per-patch telemetry: TX/RX timestamps, sum, cyc, skp, matches)
│   │   ├── run_summary.json           (Per-run statistics, mismatches, round-trip stats, UART metrics)
│   │   ├── compare.json               (Bit-exact comparison verdict)
│   │   ├── console.log                (Full console transcript)
│   │   ├── board_edge.png             (Processed edge-detected output image)
│   │   ├── expected_edge.png          (Golden simulation reference image)
│   │   ├── diff.png                   (Present ONLY if pixel differences exist)
│   │   └── profile_<design>.json      (Profiler hardware metrics record)
│   ├── image_summary.csv              (Tabular summary across all 9 designs on this image)
│   └── image_summary.md               (Markdown table of cycles, speedups, and derived times)
├── all_images_summary/
│   ├── all_images_summary.csv         (44,032-patch aggregate metrics across all 4 images)
│   ├── all_images_summary.md          (Aggregate speedups and active compute times)
│   └── cross_design_consistency.md    (Verification that cg==oi_cg and zs_cg==combined)
├── power/
│   ├── POWER_PROCEDURE.md             (Experimental controls and uncertainty rules)
│   ├── run_order.csv                  (Pseudorandom execution sequence with baseline drift anchors)
│   ├── meter_log_template.csv         (Manual entry CSV template if no auto-exporting meter)
│   ├── sysmon_log.csv                 (On-chip XADC telemetry logged before and after runs)
│   ├── power_summary.csv              (Energy integrals, mean power, and baseline drift)
│   └── power_summary.md               (Executive power table and uncertainty verdicts)
└── logs/
    ├── board_run_log.csv              (Master log: timestamps, designs, bitstream hashes, status)
    └── program_<design>.log           (Vivado Hardware Manager programming transcripts)
```
*(Any interrupted or failing run automatically quarantines its files into `interrupted_<time>/` inside the design folder).*

---

## 7. Post-Run Collection & Deliverable Archive

To package the entire campaign into a single deliverable zip archive with an integrity manifest:
```powershell
python scripts/collect_board_results.py board_results_<YYYYMMDD_HHMM>
```
**Send Back to Engineer:**
- The single zip archive: `board_results_<YYYYMMDD_HHMM>.zip`
- The printed SHA-256 hash of the zip archive.
