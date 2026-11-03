# Spartan-7 FPGA Hardware Execution Results & Telemetry Tree

**Target Hardware:** Invent Logics EDGE Spartan-7 Development Board  
**Target Device:** AMD/Xilinx Spartan-7 XC7S15-1FTGB196C @ 50 MHz  
**Interface:** Direct 115,200 Baud UART (8-N-1) on FTDI Serial Bridge  
**Data Tags:** `[BOARD-MEASURED]`, `[HOST-MEASURED]`, `[SIM-EXPECTED]`, `[DERIVED]`, `[MANUAL-ENTRY]`, `[NOT MEASURABLE]`  

---

## 1. Operation Counts & Mathematical Definitions (M3)

For each image with $P$ patches ($P \in \{11648, 12288, 9216, 10880\}$):
1. **Total MAC Slots [DERIVED]:**
   $$\text{Total MAC Slots} = 9 \times P$$
   Represents the theoretical dense $3 \times 3$ multiply-accumulate slots in the raster.
2. **Issued MAC Operations [BOARD-MEASURED]:**
   $$\text{Issued MAC Operations} = \sum_{k=0}^{P-1} \text{compute\_cycles}_k$$
   Represents the actual clock cycles during which the multiplier/accumulator arithmetic datapath executes on silicon.
3. **Skipped or Gated Products [BOARD-MEASURED]:**
   $$\text{Skipped / Gated Products} = \sum_{k=0}^{P-1} \text{skip\_count}_k$$

### Architectural Semantics per Design
- **`zs`, `zs_oi`, `zs_cg`, `combined` (Zero-Skipping Family):**
  Zero-valued products are bypassed dynamically by the address-generation sequencer. Bypassed products consume 0 clock cycles; thus, compute cycles drop to active non-zero terms (1 cycle/non-zero product) and execution time scales directly with image sparsity.
- **`baseline`, `oi`, `cg`, `oi_cg` (Fixed 9-Cycle Engines):**
  Always execute exactly 9 compute cycles per patch regardless of input content. For `oi`, `cg`, and `oi_cg`, `skip_count` reports the count of operand-isolated or clock-gated zero products (saving dynamic energy without latency reduction).
- **`static_sobel` (Hardcoded 6-Tap Engine):**
  Executes exactly 6 compute cycles per patch by construction (the 3 structural zeros of the Sobel kernel are eliminated at synthesis); `skip_count` is 0.

### Workload Golden Sparsity & Zero Products [SIM-EXPECTED]
- **image1.jpg (128x91 = 11,648 patches):** 104,832 total MAC slots, **36,396 zero products (34.72%)**, 68,436 active operations.
- **image2.jpg (128x96 = 12,288 patches):** 110,592 total MAC slots, **38,136 zero products (34.48%)**, 72,456 active operations.
- **image3.jpg (128x72 = 9,216 patches):** 82,944 total MAC slots, **28,702 zero products (34.60%)**, 54,242 active operations.
- **image4.jpg (128x85 = 10,880 patches):** 97,920 total MAC slots, **33,750 zero products (34.47%)**, 64,170 active operations.
- **Full Benchmark Suite (44,032 patches):** 396,288 total MAC slots, **136,984 zero products (34.57%)**, 259,304 active operations.

---

## 2. Derived Metrics & Mathematical Formulas (M4)

1. **Cycles Saved vs. Baseline [DERIVED]:**
   $$\Delta C = C_{\text{baseline}} - C_{\text{design}}$$
   $$\text{Saving \%} = \frac{C_{\text{baseline}} - C_{\text{design}}}{C_{\text{baseline}}} \times 100\%$$
2. **Compute-Cycle Speedup [DERIVED]:**
   $$S_{\text{compute}} = \frac{C_{\text{baseline}}}{C_{\text{design}}}$$
3. **Modelled Engine Wall Cycles [DERIVED]:**
   $$\text{Wall Cycles} = C_{\text{compute}} + 2 \times P$$
   *(Includes 1 cycle for input registering / operand isolation and 1 cycle for done handshake).*
   $$\text{Modelled Engine Active Time @ 50 MHz} = \text{Wall Cycles} \times 20.000\text{ ns}$$
   *(Note: Engine wall-clock cycles are NOT returned directly by the RTL registers).*
4. **Pure UART Transfer Time Lower Bound [DERIVED]:**
   $$T_{\text{transfer}} = \frac{24\text{ bytes/patch} \times 10\text{ bits/byte}}{115,200\text{ baud}} \times P = 0.0020833\text{ s/patch} \times P$$
   - `image1.jpg`: $24.267\text{ seconds}$
   - `image2.jpg`: $25.600\text{ seconds}$
   - `image3.jpg`: $19.200\text{ seconds}$
   - `image4.jpg`: $22.667\text{ seconds}$
   - `All 4 Images (44,032 patches)`: $91.733\text{ seconds}$
   Compared against total measured host execution time `[HOST-MEASURED]`.

---

## 3. Explicit List of Non-Measurable Parameters (M5)

The following parameters are strictly **[NOT MEASURABLE]** directly from board telemetry without invasive RTL modifications:
1. **Engine Wall-Clock Cycles on Board:** The hardware registers capture active arithmetic compute cycles and skipped zero products; state transition handshake cycles (2 cycles/patch) are derived by model.
2. **Engine-Level Dynamic Power:** Physical power meters measure whole-board current, which includes linear/switching regulators, FTDI USB bridge, clock oscillator, and I/O pads. Internal engine-level power is evaluated via post-implementation SAIF switching activity.
3. **Glitch / Transition Power:** Cannot be isolated on board rail; characterized exclusively in SDF timing simulation.
4. **Per-Patch Sub-Microsecond Engine Latency:** Hardware engine latency ($120\text{ ns to } 220\text{ ns}$) is completely embedded within the $2.083\text{ ms}$ UART transmission envelope.
