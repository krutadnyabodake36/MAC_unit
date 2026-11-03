import os
import subprocess
import shutil

PROJECT_ROOT = r"C:/Users/Krutadnye/Downloads/Projects/MAC".replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")
GLBL  = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v".replace("\\", "/")

v = f"{PROJECT_ROOT}/results/final_run_20261030_1056/netlists_v2/baseline/baseline_timesim.v"
sdf = f"{PROJECT_ROOT}/results/final_run_20261030_1056/netlists_v2/baseline/baseline_timesim.sdf"
shutil.copy2(sdf, f"{PROJECT_ROOT}/baseline_timesim.sdf")

print("[1/3] Running xvlog...")
subprocess.run([XVLOG, "-sv", GLBL, v, "tb/tb_baseline_sdf_audit.sv"], cwd=PROJECT_ROOT, check=True)

print("[2/3] Running xelab...")
r_elab = subprocess.run([XELAB, "-top", "tb_baseline_sdf_audit", "-top", "glbl", "-s", "snap_baseline_sdf_audit", 
                         "-L", "simprims_ver", "-L", "unisims_ver", "-debug", "typical"], 
                        cwd=PROJECT_ROOT, capture_output=True, text=True)
print(r_elab.stdout[-1000:])
if r_elab.returncode != 0:
    print(r_elab.stderr)
    exit(1)

print("[3/3] Launching xsim...")
# Run xsim and redirect output to baseline_sdf_audit.log
log_path = f"{PROJECT_ROOT}/baseline_sdf_audit.log"
with open(log_path, "w", encoding="utf-8") as out_f:
    r_sim = subprocess.run([XSIM, "snap_baseline_sdf_audit", "-R"], cwd=PROJECT_ROOT, stdout=out_f, stderr=subprocess.STDOUT, text=True)

print(f"Simulation finished with exit code {r_sim.returncode}")

