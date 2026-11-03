# G4 Sobel Switching Activity & Power Analysis Summary (Wrapper v2)

Target: Spartan-7 XC7S15-1FTGB196C @ 50 MHz  
Stimulus: 44,032 real Sobel patches (Natural Order, Back-to-Back)  
Wrapper: `conv2d_engine_wrapper_v2.sv` (with 1-cycle operand settling pipeline)  

| Variant | Select | Patches | Mismatches | Cycles | Speedup | Coverage | Conf | Dyn Power (XML mW) | Dyn Power Δ% | Static Power (XML mW) | Energy/Patch (nJ) | Energy Δ% | Core Row (Text mW) |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `baseline` | 0 | 44032 | 0 | 572416 | 1.0000x | 94% | High | 2.061 | +0.00% | 16.383 | 0.5359 | +0.00% | 2.0 |
| `cg` | 2 | 44032 | 0 | 572416 | 1.0000x | 93% | High | 2.024 | -1.80% | 16.383 | 0.5262 | -1.80% | 2.0 |
| `oi` | 1 | 44032 | 0 | 572416 | 1.0000x | 94% | High | 2.380 | +15.48% | 16.383 | 0.6188 | +15.48% | 2.0 |
| `zs` | 3 | 44032 | 0 | 435432 | 1.3146x | 93% | High | 2.475 | +20.09% | 16.383 | 0.4895 | -8.65% | 2.0 |
| `zs_oi` | 5 | 44032 | 0 | 435432 | 1.3146x | 93% | High | 2.495 | +21.06% | 16.383 | 0.4935 | -7.91% | 2.0 |
| `zs_cg` | 6 | 44032 | 0 | 435432 | 1.3146x | 93% | High | 2.503 | +21.45% | 16.383 | 0.4950 | -7.62% | 2.0 |
| `static_sobel` | 8 | 44032 | 0 | 440320 | 1.3000x | 93% | High | 1.834 | -11.01% | 16.383 | 0.3668 | -31.55% | 2.0 |
| `oi_cg` | 7 | 44032 | 0 | 572416 | 1.0000x | 93% | High | 2.024 | -1.80% | 16.383 | 0.5262 | -1.80% | 2.0 |
| `combined` | 4 | 44032 | 0 | 435432 | 1.3146x | 93% | High | 2.503 | +21.45% | 16.383 | 0.4950 | -7.62% | 2.0 |
