# Superseded SAIF Power Results (Wrapper v1)

**Notice:**
These SAIF power results and gate-level simulation logs were produced using `src/conv2d_engine_wrapper.sv` (Wrapper v1).
Wrapper v1 contained a synchronous operand registration timing defect:
In `conv2d_engine_wrapper.sv`, `w_reg` and `p_reg` were clocked flip-flops enabled by `start`. When testbenches drove `start=1` synchronously with new inputs, `w_reg` and `p_reg` only updated *after* the clock edge. In `conv2d_serial_zs.sv` and all zero-skipping variants, `nz_mask` is evaluated combinationally and sampled into `remaining` at the *exact same* clock edge where `start` is sampled high. Consequently, `u_core` sampled the non-zero mask from the *previous* patch, leading to 1,427 functional mismatches at row boundaries across the 44,032 Sobel patches.

All results in this folder are retained for full auditability and transparency, but are formally superseded by the corrected Wrapper v2 (`conv2d_engine_wrapper_v2.sv`) flow.

