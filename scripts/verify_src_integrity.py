#!/usr/bin/env python3
"""
scripts/verify_src_integrity.py
Verifies that no original file listed in manifest_sha256.txt was modified.
Computes current SHA-256 and compares bit-for-bit.
Also records SHA-256 for newly created ablation files.
"""

import os
import hashlib
import sys

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MANIFEST = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "manifest_sha256.txt")
NEW_MANIFEST = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "manifest_new_files_sha256.txt")

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def main():
    print("=" * 80)
    print(" >>> INTEGRITY CHECK: VERIFYING ORIGINAL FILES AGAINST MANIFEST <<<")
    print("=" * 80)

    if not os.path.exists(MANIFEST):
        print(f"[ERROR] Manifest not found: {MANIFEST}")
        sys.exit(1)

    mismatches = []
    checked = 0

    with open(MANIFEST, "r", encoding="utf-8") as f:
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
                print(f"[OK] {rel_path} (SHA-256: {current_hash[:16]}...)")

    print("\n" + "=" * 80)
    if mismatches:
        print(f"[FAILED] {len(mismatches)} files had mismatches or were missing!")
        for m in mismatches:
            print(f"  {m}")
        sys.exit(1)
    else:
        print(f"[SUCCESS] All {checked} original files match their initial SHA-256 hashes exactly!")
        print("Zero original files were altered.")

    # Now record hashes of new files created for ablation
    new_files = [
        "src/conv2d_serial_oi_cg.sv",
        "src/conv2d_serial_zs_oi.sv",
        "src/conv2d_serial_zs_cg.sv",
        "src/conv2d_serial_static_sobel.sv",
        "src/conv2d_benchmark_top_ablation.sv",
        "src/conv2d_benchmark_top_static.sv",
        "src/conv2d_engine_wrapper.sv",
        "src/conv2d_engine_wrapper_v2.sv",
        "tb/tb_cycle_measurement_8var.sv",
        "tb/tb_cycle_measurement_static.sv",
        "tb/tb_image_workloads_8var.sv",
        "tb/tb_conv2d_engine_saif.sv",
        "tb/tb_conv2d_engine_saif_timesim.sv",
        "tb/tb_conv2d_engine_saif_timesim_v2.sv",
        "tb/tb_conv2d_engine_part_c_saif_v2.sv",
        "tb/tb_uart_board_path_check.sv",
        "tb/tb_part_c_dual_rules.sv",
        "scripts/build_final_run_8var.tcl",
        "scripts/build_static_sobel.tcl",
        "scripts/run_stage3_missing.py",
        "scripts/parse_final_run.py",
        "scripts/verify_src_integrity.py",
        "scripts/compute_part_c_both_rules.py",
        "scripts/run_sobel_14_images_all_variants.py",
        "scripts/generate_part_c_vectors.py",
        "scripts/run_part_c_complete.py",
        "scripts/measure_zero_padding_gain.py",
        "scripts/run_timesim_saif_clean.py",
        "scripts/run_g3_functional_netlist_check_all.py",
        "scripts/run_g4_saif_sweep_v2.py",
        "scripts/run_uart_board_path_check_all9.py",
        "scripts/keep_awake.py",
        "images_extra/SOURCES.csv",
        "fpga_vision_profiler.py",
        "image2.jpg",
    ]

    print("\n" + "=" * 80)
    print(" >>> RECORDING HASHES FOR NEWLY CREATED ABLATION FILES <<<")
    print("=" * 80)
    with open(NEW_MANIFEST, "w", encoding="utf-8") as nf:
        nf.write(f"# SHA-256 Manifest for Newly Created Ablation Files\n")
        nf.write(f"# Format: SHA256  REL_PATH\n")
        nf.write("-" * 80 + "\n")
        for nf_rel in new_files:
            nf_full = os.path.join(PROJECT_ROOT, nf_rel.replace("/", os.sep))
            if os.path.exists(nf_full):
                h = sha256_file(nf_full)
                line = f"{h}  {nf_rel}"
                print(f"[NEW] {line}")
                nf.write(line + "\n")
            else:
                print(f"[NOT FOUND] {nf_rel}")

    print(f"\nWrote new files manifest to: {NEW_MANIFEST}\n")

if __name__ == "__main__":
    main()

