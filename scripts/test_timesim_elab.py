import os
import subprocess

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")).replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
GLBL = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v"

xvlog = f"{VIVADO_BIN}/xvlog.bat"
xelab = f"{VIVADO_BIN}/xelab.bat"

# 1. Compile
cmd_xvlog = [xvlog, "-sv", GLBL, "results/final_run_20261030_1056/saif/baseline_timesim.v", "tb/tb_conv2d_engine_saif_timesim.sv"]
p1 = subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, capture_output=True, text=True)
print("xvlog stdout:\n", p1.stdout)
if p1.returncode != 0:
    print("xvlog failed:\n", p1.stderr)
    exit(1)

# 2. Elaborate
cmd_xelab = [
    xelab,
    "-top", "tb_conv2d_engine_saif_timesim",
    "-top", "glbl",
    "-s", "tb_timesim_snapshot",
    "-L", "simprims_ver",
    "-L", "unisims_ver",
    "-debug", "typical"
]
p2 = subprocess.run(cmd_xelab, cwd=PROJECT_ROOT, capture_output=True, text=True)
print("xelab stdout:\n", p2.stdout)
if p2.returncode != 0:
    print("xelab failed:\n", p2.stderr)
    exit(1)

print("Elaboration SUCCESSFUL!")

