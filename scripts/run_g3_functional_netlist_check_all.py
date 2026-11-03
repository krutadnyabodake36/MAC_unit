#!/usr/bin/env python3
# =============================================================================
# File: scripts/run_g3_functional_netlist_check_all.py
# Description: Automated out-of-context implementation and zero-delay post-implementation
#              functional netlist verification for all 9 architectural variants.
# Top: conv2d_engine_wrapper_v2
# Stimulus: 44,032 Sobel patches (image1..4 back-to-back)
# =============================================================================

import os
import sys
import subprocess
import time
import json
import shutil

VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")
VIVADO = os.path.join(VIVADO_BIN, "vivado.bat").replace("\\", "/")
GLBL   = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v".replace("\\", "/")

PROJECT_ROOT = os.path.abspath(r"C:\Users\Krutadnye\Downloads\Projects\MAC").replace("\\", "/")
NETLIST_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/netlists_v2"
FUNCSIM_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/funcsim_v2"
TB_SV = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_saif_timesim_v2.sv"

os.makedirs(NETLIST_DIR, exist_ok=True)
os.makedirs(FUNCSIM_DIR, exist_ok=True)

VARIANTS = [
    (0, "baseline"),
    (1, "oi"),
    (2, "cg"),
    (3, "zs"),
    (4, "combined"),
    (5, "zs_oi"),
    (6, "zs_cg"),
    (7, "oi_cg"),
    (8, "static_sobel")
]

results = []

for sel, name in VARIANTS:
    v_dir = f"{NETLIST_DIR}/{name}"
    os.makedirs(v_dir, exist_ok=True)
    routed_dcp  = f"{v_dir}/{name}_routed.dcp"
    funcsim_v   = f"{v_dir}/{name}_funcsim.v"
    timesim_v   = f"{v_dir}/{name}_timesim.v"
    timesim_sdf = f"{v_dir}/{name}_timesim.sdf"

    print(f"\n================================================================================")
    print(f" >>> [G3 CHECK] VARIANT {sel}: {name.upper()} <<<")
    print(f"================================================================================")

    # 1. Implementation if DCP missing
    if not (os.path.exists(routed_dcp) and os.path.exists(funcsim_v) and os.path.exists(timesim_v) and os.path.exists(timesim_sdf)):
        print(f">>> [1/3] Synthesizing, placing, and routing {name}...")
        tcl_code = f"""create_project -in_memory -part xc7s15ftgb196-1
add_files [list \\
    "{PROJECT_ROOT}/src/conv2d_serial_baseline.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_oi.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_cg.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_zs.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_zs_oi.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_zs_cg.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_oi_cg.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_combined.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_static_sobel.sv" \\
    "{PROJECT_ROOT}/src/conv2d_engine_wrapper_v2.sv" \\
]
set_property file_type SystemVerilog [get_files *.sv]
add_files -fileset constrs_1 "{PROJECT_ROOT}/scripts/temp_clk.xdc"

synth_design -top conv2d_engine_wrapper_v2 -part xc7s15ftgb196-1 -mode out_of_context -generic DESIGN_SELECT={sel}
opt_design
place_design
route_design

write_checkpoint -force "{routed_dcp}"
write_verilog -mode funcsim -force "{funcsim_v}"
write_verilog -mode timesim -sdf_anno true -force "{timesim_v}"
write_sdf -force "{timesim_sdf}"
exit
"""
        build_tcl = f"{v_dir}/build_{name}.tcl"
        with open(build_tcl, "w", encoding="utf-8") as f:
            f.write(tcl_code)
        
        t0 = time.time()
        res = subprocess.run([VIVADO, "-mode", "batch", "-source", build_tcl], cwd=PROJECT_ROOT, check=True)
        print(f"Implementation completed in {time.time()-t0:.2f} s")
    else:
        print(f">>> [1/3] Reusing existing routed netlists for {name}.")

    # 2. Compile simulation
    print(f">>> [2/3] Compiling {funcsim_v} with {TB_SV}...")
    snap = f"snap_funcsim_{name}"
    subprocess.run([XVLOG, "-sv", GLBL, funcsim_v, TB_SV], cwd=PROJECT_ROOT, check=True)
    subprocess.run([
        XELAB,
        "-top", "tb_conv2d_engine_saif_timesim_v2",
        "-top", "glbl",
        "-s", snap,
        "-L", "simprims_ver",
        "-L", "unisims_ver",
        "-debug", "typical"
    ], cwd=PROJECT_ROOT, check=True)

    # 3. Simulate
    print(f">>> [3/3] Simulating zero-delay functional netlist for {name} (44,032 Sobel patches)...")
    t0 = time.time()
    r = subprocess.run([XSIM, snap, "-R"], cwd=PROJECT_ROOT, capture_output=True, text=True)
    sim_time = time.time() - t0
    print(f"Simulation completed in {sim_time:.2f} s")
    print(r.stdout)

    summary_file = f"{PROJECT_ROOT}/run_summary.json"
    if not os.path.exists(summary_file):
        print(f"[FATAL ERROR] {summary_file} was not generated!")
        sys.exit(1)

    with open(summary_file, "r") as sf:
        summary_data = json.load(sf)

    summary_data["variant"] = name
    summary_data["design_select"] = sel
    summary_data["sim_elapsed_sec"] = sim_time
    summary_data["cycles_per_patch"] = summary_data["measured_wall_cycles"] / summary_data["total_patches"]

    # Save variant summary
    shutil.copy2(summary_file, f"{FUNCSIM_DIR}/{name}_summary.json")
    results.append(summary_data)

    if summary_data["total_mismatches"] != 0:
        print(f"[FATAL ERROR] Variant {name} produced {summary_data['total_mismatches']} mismatches! STOPPING.")
        sys.exit(1)
    else:
        print(f">>> [PASS] Variant {name}: 100% Bit-Exact Match (0 mismatches across {summary_data['total_patches']} patches)")
        print(f"    Wall Cycles: {summary_data['measured_wall_cycles']} ({summary_data['cycles_per_patch']:.4f} cyc/patch)")

# Write overall summary
all_summary_path = f"{FUNCSIM_DIR}/summary_functional_check.json"
with open(all_summary_path, "w", encoding="utf-8") as f:
    json.dump(results, f, indent=2)

md_path = f"{FUNCSIM_DIR}/summary_functional_check.md"
with open(md_path, "w", encoding="utf-8") as f:
    f.write("# G3 Post-Implementation Functional Netlist Verification Summary\n\n")
    f.write("Target: Spartan-7 XC7S15 @ 50 MHz  \n")
    f.write("Wrapper: `conv2d_engine_wrapper_v2.sv` (with 1-cycle operand settling pipeline)  \n")
    f.write("Stimulus: 44,032 back-to-back real Sobel image patches (image1..4)  \n\n")
    f.write("| Variant Index | Architecture Name | Total Patches | Total Mismatches | Measured Wall Cycles | Wall Cycles / Patch | Status |\n")
    f.write("|---|---|---|---|---|---|---|\n")
    for r in results:
        f.write(f"| {r['design_select']} | `{r['variant']}` | {r['total_patches']} | {r['total_mismatches']} | {r['measured_wall_cycles']} | {r['cycles_per_patch']:.4f} | **{r['status'].strip()}** |\n")

print(f"\n================================================================================")
print(f" >>> ALL 9 ARCHITECTURAL VARIANTS PASSED FUNCTIONAL VERIFICATION (0 MISMATCHES) <<<")
print(f" Summary saved to: {all_summary_path} and {md_path}")
print(f"================================================================================")

