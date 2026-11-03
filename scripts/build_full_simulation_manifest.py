import os
import hashlib
import glob

PROJECT_ROOT = os.path.abspath(r"C:\Users\Krutadnye\Downloads\Projects\MAC").replace("\\", "/")
RUN_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056"
MANIFEST_PATH = f"{RUN_DIR}/manifest_full_simulation_run_sha256.txt"

def get_sha256(filepath):
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

all_files = []
for root, dirs, files in os.walk(RUN_DIR):
    for f in files:
        full_path = os.path.join(root, f).replace("\\", "/")
        if "manifest" in f:
            continue
        all_files.append(full_path)

all_files.sort()

lines = []
lines.append(f"# FROZEN COMPLETE SIMULATION MANIFEST (SHA-256)")
lines.append(f"# Generated: {os.path.basename(MANIFEST_PATH)}")
lines.append(f"# Total Tracked Artifacts: {len(all_files)}")
lines.append(f"# " + "=" * 90)

for fpath in all_files:
    rel_path = os.path.relpath(fpath, PROJECT_ROOT).replace("\\", "/")
    sha = get_sha256(fpath)
    size_b = os.path.getsize(fpath)
    lines.append(f"{sha}  {rel_path:85s}  ({size_b} bytes)")

with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print(f"Manifest successfully generated: {MANIFEST_PATH} ({len(all_files)} files)")

