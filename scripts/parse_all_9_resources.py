import os
import re

RPT_DIR = r"results/final_run_20261030_1056/reports"

variants = [
    ("baseline", "conv2d_serial_baseline", "gen_baseline.u_engine"),
    ("oi", "conv2d_serial_oi", "gen_oi.u_engine"),
    ("cg", "conv2d_serial_cg", "gen_cg.u_engine"),
    ("zs", "conv2d_serial_zs", "gen_zs.u_engine"),
    ("zs_oi", "conv2d_serial_zs_oi", "gen_zs_oi.u_engine"),
    ("zs_cg", "conv2d_serial_zs_cg", "gen_zs_cg.u_engine"),
    ("oi_cg", "conv2d_serial_oi_cg", "gen_oi_cg.u_engine"),
    ("combined", "conv2d_serial_combined", "gen_combined.u_engine"),
    ("static_sobel", "conv2d_serial_static_sobel", "gen_static_sobel.u_engine"),
]

print("=" * 100)
print(f"{'Variant':15s} | {'Top LUTs':10s} | {'Top FFs':10s} | {'WNS (ns)':10s} | {'Eng LUTs':10s} | {'Eng FFs':10s}")
print("=" * 100)

for vname, eng_mod, hier_inst in variants:
    # 1. Top utilization
    top_util_file = f"{RPT_DIR}/utilization_benchmark_{vname}.txt"
    top_luts, top_ffs = "N/A", "N/A"
    lut_line, ff_line = 0, 0
    if os.path.exists(top_util_file):
        with open(top_util_file, "r", encoding="utf-8") as f:
            for idx, line in enumerate(f, 1):
                if "Slice LUTs" in line and top_luts == "N/A":
                    # | Slice LUTs*               |      247 |     0 |      8000 |  3.08 |
                    parts = [p.strip() for p in line.split("|")]
                    if len(parts) >= 3:
                        top_luts = parts[2]
                        lut_line = idx
                elif "Slice Registers" in line and top_ffs == "N/A":
                    parts = [p.strip() for p in line.split("|")]
                    if len(parts) >= 3:
                        top_ffs = parts[2]
                        ff_line = idx

    # 2. Timing
    timing_file = f"{RPT_DIR}/timing_benchmark_{vname}.txt"
    wns = "N/A"
    wns_line = 0
    if os.path.exists(timing_file):
        with open(timing_file, "r", encoding="utf-8") as f:
            for idx, line in enumerate(f, 1):
                if "Worst Negative Slack (WNS):" in line:
                    m = re.search(r"Worst Negative Slack \(WNS\):\s+([-\d\.]+)\s*ns", line)
                    if m:
                        wns = m.group(1)
                        wns_line = idx
                        break

    # 3. Hierarchical
    hier_file = f"{RPT_DIR}/utilization_hierarchical_{vname}.txt"
    eng_luts, eng_ffs = "N/A", "N/A"
    eng_line = 0
    if os.path.exists(hier_file):
        with open(hier_file, "r", encoding="utf-8") as f:
            for idx, line in enumerate(f, 1):
                if eng_mod in line or (hier_inst and hier_inst.split(".")[-1] in line) or "u_engine" in line:
                    parts = [p.strip() for p in line.split("|")]
                    if len(parts) >= 5:
                        eng_luts = parts[3]
                        eng_ffs = parts[4]
                        eng_line = idx
                        break

    print(f"{vname:15s} | {top_luts:10s} (L{lut_line}) | {top_ffs:10s} (L{ff_line}) | {wns:10s} (L{wns_line}) | {eng_luts:10s} (L{eng_line}) | {eng_ffs:10s}")

