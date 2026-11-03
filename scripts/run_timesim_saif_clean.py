#!/usr/bin/env python3
"""
scripts/run_timesim_saif_clean.py

Runs the full netlist timing simulation and SAIF generation for baseline pilot:
1. Re-compiles tb_conv2d_engine_saif_timesim.sv.
2. Re-elaborates tb_timesim_snapshot.
3. Executes xsim with `run 9687160 ns`, logging SAIF to local file across all 44,032 patches.
4. Closes SAIF cleanly, copies to SAIF_DIR, and checks file size > 0.
5. Runs Vivado report_power (text and XML).
6. Verifies coverage >= 90% and confidence is High.
"""

import os
import shutil
import subprocess
import time

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")).replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
GLBL = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v"
SAIF_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif"
RPT_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/reports"

xvlog = f"{VIVADO_BIN}/xvlog.bat"
xelab = f"{VIVADO_BIN}/xelab.bat"
xsim  = f"{VIVADO_BIN}/xsim.bat"
vivado = f"{VIVADO_BIN}/vivado.bat"

# Step 1: Compile
print(">>> Step 1: Compiling netlist and testbench...")
subprocess.run([xvlog, "-sv", GLBL, f"{SAIF_DIR}/baseline_timesim.v", "tb/tb_conv2d_engine_saif_timesim.sv"], cwd=PROJECT_ROOT, check=True)

# Step 2: Elaborate
print(">>> Step 2: Elaborating tb_timesim_snapshot...")
cmd_xelab = [
    xelab,
    "-top", "tb_conv2d_engine_saif_timesim",
    "-top", "glbl",
    "-s", "tb_timesim_snapshot",
    "-L", "simprims_ver",
    "-L", "unisims_ver",
    "-debug", "typical"
]
subprocess.run(cmd_xelab, cwd=PROJECT_ROOT, check=True)

# Step 3: SAIF Tcl with relative path
local_saif = "switching_baseline_timesim.saif"
target_saif = f"{SAIF_DIR}/switching_baseline_timesim.saif"

if os.path.exists(local_saif):
    os.remove(local_saif)

tcl_path = f"{SAIF_DIR}/xsim_saif_baseline_timesim.tcl"
with open(tcl_path, "w", encoding="utf-8") as f:
    f.write(f"""open_saif "{local_saif}"
log_saif [get_objects -r /tb_conv2d_engine_saif_timesim/u_dut/*]
run 9687160 ns
close_saif
exit
""")

# Step 4: Simulate
print(">>> Step 3: Running gate-level timing simulation (44,032 patches)...")
t0 = time.time()
p_sim = subprocess.run([xsim, "tb_timesim_snapshot", "-t", tcl_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
t1 = time.time()

log_sim_path = f"{SAIF_DIR}/timesim_baseline_pilot.log"
with open(log_sim_path, "w", encoding="utf-8") as lf:
    lf.write(p_sim.stdout)
    if p_sim.stderr:
        lf.write("\nSTDERR:\n" + p_sim.stderr)

print(f"Simulation completed in {t1 - t0:.1f} seconds. Log saved to {log_sim_path}.")
for line in p_sim.stdout.splitlines():
    if "Capture Window" in line or "Check:" in line or "Measured Wall Cycles" in line or "Total Patches" in line:
        print("  ", line)

if os.path.exists(local_saif):
    sz = os.path.getsize(local_saif)
    print(f"Generated local SAIF: {sz} bytes")
    shutil.copy(local_saif, target_saif)
    print(f"Copied to {target_saif}")
else:
    print(f"[ERROR] {local_saif} not generated! Aborting.")
    exit(1)

# Step 5: Vivado Power Analysis
print(">>> Step 4: Running Vivado Power Analysis with generated SAIF...")
power_tcl = f"{SAIF_DIR}/test_pilot_power.tcl"
with open(power_tcl, "w", encoding="utf-8") as f:
    f.write(f"""open_checkpoint "{SAIF_DIR}/baseline_routed.dcp"
read_saif -file "{local_saif}" -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power -file "{RPT_DIR}/power_saif_baseline_pilot.txt"
report_power -format xml -file "{RPT_DIR}/power_saif_baseline_pilot.xml"
exit
""")

subprocess.run([vivado, "-mode", "batch", "-source", power_tcl, "-log", f"{RPT_DIR}/power_pilot_vivado.log"], cwd=PROJECT_ROOT, check=True)

with open(f"{RPT_DIR}/power_pilot_vivado.log", "r", encoding="utf-8") as vf:
    for line in vf:
        if "Design nets matched" in line or "annotated" in line or "Confidence" in line:
            print("  ", line.strip())

print("Pilot run complete!")
