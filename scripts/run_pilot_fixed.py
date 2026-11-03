#!/usr/bin/env python3
"""
scripts/run_pilot_fixed.py

Compiles, elaborates, simulates, and runs SAIF power analysis on the baseline netlist
with the fixed negedge handshake in tb/tb_conv2d_engine_saif_timesim.sv.
Verifies the pilot window check against 484,352 cycles * 20 ns = 9,687,040 ns.
"""

import os
import subprocess
import time

PROJECT_ROOT = os.getcwd().replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
GLBL = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v"
SAIF_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif"
RPT_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/reports"

xvlog = f"{VIVADO_BIN}/xvlog.bat"
xelab = f"{VIVADO_BIN}/xelab.bat"
xsim  = f"{VIVADO_BIN}/xsim.bat"
vivado = f"{VIVADO_BIN}/vivado.bat"

# 1. Compile testbench and netlist
print(">>> Step 1: Compiling netlist and fixed testbench...")
subprocess.run([xvlog, "-sv", GLBL, f"{SAIF_DIR}/baseline_timesim.v", "tb/tb_conv2d_engine_saif_timesim.sv"], cwd=PROJECT_ROOT, check=True)

# 2. Elaborate snapshot
print(">>> Step 2: Elaborating simulation snapshot...")
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

# 3. Simulate with SAIF dump
tcl_path = f"{SAIF_DIR}/xsim_saif_baseline_timesim.tcl"
with open(tcl_path, "w", encoding="utf-8") as f:
    f.write(f"""open_saif "{SAIF_DIR}/switching_baseline_timesim.saif"
log_saif [get_objects -r /tb_conv2d_engine_saif_timesim/u_dut/*]
run all
close_saif
exit
""")

print(">>> Step 3: Running gate-level timing simulation (44,032 patches)...")
t0 = time.time()
p_sim = subprocess.run([xsim, "tb_timesim_snapshot", "-t", tcl_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
t1 = time.time()

log_sim_path = f"{SAIF_DIR}/timesim_baseline_pilot.log"
with open(log_sim_path, "w", encoding="utf-8") as lf:
    lf.write(p_sim.stdout)
    if p_sim.stderr:
        lf.write("\nSTDERR:\n" + p_sim.stderr)

print(f"Simulation completed in {t1 - t0:.1f} seconds. Output saved to {log_sim_path}.")

# Print window check lines
for line in p_sim.stdout.splitlines():
    if "Capture Window" in line or "Check:" in line or "Measured Wall Cycles" in line or "Total Patches" in line:
        print("  ", line)

# 4. Run Vivado SAIF Power Report
print(">>> Step 4: Running Vivado Power Analysis with new SAIF...")
power_tcl = f"{SAIF_DIR}/run_power_pilot.tcl"
with open(power_tcl, "w", encoding="utf-8") as f:
    f.write(f"""open_checkpoint "{SAIF_DIR}/baseline_routed.dcp"
read_saif -file "{SAIF_DIR}/switching_baseline_timesim.saif" -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power -file "{RPT_DIR}/power_saif_baseline_pilot.txt"
report_power -format xml -file "{RPT_DIR}/power_saif_baseline_pilot.xml"
exit
""")

subprocess.run([vivado, "-mode", "batch", "-source", power_tcl, "-log", f"{RPT_DIR}/power_pilot_vivado.log"], cwd=PROJECT_ROOT, check=True)
print("Power analysis complete! Reports saved to:")
print(f"  {RPT_DIR}/power_saif_baseline_pilot.txt")
print(f"  {RPT_DIR}/power_saif_baseline_pilot.xml")

