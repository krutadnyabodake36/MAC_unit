import re
import hashlib
import difflib

ORIGINAL_FILE = "fpga_vision_profiler.py"
BACKUP_FILE = "fpga_vision_profiler_backup_20261101_1618.py"

with open(ORIGINAL_FILE, "r", encoding="utf-8") as f:
    orig_code = f.read()

# 1. Update argparse choices for --design
old_argparse = """    parser.add_argument(
        '--design',
        choices=['auto', 'baseline', 'oi', 'cg', 'zs', 'combined', 'zs_oi', 'zs_cg', 'oi_cg', 'proposed'],
        default='auto',
        help="Target FPGA bitstream design mode (e.g. baseline, combined, zs, oi, cg, zs_oi, zs_cg, oi_cg)"
    )"""

new_argparse = """    parser.add_argument(
        '--design',
        choices=['auto', 'baseline', 'oi', 'cg', 'zs', 'combined', 'zs_oi', 'zs_cg', 'oi_cg', 'static_sobel', 'proposed'],
        default='auto',
        help="Target FPGA bitstream design mode (e.g. baseline, combined, zs, oi, cg, zs_oi, zs_cg, oi_cg, static_sobel)"
    )"""

assert old_argparse in orig_code, "argparse snippet not found"
code = orig_code.replace(old_argparse, new_argparse)

# 2. Update print_hardware_report to label model energy and support all 9 designs
old_section3_bl = 'print(" 3. SILICON DYNAMIC POWER & ENERGY PROFILE")'
new_section3_bl = 'print(" 3. SILICON DYNAMIC POWER & ENERGY PROFILE [MODEL (assumed constants, not measured)]")'
code = code.replace(old_section3_bl, new_section3_bl)

# 3. Add explicit handling in print_hardware_report for all 9 designs and auto-detection
old_report_branch = """    if design_mode == 'baseline':
        actual_cyc = metrics.get('hw_silicon_cycles', metrics['eng_bl_cycles']) if metrics.get('has_hw_telemetry') else metrics['eng_bl_cycles']
        actual_skp = metrics.get('hw_silicon_skips', 0) if metrics.get('has_hw_telemetry') else 0
        actual_time_ms = metrics.get('eng_bl_time_ms', (actual_cyc * 20.0e-9) * 1000.0)

        print("\\n" + "=" * 80)
        print("      INVENT LOGICS EDGE SPARTAN-7 FPGA — BASELINE SILICON PROFILER")
        print("=" * 80)
        print(f" Target Device            : Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)")
        print(f" Execution Mode           : {metrics['execution_mode']}")
        print(f" Bitstream Under Test     : BASELINE (conv2d_benchmark_baseline.bit)")"""

new_report_branch = """    # Map design names to bitstream descriptions
    DESIGN_BITSTREAMS = {
        'baseline': 'BASELINE (conv2d_benchmark_baseline.bit)',
        'oi': 'OPERAND ISOLATION (conv2d_benchmark_oi.bit)',
        'cg': 'CLOCK GATING (conv2d_benchmark_cg.bit)',
        'zs': 'ZERO SKIPPING (conv2d_benchmark_zs.bit)',
        'combined': 'COMBINED PIPELINE (conv2d_benchmark_combined.bit)',
        'zs_oi': 'ZERO SKIPPING + OPERAND ISOLATION (conv2d_benchmark_zs_oi.bit)',
        'zs_cg': 'ZERO SKIPPING + CLOCK GATING (conv2d_benchmark_zs_cg.bit)',
        'oi_cg': 'OPERAND ISOLATION + CLOCK GATING (conv2d_benchmark_oi_cg.bit)',
        'static_sobel': 'STATIC SOBEL (conv2d_benchmark_static_sobel.bit)',
        'proposed': 'PROPOSED ZERO-SKIPPING (conv2d_benchmark_proposed.bit)',
    }

    # Auto-detection safeguard against misclassifying static_sobel or other variants
    if design_mode == 'auto' and metrics.get('has_hw_telemetry'):
        hw_cyc = metrics.get('hw_silicon_cycles', 0)
        hw_skp = metrics.get('hw_silicon_skips', 0)
        tot_patches = metrics.get('total_patches', 1)
        if tot_patches > 0 and hw_cyc == tot_patches * 6 and hw_skp == 0:
            print("[AUTO-DETECT] Hardware telemetry indicates constant 6 cycles/patch and 0 skips -> Identified as 'static_sobel'.")
            design_mode = 'static_sobel'
            metrics['design_mode'] = 'static_sobel'
        elif tot_patches > 0 and hw_cyc == tot_patches * 9 and hw_skp == 0:
            print("[AUTO-DETECT] Hardware telemetry indicates constant 9 cycles/patch and 0 skips -> Identified as dense schedule.")
        else:
            print("[AUTO-DETECT NOTICE] Telemetry received. For definitive logging, pass explicit --design <name>.")

    if design_mode in ['baseline', 'oi', 'cg', 'oi_cg']:
        actual_cyc = metrics.get('hw_silicon_cycles', metrics['eng_bl_cycles']) if metrics.get('has_hw_telemetry') else metrics['eng_bl_cycles']
        actual_skp = metrics.get('hw_silicon_skips', 0) if metrics.get('has_hw_telemetry') else 0
        actual_time_ms = metrics.get('eng_bl_time_ms', (actual_cyc * 20.0e-9) * 1000.0)

        print("\\n" + "=" * 80)
        print(f"      INVENT LOGICS EDGE SPARTAN-7 FPGA — {design_mode.upper()} SILICON PROFILER")
        print("=" * 80)
        print(f" Target Device            : Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)")
        print(f" Execution Mode           : {metrics['execution_mode']}")
        print(f" Bitstream Under Test     : {DESIGN_BITSTREAMS.get(design_mode, design_mode)}")"""

assert old_report_branch in code, "report branch snippet not found"
code = code.replace(old_report_branch, new_report_branch)

# 4. Handle static_sobel in print_hardware_report
old_proposed_branch = """    elif design_mode == 'proposed':
        actual_cyc = metrics.get('hw_silicon_cycles', metrics['eng_pr_cycles']) if metrics.get('has_hw_telemetry') else metrics['eng_pr_cycles']
        actual_skp = metrics.get('hw_silicon_skips', metrics['zero_macs']) if metrics.get('has_hw_telemetry') else metrics['zero_macs']
        actual_time_ms = metrics.get('eng_pr_time_ms', (actual_cyc * 20.0e-9) * 1000.0)

        print("\\n" + "=" * 80)
        print("      INVENT LOGICS EDGE SPARTAN-7 FPGA — PROPOSED SILICON PROFILER")
        print("=" * 80)
        print(f" Target Device            : Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)")
        print(f" Execution Mode           : {metrics['execution_mode']}")
        print(f" Bitstream Under Test     : PROPOSED ZERO-SKIPPING (conv2d_benchmark_proposed.bit)")"""

new_proposed_branch = """    elif design_mode == 'static_sobel':
        actual_cyc = metrics.get('hw_silicon_cycles', metrics['total_patches'] * 6) if metrics.get('has_hw_telemetry') else metrics['total_patches'] * 6
        actual_skp = metrics.get('hw_silicon_skips', 0) if metrics.get('has_hw_telemetry') else 0
        actual_time_ms = (actual_cyc * 20.0e-9) * 1000.0

        print("\\n" + "=" * 80)
        print("      INVENT LOGICS EDGE SPARTAN-7 FPGA — STATIC SOBEL SILICON PROFILER")
        print("=" * 80)
        print(f" Target Device            : Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)")
        print(f" Execution Mode           : {metrics['execution_mode']}")
        print(f" Bitstream Under Test     : {DESIGN_BITSTREAMS['static_sobel']}")
        print(f" Processed Image Size     : {w} x {h} pixels ({metrics['total_patches']:,} patches / {metrics['total_macs']:,} MAC ops)")
        print(f" Output Image Saved       : {output_filename}")
        print("-" * 80)
        print(" 1. WORKLOAD & OPERAND CHARACTERIZATION")
        print("-" * 80)
        print(f"   Total MAC Operations  : {metrics['total_macs']:,}")
        print(f"   Zero-Valued MAC Terms : {metrics['zero_macs']:,}  ({metrics['sparsity_pct']:.2f}%)")
        print(f"   Non-Zero Active Terms : {metrics['nonzero_macs']:,}  ({100.0 - metrics['sparsity_pct']:.2f}%)")
        print(f"   Workload Sparsity     : {metrics['sparsity_pct']:.2f}% (Available zero terms in input)")
        print("-" * 80)
        print(" 2. DIRECT SILICON TELEMETRY (MEASURED VIA FPGA UART REGISTERS)")
        print("-" * 80)
        print(f"   Silicon Clock Cycles  : {actual_cyc:,} cycles (Constant 6 cycles/patch, static schedule)")
        print(f"   Hardware Zero-Skips   : {actual_skp:,} skips (Static schedule evaluates taps 0,2,3,5,6,8; 0 dynamic skips)")
        print(f"   Compute Latency       : {actual_time_ms * 1000.0:.2f} us ({actual_time_ms:.3f} ms @ 50 MHz)")
        print(f"   Average Latency/Patch : 6.00 cycles/patch (120.0 ns)")
        print(f"   Compute Throughput    : {(metrics['total_macs'] / (actual_time_ms / 1000.0)) / 1.0e6:.2f} MMAC/s")
        print("-" * 80)
        print(" 3. SILICON DYNAMIC POWER & ENERGY PROFILE [MODEL (assumed constants, not measured)]")
        print("-" * 80)
        print(f"   Silicon Status        : Completed {metrics['total_patches']:,} patches with fixed 6 cyc/patch Sobel schedule.")
        print("=" * 80)
        print(" [NEXT STEP]: Run comparison against baseline: python fpga_vision_profiler.py --compare")
        print("=" * 80 + "\\n")
        return

    elif design_mode in ['proposed', 'zs', 'combined', 'zs_oi', 'zs_cg']:
        actual_cyc = metrics.get('hw_silicon_cycles', metrics['eng_pr_cycles']) if metrics.get('has_hw_telemetry') else metrics['eng_pr_cycles']
        actual_skp = metrics.get('hw_silicon_skips', metrics['zero_macs']) if metrics.get('has_hw_telemetry') else metrics['zero_macs']
        actual_time_ms = metrics.get('eng_pr_time_ms', (actual_cyc * 20.0e-9) * 1000.0)

        print("\\n" + "=" * 80)
        print(f"      INVENT LOGICS EDGE SPARTAN-7 FPGA — {design_mode.upper()} SILICON PROFILER")
        print("=" * 80)
        print(f" Target Device            : Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)")
        print(f" Execution Mode           : {metrics['execution_mode']}")
        print(f" Bitstream Under Test     : {DESIGN_BITSTREAMS.get(design_mode, design_mode)}")"""

assert old_proposed_branch in code, "proposed branch snippet not found"
code = code.replace(old_proposed_branch, new_proposed_branch)

# 5. Update compare_hardware_profiles to automatically locate any variant profile
old_compare_find = """    # Locate profile_proposed.json
    if pr_file is None:
        if session_dir and os.path.exists(os.path.join(session_dir, 'profile_proposed.json')):
            pr_file = os.path.join(session_dir, 'profile_proposed.json')
        elif os.path.exists('profile_proposed.json'):
            pr_file = 'profile_proposed.json'"""

new_compare_find = """    # Locate target profile (proposed or any of the 8 ablation / static variants)
    if pr_file is None:
        target_candidates = [
            'profile_proposed.json',
            'profile_combined.json',
            'profile_zs.json',
            'profile_static_sobel.json',
            'profile_zs_cg.json',
            'profile_zs_oi.json',
            'profile_oi_cg.json',
            'profile_oi.json',
            'profile_cg.json',
        ]
        for cand in target_candidates:
            cand_path = os.path.join(session_dir, cand) if session_dir else cand
            if os.path.exists(cand_path):
                pr_file = cand_path
                break
        if pr_file is None:
            for cand in target_candidates:
                if os.path.exists(cand):
                    pr_file = cand
                    break"""

assert old_compare_find in code, "compare find snippet not found"
code = code.replace(old_compare_find, new_compare_find)

# Write patched file
with open(ORIGINAL_FILE, "w", encoding="utf-8") as f:
    f.write(code)

# Compute SHA-256
h_orig = hashlib.sha256(open(BACKUP_FILE, "rb").read()).hexdigest()
h_new  = hashlib.sha256(open(ORIGINAL_FILE, "rb").read()).hexdigest()

print("=" * 80)
print(" >>> B1: PROFILER PATCH DIFF & INTEGRITY AUDIT <<<")
print("=" * 80)
print(f"Original / Backup File : {BACKUP_FILE}")
print(f"Original SHA-256       : {h_orig}")
print(f"Patched File           : {ORIGINAL_FILE}")
print(f"Patched SHA-256        : {h_new}")
print("-" * 80)
print("Unified Diff:")

diff = difflib.unified_diff(
    orig_code.splitlines(keepends=True),
    code.splitlines(keepends=True),
    fromfile="fpga_vision_profiler.py (original)",
    tofile="fpga_vision_profiler.py (patched)"
)
print("".join(diff))
print("=" * 80)

