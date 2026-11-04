# Cross-Design Functional & Telemetry Consistency Verification

This verification checks whether designs with mathematically equivalent execution policies
produce bit-identical cycle counts and zero-skip/gating counts on real Spartan-7 silicon.

| Comparison Pair | Design A | Design B | Design A Cycles | Design B Cycles | Cycle Diff | Design A Skips | Design B Skips | Skip Diff | Hardware Verification Verdict |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Fixed-Latency Power Gating (CG vs OI+CG) | `cg` | `oi_cg` | 298,368 | 298,368 | 0 | 103,234 | 103,234 | 0 | **PASS (Bit-Identical Silicon Match)** |
| Fixed-Latency Multiplier Clamping (OI vs CG) | `oi` | `cg` | 298,368 | 298,368 | 0 | 103,234 | 103,234 | 0 | **PASS (Bit-Identical Silicon Match)** |
| Zero-Skipping Engine (ZS vs ZS+CG) | `zs` | `zs_cg` | 195,134 | 195,134 | 0 | 103,234 | 103,234 | 0 | **PASS (Bit-Identical Silicon Match)** |
| Zero-Skipping Engine (ZS vs ZS+OI) | `zs` | `zs_oi` | 195,134 | 195,134 | 0 | 103,234 | 103,234 | 0 | **PASS (Bit-Identical Silicon Match)** |
| Full Tri-Optimization (ZS+CG vs Combined) | `zs_cg` | `combined` | 195,134 | 195,134 | 0 | 103,234 | 103,234 | 0 | **PASS (Bit-Identical Silicon Match)** |
| Proposed vs Baseline Speedup | `combined` | `baseline` | 195,134 | 298,368 | -103234 | 103,234 | 0 | 103234 | **PASS (103,234 cycles saved, 34.60% speedup)** |
