import os
from PIL import Image
import numpy as np

images = [
    ('image1.jpg', 'image1.jpg'),
    ('image2.jpg', 'image2.jpg'),
    ('image3.jpg', 'image3.jpg'),
    ('image4.jpg', 'image4.jpg'),
]
if os.path.exists('images_extra'):
    for f in sorted(os.listdir('images_extra')):
        if f.endswith('.jpg'):
            images.append((f'images_extra/{f}', os.path.join('images_extra', f)))

print(f"Found {len(images)} total images. Analyzing properties...\n")

sobel_x = np.array([1, 0, -1, 2, 0, -2, 1, 0, -1], dtype=np.int32)

results = []
for label, path in images:
    try:
        img = Image.open(path)
        w, h = img.size
        
        # Profiler resize logic
        if w >= h:
            new_w = 128
            new_h = int(round(h * 128.0 / w))
        else:
            new_h = 128
            new_w = int(round(w * 128.0 / h))
            
        img_gray = img.convert('L').resize((new_w, new_h), Image.Resampling.BILINEAR)
        arr = np.array(img_gray, dtype=np.int8)
        padded = np.pad(arr, 1, mode='constant', constant_values=0)
        
        # Calculate statistics
        mean_val = float(np.mean(arr))
        std_val = float(np.std(arr))
        
        # Count zeros in raw pixels
        raw_zeros = int(np.sum(arr == 0))
        raw_zero_pct = raw_zeros / arr.size * 100.0
        
        # Count patch-level zero products with Sobel-X
        patches = new_w * new_h
        total_macs = patches * 9
        zero_products = 0
        
        for r in range(new_h):
            for c in range(new_w):
                p = padded[r:r+3, c:c+3].flatten()
                # A product is 0 if weight is 0 or pixel is 0
                zero_products += int(np.sum((sobel_x == 0) | (p == 0)))
                
        prod_zero_pct = zero_products / total_macs * 100.0
        
        results.append({
            'label': label,
            'orig_size': f"{w}x{h}",
            'grid': f"{new_w}x{new_h}",
            'patches': patches,
            'mean': mean_val,
            'std': std_val,
            'pixel_zero_pct': raw_zero_pct,
            'mac_zero_pct': prod_zero_pct
        })
    except Exception as e:
        print(f"Error processing {label}: {e}")

print(f"{'Image':<25} {'Orig Res':<12} {'Grid':<10} {'Patches':<8} {'Mean':<6} {'Std':<6} {'Pix 0%':<8} {'MAC 0%':<8}")
print("-" * 88)
for r in results:
    print(f"{r['label']:<25} {r['orig_size']:<12} {r['grid']:<10} {r['patches']:<8} {r['mean']:<6.1f} {r['std']:<6.1f} {r['pixel_zero_pct']:<8.2f} {r['mac_zero_pct']:<8.2f}")

