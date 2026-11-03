# G3 Post-Implementation Functional Netlist Verification Summary

Target: Spartan-7 XC7S15 @ 50 MHz  
Wrapper: `conv2d_engine_wrapper_v2.sv` (with 1-cycle operand settling pipeline)  
Stimulus: 44,032 back-to-back real Sobel image patches (image1..4)  

| Variant Index | Architecture Name | Total Patches | Total Mismatches | Measured Wall Cycles | Wall Cycles / Patch | Status |
|---|---|---|---|---|---|---|
| 0 | `baseline` | 44032 | 0 | 572416 | 13.0000 | **PASS** |
| 1 | `oi` | 44032 | 0 | 572416 | 13.0000 | **PASS** |
| 2 | `cg` | 44032 | 0 | 572416 | 13.0000 | **PASS** |
| 3 | `zs` | 44032 | 0 | 435432 | 9.8890 | **PASS** |
| 4 | `combined` | 44032 | 0 | 435432 | 9.8890 | **PASS** |
| 5 | `zs_oi` | 44032 | 0 | 435432 | 9.8890 | **PASS** |
| 6 | `zs_cg` | 44032 | 0 | 435432 | 9.8890 | **PASS** |
| 7 | `oi_cg` | 44032 | 0 | 572416 | 13.0000 | **PASS** |
| 8 | `static_sobel` | 44032 | 0 | 440320 | 10.0000 | **PASS** |
