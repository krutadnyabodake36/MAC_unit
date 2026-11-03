#!/usr/bin/env python3
# ==============================================================================
# File: generate_test_data.py
# Description: Generates 3 Real-World CNN Workload Test Datasets for MAC & Conv2D:
#   1. Workload 1: Early-Layer CNN / Spatial Filtering (Dense, ~35% Sparsity)
#   2. Workload 2: Mid-Layer CNN / Residual Block (Typical Post-ReLU, ~68% Sparsity)
#   3. Workload 3: Deep / Pruned Layer CNN (Ultra-High Sparsity, ~88% Sparsity)
# ==============================================================================

import json
import random
import os

random.seed(42)  # Deterministic generation for 100% reproducibility

def clamp8(v):
    return max(-128, min(127, int(v)))

def generate_workload_1_dense(num_patches=100):
    """
    Workload 1: Early Layer CNN / Edge Detection / Spatial Filtering
    Sparsity: ~35% zero products.
    Characteristics:
      - Kernel weights: Standard spatial filters (Sobel, Gaussian, Box, Laplacian)
      - Activations: Raw image normalized pixel gradients (low zero percentage ~15%)
    """
    kernels = [
        # Sobel Horizontal
        [-1, 0, 1, -2, 0, 2, -1, 0, 1],
        # Sobel Vertical
        [-1, -2, -1, 0, 0, 0, 1, 2, 1],
        # Gaussian Blur 3x3 approximation
        [1, 2, 1, 2, 4, 2, 1, 2, 1],
        # Laplacian Edge Detector
        [0, 1, 0, 1, -4, 1, 0, 1, 0],
        # Sharpen Filter
        [0, -1, 0, -1, 5, -1, 0, -1, 0],
        # Prewitt Horizontal
        [-1, 0, 1, -1, 0, 1, -1, 0, 1]
    ]

    patches = []
    total_zeros = 0
    total_ops = num_patches * 9

    for p in range(num_patches):
        base_kernel = kernels[p % len(kernels)]
        # Add slight natural variation to kernel weights
        weights = [clamp8(w + random.randint(-1, 1) if w != 0 else (0 if random.random() > 0.15 else random.randint(-2, 2))) for w in base_kernel]
        
        # Dense pixel patch: mostly non-zero pixels with only ~15% zeros (e.g. edge of object/background)
        pixels = []
        for _ in range(9):
            if random.random() < 0.15:
                pixels.append(0)
            else:
                pixels.append(clamp8(random.gauss(30, 45)))

        # Compute exact mathematical reference
        expected_accum = sum(w * px for w, px in zip(weights, pixels))
        zero_skips = sum(1 for w, px in zip(weights, pixels) if w == 0 or px == 0)
        total_zeros += zero_skips

        patches.append({
            'patch_id': p,
            'weights': weights,
            'pixels': pixels,
            'expected_accum': expected_accum,
            'zero_skips': zero_skips,
            'active_terms': 9 - zero_skips
        })

    sparsity = total_zeros / total_ops
    return {
        'workload_name': 'Workload 1: Early-Layer / Dense CNN Filter',
        'description': 'Represents initial convolutional layer & spatial gradient filters with mostly dense pixels (~15% zero pixels, structured kernel zeros).',
        'num_patches': num_patches,
        'total_operations': total_ops,
        'zero_products': total_zeros,
        'sparsity_percentage': round(sparsity * 100, 2),
        'patches': patches
    }


def generate_workload_2_typical(num_patches=100):
    """
    Workload 2: Mid-Layer CNN / Residual Block (Post-ReLU)
    Sparsity: ~68% zero products.
    Characteristics:
      - Kernel weights: Trained int8 weights with ~35% small weights clipped/pruned
      - Activations: Post-ReLU activation maps (negative values zeroed out, ~58% zeros)
    """
    patches = []
    total_zeros = 0
    total_ops = num_patches * 9

    for p in range(num_patches):
        # Weights: Gaussian distribution centered at 0, with small values pruned to 0
        weights = []
        for _ in range(9):
            val = random.gauss(0, 18)
            if abs(val) < 8:  # ~35% zero weights
                weights.append(0)
            else:
                weights.append(clamp8(val))

        # Activations: Post-ReLU (strictly >= 0, ~58% exact zeros)
        pixels = []
        for _ in range(9):
            val = random.gauss(-5, 40)
            if val <= 0:  # ReLU operation truncates all <= 0 to 0
                pixels.append(0)
            else:
                pixels.append(clamp8(val))

        expected_accum = sum(w * px for w, px in zip(weights, pixels))
        zero_skips = sum(1 for w, px in zip(weights, pixels) if w == 0 or px == 0)
        total_zeros += zero_skips

        patches.append({
            'patch_id': p,
            'weights': weights,
            'pixels': pixels,
            'expected_accum': expected_accum,
            'zero_skips': zero_skips,
            'active_terms': 9 - zero_skips
        })

    sparsity = total_zeros / total_ops
    return {
        'workload_name': 'Workload 2: Mid-Layer / Standard Post-ReLU CNN',
        'description': 'Represents standard hidden residual layers (ResNet/MobileNet) where ReLU truncates negative activations, creating ~58% zero activations convolved with ~35% zero weights.',
        'num_patches': num_patches,
        'total_operations': total_ops,
        'zero_products': total_zeros,
        'sparsity_percentage': round(sparsity * 100, 2),
        'patches': patches
    }


def generate_workload_3_sparse(num_patches=100):
    """
    Workload 3: Deep / Pruned Layer CNN
    Sparsity: ~88% zero products.
    Characteristics:
      - Kernel weights: Pruned neural network model (~65% zero weights)
      - Activations: High-level sparse feature maps (~75% zeros)
    """
    patches = []
    total_zeros = 0
    total_ops = num_patches * 9

    for p in range(num_patches):
        # Pruned weights: ~65% exact zeros
        weights = []
        for _ in range(9):
            if random.random() < 0.65:
                weights.append(0)
            else:
                weights.append(clamp8(random.choice([-1, 1]) * random.randint(12, 90)))

        # Deep layer activations: highly selective feature detectors with ~78% zeros
        pixels = []
        for _ in range(9):
            if random.random() < 0.78:
                pixels.append(0)
            else:
                pixels.append(clamp8(random.randint(15, 120)))

        expected_accum = sum(w * px for w, px in zip(weights, pixels))
        zero_skips = sum(1 for w, px in zip(weights, pixels) if w == 0 or px == 0)
        total_zeros += zero_skips

        patches.append({
            'patch_id': p,
            'weights': weights,
            'pixels': pixels,
            'expected_accum': expected_accum,
            'zero_skips': zero_skips,
            'active_terms': 9 - zero_skips
        })

    sparsity = total_zeros / total_ops
    return {
        'workload_name': 'Workload 3: Deep / Highly-Pruned Sparse CNN',
        'description': 'Represents deep or magnitude-pruned neural networks with 65% weight sparsity and 78% activation sparsity, testing the peak efficiency boundary of zero-skipping.',
        'num_patches': num_patches,
        'total_operations': total_ops,
        'zero_products': total_zeros,
        'sparsity_percentage': round(sparsity * 100, 2),
        'patches': patches
    }


def main():
    os.makedirs('test_data', exist_ok=True)

    w1 = generate_workload_1_dense(100)
    w2 = generate_workload_2_typical(100)
    w3 = generate_workload_3_sparse(100)

    for data, filename in [
        (w1, 'test_data/workload1_dense_early_layer.json'),
        (w2, 'test_data/workload2_typical_mid_layer.json'),
        (w3, 'test_data/workload3_sparse_deep_layer.json')
    ]:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
        print(f"Generated {filename} ({data['sparsity_percentage']}% sparsity across {data['total_operations']} ops)")

    print("\nAll 3 workload datasets generated successfully in test_data/!")

if __name__ == '__main__':
    main()
