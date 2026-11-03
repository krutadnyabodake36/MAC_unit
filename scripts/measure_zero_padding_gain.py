#!/usr/bin/env python3
"""
scripts/measure_zero_padding_gain.py

Measures interior vs border zero-product counts for Sobel-X kernel across all 14 benchmark images.
Evaluates the empirical hypothesis: does zero-padding at image borders drive the higher sparsity?
"""

import os
import json
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# 14 Benchmark images (4 root images + 10 images_extra)
IMAGE_PATHS = [
    os.path.join(PROJECT_ROOT, "image1.jpg"),
    os.path.join(PROJECT_ROOT, "image2.jpg"),
    os.path.join(PROJECT_ROOT, "image3.jpg"),
    os.path.join(PROJECT_ROOT, "image4.jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (1).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (2).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (3).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (4).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (5).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (6).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (7).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images (8).jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images.jpg"),
    os.path.join(PROJECT_ROOT, "images_extra", "images1.jpg"),
]

SOBEL_X = np.array([-1, 0, 1, -2, 0, 2, -1, 0, 1], dtype=np.int32)

def resize_aspect_preserved(im, max_edge=128):
    w, h = im.size
    if max(w, h) > max_edge:
        if w >= h:
            new_w = max_edge
            new_h = int(round(h * max_edge / w))
        else:
            new_h = max_edge
            new_w = int(round(w * max_edge / h))
        im = im.resize((new_w, new_h), Image.Resampling.BILINEAR)
    return im

def analyze_image(path):
    im = Image.open(path).convert('L')
    im = resize_aspect_preserved(im, max_edge=128)
    arr = np.array(im, dtype=np.int32)
    signed_arr = arr - 128
    H, W = signed_arr.shape
    
    # 0-padding by 1 pixel on all sides
    padded = np.pad(signed_arr, ((1, 1), (1, 1)), mode='constant', constant_values=0)
    
    total_patches = H * W
    interior_patches = (H - 2) * (W - 2) if (H > 2 and W > 2) else 0
    border_patches = total_patches - interior_patches
    
    interior_zero_products = 0
    border_zero_products = 0
    
    for r in range(H):
        for c in range(W):
            patch = padded[r:r+3, c:c+3].flatten()
            zero_prods = int(np.sum((patch * SOBEL_X) == 0))
            
            is_border = (r == 0 or r == H - 1 or c == 0 or c == W - 1)
            if is_border:
                border_zero_products += zero_prods
            else:
                interior_zero_products += zero_prods
                
    int_ops = interior_patches * 9
    bor_ops = border_patches * 9
    tot_ops = total_patches * 9
    
    int_sparsity = (interior_zero_products / int_ops * 100.0) if int_ops > 0 else 0.0
    bor_sparsity = (border_zero_products / bor_ops * 100.0) if bor_ops > 0 else 0.0
    tot_sparsity = ((interior_zero_products + border_zero_products) / tot_ops * 100.0)
    
    rel_path = os.path.relpath(path, PROJECT_ROOT).replace("\\", "/")
    return {
        "filepath": rel_path,
        "filename": os.path.basename(path),
        "dimensions": f"{W}x{H}",
        "total_patches": total_patches,
        "interior_patches": interior_patches,
        "border_patches": border_patches,
        "interior_zero_products": interior_zero_products,
        "border_zero_products": border_zero_products,
        "total_zero_products": interior_zero_products + border_zero_products,
        "interior_sparsity_pct": round(int_sparsity, 4),
        "border_sparsity_pct": round(bor_sparsity, 4),
        "total_sparsity_pct": round(tot_sparsity, 4),
        "sparsity_gain_from_padding_pct": round(tot_sparsity - int_sparsity, 4)
    }

def main():
    results = []
    print(f"{'Image File':<25} | {'Dims':<8} | {'Total':<7} | {'Border':<6} | {'Int Sp %':<10} | {'Bor Sp %':<10} | {'Tot Sp %':<10} | {'Gain %':<8}")
    print("-" * 105)
    for p in IMAGE_PATHS:
        res = analyze_image(p)
        results.append(res)
        print(f"{res['filepath']:<25} | {res['dimensions']:<8} | {res['total_patches']:<7} | {res['border_patches']:<6} | {res['interior_sparsity_pct']:<10.2f} | {res['border_sparsity_pct']:<10.2f} | {res['total_sparsity_pct']:<10.2f} | {res['sparsity_gain_from_padding_pct']:<+8.2f}")
        
    out_json = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "zero_padding_gain_analysis.json")
    with open(out_json, "w") as f:
        json.dump(results, f, indent=2)
    print("\nSaved detailed results to", out_json)

if __name__ == "__main__":
    main()
