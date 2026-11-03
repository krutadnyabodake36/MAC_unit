import os
import subprocess
import time

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")).replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
GLBL = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v"

xvlog = f"{VIVADO_BIN}/xvlog.bat"
xelab = f"{VIVADO_BIN}/xelab.bat"

# Elaborate with -notimingchecks
cmd_xelab = [
    xelab,
    "-top", "tb_conv2d_engine_saif_timesim",
    "-top", "glbl",
    "-s", "tb_timesim_fast_snapshot",
    "-L", "simprims_ver",
    "-L", "unisims_ver",
    "-notimingchecks",
    "-debug", "typical"
]
t0 = time.time()
p = subprocess.run(cmd_xelab, cwd=PROJECT_ROOT, capture_output=True, text=True)
t1 = time.time()
print(p.stdout)
if p.returncode != 0:
    print(p.stderr)
else:
    print(f"Elaboration with -notimingchecks SUCCESSFUL in {t1 - t0:.1f}s")

