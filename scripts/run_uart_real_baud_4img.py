import os
import subprocess
import sys
import time

PROJECT_ROOT = r"C:/Users/Krutadnye/Downloads/Projects/MAC".replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")

RESULTS_DIR = f"{PROJECT_ROOT}/results/uart_real_baud"
os.makedirs(RESULTS_DIR, exist_ok=True)

SRC_FILES = [
    "src/mac_baseline.sv",
    "src/mac_oi.sv",
    "src/mac_cg.sv",
    "src/mac_zs.sv",
    "src/mac_combined.sv",
    "src/conv2d_serial_baseline.sv",
    "src/conv2d_serial_oi.sv",
    "src/conv2d_serial_cg.sv",
    "src/conv2d_serial_zs.sv",
    "src/conv2d_serial_combined.sv",
    "src/conv2d_serial_zs_oi.sv",
    "src/conv2d_serial_zs_cg.sv",
    "src/conv2d_serial_oi_cg.sv",
    "src/conv2d_serial_static_sobel.sv",
    "src/uart_rx.sv",
    "src/uart_tx.sv",
    "src/conv2d_benchmark_top_static.sv",
    "tb/tb_uart_real_baud_4img.sv"
]

def main():
    print("=== [STEP 1] Compiling all RTL sources with xvlog ===", flush=True)
    cmd_xvlog = [XVLOG, "-sv"] + [f"{PROJECT_ROOT}/{f}" for f in SRC_FILES]
    r_vlog = subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, capture_output=True, text=True)
    if r_vlog.returncode != 0:
        print("[ERROR] xvlog failed:", flush=True)
        print(r_vlog.stdout, flush=True)
        print(r_vlog.stderr, flush=True)
        sys.exit(1)
    print("xvlog compilation successful.", flush=True)

    targets = [
        ("baseline", "tb_uart_real_baud_4img_baseline", "snap_uart_4img_baseline"),
        ("static_sobel", "tb_uart_real_baud_4img_static_sobel", "snap_uart_4img_static_sobel")
    ]

    for name, top_mod, snap in targets:
        print(f"\n--- [STEP 2] Elaborating {name} ({top_mod}) ---", flush=True)
        cmd_elab = [
            XELAB, "-top", top_mod, "-s", snap,
            "-L", "work", "-L", "unisims_ver",
            "-timescale", "1ns/1ps", "-debug", "typical"
        ]
        r_elab = subprocess.run(cmd_elab, cwd=PROJECT_ROOT, capture_output=True, text=True)
        if r_elab.returncode != 0:
            print(f"[ERROR] xelab failed for {top_mod}:", flush=True)
            print(r_elab.stdout, flush=True)
            print(r_elab.stderr, flush=True)
            sys.exit(1)
        print(f"Elaboration successful for {top_mod}.", flush=True)

        print(f"--- [STEP 3] Running Simulation for {name} ---", flush=True)
        t0 = time.time()
        log_file = f"{RESULTS_DIR}/uart_real_baud_4img_{name}.log"
        with open(log_file, "w", encoding="utf-8") as out_f:
            r_sim = subprocess.run(
                [XSIM, snap, "-R"],
                cwd=PROJECT_ROOT,
                stdout=out_f,
                stderr=subprocess.STDOUT,
                text=True
            )
        elapsed = time.time() - t0
        print(f"Simulation of {name} completed in {elapsed:.1f} s. Exit code: {r_sim.returncode}", flush=True)

        # Parse log
        with open(log_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        tail = [l.strip() for l in lines if "RESULT:" in l or "Total" in l or "Completed" in l]
        print(f"Summary for {name}:")
        for l in tail[-6:]:
            print("  ", l)

if __name__ == "__main__":
    main()

