# Cross-Design Functional & Counter Consistency Verification

| Architecture Pair | Design A | Design B | Design A Cycles | Design B Cycles | Cycle Difference | Design A Skips | Design B Skips | Skip Difference | Status |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Clock Gating Equivalence | `cg` | `oi_cg` | 396,288 | 396,288 | 0 | 136,984 | 136,984 | 0 | **PASS (Bit-Identical)** |
| Zero-Skipping Equivalence | `zs_cg` | `combined` | 259,304 | 259,304 | 0 | 136,984 | 136,984 | 0 | **PASS (Bit-Identical)** |
