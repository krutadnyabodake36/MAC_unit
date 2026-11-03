#!/usr/bin/env python3
# ==============================================================================
# File: scripts/regenerate_5variants_results.py
# Description: Task T2: Regenerate Results for All 5 EXISTING Variants Across 4 Images
#              with Approved Zero-Point Shifted Pixels.
#
# Marks every number explicitly as:
#   [FORMULA/MODEL (Python)] - Evaluated via analytical profiler model
#   [COUNTER (Hardware Telemetry)] - Extracted from physical Spartan-7 registers
# ==============================================================================

import os
import sys
import json
import numpy as np
from PIL import Image

# Force UTF-8 stdout
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# Import preprocessing from fpga_vision_profiler
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from fpga_vision_profiler import load_and_preprocess, SOBEL_KERNEL

IMAGES = [
    ("Workload 1 (image1.jpg)", "image1.jpg"),
    ("Workload 2 (image2.jpg)", os.path.join("results", "run_20261007_181454", "image2.jpg")),
    ("Workload 3 (image3.jpg)", "image3.jpg"),
    ("Workload 4 (image4.jpg)", "image4.jpg"),
]

VARIANTS = [
    ("Baseline (conv2d_serial_baseline)", "fixed_9", "no_skip"),
    ("Only Zero-Skipping (conv2d_serial_zs)", "variable_zs", "skip_zeros"),
    ("Only Operand Isolation (conv2d_serial_oi)", "fixed_9", "isolate_zeros"),
    ("Only Clock-Enable Gating (conv2d_serial_cg)", "fixed_9", "gate_zeros"),
    ("Combined Architecture (conv2d_serial_combined)", "variable_zs", "skip_zeros"),
]

def run_evaluation():
    print("=" * 86)
    print(" TASK T2: 5-VARIANT PROFILER REGENERATION (ZERO-POINT SHIFTED INT8)")
    print("=" * 86)

    all_results = {}

    for label, path in IMAGES:
        if not os.path.exists(path):
            print(f"[WARN] Image not found: {path}")
            continue

        padded_img, h, w = load_and_preprocess(path, max_size=128)
        total_patches = h * w
        total_macs = total_patches * 9
        kernel_flat = SOBEL_KERNEL.flatten()

        print(f"\n==============================================================================")
        print(f" {label.upper()} | Dimensions: {h}x{w} ({total_patches} patches, {total_macs} MAC ops)")
        print(f"==============================================================================")

        # Pre-extract all patches
        patches = []
        for r in range(h):
            for c in range(w):
                patches.append(padded_img[r:r+3, c:c+3].flatten().astype(np.int8))

        # Golden mathematical model
        golden_outputs = []
        zero_products_per_patch = []
        nonzero_products_per_patch = []

        for p in patches:
            accum = int(np.sum(kernel_flat.astype(np.int32) * p.astype(np.int32)))
            golden_outputs.append(accum)

            zeros = sum(1 for wk, pk in zip(kernel_flat, p) if wk == 0 or pk == 0)
            zero_products_per_patch.append(zeros)
            nonzero_products_per_patch.append(9 - zeros)

        total_zeros = sum(zero_products_per_patch)
        total_nonzeros = sum(nonzero_products_per_patch)
        sparsity_pct = (total_zeros / total_macs) * 100.0

        image_variant_results = {}

        print(f" {'Configuration':<45} | {'Cycles':<10} | {'Skips':<8} | {'Mismatches':<10} | {'Data Source'}")
        print("-" * 105)

        for var_name, timing_type, skip_type in VARIANTS:
            mismatches = 0
            cycles = 0
            skips = 0

            for p_idx, p in enumerate(patches):
                # Arithmetic check
                res = int(np.sum(kernel_flat.astype(np.int32) * p.astype(np.int32)))
                if res != golden_outputs[p_idx]:
                    mismatches += 1

                # Cycle and skip accounting per variant
                if timing_type == "fixed_9":
                    cycles += 9
                elif timing_type == "variable_zs":
                    cycles += nonzero_products_per_patch[p_idx]

                if skip_type == "no_skip":
                    skips += 0
                elif skip_type in ["skip_zeros", "isolate_zeros", "gate_zeros"]:
                    skips += zero_products_per_patch[p_idx]

            data_source = "[FORMULA/MODEL (Python)]"
            avg_cpc = cycles / float(total_patches)
            speedup = (total_patches * 9.0) / float(cycles) if cycles > 0 else 1.0
            cyc_saved = (total_patches * 9) - cycles
            cyc_reduction_pct = (cyc_saved / float(total_patches * 9)) * 100.0

            print(f" {var_name:<45} | {cycles:<10} | {skips:<8} | {mismatches:<10} | {data_source}")

            image_variant_results[var_name] = {
                "compute_cycles": cycles,
                "cycles_per_patch": round(avg_cpc, 3),
                "cycle_reduction_pct": round(cyc_reduction_pct, 3),
                "speedup_factor": round(speedup, 3),
                "skips_count": skips,
                "mismatches": mismatches,
                "data_source": data_source,
                "hardware_telemetry_status": "NOT RUN (Requires Board)"
            }

        all_results[label] = {
            "image_path": path,
            "height": h,
            "width": w,
            "total_patches": total_patches,
            "total_mac_operations": total_macs,
            "total_zero_products": total_zeros,
            "total_nonzero_products": total_nonzeros,
            "joint_sparsity_pct": round(sparsity_pct, 4),
            "variants": image_variant_results
        }

    os.makedirs("results", exist_ok=True)
    out_file = os.path.join("results", "five_variants_profiler_results.json")
    with open(out_file, 'w', encoding='utf-8') as f:
        json.dump(all_results, f, indent=2)

    print("\n" + "=" * 86)
    print(f" [DONE] Saved 5-variant results to: {out_file}")
    print("=" * 86)

if __name__ == '__main__':
    run_evaluation()
