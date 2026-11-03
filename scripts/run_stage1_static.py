#!/usr/bin/env python3
"""
Stage 1 with Static Sobel: Cycle Measurement Simulation Runner.
Executes xvlog, xelab, and xsim for tb_cycle_measurement_static.
"""

import os
import sys
import subprocess

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VIVADO_BIN = r"C:\AMDDesignTools\2026.1\Vivado\bin"
LOG_PATH = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "logs", "stage1_cycle_measurement_static.log")

def run_cmd(cmd, log_file):
    print(f"[RUNNING] {' '.join(cmd)}")
    log_file.write(f"\n{'=' * 80}\n[COMMAND] {' '.join(cmd)}\n{'=' * 80}\n")
    log_file.flush()
    proc = subprocess.Popen(
        cmd,
        cwd=PROJECT_ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )
    for line in proc.stdout:
        sys.stdout.write(line)
        log_file.write(line)
    proc.wait()
    log_file.flush()
    if proc.returncode != 0:
        print(f"[ERROR] Command failed with exit code {proc.returncode}")
        sys.exit(proc.returncode)

def main():
    os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
    with open(LOG_PATH, "w", encoding="utf-8") as lf:
        xvlog = os.path.join(VIVADO_BIN, "xvlog.bat")
        xelab = os.path.join(VIVADO_BIN, "xelab.bat")
        xsim  = os.path.join(VIVADO_BIN, "xsim.bat")

        sources = [
            "src/conv2d_serial_baseline.sv",
            "src/conv2d_serial_oi.sv",
            "src/conv2d_serial_cg.sv",
            "src/conv2d_serial_zs.sv",
            "src/conv2d_serial_zs_oi.sv",
            "src/conv2d_serial_zs_cg.sv",
            "src/conv2d_serial_oi_cg.sv",
            "src/conv2d_serial_combined.sv",
            "src/conv2d_serial_static_sobel.sv",
            "tb/tb_cycle_measurement_static.sv"
        ]

        # 1. xvlog
        run_cmd([xvlog, "-sv"] + sources, lf)

        # 2. xelab
        run_cmd([xelab, "-top", "tb_cycle_measurement_static", "-s", "tb_cycle_static_snapshot"], lf)

        # 3. xsim
        run_cmd([xsim, "tb_cycle_static_snapshot", "-R"], lf)

    print(f"\nStage 1 (with static Sobel) simulation complete. Log written to: {LOG_PATH}")

if __name__ == "__main__":
    main()

