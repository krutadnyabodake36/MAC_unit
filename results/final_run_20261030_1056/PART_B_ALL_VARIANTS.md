# Part B: Sparsity & Kernel Sweep (All 8 Variants + Static Baseline)

> **Standing Note on Architectural Equivalence:**
> - **Fixed-Schedule Variants (Baseline, OI-only, CG-only, OI+CG)** are cycle-exact identical: always 11 wall cycles (9 compute + 2 overhead) per patch.
> - **Zero-Skipping Family (ZS-only, ZS+OI, ZS+CG, Combined)** are cycle-exact identical: always non-zero MACs + 2 overhead cycles per patch.
> - **Static Sobel Baseline** is valid ONLY on Sobel-X: always 8 wall cycles (6 compute + 2 overhead) per patch.

| Kernel | Sparsity | Patches | Fixed Variants Wall | ZS-Family Wall | ZS Speedup | Static Sobel Wall | Static Speedup | Mismatches |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| sobel | 0% | 2000 | 22000 | 16000 | 1.3750x | 16000 | 1.3750x | 0 |
| gaussian | 0% | 2000 | 22000 | 22000 | 1.0000x | N/A | N/A | 0 |
| random | 0% | 2000 | 22000 | 22000 | 1.0000x | N/A | N/A | 0 |
| sobel | 10% | 2000 | 22000 | 14867 | 1.4798x | 16000 | 1.3750x | 0 |
| gaussian | 10% | 2000 | 22000 | 20269 | 1.0854x | N/A | N/A | 0 |
| random | 10% | 2000 | 22000 | 20269 | 1.0854x | N/A | N/A | 0 |
| sobel | 20% | 2000 | 22000 | 13473 | 1.6329x | 16000 | 1.3750x | 0 |
| gaussian | 20% | 2000 | 22000 | 18194 | 1.2092x | N/A | N/A | 0 |
| random | 20% | 2000 | 22000 | 18194 | 1.2092x | N/A | N/A | 0 |
| sobel | 30% | 2000 | 22000 | 12385 | 1.7763x | 16000 | 1.3750x | 0 |
| gaussian | 30% | 2000 | 22000 | 16530 | 1.3309x | N/A | N/A | 0 |
| random | 30% | 2000 | 22000 | 16530 | 1.3309x | N/A | N/A | 0 |
| sobel | 40% | 2000 | 22000 | 11196 | 1.9650x | 16000 | 1.3750x | 0 |
| gaussian | 40% | 2000 | 22000 | 14785 | 1.4880x | N/A | N/A | 0 |
| random | 40% | 2000 | 22000 | 14785 | 1.4880x | N/A | N/A | 0 |
| sobel | 50% | 2000 | 22000 | 10067 | 2.1854x | 16000 | 1.3750x | 0 |
| gaussian | 50% | 2000 | 22000 | 13081 | 1.6818x | N/A | N/A | 0 |
| random | 50% | 2000 | 22000 | 13081 | 1.6818x | N/A | N/A | 0 |
| sobel | 60% | 2000 | 22000 | 8761 | 2.5111x | 16000 | 1.3750x | 0 |
| gaussian | 60% | 2000 | 22000 | 11238 | 1.9576x | N/A | N/A | 0 |
| random | 60% | 2000 | 22000 | 11238 | 1.9576x | N/A | N/A | 0 |
| sobel | 70% | 2000 | 22000 | 7611 | 2.8906x | 16000 | 1.3750x | 0 |
| gaussian | 70% | 2000 | 22000 | 9389 | 2.3432x | N/A | N/A | 0 |
| random | 70% | 2000 | 22000 | 9389 | 2.3432x | N/A | N/A | 0 |
| sobel | 80% | 2000 | 22000 | 6490 | 3.3898x | 16000 | 1.3750x | 0 |
| gaussian | 80% | 2000 | 22000 | 7712 | 2.8527x | N/A | N/A | 0 |
| random | 80% | 2000 | 22000 | 7712 | 2.8527x | N/A | N/A | 0 |
| sobel | 90% | 2000 | 22000 | 5147 | 4.2743x | 16000 | 1.3750x | 0 |
| gaussian | 90% | 2000 | 22000 | 5733 | 3.8374x | N/A | N/A | 0 |
| random | 90% | 2000 | 22000 | 5733 | 3.8374x | N/A | N/A | 0 |
