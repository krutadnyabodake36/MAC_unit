#!/usr/bin/env python3
# =============================================================================
# File: scripts/run_g4_saif_sweep_v2.py
# Description: Automated SAIF switching activity capture, power analysis, and
#              energy per patch evaluation for Spartan-7 XC7S15 @ 50 MHz.
# Flow: Post-implementation netlist simulation using conv2d_engine_wrapper_v2.
# Workloads:
#   1. Primary Sobel stimulus (44,032 patches, natural order, back-to-back):
#      baseline, cg, oi, zs, zs_oi, zs_cg, static_sobel, oi_cg, combined
#   2. Part C stimulus (Rule 2 Gaussian, 44,032 patches, natural order, back-to-back):
#      baseline, cg, oi, zs, zs_cg
# =============================================================================

import os
import sys
import subprocess
import time
import datetime
import json
import shutil
import re
import xml.etree.ElementTree as ET

VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")
VIVADO = os.path.join(VIVADO_BIN, "vivado.bat").replace("\\", "/")
GLBL   = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v".replace("\\", "/")

PROJECT_ROOT = os.path.abspath(r"C:\Users\Krutadnye\Downloads\Projects\MAC").replace("\\", "/")
NETLIST_DIR  = f"{PROJECT_ROOT}/results/final_run_20261030_1056/netlists_v2"
SAIF_SOBEL_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif/natural"
SAIF_GAUSS_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif_part_c/natural"
PROGRESS_LOG   = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif/progress_v2.log"

os.makedirs(SAIF_SOBEL_DIR, exist_ok=True)
os.makedirs(SAIF_GAUSS_DIR, exist_ok=True)
os.makedirs(os.path.dirname(PROGRESS_LOG), exist_ok=True)

PER_RUN_TIMEOUT_SEC = 5400 # 90 minutes per run

TOTAL_PATCHES = 44032

# Sobel run list in exact requested order
SOBEL_VARIANTS = [
    ("baseline",     0),
    ("cg",           2),
    ("oi",           1),
    ("zs",           3),
    ("zs_oi",        5),
    ("zs_cg",        6),
    ("static_sobel", 8),
    ("oi_cg",        7),
    ("combined",     4)
]

# Part C Gaussian run list in exact requested order
GAUSSIAN_VARIANTS = [
    ("baseline",     0),
    ("cg",           2),
    ("oi",           1),
    ("zs",           3),
    ("zs_cg",        6)
]

def log_progress(msg):
    ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted = f"[{ts}] {msg}"
    print(formatted, flush=True)
    with open(PROGRESS_LOG, "a", encoding="utf-8") as f:
        f.write(formatted + "\n")

def parse_xml_rails(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    rails = []
    tot_dyn_w = 0.0
    tot_stat_w = 0.0
    for section in root.findall('.//section'):
        if section.attrib.get('title') == 'Power Supply Summary':
            for row in section.findall('.//tablerow'):
                cells = [c.attrib.get('contents', '').strip() for c in row.findall('.//tablecell')]
                if len(cells) >= 5:
                    rail = cells[0]
                    try:
                        v = float(cells[1])
                        tot_i = float(cells[2])
                        dyn_i = float(cells[3])
                        stat_i = float(cells[4])
                        p_dyn = v * dyn_i * 1000.0
                        tot_dyn_w += v * dyn_i
                        tot_stat_w += v * stat_i
                        rails.append({
                            "rail": rail,
                            "voltage": v,
                            "total_a": tot_i,
                            "dynamic_a": dyn_i,
                            "static_a": stat_i,
                            "dynamic_mw": p_dyn
                        })
                    except ValueError:
                        pass
    return rails, tot_dyn_w, tot_stat_w

def parse_txt_report(txt_path):
    content = open(txt_path, "r", encoding="utf-8").read()
    conf_m = re.search(r"\|\s*Confidence Level\s*\|\s*(\w+)\s*\|", content)
    cov_m  = re.search(r"\|\s*Design Nets Matched\s*\|\s*(\d+)%\s*\(([\d/]+)\)\s*\|", content)
    tot_onchip_m = re.search(r"\|\s*Total On-Chip Power \(W\)\s*\|\s*([\d\.]+)\s*\|", content)
    dyn_m = re.search(r"\|\s*Dynamic \(W\)\s*\|\s*([\d\.]+)\s*\|", content)
    stat_m = re.search(r"\|\s*Device Static \(W\)\s*\|\s*([\d\.]+)\s*\|", content)
    
    core_dyn_w = None
    for line in content.splitlines():
        if "u_core" in line or "gen_engine" in line:
            parts = [p.strip() for p in line.split("|") if p.strip()]
            if len(parts) >= 2:
                try:
                    val = parts[1].replace("<", "")
                    core_dyn_w = float(val)
                except ValueError:
                    pass
    
    return {
        "confidence": conf_m.group(1) if conf_m else "UNKNOWN",
        "coverage_pct": int(cov_m.group(1)) if cov_m else 0,
        "coverage_ratio": cov_m.group(2) if cov_m else "0/0",
        "tot_onchip_w": float(tot_onchip_m.group(1)) if tot_onchip_m else 0.0,
        "dyn_w": float(dyn_m.group(1)) if dyn_m else 0.0,
        "stat_w": float(stat_m.group(1)) if stat_m else 0.0,
        "core_dyn_w": core_dyn_w
    }

def is_valid_run(run_dir, variant):
    marker_file = f"{run_dir}/COMPLETED.marker"
    summary_file = f"{run_dir}/run_summary.json"
    saif_file = f"{run_dir}/switching_{variant}_timesim.saif"
    rpt_file = f"{run_dir}/power_{variant}_timesim.txt"
    xml_file = f"{run_dir}/power_{variant}_timesim.xml"
    if not (os.path.exists(marker_file) and os.path.exists(summary_file) and 
            os.path.exists(saif_file) and os.path.exists(rpt_file) and os.path.exists(xml_file)):
        return False
    if os.path.getsize(summary_file) == 0:
        return False
    try:
        with open(summary_file, "r") as sf:
            sdata = json.load(sf)
            if sdata.get("total_mismatches", -1) != 0:
                return False
    except Exception:
        return False
    return os.path.getmtime(rpt_file) >= os.path.getmtime(saif_file)

def run_saif_variant(workload, variant, design_sel):
    base_out = SAIF_GAUSS_DIR if workload == "GAUSSIAN" else SAIF_SOBEL_DIR
    run_dir = f"{base_out}/{variant}"
    os.makedirs(run_dir, exist_ok=True)

    if is_valid_run(run_dir, variant):
        log_progress(f"[{workload}] {variant}: Valid COMPLETED.marker found. Skipping rerun.")
        with open(f"{run_dir}/metrics_summary.json", "r", encoding="utf-8") as f:
            return json.load(f)

    log_progress(f"\n================================================================================")
    log_progress(f" >>> [{workload}] STARTING SAIF RUN: {variant.upper()} (DESIGN_SELECT={design_sel}) <<<")
    log_progress(f"================================================================================")

    # Netlist paths
    v_net_dir   = f"{NETLIST_DIR}/{variant}"
    routed_dcp  = f"{v_net_dir}/{variant}_routed.dcp"
    funcsim_v   = f"{v_net_dir}/{variant}_funcsim.v"

    if not (os.path.exists(routed_dcp) and os.path.exists(funcsim_v)):
        log_progress(f"[{workload}] {variant}: Netlist files missing in {v_net_dir}!")
        return None

    # Testbench selection
    if workload == "GAUSSIAN":
        tb_sv  = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_part_c_saif_v2.sv"
        tb_top = "tb_conv2d_engine_part_c_saif_v2"
    else:
        tb_sv  = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_saif_timesim_v2.sv"
        tb_top = "tb_conv2d_engine_saif_timesim_v2"

    snap = f"snap_saif_{workload.lower()}_{variant}"

    # 1. Compile and Elaborate
    log_progress(f"[{workload}] {variant}: Compiling {funcsim_v} with {tb_sv}...")
    try:
        subprocess.run([XVLOG, "-sv", GLBL, funcsim_v, tb_sv], cwd=PROJECT_ROOT, check=True)
        subprocess.run([
            XELAB,
            "-top", tb_top,
            "-top", "glbl",
            "-s", snap,
            "-L", "simprims_ver",
            "-L", "unisims_ver",
            "-debug", "typical"
        ], cwd=PROJECT_ROOT, check=True)
    except Exception as e:
        log_progress(f"[{workload}] {variant}: Elaboration FAILED: {e}")
        return None

    # 2. Simulation & SAIF capture
    log_progress(f"[{workload}] {variant}: Running simulation with SAIF capture (timeout {PER_RUN_TIMEOUT_SEC}s)...")
    local_saif = f"switching_{variant}_timesim.saif"
    target_saif = f"{run_dir}/switching_{variant}_timesim.saif"
    if os.path.exists(local_saif):
        os.remove(local_saif)

    # Determine exact simulation run time from G3 functional netlist check or known exact cycle counts
    if workload == "GAUSSIAN":
        if variant in ["zs", "zs_cg"]:
            # Part C Gaussian ZS: 307805 cycles -> 6,156,100 ns window
            dur_ns = 6156100
        else:
            # Part C Gaussian Baseline/OI/CG: 572416 cycles -> 11,448,320 ns window
            dur_ns = 11448320
    else:
        if variant in ["zs", "zs_oi", "zs_cg", "combined"]:
            # Sobel ZS family: 435432 cycles -> 8,708,640 ns window
            dur_ns = 8708640
        elif variant == "static_sobel":
            # Sobel static: 440320 cycles -> 8,806,400 ns window
            dur_ns = 8806400
        else:
            # Sobel baseline/oi/cg/oi_cg: 572416 cycles -> 11,448,320 ns window
            dur_ns = 11448320

    sim_tcl = f"{run_dir}/run_sim.tcl"
    with open(sim_tcl, "w", encoding="utf-8") as f:
        f.write(f"""run 110 ns
open_saif "{local_saif}"
set dut_scope [lindex [get_scopes -filter {{name =~ *u_dut*}}] 0]
current_scope $dut_scope
log_saif [get_objects -r *]
run {dur_ns} ns
close_saif
run 1000 ns
exit
""")

    t0 = time.time()
    sim_log = f"{run_dir}/xsim.log"
    with open(sim_log, "w", encoding="utf-8") as lf:
        try:
            r = subprocess.run([XSIM, snap, "-tclbatch", sim_tcl], cwd=PROJECT_ROOT,
                               stdin=subprocess.DEVNULL, stdout=lf, stderr=subprocess.STDOUT,
                               timeout=PER_RUN_TIMEOUT_SEC)
        except subprocess.TimeoutExpired:
            log_progress(f"[{workload}] {variant}: TIMED OUT (>90 min). FAILED.")
            return None

    sim_elapsed = time.time() - t0
    log_progress(f"[{workload}] {variant}: Simulation completed in {sim_elapsed:.2f} s")

    if not os.path.exists(local_saif):
        log_progress(f"[{workload}] {variant}: SAIF file was not produced! FAILED.")
        return None

    shutil.copy2(local_saif, target_saif)
    os.remove(local_saif)

    # Copy and verify run_summary.json
    root_summary = f"{PROJECT_ROOT}/run_summary.json"
    run_summary_path = f"{run_dir}/run_summary.json"
    if not os.path.exists(root_summary):
        log_progress(f"[{workload}] {variant}: run_summary.json not produced! FAILED.")
        return None

    shutil.copy2(root_summary, run_summary_path)
    with open(run_summary_path, "r", encoding="utf-8") as sf:
        sim_meta = json.load(sf)

    # 3. Check 1: Mismatches must be exactly 0
    if sim_meta.get("total_mismatches", -1) != 0:
        log_progress(f"[{workload}] {variant}: HARD FAILURE: total_mismatches = {sim_meta.get('total_mismatches')} != 0!")
        return None

    # Check 2: Window duration == measured_wall_cycles * 20.0 ns and matches dur_ns
    expected_dur = sim_meta["measured_wall_cycles"] * 20.0
    if abs(sim_meta["window_dur_ns"] - expected_dur) > 0.1:
        log_progress(f"[{workload}] {variant}: Window duration check FAILED! ({sim_meta['window_dur_ns']} != {expected_dur})")
        return None
    if abs(dur_ns - expected_dur) > 0.1:
        log_progress(f"[{workload}] {variant}: Run duration mismatch! ({dur_ns} != {expected_dur})")
        return None

    log_progress(f"[{workload}] {variant}: Golden Check PASS (0 mismatches, {sim_meta['total_patches']} patches)")
    log_progress(f"[{workload}] {variant}: Window Check PASS ({sim_meta['window_dur_ns']} ns == {sim_meta['measured_wall_cycles']} cyc x 20.0 ns)")

    # 4. Vivado report_power
    log_progress(f"[{workload}] {variant}: Running Vivado report_power...")
    rpt_txt = f"{run_dir}/power_{variant}_timesim.txt"
    rpt_xml = f"{run_dir}/power_{variant}_timesim.xml"
    power_tcl = f"{run_dir}/run_power.tcl"
    strip_path = f"{tb_top}/u_dut"

    with open(power_tcl, "w", encoding="utf-8") as f:
        f.write(f"""open_checkpoint "{routed_dcp}"
read_saif -file "{target_saif}" -strip_path "{strip_path}"
report_power -file "{rpt_txt}"
report_power -format xml -file "{rpt_xml}"
exit
""")

    power_log = f"{run_dir}/power_vivado.log"
    with open(power_log, "w", encoding="utf-8") as lf:
        subprocess.run([VIVADO, "-mode", "batch", "-source", power_tcl], cwd=PROJECT_ROOT,
                       stdin=subprocess.DEVNULL, stdout=lf, stderr=subprocess.STDOUT, timeout=600)

    if not (os.path.exists(rpt_txt) and os.path.exists(rpt_xml)):
        log_progress(f"[{workload}] {variant}: Vivado report_power FAILED to create reports!")
        return None

    # Check 3: Power report timestamp newer than SAIF
    if os.path.getmtime(rpt_txt) < os.path.getmtime(target_saif):
        log_progress(f"[{workload}] {variant}: Power report timestamp is NOT newer than SAIF! FAILED.")
        return None

    txt_meta = parse_txt_report(rpt_txt)
    rails, tot_dyn_w, tot_stat_w = parse_xml_rails(rpt_xml)

    # Check 4: SAIF coverage >= 90%
    if txt_meta["coverage_pct"] < 90:
        log_progress(f"[{workload}] {variant}: SAIF coverage check FAILED ({txt_meta['coverage_pct']}% < 90%)!")
        return None

    # Energy calculations
    dur_ns_val = sim_meta["window_dur_ns"]
    window_s = dur_ns_val * 1e-9
    total_dynamic_energy_j = tot_dyn_w * window_s
    energy_per_patch_uj = (total_dynamic_energy_j / TOTAL_PATCHES) * 1e6
    energy_per_patch_nj = energy_per_patch_uj * 1000.0

    metrics = {
        "workload": workload,
        "variant": variant,
        "design_select": design_sel,
        "total_patches": TOTAL_PATCHES,
        "total_mismatches": 0,
        "measured_wall_cycles": sim_meta["measured_wall_cycles"],
        "cycles_per_patch": sim_meta["measured_wall_cycles"] / TOTAL_PATCHES,
        "window_start_ns": sim_meta["window_start_ns"],
        "window_end_ns": sim_meta["window_end_ns"],
        "window_dur_ns": dur_ns_val,
        "coverage_pct": txt_meta["coverage_pct"],
        "coverage_ratio": txt_meta["coverage_ratio"],
        "confidence": txt_meta["confidence"],
        "xml_total_dynamic_power_w": tot_dyn_w,
        "xml_total_dynamic_power_mw": tot_dyn_w * 1000.0,
        "xml_total_static_power_w": tot_stat_w,
        "xml_total_static_power_mw": tot_stat_w * 1000.0,
        "text_dynamic_power_w": txt_meta["dyn_w"],
        "text_static_power_w": txt_meta["stat_w"],
        "text_core_dynamic_power_w": txt_meta["core_dyn_w"],
        "text_core_dynamic_power_mw": txt_meta["core_dyn_w"] * 1000.0 if txt_meta["core_dyn_w"] is not None else None,
        "total_dynamic_energy_j": total_dynamic_energy_j,
        "energy_per_patch_uj": energy_per_patch_uj,
        "energy_per_patch_nj": energy_per_patch_nj,
        "completed_at": datetime.datetime.now().isoformat()
    }

    with open(f"{run_dir}/metrics_summary.json", "w", encoding="utf-8") as f:
        json.dump(metrics, f, indent=2)

    # Write COMPLETED.marker only after all 4 checks passed
    marker_content = f"""COMPLETED
Timestamp: {datetime.datetime.now().isoformat()}
Workload: {workload}
Variant: {variant}
Total Patches: {TOTAL_PATCHES}
Total Mismatches: 0
Measured Wall Cycles: {sim_meta['measured_wall_cycles']}
Window Duration: {dur_ns_val:.3f} ns
SAIF Coverage: {txt_meta['coverage_pct']}% ({txt_meta['coverage_ratio']})
Confidence Level: {txt_meta['confidence']}
Dynamic Power (XML sum): {tot_dyn_w*1000.0:.3f} mW
Static Power (XML sum): {tot_stat_w*1000.0:.3f} mW
Dynamic Energy/Patch: {energy_per_patch_nj:.4f} nJ ({energy_per_patch_uj:.6f} uJ)
"""
    with open(f"{run_dir}/COMPLETED.marker", "w", encoding="utf-8") as f:
        f.write(marker_content)

    log_progress(f"[{workload}] {variant}: COMPLETED.marker created.")
    log_progress(f"    Dynamic Power: {tot_dyn_w*1000.0:.3f} mW | Energy/patch: {energy_per_patch_nj:.4f} nJ")
    return metrics

def run_all_saif():
    log_progress("================================================================================")
    log_progress(" >>> STARTING G4 SAIF POWER SWEEP WITH WRAPPER V2 <<<")
    log_progress("================================================================================")

    # 1. Primary Sobel Runs
    sobel_results = []
    for var, sel in SOBEL_VARIANTS:
        m = run_saif_variant("SOBEL", var, sel)
        if m is None:
            log_progress(f"[FATAL] Sobel run for {var} FAILED. Stopping sweep.")
            sys.exit(1)
        sobel_results.append(m)

    # Compute % vs baseline for Sobel
    base_sobel = next(r for r in sobel_results if r["variant"] == "baseline")
    for r in sobel_results:
        r["delta_dynamic_power_pct"] = ((r["xml_total_dynamic_power_mw"] - base_sobel["xml_total_dynamic_power_mw"]) / base_sobel["xml_total_dynamic_power_mw"]) * 100.0
        r["delta_energy_per_patch_pct"] = ((r["energy_per_patch_nj"] - base_sobel["energy_per_patch_nj"]) / base_sobel["energy_per_patch_nj"]) * 100.0
        r["speedup_vs_baseline"] = base_sobel["measured_wall_cycles"] / r["measured_wall_cycles"]

    # Save Sobel JSON and Markdown
    sobel_json = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif/summary_sobel_saif_v2.json"
    with open(sobel_json, "w", encoding="utf-8") as f:
        json.dump(sobel_results, f, indent=2)

    sobel_md = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif/summary_sobel_saif_v2.md"
    with open(sobel_md, "w", encoding="utf-8") as f:
        f.write("# G4 Sobel Switching Activity & Power Analysis Summary (Wrapper v2)\n\n")
        f.write("Target: Spartan-7 XC7S15-1FTGB196C @ 50 MHz  \n")
        f.write("Stimulus: 44,032 real Sobel patches (Natural Order, Back-to-Back)  \n")
        f.write("Wrapper: `conv2d_engine_wrapper_v2.sv` (with 1-cycle operand settling pipeline)  \n\n")
        f.write("| Variant | Select | Patches | Mismatches | Cycles | Speedup | Coverage | Conf | Dyn Power (XML mW) | Dyn Power Δ% | Static Power (XML mW) | Energy/Patch (nJ) | Energy Δ% | Core Row (Text mW) |\n")
        f.write("|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|\n")
        for r in sobel_results:
            f.write(f"| `{r['variant']}` | {r['design_select']} | {r['total_patches']} | {r['total_mismatches']} | {r['measured_wall_cycles']} | {r['speedup_vs_baseline']:.4f}x | {r['coverage_pct']}% | {r['confidence']} | {r['xml_total_dynamic_power_mw']:.3f} | {r['delta_dynamic_power_pct']:+.2f}% | {r['xml_total_static_power_mw']:.3f} | {r['energy_per_patch_nj']:.4f} | {r['delta_energy_per_patch_pct']:+.2f}% | {r['text_core_dynamic_power_mw'] if r['text_core_dynamic_power_mw'] is not None else 'N/A'} |\n")

    sobel_csv = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif/summary_sobel_saif_v2.csv"
    with open(sobel_csv, "w", encoding="utf-8") as f:
        f.write("variant,design_select,total_patches,total_mismatches,measured_wall_cycles,speedup_vs_baseline,coverage_pct,confidence,xml_dynamic_power_mw,delta_dynamic_power_pct,xml_static_power_mw,energy_per_patch_nj,delta_energy_per_patch_pct,text_core_dynamic_power_mw\n")
        for r in sobel_results:
            f.write(f"{r['variant']},{r['design_select']},{r['total_patches']},{r['total_mismatches']},{r['measured_wall_cycles']},{r['speedup_vs_baseline']:.4f},{r['coverage_pct']},{r['confidence']},{r['xml_total_dynamic_power_mw']:.3f},{r['delta_dynamic_power_pct']:.2f},{r['xml_total_static_power_mw']:.3f},{r['energy_per_patch_nj']:.4f},{r['delta_energy_per_patch_pct']:.2f},{r['text_core_dynamic_power_mw']}\n")

    # 2. Part C Gaussian Runs
    gauss_results = []
    for var, sel in GAUSSIAN_VARIANTS:
        m = run_saif_variant("GAUSSIAN", var, sel)
        if m is None:
            log_progress(f"[FATAL] Gaussian run for {var} FAILED. Stopping sweep.")
            sys.exit(1)
        gauss_results.append(m)

    # Compute % vs baseline for Gaussian
    base_gauss = next(r for r in gauss_results if r["variant"] == "baseline")
    for r in gauss_results:
        r["delta_dynamic_power_pct"] = ((r["xml_total_dynamic_power_mw"] - base_gauss["xml_total_dynamic_power_mw"]) / base_gauss["xml_total_dynamic_power_mw"]) * 100.0
        r["delta_energy_per_patch_pct"] = ((r["energy_per_patch_nj"] - base_gauss["energy_per_patch_nj"]) / base_gauss["energy_per_patch_nj"]) * 100.0
        r["speedup_vs_baseline"] = base_gauss["measured_wall_cycles"] / r["measured_wall_cycles"]

    gauss_json = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif_part_c/summary_gaussian_saif_v2.json"
    with open(gauss_json, "w", encoding="utf-8") as f:
        json.dump(gauss_results, f, indent=2)

    gauss_md = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif_part_c/summary_gaussian_saif_v2.md"
    with open(gauss_md, "w", encoding="utf-8") as f:
        f.write("# G4 Part C Gaussian Switching Activity & Power Analysis Summary (Wrapper v2)\n\n")
        f.write("Target: Spartan-7 XC7S15-1FTGB196C @ 50 MHz  \n")
        f.write("Stimulus: 44,032 real Gaussian patches (Rule 2 Rescaling, Natural Order, Back-to-Back)  \n")
        f.write("Wrapper: `conv2d_engine_wrapper_v2.sv` (with 1-cycle operand settling pipeline)  \n\n")
        f.write("| Variant | Select | Patches | Mismatches | Cycles | Speedup | Coverage | Conf | Dyn Power (XML mW) | Dyn Power Δ% | Static Power (XML mW) | Energy/Patch (nJ) | Energy Δ% | Core Row (Text mW) |\n")
        f.write("|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|\n")
        for r in gauss_results:
            f.write(f"| `{r['variant']}` | {r['design_select']} | {r['total_patches']} | {r['total_mismatches']} | {r['measured_wall_cycles']} | {r['speedup_vs_baseline']:.4f}x | {r['coverage_pct']}% | {r['confidence']} | {r['xml_total_dynamic_power_mw']:.3f} | {r['delta_dynamic_power_pct']:+.2f}% | {r['xml_total_static_power_mw']:.3f} | {r['energy_per_patch_nj']:.4f} | {r['delta_energy_per_patch_pct']:+.2f}% | {r['text_core_dynamic_power_mw'] if r['text_core_dynamic_power_mw'] is not None else 'N/A'} |\n")

    gauss_csv = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif_part_c/summary_gaussian_saif_v2.csv"
    with open(gauss_csv, "w", encoding="utf-8") as f:
        f.write("variant,design_select,total_patches,total_mismatches,measured_wall_cycles,speedup_vs_baseline,coverage_pct,confidence,xml_dynamic_power_mw,delta_dynamic_power_pct,xml_static_power_mw,energy_per_patch_nj,delta_energy_per_patch_pct,text_core_dynamic_power_mw\n")
        for r in gauss_results:
            f.write(f"{r['variant']},{r['design_select']},{r['total_patches']},{r['total_mismatches']},{r['measured_wall_cycles']},{r['speedup_vs_baseline']:.4f},{r['coverage_pct']},{r['confidence']},{r['xml_total_dynamic_power_mw']:.3f},{r['delta_dynamic_power_pct']:.2f},{r['xml_total_static_power_mw']:.3f},{r['energy_per_patch_nj']:.4f},{r['delta_energy_per_patch_pct']:.2f},{r['text_core_dynamic_power_mw']}\n")

    log_progress("\n================================================================================")
    log_progress(" >>> ALL G4 SAIF SWEEP RUNS SUCCESSFULLY COMPLETED <<<")
    log_progress("================================================================================")

if __name__ == "__main__":
    run_all_saif()
