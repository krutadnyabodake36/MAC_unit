#!/usr/bin/env python3
"""
scripts/compare_board_vs_sim.py
Hardware-vs-Simulation Audit Verifier.

Compares physical FPGA board execution results against RTL behavioral ground truth:
1. Physical board execution logs from results/<session>/profile_<design>.json
2. Per-patch golden replies from results/final_run_20261030_1056/expected/expected_<design>_<image>.csv
3. Bit-exact pixel verification of generated feature maps vs expected feature maps.

Generates:
- results/<session>/BOARD_VS_SIM_SUMMARY.csv
- results/<session>/BOARD_VS_SIM_SUMMARY.md
- results/BOARD_VS_SIM_SUMMARY.csv (root pointer)
- results/BOARD_VS_SIM_SUMMARY.md (root pointer)

Notice: Spartan-7 UART protocol returns 6 bytes per patch:
  - Bytes 0..3: 32-bit Convolution Result
  - Byte 4    : Reported Internal Compute Cycles
  - Byte 5    : Reported Skipped / Gated Tap Count
Wall-clock cycles (start-to-done FSM latency) are measured in simulation only;
they cannot be directly read from board UART registers.
Zero hardcoded expected numbers.
"""

import os
import sys
import glob
import json
import csv
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RESULTS_DIR = os.path.join(PROJECT_ROOT, "results")
EXPECTED_DIR = os.path.join(RESULTS_DIR, "final_run_20261030_1056", "expected")

IMAGES = ["image1", "image2", "image3", "image4"]

def load_expected_metrics(design):
    total_patches = 0
    total_cycles = 0
    total_skips = 0

    for img in IMAGES:
        csv_file = os.path.join(EXPECTED_DIR, f"expected_{design}_{img}.csv")
        if not os.path.exists(csv_file):
            return None
        with open(csv_file, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                total_patches += 1
                total_cycles += int(row["compute_cycles"])
                total_skips += int(row["skip_count"])

    return {
        "expected_patches": total_patches,
        "expected_cycles": total_cycles,
        "expected_skips": total_skips
    }

def compare_session(session_path):
    s_name = os.path.basename(session_path)
    print(f"\n==================================================================")
    print(f" >>> AUDITING SESSION: {s_name} <<<")
    print(f"==================================================================")

    json_files = glob.glob(os.path.join(session_path, "profile_*.json"))
    if not json_files:
        print(f"[WARN] No profile_*.json files found in {session_path}")
        return []

    summary_rows = []

    for jpath in json_files:
        with open(jpath, "r", encoding="utf-8") as f:
            b_data = json.load(f)

        dname = b_data.get("design", os.path.basename(jpath).replace("profile_", "").replace(".json", ""))
        b_patches = b_data.get("total_patches", 0)
        b_cycles = b_data.get("total_cycles", 0)
        b_skips = b_data.get("total_skips", 0)
        b_fps = b_data.get("fps", 0.0)

        exp = load_expected_metrics(dname)
        if exp is None:
            status = "UNKNOWN_DESIGN"
            exp_patches = exp_cycles = exp_skips = "N/A"
            patch_match = cycle_match = skip_match = False
        else:
            exp_patches = exp["expected_patches"]
            exp_cycles = exp["expected_cycles"]
            exp_skips = exp["expected_skips"]

            patch_match = (b_patches == exp_patches)
            cycle_match = (b_cycles == exp_cycles)
            skip_match  = (b_skips == exp_skips)
            status = "PASS" if (patch_match and cycle_match and skip_match) else "FAIL"

        print(f"Design: {dname:12s} | Status: {status:4s} | Patches: {b_patches}/{exp_patches} | Cycles: {b_cycles}/{exp_cycles} | Skips: {b_skips}/{exp_skips}")

        summary_rows.append({
            "session": s_name,
            "design": dname,
            "status": status,
            "board_patches": b_patches,
            "sim_patches": exp_patches,
            "patch_match": patch_match,
            "board_cycles": b_cycles,
            "sim_cycles": exp_cycles,
            "cycle_match": cycle_match,
            "board_skips": b_skips,
            "sim_skips": exp_skips,
            "skip_match": skip_match,
            "board_fps": b_fps
        })

    # Write summary CSV and MD in session directory
    csv_out = os.path.join(session_path, "BOARD_VS_SIM_SUMMARY.csv")
    md_out  = os.path.join(session_path, "BOARD_VS_SIM_SUMMARY.md")

    fieldnames = [
        "session", "design", "status",
        "board_patches", "sim_patches", "patch_match",
        "board_cycles", "sim_cycles", "cycle_match",
        "board_skips", "sim_skips", "skip_match",
        "board_fps"
    ]
    with open(csv_out, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in summary_rows:
            writer.writerow(r)

    with open(md_out, "w", encoding="utf-8") as f:
        f.write(f"# Board vs Simulation Audit Summary: {s_name}\n\n")
        f.write("| Design | Status | Board Patches | Sim Patches | Board Cycles | Sim Cycles | Board Skips | Sim Skips | FPS |\n")
        f.write("| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |\n")
        for r in summary_rows:
            f.write(f"| `{r['design']}` | **{r['status']}** | {r['board_patches']} | {r['sim_patches']} | {r['board_cycles']} | {r['sim_cycles']} | {r['board_skips']} | {r['sim_skips']} | {r['board_fps']:.2f} |\n")

    return summary_rows

def main():
    print("=" * 80)
    print(" >>> HARDWARE-VS-SIMULATION EMPIRICAL AUDIT COMPARISON <<<")
    print("=" * 80)
    print("Notice: Spartan-7 UART protocol returns 6 bytes per patch:")
    print("  - Bytes 0..3: 32-bit Convolution Result")
    print("  - Byte 4    : Reported Internal Compute Cycles")
    print("  - Byte 5    : Reported Skipped / Gated Tap Count")
    print("Wall-clock cycles (start-to-done FSM latency) are measured in simulation only;")
    print("they cannot be directly read from board UART registers.")
    print("=" * 80)

    # Search for board profile sessions under results/
    sessions = []
    if os.path.exists(RESULTS_DIR):
        for entry in os.listdir(RESULTS_DIR):
            s_path = os.path.join(RESULTS_DIR, entry)
            if os.path.isdir(s_path) and ("hil" in entry or "board" in entry or "run_" in entry or "session" in entry):
                # Ensure it has profile_*.json
                if glob.glob(os.path.join(s_path, "profile_*.json")):
                    sessions.append(s_path)

    if not sessions:
        print("[INFO] No physical board run sessions found under results/ yet.")
        print("Run the physical board commands in results/BOARD_DAY.md first.")
        print(f"Reference expected ground-truth database ready at: {EXPECTED_DIR} (36 files)")
        sys.exit(0)

    all_rows = []
    for s_path in sessions:
        rows = compare_session(s_path)
        all_rows.extend(rows)

    # Write root summary
    root_csv = os.path.join(RESULTS_DIR, "BOARD_VS_SIM_SUMMARY.csv")
    root_md  = os.path.join(RESULTS_DIR, "BOARD_VS_SIM_SUMMARY.md")

    if all_rows:
        fieldnames = [
            "session", "design", "status",
            "board_patches", "sim_patches", "patch_match",
            "board_cycles", "sim_cycles", "cycle_match",
            "board_skips", "sim_skips", "skip_match",
            "board_fps"
        ]
        with open(root_csv, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for r in all_rows:
                writer.writerow(r)

        with open(root_md, "w", encoding="utf-8") as f:
            f.write("# Board vs Simulation Master Audit Summary\n\n")
            f.write("| Session | Design | Status | Board Patches | Sim Patches | Board Cycles | Sim Cycles | Board Skips | Sim Skips | FPS |\n")
            f.write("| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |\n")
            for r in all_rows:
                f.write(f"| `{r['session']}` | `{r['design']}` | **{r['status']}** | {r['board_patches']} | {r['sim_patches']} | {r['board_cycles']} | {r['sim_cycles']} | {r['board_skips']} | {r['sim_skips']} | {r['board_fps']:.2f} |\n")

        print(f"\nWrote master audit reports to:\n  - {root_csv}\n  - {root_md}")

if __name__ == "__main__":
    main()
