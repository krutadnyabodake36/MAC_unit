#!/usr/bin/env python3
# =============================================================================
# File: scripts/run_part_c_saif_sweep.py
# Description: Automated, Resumable SAIF Power & Gate-Level Verification Sweep
#              for Part C Dense Gaussian Kernel on 44,032 Rule 2 Patches.
# Variants: baseline (natural_rerun netlist), cg, zs, zs_cg, oi.
# =============================================================================

import os
import sys
import shutil
import subprocess
import datetime
import xml.etree.ElementTree as ET
import json
import re

VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")
VIVADO = os.path.join(VIVADO_BIN, "vivado.bat").replace("\\", "/")
GLBL   = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v".replace("\\", "/")

PROJECT_ROOT = os.path.abspath(r"C:\Users\Krutadnye\Downloads\Projects\MAC").replace("\\", "/")
SAIF_BASE_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif"
OUT_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif_part_c"
PROGRESS_LOG = f"{OUT_DIR}/progress.log"

CLOCK_PERIOD_NS = 20.0
TOTAL_PATCHES = 44032
PER_RUN_TIMEOUT_SEC = 5400  # 90 minutes

# Variants to run on Part C Dense Gaussian: (name, design_select, wall_cycles, dur_ns, source_folder)
VARIANTS_PART_C = [
    ("baseline", 0, 484352, 9687160, f"{SAIF_BASE_DIR}/natural_rerun/baseline"),
    ("cg",       2, 484352, 9687160, f"{SAIF_BASE_DIR}/natural/cg"),
    ("zs",       3, 219741, 4394940, f"{SAIF_BASE_DIR}/natural/zs"),
    ("zs_cg",    6, 219741, 4394940, f"{SAIF_BASE_DIR}/natural/zs_cg"),
    ("oi",       1, 484352, 9687160, f"{SAIF_BASE_DIR}/natural/oi"),
]

def log_progress(msg):
    ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted = f"[{ts}] {msg}"
    print(formatted, flush=True)
    os.makedirs(os.path.dirname(PROGRESS_LOG), exist_ok=True)
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

def is_valid_run(variant):
    run_dir = f"{OUT_DIR}/{variant}"
    marker_file = f"{run_dir}/COMPLETED.marker"
    summary_file = f"{run_dir}/run_summary.json"
    saif_file = f"{run_dir}/switching_{variant}_timesim.saif"
    rpt_file = f"{run_dir}/power_{variant}_timesim.txt"
    if not (os.path.exists(marker_file) and os.path.exists(summary_file) and os.path.exists(saif_file) and os.path.exists(rpt_file)):
        return False
    if os.path.getsize(summary_file) == 0:
        return False
    return os.path.getmtime(rpt_file) >= os.path.getmtime(saif_file)

def run_part_c_variant(variant, design_sel, wall_cycles, dur_ns, src_dir):
    run_dir = f"{OUT_DIR}/{variant}"
    marker_file = f"{run_dir}/COMPLETED.marker"
    
    if is_valid_run(variant):
        log_progress(f"[PART_C] {variant} already completed with valid marker. SKIPPING.")
        return True

    log_progress(f"[PART_C] Starting run for {variant} (cycles={wall_cycles}, dur={dur_ns}ns)...")
    os.makedirs(run_dir, exist_ok=True)
    
    routed_dcp  = f"{run_dir}/{variant}_routed.dcp"
    timesim_v   = f"{run_dir}/{variant}_timesim.v"
    timesim_sdf = f"{run_dir}/{variant}_timesim.sdf"
    
    src_dcp = f"{src_dir}/{variant}_routed.dcp"
    src_v   = f"{src_dir}/{variant}_timesim.v"
    src_sdf = f"{src_dir}/{variant}_timesim.sdf"
    
    log_progress(f"[PART_C] {variant}: Reusing routed netlist and SDF from {src_dir}")
    shutil.copy2(src_dcp, routed_dcp)
    shutil.copy2(src_v, timesim_v)
    shutil.copy2(src_sdf, timesim_sdf)
    
    # 1. Compile & Elaborate
    tb_sv = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_part_c_saif.sv"
    tb_top = "tb_conv2d_engine_part_c_saif"
    
    local_sdf = f"{PROJECT_ROOT}/{variant}_timesim.sdf"
    shutil.copy2(timesim_sdf, local_sdf)
    
    cmd_xvlog = [XVLOG, "-sv", GLBL, timesim_v, tb_sv]
    r = subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=300)
    if r.returncode != 0:
        log_progress(f"[PART_C] {variant}: xvlog FAILED: {r.stderr}")
        if os.path.exists(local_sdf): os.remove(local_sdf)
        return False
        
    cmd_xelab = [
        XELAB,
        "-top", tb_top,
        "-top", "glbl",
        "-s", "tb_part_c_snapshot",
        "-L", "simprims_ver",
        "-L", "unisims_ver",
        "-debug", "typical"
    ]
    r = subprocess.run(cmd_xelab, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=600)
    if r.returncode != 0:
        log_progress(f"[PART_C] {variant}: xelab FAILED: {r.stderr}")
        if os.path.exists(local_sdf): os.remove(local_sdf)
        return False

    # 2. Simulation with SAIF logging and functional check
    log_progress(f"[PART_C] {variant}: Running timing simulation for {dur_ns} ns...")
    local_saif = f"switching_{variant}_timesim.saif"
    target_saif = f"{run_dir}/switching_{variant}_timesim.saif"
    if os.path.exists(local_saif):
        os.remove(local_saif)
        
    sim_tcl = f"{run_dir}/run_sim.tcl"
    with open(sim_tcl, "w", encoding="utf-8") as f:
        f.write(f"""open_saif "{local_saif}"
set dut_scope [lindex [get_scopes -filter {{name =~ *u_dut*}}] 0]
current_scope $dut_scope
log_saif [get_objects -r *]
run {dur_ns} ns
close_saif
exit
""")
    
    cmd_xsim = [XSIM, "tb_part_c_snapshot", "-tclbatch", sim_tcl]
    sim_log = f"{run_dir}/xsim_timesim.log"
    with open(sim_log, "w", encoding="utf-8") as lf:
        try:
            res = subprocess.run(cmd_xsim, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, stdout=lf, stderr=subprocess.STDOUT, timeout=PER_RUN_TIMEOUT_SEC)
        except subprocess.TimeoutExpired:
            log_progress(f"[PART_C] {variant}: xsim TIMED OUT (>90 min). FAILED.")
            if os.path.exists(local_sdf): os.remove(local_sdf)
            return False
            
    if os.path.exists(local_sdf):
        os.remove(local_sdf)
        
    if res.returncode != 0:
        log_progress(f"[PART_C] {variant}: xsim FAILED. Check {sim_log}")
        return False
        
    if os.path.exists(local_saif):
        shutil.copy2(local_saif, target_saif)
        os.remove(local_saif)
    else:
        log_progress(f"[PART_C] {variant}: SAIF file was not produced!")
        return False

    # Check functional result in sim_log
    log_content = open(sim_log, "r", encoding="utf-8").read()
    mismatches_m = re.search(r"Total Output Mismatches\s*:\s*(\d+)", log_content)
    total_mismatches = int(mismatches_m.group(1)) if mismatches_m else -1
    log_progress(f"[PART_C] {variant}: Simulation finished. Mismatches = {total_mismatches}")
    if total_mismatches != 0:
        log_progress(f"[PART_C] {variant}: NOTE - Gate-level functional check reported {total_mismatches} mismatches.")

    # 3. Report Power
    log_progress(f"[PART_C] {variant}: Running Vivado report_power...")
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
    
    cmd_vivado = [VIVADO, "-mode", "batch", "-source", power_tcl]
    power_log = f"{run_dir}/power_vivado.log"
    with open(power_log, "w", encoding="utf-8") as lf:
        try:
            res = subprocess.run(cmd_vivado, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, stdout=lf, stderr=subprocess.STDOUT, timeout=600)
        except subprocess.TimeoutExpired:
            log_progress(f"[PART_C] {variant}: report_power TIMED OUT. FAILED.")
            return False
            
    if res.returncode != 0:
        log_progress(f"[PART_C] {variant}: Power analysis FAILED. Check {power_log}")
        return False

    # 4. Verify & Write Summary
    if not (os.path.exists(rpt_txt) and os.path.exists(rpt_xml) and os.path.exists(target_saif)):
        log_progress(f"[PART_C] {variant}: Required files missing. FAILED.")
        return False
        
    if os.path.getmtime(rpt_txt) < os.path.getmtime(target_saif):
        log_progress(f"[PART_C] {variant}: Report older than SAIF. FAILED.")
        return False
        
    txt_meta = parse_txt_report(rpt_txt)
    rails, tot_dyn_w, tot_stat_w = parse_xml_rails(rpt_xml)
    
    if txt_meta["coverage_pct"] < 90:
        log_progress(f"[PART_C] {variant}: FAILED coverage check: {txt_meta['coverage_pct']}% < 90%")
        return False
    if txt_meta["confidence"] == "Low":
        log_progress(f"[PART_C] {variant}: FAILED confidence check: Level is Low")
        return False
        
    window_s = dur_ns * 1e-9
    total_energy_j = tot_dyn_w * window_s
    energy_per_patch_uj = (total_energy_j / TOTAL_PATCHES) * 1e6
    energy_per_patch_nj = energy_per_patch_uj * 1000.0
    
    summary = {
        "order": "part_c_natural",
        "variant": variant,
        "design_select": design_sel,
        "wall_cycles": wall_cycles,
        "capture_window_ns": dur_ns,
        "total_mismatches": total_mismatches,
        "confidence": txt_meta["confidence"],
        "coverage_pct": txt_meta["coverage_pct"],
        "coverage_ratio": txt_meta["coverage_ratio"],
        "text_tot_onchip_power_w": txt_meta["tot_onchip_w"],
        "text_dynamic_power_w": txt_meta["dyn_w"],
        "text_static_power_w": txt_meta["stat_w"],
        "text_core_dynamic_power_w": txt_meta["core_dyn_w"],
        "xml_total_dynamic_power_w": tot_dyn_w,
        "xml_total_dynamic_power_mw": tot_dyn_w * 1000.0,
        "xml_total_static_power_w": tot_stat_w,
        "xml_total_static_power_mw": tot_stat_w * 1000.0,
        "total_dynamic_energy_j": total_energy_j,
        "energy_per_patch_uj": energy_per_patch_uj,
        "energy_per_patch_nj": energy_per_patch_nj,
        "rails": rails
    }
    
    summary_path = f"{run_dir}/run_summary.json"
    with open(summary_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
        
    with open(marker_file, "w", encoding="utf-8") as f:
        f.write(f"COMPLETED {datetime.datetime.now().isoformat()}\n")
        
    log_progress(f"[PART_C] {variant}: COMPLETED! Dyn Power = {tot_dyn_w*1000.0:.4f} mW, E/patch = {energy_per_patch_nj:.4f} nJ, Mismatches = {total_mismatches}")
    return True

def main():
    log_progress("==================================================================")
    log_progress(" >>> STARTING PART C DENSE GAUSSIAN SAIF SWEEP: 5 RUNS <<<")
    log_progress("==================================================================")
    
    for variant, sel, cyc, dur, src_dir in VARIANTS_PART_C:
        success = run_part_c_variant(variant, sel, cyc, dur, src_dir)
        if not success:
            log_progress(f"[WARNING] Part C run for {variant} failed. Continuing.")
            
    log_progress("==================================================================")
    log_progress(" >>> PART C DENSE GAUSSIAN SAIF SWEEP FINISHED <<<")
    log_progress("==================================================================")

if __name__ == "__main__":
    main()

