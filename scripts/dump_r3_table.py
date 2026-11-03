import os
import re

RPT_DIR = r"results/final_run_20261030_1056/reports"

variants = [
    ("baseline", "conv2d_serial_baseline"),
    ("oi", "conv2d_serial_oi"),
    ("cg", "conv2d_serial_cg"),
    ("zs", "conv2d_serial_zs"),
    ("zs_oi", "conv2d_serial_zs_oi"),
    ("zs_cg", "conv2d_serial_zs_cg"),
    ("oi_cg", "conv2d_serial_oi_cg"),
    ("combined", "conv2d_serial_combined"),
    ("static_sobel", "conv2d_serial_static_sobel"),
]

data = []

for vname, eng_mod in variants:
    # 1. Top utilization
    top_util_file = f"{RPT_DIR}/utilization_benchmark_{vname}.txt"
    top_luts, top_ffs = None, None
    lut_line, ff_line = None, None
    with open(top_util_file, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f, 1):
            if "Slice LUTs*" in line or "Slice LUTs " in line:
                if top_luts is None:
                    parts = [p.strip() for p in line.split("|")]
                    top_luts = parts[2]
                    lut_line = idx
            elif "Slice Registers" in line:
                if top_ffs is None:
                    parts = [p.strip() for p in line.split("|")]
                    top_ffs = parts[2]
                    ff_line = idx

    # 2. Timing (line 141)
    timing_file = f"{RPT_DIR}/timing_benchmark_{vname}.txt"
    wns, wns_line = None, None
    with open(timing_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
        # Find line after dashes under WNS(ns)
        for idx, line in enumerate(lines, 1):
            if "WNS(ns)" in line and "TNS(ns)" in line:
                val_line = lines[idx + 1].strip() # 2 lines down
                parts = val_line.split()
                if parts:
                    wns = parts[0]
                    wns_line = idx + 2
                    break

    # 3. Hierarchical utilization
    hier_file = f"{RPT_DIR}/utilization_hierarchical_{vname}.txt"
    eng_luts, eng_ffs = None, None
    eng_line = None
    with open(hier_file, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f, 1):
            if eng_mod in line:
                parts = [p.strip() for p in line.split("|")]
                # | Instance | Module | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs |
                eng_luts = parts[3]
                eng_ffs = parts[7]
                eng_line = idx
                break

    data.append({
        "variant": vname,
        "eng_mod": eng_mod,
        "top_luts": top_luts, "lut_line": lut_line,
        "top_ffs": top_ffs, "ff_line": ff_line,
        "wns": wns, "wns_line": wns_line,
        "eng_luts": eng_luts, "eng_ffs": eng_ffs, "eng_line": eng_line
    })

print("| Variant | Target Module | Top LUTs (Line) | Top FFs (Line) | WNS ns (Line) | Engine LUTs (Line) | Engine FFs (Line) |")
print("|---|---|:---:|:---:|:---:|:---:|:---:|")
for d in data:
    print(f"| `{d['variant']}` | `{d['eng_mod']}` | {d['top_luts']} (L{d['lut_line']}) | {d['top_ffs']} (L{d['ff_line']}) | {d['wns']} ns (L{d['wns_line']}) | {d['eng_luts']} (L{d['eng_line']}) | {d['eng_ffs']} (L{d['eng_line']}) |")

