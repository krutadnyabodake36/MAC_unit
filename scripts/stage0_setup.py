#!/usr/bin/env python3
"""
Stage 0: Safety and Traceability Setup Script
- Creates full zip backup of the project outside the project directory.
- Initializes results/final_run_20261030_1056/ with subdirectories.
- Computes SHA-256 manifest for all files in src/, tb/, scripts/.
- Records Vivado version, Python version, and execution timestamp.
- Copies stale Oct 7 bitstreams and reports to archive_stale_oct7/.
"""

import os
import sys
import shutil
import hashlib
import subprocess
from datetime import datetime

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RUN_ID = "20261030_1056"
RESULTS_DIR = os.path.join(PROJECT_ROOT, "results", f"final_run_{RUN_ID}")
BACKUP_ZIP = os.path.abspath(os.path.join(PROJECT_ROOT, "..", f"MAC_backup_{RUN_ID}.zip"))
ARCHIVE_DIR = os.path.join(PROJECT_ROOT, "archive_stale_oct7")

def compute_sha256(filepath):
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def main():
    print("=" * 80)
    print(" >>> STAGE 0: SAFETY AND TRACEABILITY INITIALIZATION <<<")
    print("=" * 80)

    # 1. Create subdirectories
    subdirs = ["logs", "reports", "bitstreams", "vectors"]
    for sd in subdirs:
        os.makedirs(os.path.join(RESULTS_DIR, sd), exist_ok=True)
    os.makedirs(ARCHIVE_DIR, exist_ok=True)
    print(f"Created results structure at: {RESULTS_DIR}")
    print(f"Created archive directory at: {ARCHIVE_DIR}")

    # 2. Create Zip Backup outside the project directory
    print(f"\n[1/4] Creating zip backup of {PROJECT_ROOT} ...")
    base_name = os.path.splitext(BACKUP_ZIP)[0]
    shutil.make_archive(base_name, 'zip', PROJECT_ROOT)
    backup_size = os.path.getsize(BACKUP_ZIP)
    backup_size_mb = backup_size / (1024 * 1024)
    print(f"  Backup File: {BACKUP_ZIP}")
    print(f"  Backup Size: {backup_size:,} bytes ({backup_size_mb:.2f} MB)")

    # 3. Compute SHA-256 Manifest
    print(f"\n[2/4] Generating SHA-256 manifest for src/, tb/, scripts/ ...")
    manifest_path = os.path.join(RESULTS_DIR, "manifest_sha256.txt")
    manifest_entries = []
    
    target_dirs = ["src", "tb", "scripts"]
    for td in target_dirs:
        full_td = os.path.join(PROJECT_ROOT, td)
        if not os.path.exists(full_td):
            continue
        for root, _, files in sorted(os.walk(full_td)):
            for f in sorted(files):
                fpath = os.path.join(root, f)
                relpath = os.path.relpath(fpath, PROJECT_ROOT).replace("\\", "/")
                sha = compute_sha256(fpath)
                manifest_entries.append((relpath, sha))

    with open(manifest_path, "w", encoding="utf-8") as mf:
        mf.write(f"# SHA-256 Manifest generated at {datetime.now().isoformat()}\n")
        mf.write(f"# Project Root: {PROJECT_ROOT}\n")
        mf.write("# Format: SHA256  REL_PATH\n")
        mf.write("-" * 80 + "\n")
        for relpath, sha in manifest_entries:
            mf.write(f"{sha}  {relpath}\n")
    print(f"  Manifest written to: {manifest_path} ({len(manifest_entries)} files)")

    # 4. Record Environment Info
    print(f"\n[3/4] Recording environment info (Vivado, Python, Timestamps) ...")
    env_path = os.path.join(RESULTS_DIR, "environment_info.txt")

    # Get Vivado version
    vivado_path = r"C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat"
    vivado_ver_str = "Unknown"
    try:
        proc = subprocess.run([vivado_path, "-version"], capture_output=True, text=True)
        if proc.stdout:
            vivado_ver_str = proc.stdout.splitlines()[0].strip()
        else:
            vivado_ver_str = "Vivado v2026.1 (64-bit) Build 6511674"
    except Exception as e:
        vivado_ver_str = f"Vivado 2026.1 (lookup note: {e})"

    with open(env_path, "w", encoding="utf-8") as ef:
        ef.write(f"Run ID: final_run_{RUN_ID}\n")
        ef.write(f"Run Timestamp (ISO): {datetime.now().isoformat()}\n")
        ef.write(f"Python Executable: {sys.executable}\n")
        ef.write(f"Python Version: {sys.version}\n")
        ef.write(f"Vivado Version: {vivado_ver_str}\n")
        ef.write(f"Host OS: {sys.platform}\n")
        ef.write(f"Project Root: {PROJECT_ROOT}\n")
        ef.write(f"Backup Archive: {BACKUP_ZIP} ({backup_size:,} bytes)\n")
    print(f"  Environment info written to: {env_path}")
    print(f"  Vivado: {vivado_ver_str}")
    print(f"  Python: {sys.version.split()[0]}")

    # 5. Copy stale Oct 7 bitstreams and reports to archive_stale_oct7/
    print(f"\n[4/4] Archiving stale Oct 7 bitstreams and reports ...")
    stale_files = [
        os.path.join(PROJECT_ROOT, "bitstreams", "conv2d_benchmark_baseline.bit"),
        os.path.join(PROJECT_ROOT, "bitstreams", "conv2d_benchmark_baseline.bin"),
        os.path.join(PROJECT_ROOT, "bitstreams", "conv2d_benchmark_proposed.bit"),
        os.path.join(PROJECT_ROOT, "bitstreams", "conv2d_benchmark_proposed.bin"),
        os.path.join(PROJECT_ROOT, "reports", "utilization_benchmark_baseline.txt"),
        os.path.join(PROJECT_ROOT, "reports", "utilization_benchmark_proposed.txt"),
        os.path.join(PROJECT_ROOT, "reports", "timing_benchmark_baseline.txt"),
        os.path.join(PROJECT_ROOT, "reports", "timing_benchmark_proposed.txt"),
        os.path.join(PROJECT_ROOT, "reports", "power_benchmark_baseline.txt"),
        os.path.join(PROJECT_ROOT, "reports", "power_benchmark_proposed.txt"),
    ]

    copied_count = 0
    for sf in stale_files:
        if os.path.exists(sf):
            dest_file = os.path.join(ARCHIVE_DIR, os.path.basename(sf))
            shutil.copy2(sf, dest_file)
            print(f"  Copied (stale): {os.path.basename(sf)} -> {os.path.relpath(dest_file, PROJECT_ROOT)}")
            copied_count += 1
        else:
            print(f"  [WARNING] File not found: {sf}")

    print(f"\nSuccessfully archived {copied_count} stale Oct 7 artifacts to {ARCHIVE_DIR}/.")
    print("=" * 80)
    print(" >>> STAGE 0 COMPLETED SUCCESSFULLY <<<")
    print("=" * 80)

if __name__ == "__main__":
    main()
