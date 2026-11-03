import os
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
OUT_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/netlists_v2/zs"
os.makedirs(OUT_DIR, exist_ok=True)

# 1. Implementation
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

synth_design -top conv2d_engine_wrapper_v2 -part xc7s15ftgb196-1 -mode out_of_context -generic DESIGN_SELECT=3
opt_design
place_design
route_design

write_checkpoint -force "{OUT_DIR}/zs_routed.dcp"
write_verilog -mode timesim -sdf_anno true -force "{OUT_DIR}/zs_timesim.v"
write_sdf -force "{OUT_DIR}/zs_timesim.sdf"
exit
"""
build_tcl = f"{OUT_DIR}/build_zs.tcl"
with open(build_tcl, "w", encoding="utf-8") as f:
    f.write(tcl_code)

print(">>> [1/3] Synthesizing, placing and routing conv2d_engine_wrapper_v2 (DESIGN_SELECT=3, ZS)...")
t0 = time.time()
subprocess.run([VIVADO, "-mode", "batch", "-source", build_tcl], cwd=PROJECT_ROOT, check=True)
print(f"Implementation completed in {time.time()-t0:.2f} s")

# 2. Compile simulation
print("\n>>> [2/3] Compiling netlist and tb_conv2d_engine_saif_timesim_v2.sv...")
tb_sv = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_saif_timesim_v2.sv"
subprocess.run([XVLOG, "-sv", GLBL, f"{OUT_DIR}/zs_timesim.v", tb_sv], cwd=PROJECT_ROOT, check=True)

subprocess.run([
    XELAB,
    "-top", "tb_conv2d_engine_saif_timesim_v2",
    "-top", "glbl",
    "-s", "snap_zs_v2_check",
    "-L", "simprims_ver",
    "-L", "unisims_ver",
    "-debug", "typical"
], cwd=PROJECT_ROOT, check=True)

# 3. Simulate
print("\n>>> [3/3] Running zero-delay functional netlist simulation (44,032 Sobel patches)...")
t0 = time.time()
r = subprocess.run([XSIM, "snap_zs_v2_check", "-R"], cwd=PROJECT_ROOT, capture_output=True, text=True)
print(f"Simulation completed in {time.time()-t0:.2f} s")
print(r.stdout)

# Check run_summary.json
if os.path.exists(f"{PROJECT_ROOT}/run_summary.json"):
    with open(f"{PROJECT_ROOT}/run_summary.json") as f:
        summary = json.load(f)
    print("\n>>> RUN SUMMARY JSON:")
    print(json.dumps(summary, indent=2))
    shutil.copy2(f"{PROJECT_ROOT}/run_summary.json", f"{OUT_DIR}/run_summary_funcsim.json")

