import os
import subprocess
import time
import re

VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat")

src_files = [
    "src/uart_rx.sv",
    "src/uart_tx.sv",
    "src/conv2d_serial_baseline.sv",
    "src/conv2d_serial_oi.sv",
    "src/conv2d_serial_cg.sv",
    "src/conv2d_serial_zs.sv",
    "src/conv2d_serial_combined.sv",
    "src/conv2d_serial_zs_oi.sv",
    "src/conv2d_serial_zs_cg.sv",
    "src/conv2d_serial_oi_cg.sv",
    "src/conv2d_serial_static_sobel.sv",
    "src/conv2d_benchmark_top_static.sv",
    "tb/tb_uart_board_path_check.sv"
]

print(">>> Compiling RTL sources for UART Board Path Check...")
r = subprocess.run([XVLOG, "-sv"] + src_files, capture_output=True, text=True)
if r.returncode != 0:
    print("xvlog failed:\n", r.stderr)
    exit(1)

# Test design 3 (ZS) first
sel = 3
snap = f"snap_uart_sel_{sel}"
top_module = f"tb_uart_sel_{sel}"
print(f"\n>>> Elaborating {top_module} (ZS)...")
r = subprocess.run([
    XELAB,
    "-top", top_module,
    "-s", snap,
    "-debug", "typical"
], capture_output=True, text=True)
if r.returncode != 0:
    print("xelab failed:\nSTDOUT:\n", r.stdout, "\nSTDERR:\n", r.stderr)
    exit(1)

print(f">>> Running simulation for {top_module} (300 patches @ 115200 baud)...")
t0 = time.time()
r = subprocess.run([XSIM, snap, "-R"], capture_output=True, text=True)
t1 = time.time()
print(f"Elapsed: {t1-t0:.2f} s")
print(r.stdout)
