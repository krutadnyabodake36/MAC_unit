import difflib

with open("fpga_vision_profiler.py", "r", encoding="utf-8") as f:
    old_content = f.read()

content = old_content

# 1. In analyze_patch metrics dict
target1 = """            # Engine Metrics - Energy (Joules & uJ)
            'eng_bl_energy_uj': eng_bl_energy_uj,"""

replacement1 = """            'model_notice': 'MODEL (assumed constants, not measured on hardware)',
            # Engine Metrics - Energy (Joules & uJ) [MODEL]
            'eng_bl_energy_uj': eng_bl_energy_uj,"""
assert target1 in content, "target1 not found"
content = content.replace(target1, replacement1, 1)

# 2. In print_summary headers
target2 = """    print("-" * 80)
    print(" 2. TIER 1 COMPARISON: SINGLE MAC UNITS (Baseline vs Proposed mac_combined)")
    print("-" * 80)"""

replacement2 = """    print("-" * 80)
    print(" 2. TIER 1 COMPARISON: SINGLE MAC UNITS [MODEL (assumed constants, not measured)]")
    print("-" * 80)"""
assert target2 in content, "target2 not found"
content = content.replace(target2, replacement2, 1)

target3 = """    print(f"   {'Total Dynamic Energy (uJ)':<32} | {mac_bl_e:<18} | {mac_pr_e:<22}")
    print(f"   {'Total Dynamic Energy (J)':<32} | {mac_bl_e_j_str:<18} | {mac_pr_e_j_str:<22}")
    print(f"   {'Dynamic Power (mW)':<32} | {mac_bl_p_mw_str:<18} | {mac_pr_p_mw_str:<22}")
    print(f"   {'Dynamic Power (Watts)':<32} | {mac_bl_p_w_str:<18} | {mac_pr_p_w_str:<22}")"""

replacement3 = """    print(f"   {'Dynamic Energy (uJ) [MODEL]':<32} | {mac_bl_e:<18} | {mac_pr_e:<22}")
    print(f"   {'Dynamic Energy (J) [MODEL]':<32} | {mac_bl_e_j_str:<18} | {mac_pr_e_j_str:<22}")
    print(f"   {'Dynamic Power (mW) [MODEL]':<32} | {mac_bl_p_mw_str:<18} | {mac_pr_p_mw_str:<22}")
    print(f"   {'Dynamic Power (Watts) [MODEL]':<32} | {mac_bl_p_w_str:<18} | {mac_pr_p_w_str:<22}")"""
assert target3 in content, "target3 not found"
content = content.replace(target3, replacement3, 1)

target4 = """    print(f"   {'Total Dynamic Energy (uJ)':<32} | {eng_bl_e:<18} | {eng_pr_e:<22}")
    print(f"   {'Total Dynamic Energy (J)':<32} | {eng_bl_e_j_str:<18} | {eng_pr_e_j_str:<22}")
    print(f"   {'Dynamic Power (mW)':<32} | {eng_bl_p_mw_str:<18} | {eng_pr_p_mw_str:<22}")
    print(f"   {'Dynamic Power (Watts)':<32} | {eng_bl_p_w_str:<18} | {eng_pr_p_w_str:<22}")"""

replacement4 = """    print(f"   {'Dynamic Energy (uJ) [MODEL]':<32} | {eng_bl_e:<18} | {eng_pr_e:<22}")
    print(f"   {'Dynamic Energy (J) [MODEL]':<32} | {eng_bl_e_j_str:<18} | {eng_pr_e_j_str:<22}")
    print(f"   {'Dynamic Power (mW) [MODEL]':<32} | {eng_bl_p_mw_str:<18} | {eng_pr_p_mw_str:<22}")
    print(f"   {'Dynamic Power (Watts) [MODEL]':<32} | {eng_bl_p_w_str:<18} | {eng_pr_p_w_str:<22}")"""
assert target4 in content, "target4 not found"
content = content.replace(target4, replacement4, 1)

target5 = """    print("-" * 80)
    print(" 5. CROSS-ARCHITECTURE EXECUTIVE SUMMARY")
    print("-" * 80)"""

replacement5 = """    print("-" * 80)
    print(" 5. CROSS-ARCHITECTURE EXECUTIVE SUMMARY [MODEL (assumed constants, not measured)]")
    print("-" * 80)"""
assert target5 in content, "target5 not found"
content = content.replace(target5, replacement5, 1)

# 3. In compare_hardware_profiles
target6 = """    print(f" {'3. DYNAMIC ENERGY (JOULES & uJ)':<40} | {'':<22} | {'':<22} | {'':<16}")"""
replacement6 = """    print(f" {'3. DYNAMIC ENERGY [MODEL (assumed constants, not measured)]':<40} | {'':<22} | {'':<22} | {'':<16}")"""
assert target6 in content, "target6 not found"
content = content.replace(target6, replacement6, 1)

target7 = """    print(f" {'4. DYNAMIC POWER (WATTS & mW)':<40} | {'':<22} | {'':<22} | {'':<16}")"""
replacement7 = """    print(f" {'4. DYNAMIC POWER [MODEL (assumed constants, not measured)]':<40} | {'':<22} | {'':<22} | {'':<16}")"""
assert target7 in content, "target7 not found"
content = content.replace(target7, replacement7, 1)

target8 = """    print(f" {'5. ENERGY-DELAY PRODUCT (EDP)':<40} | {'':<22} | {'':<22} | {'':<16}")"""
replacement8 = """    print(f" {'5. ENERGY-DELAY PRODUCT [MODEL (assumed constants, not measured)]':<40} | {'':<22} | {'':<22} | {'':<16}")"""
assert target8 in content, "target8 not found"
content = content.replace(target8, replacement8, 1)

target9 = """    comp_data = {
        "session_directory": os.path.abspath(target_dir),"""
replacement9 = """    comp_data = {
        "model_notice": "MODEL (assumed constants, not measured on hardware)",
        "session_directory": os.path.abspath(target_dir),"""
assert target9 in content, "target9 not found"
content = content.replace(target9, replacement9, 1)

with open("fpga_vision_profiler.py", "w", encoding="utf-8") as f:
    f.write(content)

# Generate diff
old_lines = old_content.splitlines(keepends=True)
new_lines = content.splitlines(keepends=True)
diff = list(difflib.unified_diff(old_lines, new_lines, fromfile="a/fpga_vision_profiler.py", tofile="b/fpga_vision_profiler.py"))

diff_path = "results/final_run_20261030_1056/profiler_model_labels.diff"
with open(diff_path, "w", encoding="utf-8") as f:
    f.writelines(diff)

print(f"Applied minimal changes to fpga_vision_profiler.py.")
print(f"Diff written to {diff_path} ({len(diff)} lines).")

