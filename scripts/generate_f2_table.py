import os
import json
import glob
import xml.etree.ElementTree as ET

BASE = "results/final_run_20261030_1056/saif"

variants_order = [
    ("natural_rerun", "baseline", "Baseline (rerun)"),
    ("natural", "baseline", "Baseline (pilot netlist) [pilot flow, not comparable]"),
    ("natural", "oi", "Operand Isolation (OI)"),
    ("natural", "cg", "Clock Gating (CG)"),
    ("natural", "oi_cg", "OI + CG"),
    ("natural", "zs", "Zero Skipping (ZS)"),
    ("natural", "zs_cg", "ZS + CG"),
    ("natural", "zs_oi", "ZS + OI"),
    ("natural", "combined", "Combined (ZS + OI + CG)"),
    ("natural", "static_sobel", "Static Sobel (Fixed 6-Tap)"),
    ("rotated", "baseline", "Baseline (Rotated order)"),
    ("rotated", "zs", "ZS (Rotated order)"),
    ("rotated", "zs_cg", "ZS + CG (Rotated order)"),
    ("rotated", "combined", "Combined (Rotated order)"),
    ("rotated", "static_sobel", "Static Sobel (Rotated order)"),
]

# Baseline reference is natural_rerun/baseline
ref_summary = json.load(open(f"{BASE}/natural_rerun/baseline/run_summary.json"))
ref_tot_dyn_mw = ref_summary["xml_total_dynamic_power_mw"]
ref_ep_nj = ref_summary["energy_per_patch_nj"]

TOTAL_PATCHES = 44032

rows = []
for flow, var, label in variants_order:
    folder = f"{BASE}/{flow}/{var}"
    sum_path = f"{folder}/run_summary.json"
    xml_path = f"{folder}/power_{var}_timesim.xml"
    txt_path = f"{folder}/power_{var}_timesim.txt"
    
    if not os.path.exists(sum_path):
        continue
        
    d = json.load(open(sum_path))
    
    # Parse XML for Vccint and rails
    tree = ET.parse(xml_path)
    root = tree.getroot()
    vccint_dyn_mw = 0.0
    vccint_stat_mw = 0.0
    for s in root.findall('.//section'):
        if s.attrib.get('title') == 'Power Supply Summary':
            for r in s.findall('.//tablerow'):
                cells = [c.attrib.get('contents', '').strip() for c in r.findall('.//tablecell')]
                if len(cells) >= 5 and cells[0] == 'Vccint':
                    v = float(cells[1])
                    dyn_a = float(cells[3])
                    stat_a = float(cells[4])
                    vccint_dyn_mw = v * dyn_a * 1000.0
                    vccint_stat_mw = v * stat_a * 1000.0
                    
    tot_dyn_mw = d["xml_total_dynamic_power_mw"]
    tot_stat_mw = d["xml_total_static_power_mw"]
    tot_onchip_mw = d["text_tot_onchip_power_w"] * 1000.0
    core_dyn_mw = (d.get("text_core_dynamic_power_w") or 0.0) * 1000.0
    wall_cycles = d["wall_cycles"]
    dur_ns = d["capture_window_ns"]
    dur_s = dur_ns * 1e-9
    
    ep_dyn_nj = d["energy_per_patch_nj"]
    
    # Static energy per patch
    # Total static energy = total static power (W) * duration (s)
    tot_stat_energy_j = (tot_stat_mw * 1e-3) * dur_s
    ep_stat_nj = (tot_stat_energy_j / TOTAL_PATCHES) * 1e9
    
    # % change vs natural_rerun/baseline
    delta_dyn_pct = ((tot_dyn_mw - ref_tot_dyn_mw) / ref_tot_dyn_mw) * 100.0
    delta_ep_pct = ((ep_dyn_nj - ref_ep_nj) / ref_ep_nj) * 100.0
    
    rows.append({
        "label": label,
        "flow": flow,
        "variant": var,
        "cycles": wall_cycles,
        "dur_ns": dur_ns,
        "vccint_dyn_mw": vccint_dyn_mw,
        "tot_dyn_mw": tot_dyn_mw,
        "core_dyn_mw": core_dyn_mw,
        "tot_onchip_mw": tot_onchip_mw,
        "delta_dyn_pct": delta_dyn_pct,
        "ep_dyn_nj": ep_dyn_nj,
        "delta_ep_pct": delta_ep_pct,
        "tot_stat_mw": tot_stat_mw,
        "vccint_stat_mw": vccint_stat_mw,
        "ep_stat_nj": ep_stat_nj,
        "coverage": f"{d['coverage_pct']}%",
        "confidence": d["confidence"]
    })

print(f"{'Variant':42s} | {'Cycles':>8s} | {'Vccint(mW)':>10s} | {'TotDyn(mW)':>10s} | {'CoreDyn(mW)':>11s} | {'E/patch(nJ)':>11s} | {'% dE vs Base':>12s} | {'Static(mW)':>10s} | {'StatE(nJ)':>9s}")
print("-" * 140)
for r in rows:
    pct_str = f"{r['delta_ep_pct']:+.2f}%" if "pilot" not in r["label"] else "N/A (pilot)"
    print(f"{r['label']:42s} | {r['cycles']:8d} | {r['vccint_dyn_mw']:10.4f} | {r['tot_dyn_mw']:10.4f} | {r['core_dyn_mw']:11.4f} | {r['ep_dyn_nj']:11.4f} | {pct_str:>12s} | {r['tot_stat_mw']:10.4f} | {r['ep_stat_nj']:9.4f}")

with open("results/final_run_20261030_1056/saif/f2_comparison_data.json", "w", encoding="utf-8") as fp:
    json.dump(rows, fp, indent=2)

