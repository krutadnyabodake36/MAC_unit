# Comprehensive Tap-by-Tap Operands and Partial Sum Breakdown for 17 SDF Mismatches
**Status:** All 17 mismatches located in **image3.vec** (global patch indices 23,936 to 33,151).
**Classification:** Labelled **HYPOTHESIS** (transient carry evaluation anomaly in simprims_ver.CARRY4 during zero-delay multi-net transition settling, not functional RTL defect).

## Patch 24307 (Image 3 Relative Index: 371) - Design: baseline
- **Expected Sum:** -710 | **Got (SDF):** -8902 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [0, -84, -120, 123, 59, -95, 127, 118, -27]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |    0 |      0 |      0 |
| 1 |    0 |  -84 |      0 |      0 |
| 2 |    1 | -120 |   -120 |   -120 |
| 3 |   -2 |  123 |   -246 |   -366 |
| 4 |    0 |   59 |      0 |   -366 |
| 5 |    2 |  -95 |   -190 |   -556 |
| 6 |   -1 |  127 |   -127 |   -683 |
| 7 |    0 |  118 |      0 |   -683 |
| 8 |    1 |  -27 |    -27 |   -710 |

## Patch 25151 (Image 3 Relative Index: 1215) - Design: baseline
- **Expected Sum:** -530 | **Got (SDF):** -8722 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [-59, -111, -19, 71, -77, -111, 122, 55, -84]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  -59 |     59 |     59 |
| 1 |    0 | -111 |      0 |     59 |
| 2 |    1 |  -19 |    -19 |     40 |
| 3 |   -2 |   71 |   -142 |   -102 |
| 4 |    0 |  -77 |      0 |   -102 |
| 5 |    2 | -111 |   -222 |   -324 |
| 6 |   -1 |  122 |   -122 |   -446 |
| 7 |    0 |   55 |      0 |   -446 |
| 8 |    1 |  -84 |    -84 |   -530 |

## Patch 25271 (Image 3 Relative Index: 1335) - Design: baseline
- **Expected Sum:** -534 | **Got (SDF):** -8726 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [32, -78, -14, 122, 55, -75, 124, 122, 30]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |   32 |    -32 |    -32 |
| 1 |    0 |  -78 |      0 |    -32 |
| 2 |    1 |  -14 |    -14 |    -46 |
| 3 |   -2 |  122 |   -244 |   -290 |
| 4 |    0 |   55 |      0 |   -290 |
| 5 |    2 |  -75 |   -150 |   -440 |
| 6 |   -1 |  124 |   -124 |   -564 |
| 7 |    0 |  122 |      0 |   -564 |
| 8 |    1 |   30 |     30 |   -534 |

## Patch 25314 (Image 3 Relative Index: 1378) - Design: baseline
- **Expected Sum:** -200 | **Got (SDF):** -8392 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [-119, -121, -121, -14, -69, -94, 122, 106, 84]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 | -119 |    119 |    119 |
| 1 |    0 | -121 |      0 |    119 |
| 2 |    1 | -121 |   -121 |     -2 |
| 3 |   -2 |  -14 |     28 |     26 |
| 4 |    0 |  -69 |      0 |     26 |
| 5 |    2 |  -94 |   -188 |   -162 |
| 6 |   -1 |  122 |   -122 |   -284 |
| 7 |    0 |  106 |      0 |   -284 |
| 8 |    1 |   84 |     84 |   -200 |

## Patch 25909 (Image 3 Relative Index: 1973) - Design: baseline
- **Expected Sum:** -863 | **Got (SDF):** -9055 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [114, -38, -91, 126, 49, -105, 126, 101, -70]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  114 |   -114 |   -114 |
| 1 |    0 |  -38 |      0 |   -114 |
| 2 |    1 |  -91 |    -91 |   -205 |
| 3 |   -2 |  126 |   -252 |   -457 |
| 4 |    0 |   49 |      0 |   -457 |
| 5 |    2 | -105 |   -210 |   -667 |
| 6 |   -1 |  126 |   -126 |   -793 |
| 7 |    0 |  101 |      0 |   -793 |
| 8 |    1 |  -70 |    -70 |   -863 |

## Patch 26038 (Image 3 Relative Index: 2102) - Design: baseline
- **Expected Sum:** -643 | **Got (SDF):** -8835 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [49, -105, -8, 101, -70, -76, 122, -12, -110]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |   49 |    -49 |    -49 |
| 1 |    0 | -105 |      0 |    -49 |
| 2 |    1 |   -8 |     -8 |    -57 |
| 3 |   -2 |  101 |   -202 |   -259 |
| 4 |    0 |  -70 |      0 |   -259 |
| 5 |    2 |  -76 |   -152 |   -411 |
| 6 |   -1 |  122 |   -122 |   -533 |
| 7 |    0 |  -12 |      0 |   -533 |
| 8 |    1 | -110 |   -110 |   -643 |

## Patch 27244 (Image 3 Relative Index: 3308) - Design: baseline
- **Expected Sum:** -926 | **Got (SDF):** -9118 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [127, 63, -109, 127, 67, -107, 127, 83, -95]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  127 |   -127 |   -127 |
| 1 |    0 |   63 |      0 |   -127 |
| 2 |    1 | -109 |   -109 |   -236 |
| 3 |   -2 |  127 |   -254 |   -490 |
| 4 |    0 |   67 |      0 |   -490 |
| 5 |    2 | -107 |   -214 |   -704 |
| 6 |   -1 |  127 |   -127 |   -831 |
| 7 |    0 |   83 |      0 |   -831 |
| 8 |    1 |  -95 |    -95 |   -926 |

## Patch 28166 (Image 3 Relative Index: 4230) - Design: baseline
- **Expected Sum:** -907 | **Got (SDF):** -9099 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [123, 101, -73, 124, 52, -110, 122, -18, -121]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  123 |   -123 |   -123 |
| 1 |    0 |  101 |      0 |   -123 |
| 2 |    1 |  -73 |    -73 |   -196 |
| 3 |   -2 |  124 |   -248 |   -444 |
| 4 |    0 |   52 |      0 |   -444 |
| 5 |    2 | -110 |   -220 |   -664 |
| 6 |   -1 |  122 |   -122 |   -786 |
| 7 |    0 |  -18 |      0 |   -786 |
| 8 |    1 | -121 |   -121 |   -907 |

## Patch 28330 (Image 3 Relative Index: 4394) - Design: baseline
- **Expected Sum:** -302 | **Got (SDF):** -8494 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [-107, -119, -119, 59, 5, -72, 120, 123, 92]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 | -107 |    107 |    107 |
| 1 |    0 | -119 |      0 |    107 |
| 2 |    1 | -119 |   -119 |    -12 |
| 3 |   -2 |   59 |   -118 |   -130 |
| 4 |    0 |    5 |      0 |   -130 |
| 5 |    2 |  -72 |   -144 |   -274 |
| 6 |   -1 |  120 |   -120 |   -394 |
| 7 |    0 |  123 |      0 |   -394 |
| 8 |    1 |   92 |     92 |   -302 |

## Patch 28549 (Image 3 Relative Index: 4613) - Design: baseline
- **Expected Sum:** -900 | **Got (SDF):** -9092 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [121, 103, -75, 125, 66, -106, 125, 24, -117]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  121 |   -121 |   -121 |
| 1 |    0 |  103 |      0 |   -121 |
| 2 |    1 |  -75 |    -75 |   -196 |
| 3 |   -2 |  125 |   -250 |   -446 |
| 4 |    0 |   66 |      0 |   -446 |
| 5 |    2 | -106 |   -212 |   -658 |
| 6 |   -1 |  125 |   -125 |   -783 |
| 7 |    0 |   24 |      0 |   -783 |
| 8 |    1 | -117 |   -117 |   -900 |

## Patch 29195 (Image 3 Relative Index: 5259) - Design: baseline
- **Expected Sum:** -939 | **Got (SDF):** -9131 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [105, -73, -121, 118, -41, -121, 120, 23, -115]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  105 |   -105 |   -105 |
| 1 |    0 |  -73 |      0 |   -105 |
| 2 |    1 | -121 |   -121 |   -226 |
| 3 |   -2 |  118 |   -236 |   -462 |
| 4 |    0 |  -41 |      0 |   -462 |
| 5 |    2 | -121 |   -242 |   -704 |
| 6 |   -1 |  120 |   -120 |   -824 |
| 7 |    0 |   23 |      0 |   -824 |
| 8 |    1 | -115 |   -115 |   -939 |

## Patch 29666 (Image 3 Relative Index: 5730) - Design: baseline
- **Expected Sum:** -883 | **Got (SDF):** -9075 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [97, 71, -103, 113, 53, -110, 122, 32, -115]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |   97 |    -97 |    -97 |
| 1 |    0 |   71 |      0 |    -97 |
| 2 |    1 | -103 |   -103 |   -200 |
| 3 |   -2 |  113 |   -226 |   -426 |
| 4 |    0 |   53 |      0 |   -426 |
| 5 |    2 | -110 |   -220 |   -646 |
| 6 |   -1 |  122 |   -122 |   -768 |
| 7 |    0 |   32 |      0 |   -768 |
| 8 |    1 | -115 |   -115 |   -883 |

## Patch 30768 (Image 3 Relative Index: 6832) - Design: baseline
- **Expected Sum:** -807 | **Got (SDF):** -8999 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [92, 109, -60, 112, 78, -99, 119, 44, -114]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |   92 |    -92 |    -92 |
| 1 |    0 |  109 |      0 |    -92 |
| 2 |    1 |  -60 |    -60 |   -152 |
| 3 |   -2 |  112 |   -224 |   -376 |
| 4 |    0 |   78 |      0 |   -376 |
| 5 |    2 |  -99 |   -198 |   -574 |
| 6 |   -1 |  119 |   -119 |   -693 |
| 7 |    0 |   44 |      0 |   -693 |
| 8 |    1 | -114 |   -114 |   -807 |

## Patch 30821 (Image 3 Relative Index: 6885) - Design: baseline
- **Expected Sum:** -897 | **Got (SDF):** -9089 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [127, 104, -59, 127, 52, -107, 123, -10, -120]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  127 |   -127 |   -127 |
| 1 |    0 |  104 |      0 |   -127 |
| 2 |    1 |  -59 |    -59 |   -186 |
| 3 |   -2 |  127 |   -254 |   -440 |
| 4 |    0 |   52 |      0 |   -440 |
| 5 |    2 | -107 |   -214 |   -654 |
| 6 |   -1 |  123 |   -123 |   -777 |
| 7 |    0 |  -10 |      0 |   -777 |
| 8 |    1 | -120 |   -120 |   -897 |

## Patch 31608 (Image 3 Relative Index: 7672) - Design: baseline
- **Expected Sum:** -492 | **Got (SDF):** -8684 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [-17, 103, -33, 52, 65, -105, 63, 72, -99]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  -17 |     17 |     17 |
| 1 |    0 |  103 |      0 |     17 |
| 2 |    1 |  -33 |    -33 |    -16 |
| 3 |   -2 |   52 |   -104 |   -120 |
| 4 |    0 |   65 |      0 |   -120 |
| 5 |    2 | -105 |   -210 |   -330 |
| 6 |   -1 |   63 |    -63 |   -393 |
| 7 |    0 |   72 |      0 |   -393 |
| 8 |    1 |  -99 |    -99 |   -492 |

## Patch 32939 (Image 3 Relative Index: 9003) - Design: baseline
- **Expected Sum:** -775 | **Got (SDF):** -8967 | **Difference:** -8192 ($-2^{13}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [118, -34, -49, 123, 10, -78, 122, 31, -84]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  118 |   -118 |   -118 |
| 1 |    0 |  -34 |      0 |   -118 |
| 2 |    1 |  -49 |    -49 |   -167 |
| 3 |   -2 |  123 |   -246 |   -413 |
| 4 |    0 |   10 |      0 |   -413 |
| 5 |    2 |  -78 |   -156 |   -569 |
| 6 |   -1 |  122 |   -122 |   -691 |
| 7 |    0 |   31 |      0 |   -691 |
| 8 |    1 |  -84 |    -84 |   -775 |

## Patch 31334 (Image 3 Relative Index: 7398) - Design: static_sobel
- **Expected Sum:** -639 | **Got (SDF):** -17023 | **Difference:** -16384 ($-2^{14}$) [HYPOTHESIS]
- **Weights (w0..w8):** [-1, 0, 1, -2, 0, 2, -1, 0, 1]
- **Pixels  (p0..p8):** [-29, -120, -120, 40, -107, -121, 112, -20, -114]
| Tap $ | Weight $ | Pixel $ | Product  \times p_i$ | Running Partial Sum |
| :---: | :---: | :---: | :---: | :---: |
| 0 |   -1 |  -29 |     29 |     29 |
| 1 |    0 | -120 |      0 |     29 |
| 2 |    1 | -120 |   -120 |    -91 |
| 3 |   -2 |   40 |    -80 |   -171 |
| 4 |    0 | -107 |      0 |   -171 |
| 5 |    2 | -121 |   -242 |   -413 |
| 6 |   -1 |  112 |   -112 |   -525 |
| 7 |    0 |  -20 |      0 |   -525 |
| 8 |    1 | -114 |   -114 |   -639 |
