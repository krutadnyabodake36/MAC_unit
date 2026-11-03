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
    "tb/tb_uart_real_baud_all9.sv"
]

DESIGN_NAMES = [
    "baseline",
    "oi",
    "cg",
    "zs",
    "combined",
    "zs_oi",
    "zs_cg",
    "oi_cg",
    "static_sobel"
]

def run_step():
    print("=== [STEP 1] Compiling all RTL sources with xvlog ===", flush=True)
    cmd_xvlog = [XVLOG, "-sv"] + [f"{PROJECT_ROOT}/{f}" for f in SRC_FILES]
    r_vlog = subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, capture_output=True, text=True)
    if r_vlog.returncode != 0:
        print("[ERROR] xvlog failed:", flush=True)
        print(r_vlog.stdout, flush=True)
        print(r_vlog.stderr, flush=True)
        sys.exit(1)
    print("xvlog compilation successful.", flush=True)

    overall_results = {}

    for idx, dname in enumerate(DESIGN_NAMES):
        top_module = f"tb_uart_real_baud_{idx}"
        snap_name = f"snap_uart_real_baud_{idx}"
        log_file = f"{RESULTS_DIR}/uart_real_baud_{dname}.log"

        print(f"\n--- Elaborating and Running Design {idx}: {dname} ({top_module}) ---", flush=True)
        t0 = time.time()

        cmd_elab = [XELAB, "-top", top_module, "-s", snap_name, "-debug", "typical"]
        r_elab = subprocess.run(cmd_elab, cwd=PROJECT_ROOT, capture_output=True, text=True)
        if r_elab.returncode != 0:
            print(f"[ERROR] xelab failed for {top_module}:", flush=True)
            print(r_elab.stdout, flush=True)
            print(r_elab.stderr, flush=True)
            sys.exit(1)

        with open(log_file, "w", encoding="utf-8") as out_f:
            cmd_sim = [XSIM, snap_name, "-R"]
            r_sim = subprocess.run(cmd_sim, cwd=PROJECT_ROOT, stdout=out_f, stderr=subprocess.STDOUT, text=True)

        elapsed = time.time() - t0
        print(f"Finished {dname} in {elapsed:.2f}s (Exit code: {r_sim.returncode})", flush=True)

        # Parse log for result
        with open(log_file, "r", encoding="utf-8") as in_f:
            content = in_f.read()

        sum_mismatches = None
        cycle_mismatches = None
        skip_mismatches = None
        patches_eval = None
        passed = False

        for line in content.splitlines():
            if "Patches Evaluated:" in line:
                patches_eval = int(line.split(":")[-1].strip())
            elif "Sum Mismatches   :" in line:
                sum_mismatches = int(line.split(":")[-1].strip())
            elif "Cycle Mismatches :" in line:
                cycle_mismatches = int(line.split(":")[-1].strip())
            elif "Skip Mismatches  :" in line:
                skip_mismatches = int(line.split(":")[-1].strip())
            elif "Result           : PASS" in line:
                passed = True

        overall_results[dname] = {
            "design_idx": idx,
            "patches": patches_eval,
            "sum_mismatches": sum_mismatches,
            "cycle_mismatches": cycle_mismatches,
            "skip_mismatches": skip_mismatches,
            "passed": passed,
            "log": log_file
        }
        print(f"Result for {dname}: Patches={patches_eval}, SumMis={sum_mismatches}, CycMis={cycle_mismatches}, SkipMis={skip_mismatches}, Passed={passed}", flush=True)

    print("\n================ SUMMARY OF ALL 9 REAL-BAUD RUNS ================", flush=True)
    all_passed = True
    for dname, res in overall_results.items():
        status = "PASS" if res["passed"] else "FAIL"
        if not res["passed"]:
            all_passed = False
        print(f"Design {res['design_idx']} ({dname:12s}): {status} | Patches: {res['patches']} | SumMis: {res['sum_mismatches']} | CycMis: {res['cycle_mismatches']} | SkipMis: {res['skip_mismatches']}", flush=True)

    print("==================================================================", flush=True)
    if all_passed:
        print("OVERALL REAL-BAUD UART VERIFICATION: PASS", flush=True)
    else:
        print("OVERALL REAL-BAUD UART VERIFICATION: FAIL", flush=True)

if __name__ == "__main__":
    run_step()
