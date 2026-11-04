# Per-Image Hardware Execution Breakdown across All 9 Variants

Workload Triad: `image1.jpg` (11,648 patches), `image2.jpg` (12,288 patches), `image3.jpg` (9,216 patches).

### Workload: `image1.jpg` (11,648 Patches)
| Variant | Silicon Compute Cycles | Mean Cyc/Patch | Zero-Skips/Gated | % Cycle Savings | Hardware Time | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `baseline` | 104,832 | 9.00 | 0 | — | 186.39 s | **PASS** |
| `zs` | 68,436 | 5.88 | 36,396 | 34.72% | 186.38 s | **PASS** |
| `oi` | 104,832 | 9.00 | 36,396 | — | 186.36 s | **PASS** |
| `cg` | 104,832 | 9.00 | 36,396 | — | 186.36 s | **PASS** |
| `zs_cg` | 68,436 | 5.88 | 36,396 | 34.72% | 186.36 s | **PASS** |
| `oi_cg` | 104,832 | 9.00 | 36,396 | — | 186.37 s | **PASS** |
| `zs_oi` | 68,436 | 5.88 | 36,396 | 34.72% | 186.39 s | **PASS** |
| `combined` | 68,436 | 5.88 | 36,396 | 34.72% | 186.37 s | **PASS** |
| `static_sobel` | 69,888 | 6.00 | 0 | 33.33% | 186.91 s | **PASS** |

### Workload: `image2.jpg` (12,288 Patches)
| Variant | Silicon Compute Cycles | Mean Cyc/Patch | Zero-Skips/Gated | % Cycle Savings | Hardware Time | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `baseline` | 110,592 | 9.00 | 0 | — | 198.91 s | **PASS** |
| `zs` | 72,456 | 5.90 | 38,136 | 34.48% | 196.60 s | **PASS** |
| `oi` | 110,592 | 9.00 | 38,136 | — | 196.63 s | **PASS** |
| `cg` | 110,592 | 9.00 | 38,136 | — | 196.62 s | **PASS** |
| `zs_cg` | 72,456 | 5.90 | 38,136 | 34.48% | 196.61 s | **PASS** |
| `oi_cg` | 110,592 | 9.00 | 38,136 | — | 197.20 s | **PASS** |
| `zs_oi` | 72,456 | 5.90 | 38,136 | 34.48% | 196.65 s | **PASS** |
| `combined` | 72,456 | 5.90 | 38,136 | 34.48% | 196.64 s | **PASS** |
| `static_sobel` | 73,728 | 6.00 | 0 | 33.33% | 197.23 s | **PASS** |

### Workload: `image3.jpg` (9,216 Patches)
| Variant | Silicon Compute Cycles | Mean Cyc/Patch | Zero-Skips/Gated | % Cycle Savings | Hardware Time | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `baseline` | 82,944 | 9.00 | 0 | — | 148.25 s | **PASS** |
| `zs` | 54,242 | 5.89 | 28,702 | 34.60% | 147.47 s | **PASS** |
| `oi` | 82,944 | 9.00 | 28,702 | — | 147.45 s | **PASS** |
| `cg` | 82,944 | 9.00 | 28,702 | — | 147.48 s | **PASS** |
| `zs_cg` | 54,242 | 5.89 | 28,702 | 34.60% | 147.46 s | **PASS** |
| `oi_cg` | 82,944 | 9.00 | 28,702 | — | 147.47 s | **PASS** |
| `zs_oi` | 54,242 | 5.89 | 28,702 | 34.60% | 147.52 s | **PASS** |
| `combined` | 54,242 | 5.89 | 28,702 | 34.60% | 147.92 s | **PASS** |
| `static_sobel` | 55,296 | 6.00 | 0 | 33.33% | 147.93 s | **PASS** |

