# Physical Board Power and Energy Measurement Procedure

**Target Board:** Invent Logics EDGE Spartan-7 Development Board (XC7S15-1FTGB196C @ 50 MHz)  
**Document Status:** Operational Procedure for Physical Verification  
**Applicability:** Whole-board electrical power and energy characterization  

---

## 1. Hardware Measurement Setups

### Setup A: Inline USB Power Meter (Default)
- **Connection:** Insert an inline USB power meter (e.g. FNIRSI FNB48S, UM25C, MakerHawk) between the host PC USB port and the board's micro-USB connector **U9**.
- **Switch Configuration:** Set onboard slide switch **SW3** to **USB** position.
- **Sampling Rate:** Configure meter data export / logging at $\ge 1\text{ Hz}$ (preferably 10 Hz or 100 Hz if meter PC software supports CSV export).
- **Metadata Entry:** Enter the meter manufacturer, model, current/voltage resolution, and calibrated accuracy into `power/power_metadata.json` `[MANUAL-ENTRY]`.

### Setup B: External Bench Power Supply (Precision Current Measurement)
- **Connection:** Connect regulated DC bench supply leads to terminal/jack **J1** (+5.000 V regulated).
- **Switch Configuration:** Move onboard slide switch **SW3** to **EXT** position.
- **Current Readout:** Read current via the power supply's precision digital readout or a calibrated inline digital multimeter (DMM).
- **Metadata Entry:** Record bench supply model, compliance limits, and shunt resolution `[MANUAL-ENTRY]`.

---

## 2. Experimental Controls & Thermal Stabilization

1. **Environmental Stability:** Keep PC on AC mains power (no battery power saving). Execute all runs in the same ambient temperature room with no direct drafts or sunlight.
2. **Dedicated USB Hub:** Connect the board to a native root USB hub on the motherboard; disconnect unnecessary high-draw USB peripherals.
3. **10-Minute Thermal Warm-up:**
   - Program the first design (`baseline`).
   - Allow the board to sit powered in an idle state for **at least 10 minutes** before recording baseline data, allowing regulator, bypass capacitor, and junction temperatures to reach steady-state thermal equilibrium.
4. **Window Structure per Design & Image:**
   Each test run consists of three contiguous, timestamped phases:
   - **Pre-Run Idle Segment (60 seconds):** FPGA configured with bitstream; no UART serial activity.
   - **Active Run Segment (Execution Duration):** Profiler streams all patches over UART; engine computes actively.
   - **Post-Run Idle Segment (60 seconds):** Processing completes; board returns to idle.
5. **Randomized Run Order & Drift Anchoring:**
   - Execute runs according to the pseudorandom schedule generated in `power/run_order.csv` (Seed: `20261101`).
   - The reference design (`baseline`) is measured at the start (Run 1), middle (Run 7), and conclusion (Run 13) to quantify and isolate ambient temperature drift, regulator thermal drift, and cable heating.
   - At least 3 independent repetitions are performed for `baseline` and one Zero-Skipping variant (`zs`).

---

## 3. Valid Comparison Criteria (Active vs. Active Only)

> [!CRITICAL]
> **COMPARE ACTIVE VS. ACTIVE ONLY:**
> The onboard USB-to-UART bridge (FTDI / Silicon Labs) consumes dynamic power whenever serial bytes are transferred across the bus. Because whole-board power meters capture the entire board rail (including the USB bridge, 3.3V, 1.8V, and 1.0V regulators, and LEDs), **idle power cannot be subtracted from active power to infer engine dynamic power**.
> 
> All valid architectural energy comparisons MUST be performed strictly under identical UART traffic (e.g. `baseline` Active vs. `zs` Active over the exact same image).

---

## 4. Strict Uncertainty & Reporting Rules (O3)

1. **Resolution & Drift Threshold:**
   Let:
   $$\Delta P_{\text{meas}} = P_{\text{baseline, active}} - P_{\text{variant, active}}$$
   $$\sigma_{\text{drift}} = \max(|P_{\text{baseline, rep1}} - P_{\text{baseline, rep2}}|, |P_{\text{baseline, rep2}} - P_{\text{baseline, rep3}}|)$$
   $$\delta_{\text{meter}} = \text{Specified measurement resolution / uncertainty of the meter}$$

2. **Uncertainty Rule:**
   If:
   $$\Delta P_{\text{meas}} \le \sigma_{\text{drift}} \quad \text{or} \quad \Delta P_{\text{meas}} \le \delta_{\text{meter}}$$
   The observed difference is reported as **UNRESOLVED**, and **NO ENGINE-LEVEL POWER OR ENERGY SAVING CLAIM IS MADE FROM BOARD DATA**.
3. **Engine-Level Authority:**
   Post-implementation switching activity analysis via SAIF (`report_power -saif`) remains the authoritative, verified engine-level power metric, as it measures internal switching logic nets isolated from external board I/O and UART transceiver overhead.

---

## 5. Fallback if No Meter is Available (O4)

If physical measurement hardware is unavailable during board testing:
- The template `power/meter_log_template.csv` remains populated as a template.
- All functional, cycle, skip, and image-verification automation runs completely without error.
- Power summary tables report board power metrics as `[NOT MEASURED - NO METER ATTACHED]`.

