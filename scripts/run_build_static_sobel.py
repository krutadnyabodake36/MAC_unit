import os
import subprocess
import time

VIVADO_BAT = r"C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat"
TCL_SCRIPT = "scripts/build_static_sobel.tcl"
LOG_FILE = "results/final_run_20261030_1056/logs/build_static_sobel.log"

os.makedirs("results/final_run_20261030_1056/logs", exist_ok=True)

print("=" * 80)
print(" >>> BUILDING STATIC SOBEL-X 6-TAP BASELINE (DESIGN_SELECT=8) <<<")
print(f"Vivado binary: {VIVADO_BAT}")
print(f"Tcl script:    {TCL_SCRIPT}")
print(f"Log file:      {LOG_FILE}")
print("=" * 80)

cmd = [VIVADO_BAT, "-mode", "batch", "-source", TCL_SCRIPT]
t0 = time.time()
with open(LOG_FILE, "w", encoding="utf-8") as f_log:
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1, encoding="utf-8", errors="replace")
    for line in p.stdout:
        f_log.write(line)
        f_log.flush()
        if any(marker in line for marker in ["[1/5]", "[2/5]", "[3/5]", "[4/5]", "[5/5]", "COMPLETED", "ERROR:", "CRITICAL WARNING:"]):
            print(f"  {line.strip()}")

p.wait()
t1 = time.time()

if p.returncode != 0:
    print(f"\n[FAILURE] Build failed with exit code {p.returncode}. See {LOG_FILE}")
    exit(p.returncode)

print(f"\n[SUCCESS] Static Sobel build finished successfully in {t1 - t0:.1f} seconds.")

