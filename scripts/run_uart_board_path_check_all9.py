import os
import subprocess
import time

VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XELAB = os.path.join(VIVADO_BIN, "xelab.bat")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat")

OUT_DIR = "results/final_run_20261030_1056/uart_board_check"
LOG_FILE = os.path.join(OUT_DIR, "uart_board_check_all9.log")

variants = [
    (0, "baseline"),
    (1, "oi"),
    (2, "cg"),
    (3, "zs"),
    (4, "combined"),
    (5, "zs_oi"),
    (6, "zs_cg"),
    (7, "oi_cg"),
    (8, "static_sobel")
]

results = []

with open(LOG_FILE, "w", encoding="utf-8") as flog:
    header = "================================================================================\n"
    header += "G2 UART BOARD PATH CHECK: ALL 9 ARCHITECTURAL VARIANTS (300 PATCHES)\n"
    header += "Stimulus: results/final_run_20261030_1056/vectors/image1.vec\n"
    header += "UART Configuration: 18-byte request frames, 6-byte reply frames\n"
    header += "Baud Divider: CLKS_PER_BIT = 16 (Parameterized UART RTL Simulation)\n"
    header += "================================================================================\n\n"
    print(header)
    flog.write(header)

    for sel, name in variants:
        snap = f"snap_uart_sel_{sel}"
        top = f"tb_uart_sel_{sel}"
        print(f">>> Elaborating {top} ({name})...")
        r_elab = subprocess.run([
            XELAB, "-top", top, "-s", snap, "-debug", "typical"
        ], capture_output=True, text=True)
        if r_elab.returncode != 0:
            msg = f"[ERROR] Elaboration failed for {top}:\n{r_elab.stderr}\n"
            print(msg)
            flog.write(msg)
            continue

        print(f">>> Simulating {top} ({name})...")
        t0 = time.time()
        r_sim = subprocess.run([XSIM, snap, "-R"], capture_output=True, text=True)
        elapsed = time.time() - t0

        sim_out = r_sim.stdout
        print(f"Elapsed: {elapsed:.2f} s")
        print(sim_out)
        flog.write(f"--- Variant {sel}: {name} ---\n")
        flog.write(sim_out)
        flog.write(f"Simulation Elapsed Time: {elapsed:.2f} s\n\n")

print(">>> ALL 9 VARIANTS COMPLETED <<<")

