import os
import subprocess
import sys
import time

PROJECT_ROOT = r"C:/Users/Krutadnye/Downloads/Projects/MAC".replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")

OUT_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/expected"
os.makedirs(OUT_DIR, exist_ok=True)

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
    "tb/tb_export_expected_replies.sv"
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

IMAGES = ["image1", "image2", "image3", "image4"]

def main():
    print("=== [1/3] Compiling sources with xvlog ===", flush=True)
    cmd_xvlog = [XVLOG, "-sv"] + [f"{PROJECT_ROOT}/{f}" for f in SRC_FILES]
    r_vlog = subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, capture_output=True, text=True)
    if r_vlog.returncode != 0:
        print("[ERROR] xvlog failed:", flush=True)
        print(r_vlog.stdout, flush=True)
        print(r_vlog.stderr, flush=True)
        sys.exit(1)
    print("xvlog compilation complete.", flush=True)

    print("=== [2/3] Elaborating and Running all 9 Design Exporters ===", flush=True)
    t_start = time.time()

    for idx, dname in enumerate(DESIGN_NAMES):
        top_mod = f"tb_export_expected_{idx}"
        snap_name = f"snap_export_expected_{idx}"
        print(f"\n--- Elaborating Design {idx}: {dname} ({top_mod}) ---", flush=True)
        t0 = time.time()

        cmd_elab = [XELAB, "-top", top_mod, "-s", snap_name, "-debug", "typical"]
        r_elab = subprocess.run(cmd_elab, cwd=PROJECT_ROOT, capture_output=True, text=True)
        if r_elab.returncode != 0:
            print(f"[ERROR] xelab failed for {top_mod}:", flush=True)
            print(r_elab.stdout, flush=True)
            print(r_elab.stderr, flush=True)
            sys.exit(1)

        print(f"Running simulation for {dname} (exporting all 4 images)...", flush=True)
        cmd_sim = [XSIM, snap_name, "-R"]
        r_sim = subprocess.run(cmd_sim, cwd=PROJECT_ROOT, capture_output=True, text=True)
        dur = time.time() - t0

        if r_sim.returncode != 0:
            print(f"[ERROR] Simulation failed for {dname}:", flush=True)
            print(r_sim.stdout, flush=True)
            print(r_sim.stderr, flush=True)
            sys.exit(1)

        print(f"Completed {dname} in {dur:.2f}s", flush=True)
        for line in r_sim.stdout.splitlines():
            if "complete:" in line or "ALL 4 IMAGES" in line:
                print(f"  {line}", flush=True)

    total_time = time.time() - t_start
    print(f"\n=== [3/3] Verifying all 36 CSV files in {OUT_DIR} ===", flush=True)
    all_ok = True
    for dname in DESIGN_NAMES:
        for img in IMAGES:
            csv_path = f"{OUT_DIR}/expected_{dname}_{img}.csv"
            if not os.path.exists(csv_path):
                print(f"[MISSING] {csv_path}", flush=True)
                all_ok = False
            else:
                with open(csv_path, "r", encoding="utf-8") as f:
                    cnt = len(f.readlines()) - 1
                print(f"  {os.path.basename(csv_path):35s} : {cnt:6d} patches", flush=True)

    if all_ok:
        print(f"\nSUCCESS! All 36 expected files generated and verified in {total_time:.2f}s!", flush=True)
    else:
        print("\nFAILURE: Some expected files are missing!", flush=True)
        sys.exit(1)

if __name__ == "__main__":
    main()
