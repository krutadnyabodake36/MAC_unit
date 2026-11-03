import os
import subprocess

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")).replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
GLBL = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v"

xvlog = f"{VIVADO_BIN}/xvlog.bat"
xelab = f"{VIVADO_BIN}/xelab.bat"

# Compile glbl and baseline_timesim.v
p1 = subprocess.run([xvlog, GLBL, "results/final_run_20261030_1056/saif/baseline_timesim.v"], cwd=PROJECT_ROOT, capture_output=True, text=True)
print("xvlog stdout:\n", p1.stdout)
print("xvlog stderr:\n", p1.stderr)
