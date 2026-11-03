#!/usr/bin/env python3
"""
scripts/check_all_manifests.py
Checks all files against:
1. manifest_sha256.txt (original 35 files)
2. manifest_root_python_sha256.txt (original root Python files)
3. Computes and records hashes for all new ablation files in src/, tb/, scripts/
Reports any hash that differs from original manifests.
"""

import os
import hashlib
import sys

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RUN_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056")
ORIG_MANIFEST = os.path.join(RUN_DIR, "manifest_sha256.txt")
PY_MANIFEST = os.path.join(RUN_DIR, "manifest_root_python_sha256.txt")
UNIFIED_MANIFEST = os.path.join(RUN_DIR, "manifest_full_audit_sha256.txt")

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def check_manifest(manifest_path, label):
    print(f"\n--- Checking {label}: {manifest_path} ---")
    if not os.path.exists(manifest_path):
        print(f"[ERROR] Manifest not found: {manifest_path}")
        return False, []

    mismatches = []
    checked = 0
    with open(manifest_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or line.startswith("-"):
                continue
            parts = line.split(maxsplit=1)
            if len(parts) != 2:
                continue
            expected_hash, rel_path = parts
            full_path = os.path.join(PROJECT_ROOT, rel_path.replace("/", os.sep))

            if not os.path.exists(full_path):
                print(f"[MISSING] {rel_path}")
                mismatches.append((rel_path, "FILE_MISSING", expected_hash))
                continue

            current_hash = sha256_file(full_path)
            checked += 1
            if current_hash != expected_hash:
                print(f"[MISMATCH] {rel_path}!\n  Expected: {expected_hash}\n  Actual:   {current_hash}")
                mismatches.append((rel_path, expected_hash, current_hash))
            else:
                print(f"[MATCH] {rel_path}")

    return (len(mismatches) == 0), mismatches

def main():
    print("=" * 80)
    print(" >>> FULL AUDIT MANIFEST INTEGRITY CHECK <<<")
    print("=" * 80)

    ok1, mis1 = check_manifest(ORIG_MANIFEST, "Original 35 RTL/TB/Script Files")
    ok2, mis2 = check_manifest(PY_MANIFEST, "Root Python Scripts")

    # Now collect all new files
    new_files = [
        "src/conv2d_serial_oi_cg.sv",
        "src/conv2d_serial_zs_oi.sv",
        "src/conv2d_serial_zs_cg.sv",
        "src/conv2d_benchmark_top_ablation.sv",
        "tb/tb_cycle_measurement_8var.sv",
        "tb/tb_image_workloads_8var.sv",
        "scripts/build_final_run_8var.tcl",
        "scripts/run_stage3_missing.py",
        "scripts/rebuild_variants_0_to_4.py",
        "scripts/parse_final_run.py",
        "scripts/verify_src_integrity.py",
        "scripts/check_all_manifests.py",
    ]

    print(f"\n--- Recording Hashes for New Ablation Files ---")
    new_entries = []
    for rel_path in new_files:
        full_path = os.path.join(PROJECT_ROOT, rel_path.replace("/", os.sep))
        if os.path.exists(full_path):
            h = sha256_file(full_path)
            print(f"[NEW] {h}  {rel_path}")
            new_entries.append((h, rel_path))
        else:
            print(f"[NOT FOUND] {rel_path}")

    # Write unified manifest
    with open(UNIFIED_MANIFEST, "w", encoding="utf-8") as uf:
        uf.write("# FULL AUDIT SHA-256 MANIFEST\n")
        uf.write("# Generated during Part A execution\n")
        uf.write("# Format: SHA256  REL_PATH\n")
        uf.write("-" * 80 + "\n")
        uf.write("# SECTION 1: Original RTL, TB, and Script Files\n")
        with open(ORIG_MANIFEST, "r", encoding="utf-8") as f:
            for line in f:
                if not line.startswith("#") and line.strip():
                    uf.write(line)
        uf.write("\n# SECTION 2: Root Python Scripts\n")
        with open(PY_MANIFEST, "r", encoding="utf-8") as f:
            for line in f:
                if not line.startswith("#") and line.strip():
                    uf.write(line)
        uf.write("\n# SECTION 3: Newly Created Ablation Files\n")
        for h, rel in new_entries:
            uf.write(f"{h}  {rel}\n")

    print(f"\nUnified manifest written to: {UNIFIED_MANIFEST}")
    print("=" * 80)
    if ok1 and ok2:
        print("[SUCCESS] All original RTL, TB, scripts, and Python files match initial hashes exactly!")
        print("Zero original files were altered.")
    else:
        print(f"[FAILURE] Integrity check failed! Mismatches: {len(mis1) + len(mis2)}")
        sys.exit(1)

if __name__ == "__main__":
    main()

