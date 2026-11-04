#!/usr/bin/env python3
"""
Automated 3-Image Triad Hardware Benchmark Runner
Target: Spartan-7 XC7S15 FPGA @ 50 MHz (Invent Logics EDGE Board)
Executes image1.jpg, image2.jpg, image3.jpg sequentially on the currently loaded FPGA bitstream.
"""

import os
import sys
import argparse
import subprocess
import json
import time

TRIAD_IMAGES = [
    ("image1.jpg", "image1", 11648),
    ("image2.jpg", "image2", 12288),
    ("image3.jpg", "image3", 9216)
]

def parse_args():
    parser = argparse.ArgumentParser(description="Automated 3-Image Triad FPGA Benchmark")
    parser.add_argument("--design", type=str, default="baseline",
                        choices=["baseline", "oi", "cg", "zs", "combined", "zs_oi", "zs_cg", "oi_cg", "static_sobel", "proposed"],
                        help="Target FPGA architecture under test (default: baseline)")
    parser.add_argument("--port", type=str, default="COM17", help="FPGA USB-UART COM port (default: COM17)")
    parser.add_argument("--baud", type=int, default=115200, help="UART Baud Rate (default: 115200)")
    parser.add_argument("--output-base", type=str, default="board_results", help="Base output directory (default: board_results)")
    return parser.parse_args()

def main():
    args = parse_args()
    print("=" * 80)
    print(" >>> SPARTAN-7 FPGA AUTOMATED 3-IMAGE TRIAD BENCHMARK RUNNER <<<")
    print(f" Target Variant : {args.design.upper()}")
    print(f" COM Port       : {args.port} @ {args.baud} baud")
    print(f" Output Folder  : {args.output_base}/{args.design}/")
    print(" Benchmark Triad: image1.jpg (11,648) + image2.jpg (12,288) + image3.jpg (9,216)")
    print(" Total Patches  : 33,152 patches (298,368 MAC operations)")
    print("=" * 80)

    overall_start = time.time()
    results = []

    for img_file, img_stem, exp_patches in TRIAD_IMAGES:
        if not os.path.exists(img_file):
            print(f"[ERROR] Benchmark image '{img_file}' not found in workspace!")
            sys.exit(1)

        out_dir = os.path.join(args.output_base, args.design, img_stem)
        os.makedirs(out_dir, exist_ok=True)

        print(f"\n[{img_stem.upper()}] Starting Hardware Execution ({img_file} -> {out_dir})...")
        cmd = [
            sys.executable,
            "fpga_vision_profiler.py",
            img_file,
            "--design", args.design,
            "--port", args.port,
            "--baud", str(args.baud),
            "--output-dir", out_dir
        ]

        t0 = time.time()
        ret = subprocess.run(cmd)
        elapsed = time.time() - t0

        if ret.returncode != 0:
            print(f"[FAIL] Execution of {img_file} returned error code {ret.returncode}!")
        else:
            print(f"[{img_stem.upper()}] Completed in {elapsed:.2f} seconds.")

        # Read back results
        comp_file = os.path.join(out_dir, "compare.json")
        summ_file = os.path.join(out_dir, "run_summary.json")

        comp_data = {}
        summ_data = {}

        if os.path.exists(comp_file):
            with open(comp_file, "r") as f:
                comp_data = json.load(f)

        if os.path.exists(summ_file):
            with open(summ_file, "r") as f:
                summ_data = json.load(f)

        results.append({
            "image": img_file,
            "stem": img_stem,
            "expected_patches": exp_patches,
            "actual_patches": comp_data.get("patches", 0),
            "elapsed_s": elapsed,
            "status": comp_data.get("status", "FAIL"),
            "sum_mismatches": comp_data.get("sum_mismatches", -1),
            "cycle_mismatches": comp_data.get("cycle_mismatches", -1),
            "skip_mismatches": comp_data.get("skip_mismatches", -1),
            "total_cycles": summ_data.get("total_compute_cycles", 0),
            "mean_cycles": summ_data.get("mean_compute_cycles_per_patch", 0.0),
            "total_skips": summ_data.get("total_skip_count", 0),
            "mean_skips": summ_data.get("mean_skip_count_per_patch", 0.0),
            "timeouts": summ_data.get("uart_metrics", {}).get("timeouts", 0)
        })

    total_time = time.time() - overall_start

    # Print summary table
    print("\n" + "=" * 90)
    print(f" >>> BENCHMARK COMPLETE: {args.design.upper()} TRIAD HARDWARE SUMMARY <<<")
    print(f" Total Elapsed Time: {total_time:.2f} seconds across 33,152 patches")
    print("=" * 90)
    print(f"{'Image':<12} {'Patches':<8} {'Time (s)':<10} {'Sum Mis':<9} {'Cyc Mis':<9} {'Mean Cyc':<10} {'Mean Skp':<10} {'Status':<8}")
    print("-" * 90)

    all_passed = True
    tot_patches = 0
    tot_cycles = 0
    tot_skips = 0

    for r in results:
        tot_patches += r['actual_patches']
        tot_cycles += r['total_cycles']
        tot_skips += r['total_skips']
        if r['status'] != 'PASS' or r['sum_mismatches'] != 0:
            all_passed = False

        print(f"{r['image']:<12} {r['actual_patches']:<8} {r['elapsed_s']:<10.2f} {r['sum_mismatches']:<9} {r['cycle_mismatches']:<9} {r['mean_cycles']:<10.2f} {r['mean_skips']:<10.2f} {r['status']:<8}")

    print("-" * 90)
    overall_mean_cyc = tot_cycles / tot_patches if tot_patches > 0 else 0
    overall_mean_skp = tot_skips / tot_patches if tot_patches > 0 else 0
    print(f"{'TOTAL':<12} {tot_patches:<8} {total_time:<10.2f} {'0' if all_passed else 'MISMATCH':<9} {'0' if all_passed else 'MISMATCH':<9} {overall_mean_cyc:<10.2f} {overall_mean_skp:<10.2f} {'PASS' if all_passed else 'FAIL':<8}")
    print("=" * 90)

    # Save summary json
    summary_path = os.path.join(args.output_base, args.design, "triad_summary.json")
    summary_doc = {
        "design": args.design,
        "total_elapsed_s": total_time,
        "all_passed": all_passed,
        "total_patches": tot_patches,
        "total_cycles": tot_cycles,
        "total_skips": tot_skips,
        "overall_mean_cycles_per_patch": overall_mean_cyc,
        "overall_mean_skips_per_patch": overall_mean_skp,
        "runs": results
    }
    with open(summary_path, "w", encoding="utf-8") as f:
        json.dump(summary_doc, f, indent=2)
    print(f"\n[SUMMARY] Saved structured triad summary to: {summary_path}\n")

if __name__ == "__main__":
    main()

