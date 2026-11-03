import os
import json
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
IMAGE_SPECS = [
    ("image1.jpg", os.path.join(PROJECT_ROOT, "image1.jpg")),
    ("image2.jpg", os.path.join(PROJECT_ROOT, "image2.jpg")),
    ("image3.jpg", os.path.join(PROJECT_ROOT, "image3.jpg")),
    ("image4.jpg", os.path.join(PROJECT_ROOT, "image4.jpg")),
    ("images (1).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (1).jpg")),
    ("images (2).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (2).jpg")),
    ("images (3).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (3).jpg")),
    ("images (4).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (4).jpg")),
    ("images (5).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (5).jpg")),
    ("images (6).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (6).jpg")),
    ("images (7).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (7).jpg")),
    ("images (8).jpg", os.path.join(PROJECT_ROOT, "images_extra", "images (8).jpg")),
    ("images.jpg", os.path.join(PROJECT_ROOT, "images_extra", "images.jpg")),
    ("images1.jpg", os.path.join(PROJECT_ROOT, "images_extra", "images1.jpg")),
]

SOBEL_X = np.array([-1, 0, 1, -2, 0, 2, -1, 0, 1], dtype=np.int32)

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

out_data = []
print("=" * 135)
header = f"{'Image':<16} | {'Dims':<8} | {'Zero Pix':<8} | {'Int Pat':<7} | {'Int ZProds':<10} | {'Int Sp %':<8} | {'Bor Pat':<7} | {'Bor ZProds':<10} | {'Bor Sp %':<8} | {'Tot ZProds':<10} | {'Tot Sp %':<8}"
print(header)
print("-" * 135)

for fn, fp in IMAGE_SPECS:
    im = Image.open(fp).convert("L")
    u8, h, w = resize_aspect_preserved(im, 128)
    s8 = (u8.astype(np.int16) - 128).astype(np.int8)
    
    zero_pix_cnt = int(np.sum(s8 == 0))
    padded = np.pad(s8.astype(np.int32), ((1, 1), (1, 1)), mode="constant", constant_values=0)
    
    int_pat = 0
    int_zp = 0
    bor_pat = 0
    bor_zp = 0
    
    for r in range(h):
        for c in range(w):
            patch = padded[r:r+3, c:c+3].flatten()
            z = int(np.sum((patch * SOBEL_X) == 0))
            is_border = (r == 0 or r == h - 1 or c == 0 or c == w - 1)
            if is_border:
                bor_pat += 1
                bor_zp += z
            else:
                int_pat += 1
                int_zp += z
                
    tot_pat = int_pat + bor_pat
    tot_zp = int_zp + bor_zp
    int_sp = int_zp / (int_pat * 9) * 100.0
    bor_sp = bor_zp / (bor_pat * 9) * 100.0
    tot_sp = tot_zp / (tot_pat * 9) * 100.0
    
    row = {
        "filename": fn,
        "dims": f"{w}x{h}",
        "zero_pixels": zero_pix_cnt,
        "int_patches": int_pat,
        "int_zero_prods": int_zp,
        "int_sp_pct": round(int_sp, 4),
        "bor_patches": bor_pat,
        "bor_zero_prods": bor_zp,
        "bor_sp_pct": round(bor_sp, 4),
        "tot_patches": tot_pat,
        "tot_zero_prods": tot_zp,
        "tot_sp_pct": round(tot_sp, 4),
    }
    out_data.append(row)
    print(f"{fn:<16} | {w}x{h:<5} | {zero_pix_cnt:<8} | {int_pat:<7} | {int_zp:<10} | {int_sp:<8.4f} | {bor_pat:<7} | {bor_zp:<10} | {bor_sp:<8.4f} | {tot_zp:<10} | {tot_sp:<8.4f}")

out_path = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "zero_padding_gain_recomputed.json")
with open(out_path, "w", encoding="utf-8") as jf:
    json.dump(out_data, jf, indent=2)

print("=" * 135)
print(f"Saved results to {out_path}")

