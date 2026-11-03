import os
import subprocess
import time

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")).replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
SAIF_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif"
os.makedirs(SAIF_DIR, exist_ok=True)

# 1. Write xsim tcl batch script with forward slashes
tcl_path = f"{SAIF_DIR}/xsim_saif_baseline.tcl"
with open(tcl_path, "w", encoding="utf-8") as f:
    f.write(f"""open_saif "{SAIF_DIR}/switching_baseline.saif"
log_saif [get_objects -r /tb_conv2d_engine_saif/u_dut/*]
run all
close_saif
exit
""")

print("=" * 80)
print(" >>> COMPILING & RUNNING 44,032 PATCH SAIF SIMULATION (PILOT: BASELINE) <<<")
print("=" * 80)

xvlog = f"{VIVADO_BIN}/xvlog.bat"
xelab = f"{VIVADO_BIN}/xelab.bat"
xsim  = f"{VIVADO_BIN}/xsim.bat"

sources = [
    "src/conv2d_serial_baseline.sv",
    "src/conv2d_engine_wrapper.sv",
    "tb/tb_conv2d_engine_saif.sv"
]

t0 = time.time()
# 1. xvlog
p1 = subprocess.run([xvlog, "-sv"] + sources, cwd=PROJECT_ROOT, capture_output=True, text=True)
if p1.returncode != 0:
    print(p1.stdout)
    print(p1.stderr)
    exit(1)
print("  [1/3] xvlog compilation successful.")

# 2. xelab
p2 = subprocess.run([xelab, "-top", "tb_conv2d_engine_saif", "-s", "tb_saif_snapshot", "-debug", "typical"], cwd=PROJECT_ROOT, capture_output=True, text=True)
if p2.returncode != 0:
    print(p2.stdout)
    print(p2.stderr)
    exit(1)
print("  [2/3] xelab elaboration successful.")

# 3. xsim
print("  [3/3] Running xsim with SAIF dumping (44,032 patches)...")
p3 = subprocess.run([xsim, "tb_saif_snapshot", "-t", tcl_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
t1 = time.time()
print(p3.stdout)

if p3.returncode != 0:
    print(f"Error in xsim: {p3.stderr}")
    exit(1)

print(f"\nSimulation finished in {t1 - t0:.1f} seconds.")
