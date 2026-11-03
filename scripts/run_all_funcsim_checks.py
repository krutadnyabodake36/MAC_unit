import os
import subprocess
import glob
import re
import json

VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")
GLBL  = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v".replace("\\", "/")

PROJECT_ROOT = os.path.abspath(r"C:\Users\Krutadnye\Downloads\Projects\MAC").replace("\\", "/")
FUNCSIM_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/funcsim"
TB_SV = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_funcsim_check.sv"

variants = [
    "baseline",
    "cg",
    "combined",
    "oi",
    "oi_cg",
    "static_sobel",
    "zs",
    "zs_cg",
    "zs_oi"
]

results = []
for var in variants:
    funcsim_v = f"{FUNCSIM_DIR}/{var}_funcsim.v"
    log_file = f"{FUNCSIM_DIR}/{var}_funcsim_sim.log"
    print(f"\n========================================================")
    print(f" >>> RUNNING POST-IMPL FUNCSIM CHECK: {var} <<<")
    print(f"========================================================")
    
    if not os.path.exists(funcsim_v):
        print(f"[ERROR] {funcsim_v} missing!")
        results.append({"variant": var, "status": "FILE_MISSING", "patches": 0, "mismatches": -1})
        continue

    # 1. xvlog
    cmd_xvlog = [XVLOG, "-sv", GLBL, funcsim_v, TB_SV]
    r = subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"[ERROR] xvlog failed for {var}:\n{r.stderr}")
        results.append({"variant": var, "status": "XVLOG_FAILED", "patches": 0, "mismatches": -1})
        continue

    # 2. xelab
    cmd_xelab = [
        XELAB,
        "-top", "tb_conv2d_engine_funcsim_check",
        "-top", "glbl",
        "-s", f"tb_funcsim_{var}",
        "-L", "unisims_ver",
        "-debug", "typical"
    ]
    r = subprocess.run(cmd_xelab, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"[ERROR] xelab failed for {var}:\n{r.stderr}")
        results.append({"variant": var, "status": "XELAB_FAILED", "patches": 0, "mismatches": -1})
        continue

    # 3. xsim
    cmd_xsim = [XSIM, f"tb_funcsim_{var}", "-R"]
    with open(log_file, "w", encoding="utf-8") as lf:
        r = subprocess.run(cmd_xsim, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, stdout=lf, stderr=subprocess.STDOUT, timeout=600)
    
    # Parse log
    log_text = open(log_file, "r", encoding="utf-8").read()
    p_m = re.search(r"Total Evaluated Patches\s*:\s*(\d+)", log_text)
    m_m = re.search(r"Total Output Mismatches\s*:\s*(\d+)", log_text)
    res_m = re.search(r"Functional Test Result\s*:\s*(.+)", log_text)
    
    patches = int(p_m.group(1)) if p_m else 0
    mismatches = int(m_m.group(1)) if m_m else -1
    res_str = res_m.group(1).strip() if res_m else "UNKNOWN"
    
    print(f"[{var.upper()}] Patches: {patches} | Mismatches: {mismatches} | Result: {res_str}")
    results.append({
        "variant": var,
        "status": "PASS" if (mismatches == 0 and patches == 44032) else "FAIL",
        "patches": patches,
        "mismatches": mismatches,
        "log_file": log_file
    })

out_json = f"{FUNCSIM_DIR}/funcsim_results.json"
with open(out_json, "w", encoding="utf-8") as fp:
    json.dump(results, fp, indent=2)

print("\n" + "=" * 80)
print(f"All 9 variants verified. Results saved to {out_json}")
print("=" * 80)

