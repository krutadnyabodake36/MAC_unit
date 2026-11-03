#!/usr/bin/env python3
"""
scripts/generate_part_c_vectors.py

Generates vector datasets for Part C across all 14 benchmark images for BOTH rescaling rules:
1. Primary Rule (Rule 2): Fixed right-shift >> 3 with saturation to [0, 127].
2. Sensitivity Rule 1: Max-normalized to 127: round(relu_map * 127.0 / max_val).

Image pipeline:
- 14 images: 4 root images (image1..4.jpg) + 10 images_extra (images (1).jpg..images (8).jpg, images.jpg, images1.jpg).
- Aspect-preserved resize to max_edge=128 (BILINEAR).
- Zero-point shift: uint8 - 128 -> int8.
- 1st stage convolution: Sobel-X with constant 0-padding (correlation order, no flips).
- ReLU: clamp < 0 to 0.
- Measure ReLU-only sparsity before rescale (count == 0 / total_pixels).
- Apply Primary Rule -> measure Rule 2 sparsity.
- Apply Sensitivity Rule 1 -> measure Rule 1 sparsity.
- Verify mathematically that Sparsity(Rule 1) >= Sparsity(ReLU) and Sparsity(Rule 2) >= Sparsity(ReLU).
- For each rule, generate 3x3 patches with constant 0-padding.
- Convolve with:
    (a) Dense Gaussian kernel: [1, 2, 1, 2, 4, 2, 1, 2, 1]
    (b) Random Dense kernel:   [-3, 2, 1, 4, -2, 5, 1, -4, 3]
- Save vector files to:
    results/final_run_20261030_1056/vectors/relu_r1/
    results/final_run_20261030_1056/vectors/relu_r2/
- Output summary metadata to results/final_run_20261030_1056/part_c_sparsity_audit.json.
"""

import os
import json
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VEC_R1_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "vectors", "relu_r1")
VEC_R2_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "vectors", "relu_r2")
os.makedirs(VEC_R1_DIR, exist_ok=True)
os.makedirs(VEC_R2_DIR, exist_ok=True)

# 14 Benchmark images with their exact filenames and paths
IMAGE_SPECS = [
    ("image1", "image1.jpg", os.path.join(PROJECT_ROOT, "image1.jpg")),
    ("image2", "image2.jpg", os.path.join(PROJECT_ROOT, "image2.jpg")),
    ("image3", "image3.jpg", os.path.join(PROJECT_ROOT, "image3.jpg")),
    ("image4", "image4.jpg", os.path.join(PROJECT_ROOT, "image4.jpg")),
    ("extra_img1", "images (1).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (1).jpg")),
    ("extra_img2", "images (2).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (2).jpg")),
    ("extra_img3", "images (3).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (3).jpg")),
    ("extra_img4", "images (4).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (4).jpg")),
    ("extra_img5", "images (5).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (5).jpg")),
    ("extra_img6", "images (6).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (6).jpg")),
    ("extra_img7", "images (7).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (7).jpg")),
    ("extra_img8", "images (8).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (8).jpg")),
    ("extra_img",  "images.jpg",      os.path.join(PROJECT_ROOT, "images_extra", "images.jpg")),
    ("extra_img1b", "images1.jpg",    os.path.join(PROJECT_ROOT, "images_extra", "images1.jpg")),
]

SOBEL_X = np.array([
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
], dtype=np.int32)

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

def export_vectors(patches, kweights, filepath):
    with open(filepath, "w", encoding="utf-8") as vf:
        for p in patches:
            golden = sum(w * px for w, px in zip(kweights, p))
            w_str = " ".join(str(w) for w in kweights)
            p_str = " ".join(str(px) for px in p)
            vf.write(f"{w_str} {p_str} {golden}\n")

def main():
    audit_results = []
    total_all_patches = 0
    
    print("=" * 115)
    print(f"{'Key':<12} | {'Filename':<17} | {'Dim':<8} | {'Patches':<7} | {'ReLU Sp %':<10} | {'Rule1 Sp %':<11} | {'Rule2 Sp %':<11} | {'Max ReLU':<8}")
    print("=" * 115)

    for key, filename, filepath in IMAGE_SPECS:
        img = Image.open(filepath).convert("L")
        raw_w, raw_h = img.size
        u8_arr, h, w = resize_aspect_preserved(img, max_edge=128)
        
        # 1. Zero-point shift
        int8_img = (u8_arr.astype(np.int16) - 128).astype(np.int8)
        
        # 2. Stage 1 Sobel-X convolution (constant 0-padding, correlation order)
        padded_s1 = np.pad(int8_img.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)
        sobel_out = np.zeros((h, w), dtype=np.int32)
        for r in range(h):
            for c in range(w):
                patch = padded_s1[r:r+3, c:c+3]
                sobel_out[r, c] = np.sum(patch * SOBEL_X)
                
        # 3. ReLU: clamp negatives to 0
        relu_out = np.maximum(0, sobel_out)
        
        total_pixels = h * w
        total_all_patches += total_pixels
        relu_zeros = int(np.sum(relu_out == 0))
        relu_sparsity = (relu_zeros / total_pixels) * 100.0
        max_relu = int(np.max(relu_out))
        
        # 4. Sensitivity Rule 1: Max-normalized to 127
        if max_relu > 0:
            scaled_r1 = np.round((relu_out * 127.0) / max_relu).astype(np.int8)
        else:
            scaled_r1 = np.zeros((h, w), dtype=np.int8)
        r1_zeros = int(np.sum(scaled_r1 == 0))
        r1_sparsity = (r1_zeros / total_pixels) * 100.0
        
        # 5. Primary Rule (Rule 2): Fixed right-shift >> 3 with saturation to [0, 127]
        scaled_r2 = np.clip(relu_out >> 3, 0, 127).astype(np.int8)
        r2_zeros = int(np.sum(scaled_r2 == 0))
        r2_sparsity = (r2_zeros / total_pixels) * 100.0
        
        # Sanity assertions
        assert r1_zeros >= relu_zeros, f"Rule 1 zeros ({r1_zeros}) < ReLU zeros ({relu_zeros})"
        assert r2_zeros >= relu_zeros, f"Rule 2 zeros ({r2_zeros}) < ReLU zeros ({relu_zeros})"
        
        print(f"{key:<12} | {filename:<17} | {w}x{h:<5} | {total_pixels:<7} | {relu_sparsity:<10.2f} | {r1_sparsity:<11.2f} | {r2_sparsity:<11.2f} | {max_relu:<8}")
        
        # 6. Extract 3x3 patches with 0-padding for both rules
        # Rule 1 patches
        padded_r1 = np.pad(scaled_r1.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)
        patches_r1 = [padded_r1[r:r+3, c:c+3].flatten().tolist() for r in range(h) for c in range(w)]
        
        # Rule 2 patches
        padded_r2 = np.pad(scaled_r2.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)
        patches_r2 = [padded_r2[r:r+3, c:c+3].flatten().tolist() for r in range(h) for c in range(w)]
        
        # Export vector files
        for kname, kweights in KERNELS.items():
            export_vectors(patches_r1, kweights, os.path.join(VEC_R1_DIR, f"{key}_{kname}.vec"))
            export_vectors(patches_r2, kweights, os.path.join(VEC_R2_DIR, f"{key}_{kname}.vec"))
            
        audit_results.append({
            "key": key,
            "filename": filename,
            "filepath": os.path.relpath(filepath, PROJECT_ROOT).replace("\\", "/"),
            "raw_dimensions": f"{raw_w}x{raw_h}",
            "proc_dimensions": f"{w}x{h}",
            "patch_count": total_pixels,
            "max_relu_val": max_relu,
            "relu_zeros": relu_zeros,
            "relu_sparsity_pct": round(relu_sparsity, 4),
            "rule1_zeros": r1_zeros,
            "rule1_sparsity_pct": round(r1_sparsity, 4),
            "rule2_zeros": r2_zeros,
            "rule2_sparsity_pct": round(r2_sparsity, 4)
        })
        
    print("-" * 115)
    print(f"Total Patches across all 14 images: {total_all_patches} (Expected: 164,096) -> {'MATCH' if total_all_patches == 164096 else 'MISMATCH'}")
    
    out_json = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "part_c_sparsity_audit.json")
    with open(out_json, "w", encoding="utf-8") as jf:
        json.dump(audit_results, jf, indent=2)
    print(f"Saved audit JSON to {out_json}")

if __name__ == "__main__":
    main()

