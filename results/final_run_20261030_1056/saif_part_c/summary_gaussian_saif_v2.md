# G4 Part C Gaussian Switching Activity & Power Analysis Summary (Wrapper v2)

Target: Spartan-7 XC7S15-1FTGB196C @ 50 MHz  
Stimulus: 44,032 real Gaussian patches (Rule 2 Rescaling, Natural Order, Back-to-Back)  
Wrapper: `conv2d_engine_wrapper_v2.sv` (with 1-cycle operand settling pipeline)  

| Variant | Select | Patches | Mismatches | Cycles | Speedup | Coverage | Conf | Dyn Power (XML mW) | Dyn Power Δ% | Static Power (XML mW) | Energy/Patch (nJ) | Energy Δ% | Core Row (Text mW) |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `baseline` | 0 | 44032 | 0 | 572416 | 1.0000x | 94% | High | 1.157 | +0.00% | 16.383 | 0.3008 | +0.00% | N/A |
| `cg` | 2 | 44032 | 0 | 572416 | 1.0000x | 93% | High | 1.151 | -0.52% | 16.383 | 0.2993 | -0.52% | N/A |
| `oi` | 1 | 44032 | 0 | 572416 | 1.0000x | 94% | High | 1.350 | +16.68% | 16.383 | 0.3510 | +16.68% | N/A |
| `zs` | 3 | 44032 | 0 | 307805 | 1.8597x | 93% | High | 1.367 | +18.15% | 16.383 | 0.1911 | -36.47% | N/A |
| `zs_cg` | 6 | 44032 | 0 | 307805 | 1.8597x | 93% | High | 1.391 | +20.22% | 16.383 | 0.1945 | -35.35% | N/A |
