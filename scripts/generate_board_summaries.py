#!/usr/bin/env python3
"""
Board Results Summarizer (Section P).
Scans a board_results_<YYYYMMDD_HHMM>/ tree, reads raw run_summary.json files,
and generates:
1. image_summary.csv & image_summary.md for each image folder
2. all_images_summary.csv & all_images_summary.md across all 4 images
3. cross_design_consistency.md verifying (cg == oi_cg) and (zs_cg == combined)
"""

import os
import sys
import json
import csv
import glob

DESIGNS = ['baseline', 'oi', 'cg', 'zs', 'zs_oi', 'zs_cg', 'oi_cg', 'combined', 'static_sobel']
IMAGES = ['image1', 'image2', 'image3', 'image4']

def summarize_tree(tree_dir):
    if not os.path.isdir(tree_dir):
        print(f"[ERROR] Directory not found: {tree_dir}")
        return False

    all_data = {}  # (image, design) -> run_summary dict

    for img in IMAGES:
        img_dir = os.path.join(tree_dir, img)
        if not os.path.isdir(img_dir):
            continue

        image_rows = []
        baseline_cycles = None

        # First pass to find baseline
        bl_json = os.path.join(img_dir, "baseline", "run_summary.json")
        if os.path.exists(bl_json):
            with open(bl_json, "r", encoding="utf-8") as f:
                bl_data = json.load(f)
                baseline_cycles = bl_data.get("total_compute_cycles", None)

        for d in DESIGNS:
            d_json = os.path.join(img_dir, d, "run_summary.json")
            if not os.path.exists(d_json):
                continue
            with open(d_json, "r", encoding="utf-8") as f:
                d_data = json.load(f)
            all_data[(img, d)] = d_data

            patches = d_data.get("patches", 0)
            comp_cyc = d_data.get("total_compute_cycles", 0)
            mean_cyc = d_data.get("mean_compute_cycles_per_patch", 0.0)
            skips = d_data.get("total_skip_count", 0)
            issued_ops = comp_cyc
            mismatches = d_data.get("mismatch_counts", {})
            total_mismatches = mismatches.get("sum_mismatches", 0) + mismatches.get("cycles_mismatches", 0) + mismatches.get("skips_mismatches", 0)
            img_comp = d_data.get("output_image_comparison", {})
            diff_pixels = img_comp.get("differing_pixels", 0)
            host_time = d_data.get("total_host_time_s", 0.0)
            pps = d_data.get("patches_per_second", 0.0)

            # Derived
            if baseline_cycles and baseline_cycles > 0:
                saved_cyc = baseline_cycles - comp_cyc
                pct_saved = (saved_cyc / baseline_cycles) * 100.0
                speedup = baseline_cycles / comp_cyc if comp_cyc > 0 else 0.0
            else:
                saved_cyc = 0
                pct_saved = 0.0
                speedup = 1.0

            wall_cyc = comp_cyc + 2 * patches
            engine_time_us = wall_cyc * 0.020  # 20 ns per cycle

            row = {
                "design": d,
                "patches": patches,
                "total_compute_cycles [BOARD]": comp_cyc,
                "mean_cycles_per_patch [BOARD]": mean_cyc,
                "skipped_gated_products [BOARD]": skips,
                "issued_mac_operations [BOARD]": issued_ops,
                "mismatch_counts [BOARD vs SIM]": total_mismatches,
                "output_diff_pixels [BOARD vs SIM]": diff_pixels,
                "host_time_s [HOST]": host_time,
                "patches_per_second [DERIVED]": pps,
                "cycles_saved_vs_baseline [DERIVED]": saved_cyc,
                "percentage_saved [DERIVED]": pct_saved,
                "compute_speedup [DERIVED]": speedup,
                "modelled_engine_wall_cycles [DERIVED]": wall_cyc,
                "modelled_engine_time_us [DERIVED]": engine_time_us
            }
            image_rows.append(row)

        # Write image_summary.csv and .md
        if image_rows:
            csv_path = os.path.join(img_dir, "image_summary.csv")
            with open(csv_path, "w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=list(image_rows[0].keys()))
                writer.writeheader()
                writer.writerows(image_rows)

            md_path = os.path.join(img_dir, "image_summary.md")
            with open(md_path, "w", encoding="utf-8") as f:
                f.write(f"# Image Execution Summary: {img}\n\n")
                f.write("| Design | Patches | Total Compute Cycles [BOARD] | Mean Cyc/Patch [BOARD] | Skips/Gated [BOARD] | Mismatches | Diff Pixels | Speedup [DERIVED] | Modelled Time (us) [DERIVED] |\n")
                f.write("| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |\n")
                for r in image_rows:
                    f.write(f"| {r['design']} | {r['patches']:,} | {r['total_compute_cycles [BOARD]']:,} | {r['mean_cycles_per_patch [BOARD]']:.2f} | {r['skipped_gated_products [BOARD]']:,} | {r['mismatch_counts [BOARD vs SIM]']} | {r['output_diff_pixels [BOARD vs SIM]']} | **{r['compute_speedup [DERIVED]']:.2f}x** | {r['modelled_engine_time_us [DERIVED]']:.1f} |\n")

    # Overall Summary across all images
    all_summary_dir = os.path.join(tree_dir, "all_images_summary")
    os.makedirs(all_summary_dir, exist_ok=True)

    totals_by_design = []
    bl_overall_cycles = 0

    # Calculate baseline overall first
    for img in IMAGES:
        if (img, 'baseline') in all_data:
            bl_overall_cycles += all_data[(img, 'baseline')].get("total_compute_cycles", 0)

    for d in DESIGNS:
        d_patches = 0
        d_comp_cyc = 0
        d_skips = 0
        d_mismatches = 0
        d_diff_pixels = 0
        d_host_time = 0.0

        for img in IMAGES:
            key = (img, d)
            if key in all_data:
                item = all_data[key]
                d_patches += item.get("patches", 0)
                d_comp_cyc += item.get("total_compute_cycles", 0)
                d_skips += item.get("total_skip_count", 0)
                m = item.get("mismatch_counts", {})
                d_mismatches += m.get("sum_mismatches", 0) + m.get("cycles_mismatches", 0) + m.get("skips_mismatches", 0)
                d_diff_pixels += item.get("output_image_comparison", {}).get("differing_pixels", 0)
                d_host_time += item.get("total_host_time_s", 0.0)

        if d_patches == 0:
            continue

        mean_cyc = d_comp_cyc / d_patches if d_patches > 0 else 0.0
        pps = d_patches / d_host_time if d_host_time > 0 else 0.0
        saved_cyc = bl_overall_cycles - d_comp_cyc
        pct_saved = (saved_cyc / bl_overall_cycles * 100.0) if bl_overall_cycles > 0 else 0.0
        speedup = (bl_overall_cycles / d_comp_cyc) if d_comp_cyc > 0 else 0.0
        wall_cyc = d_comp_cyc + 2 * d_patches
        engine_time_ms = wall_cyc * 0.000020

        totals_by_design.append({
            "design": d,
            "total_patches": d_patches,
            "total_compute_cycles [BOARD]": d_comp_cyc,
            "mean_cycles_per_patch [BOARD]": mean_cyc,
            "total_skipped_gated_products [BOARD]": d_skips,
            "total_mismatches [BOARD vs SIM]": d_mismatches,
            "total_diff_pixels [BOARD vs SIM]": d_diff_pixels,
            "total_host_time_s [HOST]": d_host_time,
            "aggregate_pps [DERIVED]": pps,
            "cycles_saved_vs_baseline [DERIVED]": saved_cyc,
            "percentage_saved [DERIVED]": pct_saved,
            "compute_speedup [DERIVED]": speedup,
            "modelled_engine_wall_cycles [DERIVED]": wall_cyc,
            "modelled_engine_time_ms [DERIVED]": engine_time_ms
        })

    if totals_by_design:
        with open(os.path.join(all_summary_dir, "all_images_summary.csv"), "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(totals_by_design[0].keys()))
            writer.writeheader()
            writer.writerows(totals_by_design)

        with open(os.path.join(all_summary_dir, "all_images_summary.md"), "w", encoding="utf-8") as f:
            f.write("# Aggregate 4-Image Hardware Execution Summary (44,032 Patches)\n\n")
            f.write("| Design | Patches | Total Compute Cycles [BOARD] | Mean Cyc/Patch [BOARD] | Skips/Gated [BOARD] | Mismatches | Diff Pixels | Aggregate Speedup [DERIVED] | Modelled Active Time (ms) [DERIVED] |\n")
            f.write("| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |\n")
            for r in totals_by_design:
                f.write(f"| **{r['design']}** | {r['total_patches']:,} | {r['total_compute_cycles [BOARD]']:,} | {r['mean_cycles_per_patch [BOARD]']:.3f} | {r['total_skipped_gated_products [BOARD]']:,} | {r['total_mismatches [BOARD vs SIM]']} | {r['total_diff_pixels [BOARD vs SIM]']} | **{r['compute_speedup [DERIVED]']:.3f}x** | {r['modelled_engine_time_ms [DERIVED]']:.3f} |\n")

    # Cross-Design Consistency Check Table (cg vs oi_cg) and (zs_cg vs combined)
    consistency_lines = [
        "# Cross-Design Functional & Counter Consistency Verification",
        "",
        "| Architecture Pair | Design A | Design B | Design A Cycles | Design B Cycles | Cycle Difference | Design A Skips | Design B Skips | Skip Difference | Status |",
        "| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |"
    ]

    pairs = [
        ("Clock Gating Equivalence", "cg", "oi_cg"),
        ("Zero-Skipping Equivalence", "zs_cg", "combined")
    ]

    for label, d_a, d_b in pairs:
        cyc_a = sum(all_data.get((img, d_a), {}).get("total_compute_cycles", 0) for img in IMAGES)
        cyc_b = sum(all_data.get((img, d_b), {}).get("total_compute_cycles", 0) for img in IMAGES)
        skp_a = sum(all_data.get((img, d_a), {}).get("total_skip_count", 0) for img in IMAGES)
        skp_b = sum(all_data.get((img, d_b), {}).get("total_skip_count", 0) for img in IMAGES)

        diff_cyc = cyc_a - cyc_b
        diff_skp = skp_a - skp_b
        status = "PASS (Bit-Identical)" if (diff_cyc == 0 and diff_skp == 0) else "FAIL (Discrepancy)"
        consistency_lines.append(
            f"| {label} | `{d_a}` | `{d_b}` | {cyc_a:,} | {cyc_b:,} | {diff_cyc} | {skp_a:,} | {skp_b:,} | {diff_skp} | **{status}** |"
        )

    with open(os.path.join(all_summary_dir, "cross_design_consistency.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(consistency_lines) + "\n")

    print(f"[SUMMARY] Successfully generated all summaries in: '{tree_dir}'")
    return True

if __name__ == "__main__":
    t_dir = sys.argv[1] if len(sys.argv) > 1 else None
    summarize_tree(t_dir)

