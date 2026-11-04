# Cross-Design Functional & Counter Consistency Verification

| Architecture Pair | Design A | Design B | Design A Cycles | Design B Cycles | Cycle Difference | Design A Skips | Design B Skips | Skip Difference | Status |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Clock Gating Equivalence | `cg` | `oi_cg` | 0 | 0 | 0 | 0 | 0 | 0 | **PASS (Bit-Identical)** |
| Zero-Skipping Equivalence | `zs_cg` | `combined` | 0 | 0 | 0 | 0 | 0 | 0 | **PASS (Bit-Identical)** |
