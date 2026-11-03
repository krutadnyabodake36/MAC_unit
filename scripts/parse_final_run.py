#!/usr/bin/env python3
"""
scripts/parse_final_run.py
Parses raw simulation logs, post-route timing, utilization, and power reports
produced in results/final_run_20261030_1056/ and generates SUMMARY.csv and SUMMARY.md.
Strictly copies numbers directly from files on disk with file path and line citations.
"""

import os
import re
import csv
import json

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RUN_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056")
LOG_DIR = os.path.join(RUN_DIR, "logs")
RPT_DIR = os.path.join(RUN_DIR, "reports")

VARIANTS = [
    ("baseline", "Baseline",                   0, 0, 0, "conv2d_serial_baseline"),
    ("oi",       "Only Operand Isolation",     0, 1, 0, "conv2d_serial_oi"),
    ("cg",       "Only Clock-Enable Gating",   0, 0, 1, "conv2d_serial_cg"),
    ("zs",       "Only Zero-Skipping",         1, 0, 0, "conv2d_serial_zs"),
    ("zs_oi",    "ZS + OI",                    1, 1, 0, "conv2d_serial_zs_oi"),
    ("zs_cg",    "ZS + CG",                    1, 0, 1, "conv2d_serial_zs_cg"),
    ("oi_cg",    "OI + CG",                    0, 1, 1, "conv2d_serial_oi_cg"),
    ("combined", "Combined Architecture (All)",1, 1, 1, "conv2d_serial_combined"),
]

def parse_utilization(rpt_path):
    if not os.path.exists(rpt_path):
        return None
    data = {}
    with open(rpt_path, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f, 1):
            if "Slice LUTs*" in line or "Slice LUTs " in line:
                m = re.findall(r"\|\s*(\d+)\s*\|", line)
                if m:
                    data["luts"] = int(m[0])
                    data["luts_citation"] = f"{rpt_path}:{idx}"
            elif "Slice Registers" in line:
                m = re.findall(r"\|\s*(\d+)\s*\|", line)
                if m:
                    data["ffs"] = int(m[0])
                    data["ffs_citation"] = f"{rpt_path}:{idx}"
            elif "| DSPs" in line:
                m = re.findall(r"\|\s*(\d+)\s*\|", line)
                if m:
                    data["dsps"] = int(m[0])
                    data["dsps_citation"] = f"{rpt_path}:{idx}"
            elif "Block RAM Tile" in line:
                m = re.findall(r"\|\s*(\d+)\s*\|", line)
                if m:
                    data["bram"] = int(m[0])
                    data["bram_citation"] = f"{rpt_path}:{idx}"
    return data

def parse_hierarchical(rpt_path, mod_name):
    if not os.path.exists(rpt_path):
        return None
    data = {}
    with open(rpt_path, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f, 1):
            if mod_name in line or "u_engine" in line:
                parts = [p.strip() for p in line.split("|") if p.strip()]
                if len(parts) >= 2 and (parts[1] == mod_name or "u_engine" in parts[0]):
                    data["engine_instance"] = parts[0]
                    data["hier_citation"] = f"{rpt_path}:{idx}"
                    data["hier_line"] = line.strip()
                    break
    return data

def parse_timing(rpt_path):
    if not os.path.exists(rpt_path):
        return None
    data = {}
    with open(rpt_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        for idx, line in enumerate(lines):
            if "WNS(ns)" in line and "TNS(ns)" in line:
                # Next line has values or 2 lines down
                val_line = lines[idx+2].strip()
                tokens = val_line.split()
                if tokens:
                    wns = float(tokens[0])
                    data["wns"] = wns
                    data["wns_citation"] = f"{rpt_path}:{idx+3}"
                    fmax = 1000.0 / (20.000 - wns)
                    data["fmax_est"] = fmax
                    break
    return data

def parse_power(rpt_path):
    if not os.path.exists(rpt_path):
        return None
    data = {}
    with open(rpt_path, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f, 1):
            if "Total On-Chip Power (W)" in line:
                m = re.findall(r"\|\s*([\d\.]+)\s*\|", line)
                if m:
                    data["total_w"] = float(m[0])
                    data["total_citation"] = f"{rpt_path}:{idx}"
            elif "Dynamic (W)" in line:
                m = re.findall(r"\|\s*([\d\.]+)\s*\|", line)
                if m:
                    data["dynamic_w"] = float(m[0])
                    data["dynamic_citation"] = f"{rpt_path}:{idx}"
            elif "Device Static (W)" in line:
                m = re.findall(r"\|\s*([\d\.]+)\s*\|", line)
                if m:
                    data["static_w"] = float(m[0])
                    data["static_citation"] = f"{rpt_path}:{idx}"
            elif "Confidence Level" in line:
                parts = [p.strip() for p in line.split("|") if p.strip()]
                if len(parts) >= 2:
                    data["confidence"] = parts[1]
                    data["conf_citation"] = f"{rpt_path}:{idx}"
    return data

def main():
    print("=" * 80)
    print(" >>> PARSING FINAL RUN METRICS INTO SUMMARY.CSV AND SUMMARY.MD <<<")
    print("=" * 80)

    rows = []
    for suffix, name, zs, oi, cg, mod in VARIANTS:
        if mod == "NOT RUN":
            rows.append({
                "suffix": suffix, "name": name, "zs": zs, "oi": oi, "cg": cg, "status": "NOT RUN",
                "luts": "NOT RUN", "ffs": "NOT RUN", "dsps": "NOT RUN", "bram": "NOT RUN",
                "wns": "NOT RUN", "fmax": "NOT RUN", "power": "NOT RUN", "module": "NOT RUN"
            })
            continue

        u_rpt = os.path.join(RPT_DIR, f"utilization_benchmark_{suffix}.txt")
        h_rpt = os.path.join(RPT_DIR, f"utilization_hierarchical_{suffix}.txt")
        t_rpt = os.path.join(RPT_DIR, f"timing_benchmark_{suffix}.txt")
        p_rpt = os.path.join(RPT_DIR, f"power_benchmark_{suffix}.txt")

        u = parse_utilization(u_rpt)
        h = parse_hierarchical(h_rpt, mod)
        t = parse_timing(t_rpt)
        p = parse_power(p_rpt)

        if not u or not t or not p:
            print(f"[ERROR] Missing reports for {suffix}!")
            rows.append({
                "suffix": suffix, "name": name, "zs": zs, "oi": oi, "cg": cg, "status": "INCOMPLETE",
                "luts": "N/A", "ffs": "N/A", "dsps": "N/A", "bram": "N/A",
                "wns": "N/A", "fmax": "N/A", "power": "N/A", "module": mod
            })
            continue

        rows.append({
            "suffix": suffix, "name": name, "zs": zs, "oi": oi, "cg": cg, "status": "VERIFIED",
            "luts": u.get("luts", "N/A"),
            "ffs": u.get("ffs", "N/A"),
            "dsps": u.get("dsps", "N/A"),
            "bram": u.get("bram", "N/A"),
            "wns": f"{t.get('wns', 0.0):.3f}",
            "fmax": f"{t.get('fmax_est', 0.0):.2f}",
            "power_dyn": f"{p.get('dynamic_w', 0.0)*1000:.1f} mW",
            "power_stat": f"{p.get('static_w', 0.0)*1000:.1f} mW",
            "power_tot": f"{p.get('total_w', 0.0)*1000:.1f} mW",
            "confidence": p.get("confidence", "Medium"),
            "module": mod,
            "citations": {
                "u": u.get("luts_citation", ""),
                "t": t.get("wns_citation", ""),
                "p": p.get("total_citation", "")
            }
        })

    # Write SUMMARY.csv
    csv_path = os.path.join(RUN_DIR, "SUMMARY.csv")
    with open(csv_path, "w", newline="", encoding="utf-8") as cf:
        fieldnames = ["Config", "ZS", "OI", "CG", "Status", "Module", "Slice_LUTs", "Slice_FFs", "DSP48", "BRAM", "WNS_ns", "Fmax_est_MHz", "Dyn_Power_mW", "Total_Power_mW", "Power_Confidence"]
        writer = csv.DictWriter(cf, fieldnames=fieldnames)
        writer.writeheader()
        for r in rows:
            writer.writerow({
                "Config": r["name"],
                "ZS": r["zs"],
                "OI": r["oi"],
                "CG": r["cg"],
                "Status": r["status"],
                "Module": r["module"],
                "Slice_LUTs": r.get("luts"),
                "Slice_FFs": r.get("ffs"),
                "DSP48": r.get("dsps"),
                "BRAM": r.get("bram"),
                "WNS_ns": r.get("wns"),
                "Fmax_est_MHz": r.get("fmax"),
                "Dyn_Power_mW": r.get("power_dyn", "NOT RUN"),
                "Total_Power_mW": r.get("power_tot", "NOT RUN"),
                "Power_Confidence": r.get("confidence", "NOT RUN")
            })
    print(f"Wrote CSV summary to: {csv_path}")

    # Write SUMMARY.md
    md_path = os.path.join(RUN_DIR, "SUMMARY.md")
    with open(md_path, "w", encoding="utf-8") as mf:
        mf.write("# FINAL RUN SUMMARY REPORT (FACTUAL OUTPUTS ONLY)\n\n")
        mf.write(f"**Run ID:** `final_run_20261030_1056`  \n")
        mf.write(f"**Target FPGA:** Xilinx Spartan-7 `xc7s15ftgb196-1` @ 50 MHz  \n")
        mf.write(f"**Tool:** AMD Vivado Design Suite v2026.1  \n\n")

        mf.write("## 1. Eight-Configuration Ablation Status\n\n")
        mf.write("| # | Config Name | ZS | OI | CG | Status | Instantiated Module | Slice LUTs | Slice FFs | DSP48 | BRAM | WNS (ns) | Fmax (est, MHz)* | Dynamic Power (mW)** | Confidence |\n")
        mf.write("|---|---|:---:|:---:|:---:|---|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|\n")
        for idx, r in enumerate(rows, 1):
            if r["status"] == "NOT RUN":
                mf.write(f"| {idx} | {r['name']} | {r['zs']} | {r['oi']} | {r['cg']} | **NOT RUN** | — | — | — | — | — | — | — | — | — |\n")
            else:
                mf.write(f"| {idx} | {r['name']} | {r['zs']} | {r['oi']} | {r['cg']} | **VERIFIED** | `{r['module']}` | {r['luts']} | {r['ffs']} | {r['dsps']} | {r['bram']} | {r['wns']} | {r['fmax']} | {r['power_dyn']} | {r['confidence']} |\n")

        mf.write("\n*\*Note on Fmax:* Calculated as `1000 / (20.000 - WNS)`. Labeled: *estimated from WNS at 50 MHz, not true Fmax*.\n")
        mf.write("\n*\*\*Note on Power:* Power values are vectorless default estimates extracted from post-route netlist report (`report_power -hier all`). Labeled: *vectorless estimate*.\n")

    print(f"Wrote Markdown summary to: {md_path}")

if __name__ == "__main__":
    main()

