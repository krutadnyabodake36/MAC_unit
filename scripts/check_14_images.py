import os
import glob
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

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

print(f"Total images found: {len(images)}")
total_patches = 0
for name, p in images:
    img = Image.open(p).convert("L")
    arr, h, w = resize_aspect_preserved(img, 128)
    patches = h * w
    total_patches += patches
    print(f"  {name:25s} | raw: {img.size[0]:4d}x{img.size[1]:4d} | proc: {w:3d}x{h:3d} | patches: {patches:5d}")

print(f"\nTotal patches across all 14 images: {total_patches}")

