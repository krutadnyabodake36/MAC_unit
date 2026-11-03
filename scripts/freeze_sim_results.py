#!/usr/bin/env python3
"""
scripts/freeze_sim_results.py
Computes SHA-256 over all simulation results, logs, vectors, golden files,
and SAIF outputs (with v1 files labelled as superseded).
Writes results to FROZEN_SIM_RESULTS.sha256 in the final_run directory.
"""

import os
import hashlib

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RUN_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056")
OUTPUT_MANIFEST = os.path.join(RUN_DIR, "FROZEN_SIM_RESULTS.sha256")

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

# Target directories to scan relative to RUN_DIR
SCAN_DIRS = [
    "vectors",
    "saif",
    "saif_part_c",
    "funcsim_v2",
    "uart_board_check",
    "reports",
    "netlists_v2",
    "bitstreams",
    "saif_v1_superseded",
    "saif_part_c_v1_superseded",
]

# Root files inside RUN_DIR to include
ROOT_FILES = [
    "SUMMARY.csv",
    "SUMMARY.md",
    "zero_padding_gain_recomputed.json",
    "manifest_sha256.txt",
    "manifest_new_files_sha256.txt",
]

entries = []

for sdir in SCAN_DIRS:
    full_sdir = os.path.join(RUN_DIR, sdir)
    if not os.path.exists(full_sdir):
        continue
    for root, dirs, files in os.walk(full_sdir):
        # Sort for deterministic order
        files.sort()
        for f in files:
            # Skip temporary checkpoints or transient lock files if any
            if f.endswith((".dcp", ".jou", ".str")):
                continue
            full_path = os.path.join(root, f)
            rel_to_run = os.path.relpath(full_path, RUN_DIR).replace("\\", "/")
            try:
                h = sha256_file(full_path)
                entries.append((rel_to_run, h))
            except Exception as e:
                print(f"[WARNING] Could not read {rel_to_run}: {e}")

for rf in ROOT_FILES:
    full_rf = os.path.join(RUN_DIR, rf)
    if os.path.exists(full_rf):
        h = sha256_file(full_rf)
        entries.append((rf, h))

entries.sort(key=lambda x: x[0])

print(f"Total frozen files indexed: {len(entries)}")

with open(OUTPUT_MANIFEST, "w", encoding="utf-8") as out:
    out.write("# ==============================================================================\n")
    out.write("# FROZEN SIMULATION RESULTS MANIFEST (SHA-256)\n")
    out.write("# Directory: results/final_run_20261030_1056/\n")
    out.write("# Status: All simulation results, logs, vectors, netlists, and SAIF reports\n")
    out.write("# Note: Files under *superseded/ correspond to legacy v1 flow.\n")
    out.write("# ==============================================================================\n")
    for rel_path, h in entries:
        out.write(f"{h}  {rel_path}\n")

print(f"Wrote frozen manifest to: {OUTPUT_MANIFEST}")

