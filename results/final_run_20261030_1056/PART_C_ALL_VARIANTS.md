# Part C: Real Image ReLU Activation Workloads (All Variants)

> **Standing Note on Architectural Equivalence:**
> - Fixed-Schedule Variants (Baseline, OI-only, CG-only, OI+CG) are cycle-exact identical (11 wall cycles/patch).
> - Zero-Skipping Family (ZS-only, ZS+OI, ZS+CG, Combined) are cycle-exact identical (non-zero MACs + 2 wall cycles/patch).
> - Static Sobel is marked **N/A** because Part C uses 100% dense kernels (Gaussian and Random Dense).

### Dual Rescale Rules Evaluated:
1. **Rule 1 (Max-Normalized):** `round(Y_relu * 127.0 / max(Y_relu))`
2. **Rule 2 (Fixed Shift):** `clip(Y_relu >> 3, 0, 127)` (Pre-chosen based on 1020 theoretical max Sobel gradient)

| Image | Proc Dim | Patches | Sp Before | Fixed Wall | Sp Rule 1 | ZS Wall (R1) | Speedup (R1) | Sp Rule 2 | ZS Wall (R2) | Speedup (R2) | Static Sobel | Mismatches |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| image1.jpg | 91x128 | 23296 | 51.64% | 256256 | 53.36% | 143334 | 1.7878x | 56.40% | 137232 | 1.8673x | N/A (Dense Kernels) | 0 |
| image2.jpg | 128x96 | 24576 | 52.14% | 270336 | 54.50% | 148388 | 1.8218x | 60.16% | 135968 | 1.9882x | N/A (Dense Kernels) | 0 |
| image3.jpg | 128x72 | 18432 | 52.32% | 202752 | 54.75% | 110920 | 1.8279x | 55.89% | 109060 | 1.8591x | N/A (Dense Kernels) | 0 |
| image4.jpg | 85x128 | 21760 | 85.24% | 239360 | 88.80% | 64488 | 3.7117x | 92.52% | 57222 | 4.1830x | N/A (Dense Kernels) | 0 |
| extra_images (1).jpg | 128x85 | 21760 | 43.69% | 239360 | 48.08% | 144140 | 1.6606x | 59.16% | 122732 | 1.9503x | N/A (Dense Kernels) | 0 |
| extra_images (2).jpg | 128x117 | 29952 | 51.98% | 329472 | 53.57% | 183520 | 1.7953x | 62.02% | 160882 | 2.0479x | N/A (Dense Kernels) | 0 |
| extra_images (3).jpg | 85x128 | 21760 | 51.41% | 239360 | 55.18% | 130118 | 1.8396x | 72.17% | 97122 | 2.4645x | N/A (Dense Kernels) | 0 |
| extra_images (4).jpg | 72x128 | 18432 | 53.97% | 202752 | 61.48% | 99742 | 2.0328x | 74.39% | 78502 | 2.5828x | N/A (Dense Kernels) | 0 |
| extra_images (5).jpg | 85x128 | 21760 | 51.32% | 239360 | 52.22% | 135894 | 1.7614x | 57.64% | 125352 | 1.9095x | N/A (Dense Kernels) | 0 |
| extra_images (6).jpg | 128x128 | 32768 | 55.07% | 360448 | 58.72% | 186278 | 1.9350x | 61.95% | 176786 | 2.0389x | N/A (Dense Kernels) | 0 |
| extra_images (7).jpg | 128x85 | 21760 | 50.69% | 239360 | 51.53% | 137156 | 1.7452x | 52.81% | 134660 | 1.7775x | N/A (Dense Kernels) | 0 |
| extra_images (8).jpg | 85x128 | 21760 | 48.53% | 239360 | 50.51% | 139716 | 1.7132x | 55.16% | 130680 | 1.8316x | N/A (Dense Kernels) | 0 |
| extra_images.jpg | 111x128 | 28416 | 61.92% | 312576 | 67.61% | 138496 | 2.2569x | 81.64% | 102844 | 3.0393x | N/A (Dense Kernels) | 0 |
| extra_images1.jpg | 85x128 | 21760 | 56.65% | 239360 | 63.09% | 114248 | 2.0951x | 69.70% | 101366 | 2.3613x | N/A (Dense Kernels) | 0 |
