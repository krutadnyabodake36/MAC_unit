#!/usr/bin/env python3
"""
scripts/collect_board_results.py
Packages board execution results from a board_results_<YYYYMMDD_HHMM>/ folder
into a single compressed deliverable zip archive with an integrity SHA-256 manifest.
"""

import os
import sys
import glob
import json
import zipfile
import hashlib
import datetime
import subprocess

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def package_tree(target_tree):
    target_tree = os.path.abspath(target_tree)
    if not os.path.isdir(target_tree):
        print(f"[ERROR] Target directory not found: {target_tree}")
        return None, None

    tree_name = os.path.basename(target_tree.rstrip("/\\"))
    zip_filename = os.path.join(PROJECT_ROOT, f"{tree_name}.zip")
    manifest_filename = os.path.join(target_tree, "manifest.sha256")

    print("=" * 80)
    print(f" >>> PACKAGING BOARD RESULTS TREE: {tree_name} <<<")
    print("=" * 80)

    # 1. Update summaries first
    sum_script = os.path.join(PROJECT_ROOT, "scripts", "generate_board_summaries.py")
    if os.path.exists(sum_script):
        try:
            subprocess.run(["python", sum_script, target_tree], check=False)
        except Exception as e:
            print(f"[WARNING] Summary script failed: {e}")

    # 2. Gather all files in the tree
    all_files = []
    for root, dirs, files in os.walk(target_tree):
        for f in files:
            full_p = os.path.join(root, f)
            rel_p = os.path.relpath(full_p, target_tree)
            if rel_p != "manifest.sha256":
                all_files.append((full_p, rel_p))

    all_files.sort(key=lambda x: x[1])

    # 3. Write manifest.sha256
    print(f"[1/2] Computing SHA-256 hashes for {len(all_files)} files...")
    manifest_lines = []
    for full_p, rel_p in all_files:
        h = sha256_file(full_p)
        manifest_lines.append(f"{h}  {rel_p.replace(os.sep, '/')}\n")

    with open(manifest_filename, "w", encoding="utf-8") as mf:
        mf.write(f"# BOARD RESULTS INTEGRITY MANIFEST\n# Generated: {datetime.datetime.now().isoformat()}\n")
        mf.writelines(manifest_lines)

    # Include manifest in zip
    all_files.append((manifest_filename, "manifest.sha256"))

    # 4. Zip the entire tree
    print(f"[2/2] Archiving into {zip_filename}...")
    with zipfile.ZipFile(zip_filename, "w", zipfile.ZIP_DEFLATED) as zf:
        for full_p, rel_p in all_files:
            arc_name = f"{tree_name}/{rel_p.replace(os.sep, '/')}"
            zf.write(full_p, arcname=arc_name)

    zip_size_mb = os.path.getsize(zip_filename) / (1024 * 1024)
    zip_sha = sha256_file(zip_filename)

    print("=" * 80)
    print(f"[SUCCESS] Packaging Complete:")
    print(f" Archive Deliverable : {zip_filename}")
    print(f" Archive Size (MB)   : {zip_size_mb:.2f} MB")
    print(f" Deliverable SHA256  : {zip_sha}")
    print("=" * 80)

    return zip_filename, zip_sha

def main():
    if len(sys.argv) > 1 and os.path.isdir(sys.argv[1]):
        target = sys.argv[1]
    else:
        # Search for newest board_results_* folder
        candidates = sorted(glob.glob(os.path.join(PROJECT_ROOT, "board_results_*")), reverse=True)
        if candidates and os.path.isdir(candidates[0]):
            target = candidates[0]
        else:
            print("[ERROR] No board_results_* folder found to package.")
            return

    package_tree(target)

if __name__ == "__main__":
    main()
