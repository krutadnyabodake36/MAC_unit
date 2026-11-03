# Empirical Verification Summary Report (Wrapper v2 Gate-Level SAIF Flow)

**Generated:** 2026-11-01 11:13:47  
**Target Silicon:** AMD/Xilinx Spartan-7 XC7S15-1FTGB196C @ 50 MHz (20.000 ns clock period)  
**Simulation Flow:** Zero-delay post-implementation routed functional netlist (`funcsim.v`) via Vivado XSim  
**Power Extraction:** Gate-level SAIF switching activity back-annotated into routed design checkpoint (`routed.dcp`) via Vivado `report_power`  
**Wrapper Architecture:** `conv2d_engine_wrapper_v2.sv` (with verified 1-cycle operand settling pipeline)  
**Note on Energy Metric:** Reported dynamic energy per patch includes the 2 setup/handshake cycles per patch for every engine over the full measurement window.  
**Noise & Resolution Threshold:** Characterised strictly by: (a) netlist-identical pairs yield exactly 0.000 mW difference, and (b) baseline pilot-vs-rerun flow difference is 4.7%. All between-variant power/energy differences under 5% are classified as **UNRESOLVED**.  
**ZS-Family Savings Note (Part A5):** ZS-family dynamic energy savings (-7.6% to -8.7%) exceed the single observed 4.7% flow-to-flow difference (v1 pilot vs rerun baseline) by a small margin; ordering among `zs`, `zs_oi`, and `zs_cg` is unresolved. `cg` remains classified as UNRESOLVED.  

---

## 1. Primary Sobel Workload Results (44,032 Real Patches)

| Variant | Select | Patches | Mismatches | Engine Cyc/P | Harness Cyc/P | Engine Speedup | Harness Speedup | SAIF Cov | Conf | Dyn Power (mW) | Dyn Δ% | Static Power (mW) | Energy/Patch (nJ) | Energy Δ% | Assessment |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|---|
| `baseline` | 0 | 44032 | **0** | **11.0000** | 13.0000 | **1.0000x** | 1.0000x | 94% | High | 2.061 | +0.00% | 16.383 | **0.5359** | **+0.00%** | Baseline Reference |
| `cg` | 2 | 44032 | **0** | **11.0000** | 13.0000 | **1.0000x** | 1.0000x | 93% | High | 2.024 | -1.80% | 16.383 | **0.5262** | **-1.80%** | **UNRESOLVED (<5% noise)** |
| `oi` | 1 | 44032 | **0** | **11.0000** | 13.0000 | **1.0000x** | 1.0000x | 94% | High | 2.380 | +15.48% | 16.383 | **0.6188** | **+15.48%** | **RESOLVED (+15.48%)** |
| `zs` | 3 | 44032 | **0** | **7.8890** | 9.8890 | **1.3943x** | 1.3146x | 93% | High | 2.475 | +20.09% | 16.383 | **0.4895** | **-8.65%** | **RESOLVED (-8.65%)** |
| `zs_oi` | 5 | 44032 | **0** | **7.8890** | 9.8890 | **1.3943x** | 1.3146x | 93% | High | 2.495 | +21.06% | 16.383 | **0.4935** | **-7.91%** | **RESOLVED (-7.91%)** |
| `zs_cg` | 6 | 44032 | **0** | **7.8890** | 9.8890 | **1.3943x** | 1.3146x | 93% | High | 2.503 | +21.45% | 16.383 | **0.4950** | **-7.62%** | **RESOLVED (-7.62%)** |
| `static_sobel` | 8 | 44032 | **0** | **8.0000** | 10.0000 | **1.3750x** | 1.3000x | 93% | High | 1.834 | -11.01% | 16.383 | **0.3668** | **-31.55%** | **RESOLVED (-31.55%)** |
| `oi_cg` | 7 | 44032 | **0** | **11.0000** | 13.0000 | **1.0000x** | 1.0000x | 93% | High | 2.024 | -1.80% | 16.383 | **0.5262** | **-1.80%** | **UNRESOLVED (<5% noise)** |
| `combined` | 4 | 44032 | **0** | **7.8890** | 9.8890 | **1.3943x** | 1.3146x | 93% | High | 2.503 | +21.45% | 16.383 | **0.4950** | **-7.62%** | **RESOLVED (-7.62%)** |

---

## 2. Part C Dense Gaussian Workload Results (Rule 2 Rescaling, 44,032 Patches)

| Variant | Select | Patches | Mismatches | Engine Cyc/P | Harness Cyc/P | Engine Speedup | Harness Speedup | SAIF Cov | Conf | Dyn Power (mW) | Dyn Δ% | Static Power (mW) | Energy/Patch (nJ) | Energy Δ% | Assessment |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|---|
| `baseline` | 0 | 44032 | **0** | **11.0000** | 13.0000 | **1.0000x** | 1.0000x | 94% | High | 1.157 | +0.00% | 16.383 | **0.3008** | **+0.00%** | Baseline Reference |
| `cg` | 2 | 44032 | **0** | **11.0000** | 13.0000 | **1.0000x** | 1.0000x | 93% | High | 1.151 | -0.52% | 16.383 | **0.2993** | **-0.52%** | **UNRESOLVED (<5% noise)** |
| `oi` | 1 | 44032 | **0** | **11.0000** | 13.0000 | **1.0000x** | 1.0000x | 94% | High | 1.350 | +16.68% | 16.383 | **0.3510** | **+16.68%** | **RESOLVED (+16.68%)** |
| `zs` | 3 | 44032 | **0** | **4.9905** | 6.9905 | **2.2042x** | 1.8597x | 93% | High | 1.367 | +18.15% | 16.383 | **0.1911** | **-36.47%** | **RESOLVED (-36.47%)** |
| `zs_cg` | 6 | 44032 | **0** | **4.9905** | 6.9905 | **2.2042x** | 1.8597x | 93% | High | 1.391 | +20.22% | 16.383 | **0.1945** | **-35.35%** | **RESOLVED (-35.35%)** |

---

## 3. Netlist-Identical Pair Verification

Only architectures whose post-synthesis netlists are provably structurally identical are evaluated as paired controls:

- **Pair 1 (`cg` vs `oi_cg`):**
  - `cg`: 2.024 mW, 0.5262 nJ
  - `oi_cg`: 2.024 mW, 0.5262 nJ
  - Difference: 0.0000 mW (0.00% difference, bit-exact match).

- **Pair 2 (`zs_cg` vs `combined`):**
  - `zs_cg`: 2.503 mW, 0.4950 nJ
  - `combined`: 2.503 mW, 0.4950 nJ
  - Difference: 0.0000 mW (0.00% difference, bit-exact match).

> [!NOTE]
> `zs` vs `zs_oi` is excluded from the netlist-identical pairs because their synthesized core engines differ in LUT utilization (247 vs 253 LUTs).

