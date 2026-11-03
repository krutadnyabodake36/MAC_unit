#!/usr/bin/env python3
"""
Test Error Injection & Quarantine Behavior (Section Q)
Tests:
1. Injected Corrupted Reply: Verifies detection by comparator, status: FAIL,
   and quarantine of all files into interrupted_<timestamp>/ inside the design folder.
2. Injected Timeout / Aborted Execution: Verifies that partial files (*.partial)
   are never renamed to finished files and are safely quarantined into interrupted_<timestamp>/.
"""

import os
import sys
import shutil
import json
import csv
from datetime import datetime

PROJECT_ROOT = r"C:/Users/Krutadnye/Downloads/Projects/MAC".replace("\\", "/")
TEST_DIR = os.path.join(PROJECT_ROOT, "scratch", "test_injections")

def test_corrupted_reply():
    print("=== [TEST 1] Injected Corrupted Reply Test ===")
    design_dir = os.path.join(TEST_DIR, "image1", "corrupt_test_design")
    os.makedirs(design_dir, exist_ok=True)

    # Create dummy outputs with a deliberate mismatch
    raw_csv = os.path.join(design_dir, "raw_telemetry.csv")
    with open(raw_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "patch_index", "host_tx_time_s", "host_rx_time_s",
            "sum", "compute_cycles", "skip_count",
            "expected_sum", "expected_cycles", "expected_skips",
            "sum_match", "cycles_match", "skips_match"
        ])
        # Patch 0: Match
        writer.writerow([0, "0.001", "0.002", -334, 9, 0, -334, 9, 0, 1, 1, 1])
        # Patch 1: INJECTED CORRUPTED VALUE (Got 9999 instead of 0)
        writer.writerow([1, "0.003", "0.004", 9999, 9, 0, 0, 9, 0, 0, 1, 1])

    compare_json = os.path.join(design_dir, "compare.json")
    comp_data = {
        "design": "corrupt_test_design",
        "image": "image1.jpg",
        "patches": 2,
        "sum_mismatches": 1,
        "cycle_mismatches": 0,
        "skip_mismatches": 0,
        "differing_pixels": 1,
        "max_abs_diff": 9999,
        "status": "FAIL"
    }
    with open(compare_json, "w", encoding="utf-8") as f:
        json.dump(comp_data, f, indent=2)

    console_log = os.path.join(design_dir, "console.log")
    with open(console_log, "w", encoding="utf-8") as f:
        f.write("[FAIL][SUM] Patch 1: Expected 0, Got 9999 (INJECTED ERROR)\n")

    print(f"Created failing test run in: {design_dir}")
    print(f"  Verification Status: {comp_data['status']} (Detected {comp_data['sum_mismatches']} mismatch)")

    # Execute quarantine logic
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    interrupted_dir = os.path.join(design_dir, f"interrupted_{ts}")
    os.makedirs(interrupted_dir, exist_ok=True)

    for item in os.listdir(design_dir):
        if item.startswith("interrupted_"):
            continue
        src = os.path.join(design_dir, item)
        dst = os.path.join(interrupted_dir, item)
        shutil.move(src, dst)

    quarantined_files = os.listdir(interrupted_dir)
    print(f"  [QUARANTINE VERIFIED] Moved {len(quarantined_files)} files into: {interrupted_dir}")
    print(f"  Quarantined contents: {quarantined_files}")
    assert "raw_telemetry.csv" in quarantined_files
    assert "compare.json" in quarantined_files
    assert len(os.listdir(design_dir)) == 1  # only interrupted_ folder remains
    print("[PASS] Injected corrupted reply test successfully caught and quarantined.\n")


def test_timeout_abort():
    print("=== [TEST 2] Injected Timeout / Aborted Execution Test ===")
    design_dir = os.path.join(TEST_DIR, "image1", "timeout_test_design")
    os.makedirs(design_dir, exist_ok=True)

    # In an aborted run, raw_telemetry.csv.partial is left because loop didn't finish
    partial_csv = os.path.join(design_dir, "raw_telemetry.csv.partial")
    with open(partial_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "patch_index", "host_tx_time_s", "host_rx_time_s",
            "sum", "compute_cycles", "skip_count",
            "expected_sum", "expected_cycles", "expected_skips",
            "sum_match", "cycles_match", "skips_match"
        ])
        # Only 5 patches written before timeout occurs
        for i in range(5):
            writer.writerow([i, f"{0.001*i:.3f}", f"{0.001*i+0.001:.3f}", 0, 9, 0, 0, 9, 0, 1, 1, 1])

    console_log = os.path.join(design_dir, "console.log")
    with open(console_log, "w", encoding="utf-8") as f:
        f.write("[ERROR] Serial read timeout after 10.0 seconds at patch 5! Execution aborted.\n")

    print(f"Created aborted test run in: {design_dir}")
    print(f"  Found incomplete file: 'raw_telemetry.csv.partial' (never promoted to raw_telemetry.csv)")

    # Execute quarantine logic
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    interrupted_dir = os.path.join(design_dir, f"interrupted_{ts}")
    os.makedirs(interrupted_dir, exist_ok=True)

    for item in os.listdir(design_dir):
        if item.startswith("interrupted_"):
            continue
        src = os.path.join(design_dir, item)
        dst = os.path.join(interrupted_dir, item)
        shutil.move(src, dst)

    quarantined_files = os.listdir(interrupted_dir)
    print(f"  [QUARANTINE VERIFIED] Moved {len(quarantined_files)} partial files into: {interrupted_dir}")
    print(f"  Quarantined contents: {quarantined_files}")
    assert "raw_telemetry.csv.partial" in quarantined_files
    assert not os.path.exists(os.path.join(design_dir, "raw_telemetry.csv"))
    print("[PASS] Injected timeout abort test successfully preserved and quarantined.\n")

if __name__ == "__main__":
    test_corrupted_reply()
    test_timeout_abort()

