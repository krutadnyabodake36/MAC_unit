#!/usr/bin/env python3
"""
Generate vector files for all 4 shifted images for SystemVerilog simulation.
Vector format per line:
9 weights (Sobel), 9 pixels (int8), 1 golden_output (int32)
All space-separated decimal integers.
"""

import os
import sys
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VECTORS_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "vectors")

IMAGES = [
    ("image1", os.path.join(PROJECT_ROOT, "image1.jpg")),
    ("image2", os.path.join(PROJECT_ROOT, "results", "run_20261007_181454", "image2.jpg")),
    ("image3", os.path.join(PROJECT_ROOT, "image3.jpg")),
    ("image4", os.path.join(PROJECT_ROOT, "image4.jpg")),
]

MAX_EDGE = 128
SOBEL_H = np.array([
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
], dtype=np.int32)

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

def main():
    os.makedirs(VECTORS_DIR, exist_ok=True)
    w_flat = SOBEL_H.flatten().tolist()

    metadata = {}
    for name, path in IMAGES:
        if not os.path.exists(path):
            print(f"[ERROR] Missing image file: {path}")
            sys.exit(1)

        raw_img = Image.open(path).convert('L')
        uint8_arr, h, w = resize_aspect_preserved(raw_img, MAX_EDGE)
        
        # Zero-point shift: int8 = int16(uint8) - 128
        int8_arr = (uint8_arr.astype(np.int16) - 128).astype(np.int8)

        # 0-padding in int8 space
        padded = np.pad(int8_arr, ((1, 1), (1, 1)), mode='constant', constant_values=0)

        vec_path = os.path.join(VECTORS_DIR, f"{name}.vec")
        patches = 0
        total_zero_prods = 0
        
        with open(vec_path, "w", encoding="ascii") as vf:
            for r in range(h):
                for c in range(w):
                    p_window = padded[r:r+3, c:c+3].astype(np.int32)
                    golden = int(np.sum(p_window * SOBEL_H))
                    p_flat = p_window.flatten().tolist()

                    for wk, pk in zip(w_flat, p_flat):
                        if wk == 0 or pk == 0:
                            total_zero_prods += 1

                    line = " ".join(str(x) for x in w_flat + p_flat + [golden]) + "\n"
                    vf.write(line)
                    patches += 1

        metadata[name] = {
            "h": h,
            "w": w,
            "patches": patches,
            "vec_file": vec_path,
            "file_size": os.path.getsize(vec_path),
            "total_zero_products": total_zero_prods,
            "sparsity_pct": (total_zero_prods / (patches * 9)) * 100.0
        }
        print(f"Generated {vec_path}: {patches} patches ({h}x{w}), Sparsity = {metadata[name]['sparsity_pct']:.3f}%")

    print("\nAll 4 image vector files successfully generated.")

if __name__ == "__main__":
    main()

