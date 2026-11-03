import glob

# Files in natural order
natural_files = [
    "results/final_run_20261030_1056/vectors/image1.vec",
    "results/final_run_20261030_1056/vectors/image2.vec",
    "results/final_run_20261030_1056/vectors/image3.vec",
    "results/final_run_20261030_1056/vectors/image4.vec",
]

# Files in rotated order
rotated_files = [
    "results/final_run_20261030_1056/vectors/image2.vec",
    "results/final_run_20261030_1056/vectors/image3.vec",
    "results/final_run_20261030_1056/vectors/image4.vec",
    "results/final_run_20261030_1056/vectors/image1.vec",
]

def load_patches(file_list):
    patches = []
    for f in file_list:
        with open(f, "r") as fp:
            for line in fp:
                line = line.strip()
                if line:
                    patches.append(line)
    return patches

nat_patches = load_patches(natural_files)
rot_patches = load_patches(rotated_files)

print(f"Natural total patches: {len(nat_patches)}")
print(f"Rotated total patches: {len(rot_patches)}")

# A patch transition is a pair of consecutive patches (p_i, p_{i+1})
nat_transitions = set()
nat_trans_list = []
for i in range(len(nat_patches) - 1):
    t = (nat_patches[i], nat_patches[i+1])
    nat_transitions.add(t)
    nat_trans_list.append(t)

rot_transitions = set()
rot_trans_list = []
for i in range(len(rot_patches) - 1):
    t = (rot_patches[i], rot_patches[i+1])
    rot_transitions.add(t)
    rot_trans_list.append(t)

print(f"Total patch-to-patch transitions in natural order: {len(nat_trans_list)}")
print(f"Total patch-to-patch transitions in rotated order: {len(rot_trans_list)}")

# How many transitions in rotated order are NOT in natural order?
unique_to_rot = [t for t in rot_trans_list if t not in nat_transitions]
unique_to_nat = [t for t in nat_trans_list if t not in rot_transitions]

print(f"Transitions in rotated order that do not occur in natural order: {len(unique_to_rot)}")
print(f"Transitions in natural order that do not occur in rotated order: {len(unique_to_nat)}")

# Positional transition differences:
pos_diffs = sum(1 for i in range(len(nat_trans_list)) if nat_trans_list[i] != rot_trans_list[i])
print(f"Transitions differing by exact temporal sequence position: {pos_diffs} of {len(nat_trans_list)}")

