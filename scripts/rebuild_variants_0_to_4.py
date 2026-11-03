#!/usr/bin/env python3
"""
scripts/rebuild_variants_0_to_4.py
Rebuilds variants 0 to 4 using build_final_run_8var.tcl and conv2d_benchmark_top_ablation
so that ALL 8 variants use the EXACT same top module and build flow.
"""

import os
import sys
import subprocess

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VIVADO_BAT = r"C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat"
LOG_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "logs")
RPT_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "reports")

VARIANTS = [
    (0, "baseline", "conv2d_serial_baseline"),
    (1, "oi",       "conv2d_serial_oi"),
    (2, "cg",       "conv2d_serial_cg"),
    (3, "zs",       "conv2d_serial_zs"),
    (4, "combined", "conv2d_serial_combined"),
]

def build_variant(design_select, suffix, expected_module):
    print("=" * 80)
    print(f" >>> REBUILDING VARIANT {design_select}: {suffix.upper()} ({expected_module}) <<<")
    print(f" Top module: conv2d_benchmark_top_ablation via build_final_run_8var.tcl")
    print("=" * 80)

    log_path = os.path.join(LOG_DIR, f"stage3_rebuild_{suffix}.log")
    env = os.environ.copy()
    env["DESIGN_SELECT"] = str(design_select)

    cmd = [VIVADO_BAT, "-mode", "batch", "-source", "scripts/build_final_run_8var.tcl"]

    with open(log_path, "w", encoding="utf-8") as lf:
        proc = subprocess.Popen(
            cmd,
            cwd=PROJECT_ROOT,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )
        for line in proc.stdout:
            sys.stdout.write(line)
            lf.write(line)
        proc.wait()
        lf.flush()

    if proc.returncode != 0:
        print(f"[ERROR] Build failed for {suffix} with exit code {proc.returncode}")
        sys.exit(proc.returncode)

    hier_rpt = os.path.join(RPT_DIR, f"utilization_hierarchical_{suffix}.txt")
    if not os.path.exists(hier_rpt):
        print(f"[ERROR] Hierarchical report not found: {hier_rpt}")
        sys.exit(1)

    found_module = False
    with open(hier_rpt, "r", encoding="utf-8") as hf:
        for line in hf:
            if expected_module in line:
                found_module = True
                print(f"[VERIFIED] Hierarchical utilization confirms module: {line.strip()}")
                break

    if not found_module:
        print(f"[ERROR] Expected module '{expected_module}' not found in {hier_rpt}!")
        sys.exit(1)

    print(f"Variant {suffix.upper()} rebuilt and verified successfully.\n")

def main():
    os.makedirs(LOG_DIR, exist_ok=True)
    for sel, suffix, mod in VARIANTS:
        build_variant(sel, suffix, mod)
    print("=" * 80)
    print(" >>> ALL 5 VARIANTS REBUILT SUCCESSFULLY WITH UNIFIED ABLATION TOP <<<")
    print("=" * 80)

if __name__ == "__main__":
    main()

