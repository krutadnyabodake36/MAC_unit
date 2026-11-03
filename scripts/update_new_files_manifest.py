import hashlib
import os

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MANIFEST = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "manifest_new_files_sha256.txt")

new_files = [
    # RTL source additions
    "src/conv2d_serial_oi_cg.sv",
    "src/conv2d_serial_zs_oi.sv",
    "src/conv2d_serial_zs_cg.sv",
    "src/conv2d_serial_static_sobel.sv",
    "src/conv2d_benchmark_top_ablation.sv",
    "src/conv2d_benchmark_top_static.sv",
    "src/conv2d_engine_wrapper.sv",
    "src/conv2d_engine_wrapper_v2.sv",
    # Testbench additions
    "tb/tb_cycle_measurement_8var.sv",
    "tb/tb_cycle_measurement_static.sv",
    "tb/tb_image_workloads_8var.sv",
    "tb/tb_conv2d_engine_saif.sv",
    "tb/tb_conv2d_engine_saif_timesim.sv",
    "tb/tb_conv2d_engine_saif_timesim_v2.sv",
    "tb/tb_conv2d_engine_part_c_saif_v2.sv",
    "tb/tb_uart_board_path_check.sv",
    "tb/tb_part_c_dual_rules.sv",
    # Scripts additions
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
    # Root additions/modifications (documented per C1)
    "fpga_vision_profiler.py",
    "image2.jpg",
]

lines = [
    "# SHA-256 Manifest for Newly Created and Modified Files\n",
    "# Format: SHA256  REL_PATH\n",
    "-" * 80 + "\n",
]

for rel in new_files:
    full = os.path.join(PROJECT_ROOT, rel.replace("/", os.sep))
    if os.path.exists(full):
        with open(full, "rb") as f:
            h = hashlib.sha256(f.read()).hexdigest()
        lines.append(f"{h}  {rel}\n")
    else:
        print(f"[WARNING] File not found: {rel}")

with open(MANIFEST, "w", encoding="utf-8") as f:
    f.writelines(lines)

print(f"Updated {MANIFEST} with {len(lines) - 3} files.")
