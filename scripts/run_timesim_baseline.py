import os
import shutil
import subprocess
import time

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")).replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
SAIF_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif"
RPT_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/reports"

xsim = f"{VIVADO_BIN}/xsim.bat"
vivado = f"{VIVADO_BIN}/vivado.bat"

local_saif = "switching_baseline_timesim.saif"
target_saif = f"{SAIF_DIR}/switching_baseline_timesim.saif"
log_path = f"{RPT_DIR}/power_pilot_vivado.log"
txt_rpt = f"{RPT_DIR}/power_saif_baseline_pilot.txt"
xml_rpt = f"{RPT_DIR}/power_saif_baseline_pilot.xml"

# Cleanup old files
for f in [local_saif, target_saif, log_path, txt_rpt, xml_rpt]:
    if os.path.exists(f):
        os.remove(f)

# Step 1: Run xsim timing simulation
tcl_path = "results/final_run_20261030_1056/saif/xsim_saif_baseline_timesim.tcl"
t0 = time.time()
print("Starting xsim timing simulation for baseline netlist (44,032 patches)...")
p = subprocess.run([xsim, "tb_timesim_snapshot", "-t", tcl_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
t1 = time.time()
print(p.stdout)
if p.returncode != 0:
    print("xsim failed:\n", p.stderr)
    exit(1)
else:
    print(f"Timing simulation finished in {t1 - t0:.1f} seconds.")

# Step 2: Check generated SAIF in project root and move to SAIF_DIR
if os.path.exists(local_saif):
    sz = os.path.getsize(local_saif)
    print(f"Generated {local_saif}: {sz} bytes")
    shutil.move(local_saif, target_saif)
    print(f"Moved to {target_saif}")
else:
    print(f"[ERROR] {local_saif} not found!")
    exit(1)

# Step 3: Run Vivado Power Analysis
print("Running Vivado Power Report on baseline netlist...")
power_tcl = f"{SAIF_DIR}/test_pilot_power.tcl"
with open(power_tcl, "w", encoding="utf-8") as f:
    f.write(f"""open_checkpoint "{SAIF_DIR}/baseline_routed.dcp"
read_saif -file "{target_saif}" -strip_path tb_conv2d_engine_saif_timesim/u_dut
report_power -file "{txt_rpt}"
report_power -format xml -file "{xml_rpt}"
exit
""")

p_viv = subprocess.run([vivado, "-mode", "batch", "-source", power_tcl, "-log", log_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
print("Vivado power stdout:\n", p_viv.stdout)

if os.path.exists(log_path):
    with open(log_path, "r", encoding="utf-8") as vf:
        for line in vf:
            if "Design nets matched" in line or "annotated" in line or "Confidence" in line:
                print("  ", line.strip())

print("Pilot run COMPLETE!")
