#!/usr/bin/env python3
"""
Stage 3: Vivado Batch Synthesis and Implementation for the 3 Missing Variants (5, 6, 7).
Executes build_final_run_8var.tcl sequentially for DESIGN_SELECT = 5, 6, 7.
Saves complete console logs to results/final_run_20261030_1056/logs/.
Verifies synthesized module name from each hierarchical report.
"""

import os
import sys
import subprocess

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VIVADO_BAT = r"C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat"
LOG_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "logs")
RPT_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "reports")

MISSING_VARIANTS = [
    (5, "zs_oi", "conv2d_serial_zs_oi"),
    (6, "zs_cg", "conv2d_serial_zs_cg"),
    (7, "oi_cg", "conv2d_serial_oi_cg"),
]

def build_variant(design_select, suffix, expected_module):
    print("=" * 80)
    print(f" >>> BUILDING VARIANT {design_select}: {suffix.upper()} ({expected_module}) <<<")
    print("=" * 80)

    log_path = os.path.join(LOG_DIR, f"stage3_build_{suffix}.log")
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

    print(f"Variant {suffix.upper()} built and verified successfully.\n")

def main():
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs(RPT_DIR, exist_ok=True)

    for ds, suffix, mod in MISSING_VARIANTS:
        build_variant(ds, suffix, mod)

    print("=" * 80)
    print(" >>> ALL 3 MISSING VARIANTS SUCCESSFULLY SYNTHESIZED AND IMPLEMENTED <<<")
    print("=" * 80)

if __name__ == "__main__":
    main()

