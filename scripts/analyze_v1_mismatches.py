#!/usr/bin/env python3
"""
scripts/analyze_v1_mismatches.py
Analyzes the 1,427 mismatches in the legacy v1 wrapper simulation.
Evaluates mask transitions and verifies correlation with mask-change patches.
"""

import os

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

natural_files = [
    os.path.join(PROJECT_ROOT, "results/final_run_20261030_1056/vectors/image1.vec"),
    os.path.join(PROJECT_ROOT, "results/final_run_20261030_1056/vectors/image2.vec"),
    os.path.join(PROJECT_ROOT, "results/final_run_20261030_1056/vectors/image3.vec"),
    os.path.join(PROJECT_ROOT, "results/final_run_20261030_1056/vectors/image4.vec")
]

patches = []
for nf in natural_files:
    with open(nf, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                tokens = list(map(int, line.split()))
                w = tokens[0:9]
                p = tokens[9:18]
                g = tokens[18]
                patches.append((w, p, g))

def get_mask(w, p):
    m = 0
    for i in range(9):
        if w[i] != 0 and p[i] != 0:
            m |= (1 << i)
    return m

mismatches = 0
mask_changed_count = 0
mismatch_and_mask_changed = 0
mismatch_and_mask_same = 0
mask_changed_and_no_mismatch = 0

prev_mask = 0

for idx, (w, p, g) in enumerate(patches):
    curr_mask = get_mask(w, p)
    mask_changed = (curr_mask != prev_mask)
    if mask_changed:
        mask_changed_count += 1
    
    # In wrapper v1, remaining was initialized with prev_mask due to 0-cycle start assertion
    remaining = prev_mask
    if remaining == 0:
        actual = 0
    else:
        accum = 0
        for tap in range(9):
            if (remaining & (1 << tap)) != 0:
                accum += w[tap] * p[tap]
        actual = accum
    
    if actual != g:
        mismatches += 1
        if mask_changed:
            mismatch_and_mask_changed += 1
        else:
            mismatch_and_mask_same += 1
    else:
        if mask_changed:
            mask_changed_and_no_mismatch += 1
            
    prev_mask = curr_mask

print(f"Total Patches Evaluated                : {len(patches)}")
print(f"Total v1 Mismatches                    : {mismatches}")
print(f"Patches with nz_mask change            : {mask_changed_count}")
print(f"Mismatches coinciding with mask change : {mismatch_and_mask_changed} (of {mismatches})")
print(f"Mismatches with NO mask change         : {mismatch_and_mask_same}")
print(f"Mask change patches that did NOT mismatch: {mask_changed_and_no_mismatch}")

