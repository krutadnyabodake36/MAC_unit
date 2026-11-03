import os
import json
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056")

SOBEL_X = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], dtype=np.int32)
KERNELS = {
    "gaussian": [ 1,  2,  1,  2,  4,  2,  1,  2,  1],
    "random":   [-3,  2,  1,  4, -2,  5,  1, -4,  3],
}

def resize_aspect_preserved(img_gray, max_edge=128):
    raw_w, raw_h = img_gray.size
    longest = max(raw_w, raw_h)
    if longest > max_edge:
        scale = max_edge / float(longest)
        new_w = max(3, int(round(raw_w * scale)))
        new_h = max(3, int(round(raw_h * scale)))
        resized = img_gray.resize((new_w, new_h), Image.Resampling.BILINEAR)
    else:
        resized = img_gray
        new_w, new_h = raw_w, raw_h
    return np.asarray(resized, dtype=np.uint8), new_h, new_w

images = []
for f in ["image1.jpg", "image2.jpg", "image3.jpg", "image4.jpg"]:
    p = os.path.join(PROJECT_ROOT, f)
    if os.path.exists(p):
        images.append((f, p))

extra_dir = os.path.join(PROJECT_ROOT, "images_extra")
for f in sorted(os.listdir(extra_dir)):
    p = os.path.join(extra_dir, f)
    if os.path.isfile(p) and f.lower().endswith((".jpg", ".jpeg", ".png")):
        images.append((f"extra_{f}", p))

results_table = []
rule1_speedups = []
rule2_speedups = []

for label, img_path in images:
    img = Image.open(img_path).convert("L")
    raw_w, raw_h = img.size
    u8_arr, h, w = resize_aspect_preserved(img, max_edge=128)
    total_pixels = h * w

    # 1. Zero-point shift
    int8_img = (u8_arr.astype(np.int16) - 128).astype(np.int8)

    # 2. Stage 1: Sobel-X conv with 0-padding
    padded_s1 = np.pad(int8_img.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)
    sobel_out = np.zeros((h, w), dtype=np.int32)
    for r in range(h):
        for c in range(w):
            patch = padded_s1[r:r+3, c:c+3]
            sobel_out[r, c] = np.sum(patch * SOBEL_X)

    # 3. Stage 1 ReLU
    relu_out = np.maximum(0, sobel_out)

    # (a) Sparsity after ReLU, before rescale
    zeros_before = int(np.sum(relu_out == 0))
    sp_before = (zeros_before / total_pixels) * 100.0

    # (b) Sparsity after Rule 1 (max-normalized rescale to [0, 127])
    max_val = np.max(relu_out)
    if max_val > 0:
        scaled_r1 = np.round((relu_out * 127.0) / max_val).astype(np.int8)
    else:
        scaled_r1 = np.zeros((h, w), dtype=np.int8)
    zeros_r1 = int(np.sum(scaled_r1 == 0))
    sp_r1 = (zeros_r1 / total_pixels) * 100.0

    # (c) Sparsity after Rule 2 (fixed right-shift >> 3 with saturation to [0, 127])
    # Pre-chosen: 1020 theoretical max Sobel-X gradient >> 3 = 127.5
    scaled_r2 = np.clip(relu_out >> 3, 0, 127).astype(np.int8)
    zeros_r2 = int(np.sum(scaled_r2 == 0))
    sp_r2 = (zeros_r2 / total_pixels) * 100.0

    # Speedup calculation on 2nd-stage 3x3 patches with dense kernels
    # Rule 1 patches
    pad_r1 = np.pad(scaled_r1.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)
    pad_r2 = np.pad(scaled_r2.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)

    total_bl_cycles = total_pixels * 11 # 11 cycles per patch
    
    # We evaluate both dense kernels (Gaussian and Random Dense)
    wall_zs_r1 = 0
    wall_zs_r2 = 0
    total_evals = 0

    for kname, kweights in KERNELS.items():
        kw = np.array(kweights, dtype=np.int32)
        for r in range(h):
            for c in range(w):
                p1 = pad_r1[r:r+3, c:c+3].flatten()
                p2 = pad_r2[r:r+3, c:c+3].flatten()
                
                # ZS cycles = count of non-zero products + 2
                nz1 = int(np.sum((kw != 0) & (p1 != 0)))
                nz2 = int(np.sum((kw != 0) & (p2 != 0)))
                
                wall_zs_r1 += (nz1 + 2)
                wall_zs_r2 += (nz2 + 2)
                total_evals += 1

    bl_wall_all = total_evals * 11
    sp_gain_r1 = bl_wall_all / wall_zs_r1
    sp_gain_r2 = bl_wall_all / wall_zs_r2

    rule1_speedups.append(sp_gain_r1)
    rule2_speedups.append(sp_gain_r2)

    results_table.append({
        "image": label,
        "raw_dim": f"{raw_w}x{raw_h}",
        "proc_dim": f"{w}x{h}",
        "total_pixels": total_pixels,
        "zeros_before_rescale": zeros_before,
        "sparsity_before_rescale_pct": sp_before,
        "zeros_rule1": zeros_r1,
        "sparsity_rule1_pct": sp_r1,
        "speedup_rule1": sp_gain_r1,
        "zeros_rule2": zeros_r2,
        "sparsity_rule2_pct": sp_r2,
        "speedup_rule2": sp_gain_r2,
        "max_relu_val": int(max_val)
    })

# Compute statistics
r1_min, r1_med, r1_max = min(rule1_speedups), float(np.median(rule1_speedups)), max(rule1_speedups)
r2_min, r2_med, r2_max = min(rule2_speedups), float(np.median(rule2_speedups)), max(rule2_speedups)

summary_json = {
    "images": results_table,
    "rule1_stats": {
        "rule_description": "Max-normalized rescale: round(Y_relu * 127 / max(Y_relu))",
        "min_speedup": r1_min,
        "median_speedup": r1_med,
        "max_speedup": r1_max
    },
    "rule2_stats": {
        "rule_description": "Pre-chosen fixed right-shift by 3: clip(Y_relu >> 3, 0, 127)",
        "min_speedup": r2_min,
        "median_speedup": r2_med,
        "max_speedup": r2_max
    }
}

json_path = os.path.join(OUT_DIR, "part_c_dual_rule_sparsity.json")
with open(json_path, "w", encoding="utf-8") as f:
    json.dump(summary_json, f, indent=2)

print("=" * 110)
print(f" {'Image':<22} | {'Proc Dim':<9} | {'Sp Before (%)':<14} | {'Sp Rule 1 (%)':<14} | {'Speedup R1':<11} | {'Sp Rule 2 (%)':<14} | {'Speedup R2':<11}")
print("=" * 110)
for r in results_table:
    print(f" {r['image']:<22} | {r['proc_dim']:<9} | {r['sparsity_before_rescale_pct']:13.2f}% | {r['sparsity_rule1_pct']:13.2f}% | {r['speedup_rule1']:10.4f}x | {r['sparsity_rule2_pct']:13.2f}% | {r['speedup_rule2']:10.4f}x")
print("=" * 110)
print(f" Rule 1 (Max-Normalized): Min = {r1_min:.4f}x, Median = {r1_med:.4f}x, Max = {r1_max:.4f}x")
print(f" Rule 2 (Fixed >> 3)    : Min = {r2_min:.4f}x, Median = {r2_med:.4f}x, Max = {r2_max:.4f}x")
print(f"Saved complete results to: {json_path}")

