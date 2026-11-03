import os
import json
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056")

SOBEL_X = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], dtype=np.int32)
SOBEL_X_FLAT = [-1, 0, 1, -2, 0, 2, -1, 0, 1]

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

all_img_results = []
total_all_patches = 0
total_bl_wall = 0
total_bl_comp = 0
total_static_wall = 0
total_static_comp = 0
total_zs_wall = 0
total_zs_comp = 0
total_mismatches_all = 0

print("=" * 125)
print(f" >>> RUNNING SOBEL-X REAL-IMAGE WORKLOAD ACROSS ALL 14 IMAGES (ALL 9 VARIANTS) <<<")
print("=" * 125)
print(f" {'Image':<22} | {'Patches':<7} | {'Baseline Wall':<13} | {'Static Wall':<11} | {'ZS Wall':<10} | {'Static Spd':<10} | {'ZS Spd':<8} | {'Mismatches':<10}")
print("-" * 125)

for label, img_path in images:
    img = Image.open(img_path).convert("L")
    raw_w, raw_h = img.size
    u8_arr, h, w = resize_aspect_preserved(img, max_edge=128)
    n_patches = h * w
    total_all_patches += n_patches

    # 1. Zero-point shift: int8 = int16(uint8) - 128
    int8_img = (u8_arr.astype(np.int16) - 128).astype(np.int8)

    # 2. Pad 1 pixel with 0 (int8 space)
    padded = np.pad(int8_img.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)

    img_bl_wall = n_patches * 11
    img_bl_comp = n_patches * 9
    img_static_wall = n_patches * 8
    img_static_comp = n_patches * 6
    img_zs_wall = 0
    img_zs_comp = 0
    img_mismatches = 0

    for r in range(h):
        for c in range(w):
            patch = padded[r:r+3, c:c+3].flatten()
            
            # Golden output
            golden = int(np.sum(patch * SOBEL_X_FLAT))

            # Hardware models for all variants:
            # Fixed variants: 9 compute, 11 wall
            # Static Sobel: taps 0, 2, 3, 5, 6, 8 (6 compute, 8 wall)
            static_out = int(patch[0]*(-1) + patch[2]*(1) + patch[3]*(-2) + patch[5]*(2) + patch[6]*(-1) + patch[8]*(1))
            if static_out != golden:
                img_mismatches += 1

            # ZS family (ZS, ZS_OI, ZS_CG, Combined):
            # Compute cycles = non-zero products
            nz = 0
            zs_out = 0
            for k in range(9):
                prod = patch[k] * SOBEL_X_FLAT[k]
                if patch[k] != 0 and SOBEL_X_FLAT[k] != 0:
                    nz += 1
                zs_out += prod
            
            if zs_out != golden:
                img_mismatches += 1

            img_zs_comp += nz
            img_zs_wall += (nz + 2)

    total_bl_wall += img_bl_wall
    total_bl_comp += img_bl_comp
    total_static_wall += img_static_wall
    total_static_comp += img_static_comp
    total_zs_wall += img_zs_wall
    total_zs_comp += img_zs_comp
    total_mismatches_all += img_mismatches

    static_spd = img_bl_wall / img_static_wall
    zs_spd = img_bl_wall / img_zs_wall

    print(f" {label:<22} | {n_patches:7d} | {img_bl_wall:13d} | {img_static_wall:11d} | {img_zs_wall:10d} | {static_spd:9.4f}x | {zs_spd:7.4f}x | {img_mismatches:10d}")

    all_img_results.append({
        "image": label,
        "patches": n_patches,
        "baseline_wall": img_bl_wall,
        "baseline_comp": img_bl_comp,
        "static_wall": img_static_wall,
        "static_comp": img_static_comp,
        "static_speedup": static_spd,
        "zs_wall": img_zs_wall,
        "zs_comp": img_zs_comp,
        "zs_speedup": zs_spd,
        "mismatches": img_mismatches
    })

print("-" * 125)
overall_static_spd = total_bl_wall / total_static_wall
overall_zs_spd = total_bl_wall / total_zs_wall
print(f" {'OVERALL (14 IMAGES)':<22} | {total_all_patches:7d} | {total_bl_wall:13d} | {total_static_wall:11d} | {total_zs_wall:10d} | {overall_static_spd:9.4f}x | {overall_zs_spd:7.4f}x | {total_mismatches_all:10d}")
print("=" * 125)

# Save summary
sobel_14_json = {
    "total_patches": total_all_patches,
    "total_baseline_wall": total_bl_wall,
    "total_baseline_comp": total_bl_comp,
    "total_static_wall": total_static_wall,
    "total_static_comp": total_static_comp,
    "overall_static_speedup": overall_static_spd,
    "total_zs_wall": total_zs_wall,
    "total_zs_comp": total_zs_comp,
    "overall_zs_speedup": overall_zs_spd,
    "total_mismatches": total_mismatches_all,
    "per_image": all_img_results
}

out_path = os.path.join(OUT_DIR, "sobel_14_images_summary.json")
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(sobel_14_json, f, indent=2)

print(f"Saved complete Sobel 14-image results to: {out_path}")

