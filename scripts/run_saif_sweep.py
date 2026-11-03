#!/usr/bin/env python3
# =============================================================================
# File: scripts/run_saif_sweep.py
# Description: Automated, Resumable SAIF Power Analysis Sweep across
#              Natural and Rotated Stimulus Orders for Spartan-7 Conv2D Engines.
# Constraints:
#   - Every number extracted strictly from produced logs and XML/TXT reports
#   - Resumable: Skips runs with COMPLETED.marker
#   - Stdin closed (DEVNULL) on all tool invocations
#   - 90-minute per-run timeout with kill on timeout
#   - Progress logged with timestamps to results/final_run_20261030_1056/saif/progress.log
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
OUT_DIR = f"{PROJECT_ROOT}/results/final_run_20261030_1056/saif"
PROGRESS_LOG = f"{OUT_DIR}/progress.log"

CLOCK_PERIOD_NS = 20.0
TOTAL_PATCHES = 44032
PER_RUN_TIMEOUT_SEC = 5400  # 90 minutes

VARIANTS_NATURAL = [
    ("combined",     4, 347368, 6947480),
    ("zs_cg",        6, 347368, 6947480),
    ("oi_cg",        7, 484352, 9687160),
    ("cg",           2, 484352, 9687160),
    ("zs",           3, 347368, 6947480),
    ("oi",           1, 484352, 9687160),
    ("zs_oi",        5, 347368, 6947480),
    ("static_sobel", 8, 352256, 7045240),
]

VARIANTS_ROTATED = [
    ("baseline",     0, 484352, 9687160),
    ("zs",           3, 347368, 6947480),
    ("zs_cg",        6, 347368, 6947480),
    ("combined",     4, 347368, 6947480),
    ("static_sobel", 8, 352256, 7045240),
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

def is_valid_run(order, variant):
    run_dir = f"{OUT_DIR}/{order}/{variant}"
    marker_file = f"{run_dir}/COMPLETED.marker"
    summary_file = f"{run_dir}/run_summary.json"
    saif_file = f"{run_dir}/switching_{variant}_timesim.saif"
    rpt_file = f"{run_dir}/power_{variant}_timesim.txt"
    if not (os.path.exists(marker_file) and os.path.exists(summary_file) and os.path.exists(saif_file) and os.path.exists(rpt_file)):
        return False
    if os.path.getsize(summary_file) == 0:
        return False
    return os.path.getmtime(rpt_file) >= os.path.getmtime(saif_file)

def is_skipped(order, variant):
    skip_file = f"{OUT_DIR}/SKIP.txt"
    if os.path.exists(skip_file):
        with open(skip_file, "r", encoding="utf-8") as f:
            skipped = [line.strip() for line in f if line.strip()]
        if f"{order}/{variant}" in skipped or variant in skipped:
            return True
    return False

def run_single_variant(order, variant, design_sel, wall_cycles, dur_ns):
    run_dir = f"{OUT_DIR}/{order}/{variant}"
    marker_file = f"{run_dir}/COMPLETED.marker"
    
    if is_skipped(order, variant):
        log_progress(f"[{order.upper()}] {variant} listed in SKIP.txt. SKIPPING.")
        return True

    if is_valid_run(order, variant):
        log_progress(f"[{order.upper()}] {variant} already completed with valid marker. SKIPPING.")
        return True

    log_progress(f"[{order.upper()}] Starting run for {variant} (DESIGN_SELECT={design_sel}, dur={dur_ns}ns)...")
    os.makedirs(run_dir, exist_ok=True)
    
    routed_dcp = f"{run_dir}/{variant}_routed.dcp"
    timesim_v  = f"{run_dir}/{variant}_timesim.v"
    timesim_sdf = f"{run_dir}/{variant}_timesim.sdf"
    
    if variant == "baseline" and os.path.exists(f"{OUT_DIR}/natural_rerun/{variant}/{variant}_routed.dcp"):
        nat_dcp = f"{OUT_DIR}/natural_rerun/{variant}/{variant}_routed.dcp"
        nat_v   = f"{OUT_DIR}/natural_rerun/{variant}/{variant}_timesim.v"
        nat_sdf = f"{OUT_DIR}/natural_rerun/{variant}/{variant}_timesim.sdf"
    else:
        nat_dcp = f"{OUT_DIR}/natural/{variant}/{variant}_routed.dcp"
        nat_v   = f"{OUT_DIR}/natural/{variant}/{variant}_timesim.v"
        nat_sdf = f"{OUT_DIR}/natural/{variant}/{variant}_timesim.sdf"
    
    # 1. Implementation
    if order == "rotated" and os.path.exists(nat_dcp) and os.path.exists(nat_v) and os.path.exists(nat_sdf):
        log_progress(f"[{order.upper()}] {variant}: Reusing routed netlist & SDF from natural run.")
        shutil.copy2(nat_dcp, routed_dcp)
        shutil.copy2(nat_v, timesim_v)
        shutil.copy2(nat_sdf, timesim_sdf)
    elif not (os.path.exists(routed_dcp) and os.path.exists(timesim_v) and os.path.exists(timesim_sdf)):
        log_progress(f"[{order.upper()}] {variant}: Synthesizing and implementing engine...")
        build_tcl = f"{run_dir}/build_impl.tcl"
        tcl_code = f"""create_project -in_memory -part xc7s15ftgb196-1
add_files [list \\
    "{PROJECT_ROOT}/src/conv2d_serial_baseline.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_oi.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_cg.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_zs.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_zs_oi.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_zs_cg.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_oi_cg.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_combined.sv" \\
    "{PROJECT_ROOT}/src/conv2d_serial_static_sobel.sv" \\
    "{PROJECT_ROOT}/src/conv2d_engine_wrapper.sv" \\
]
set_property file_type SystemVerilog [get_files *.sv]
add_files -fileset constrs_1 "{PROJECT_ROOT}/scripts/temp_clk.xdc"

synth_design -top conv2d_engine_wrapper -part xc7s15ftgb196-1 -mode out_of_context -generic DESIGN_SELECT={design_sel}
opt_design
place_design
route_design

write_checkpoint -force "{routed_dcp}"
write_verilog -mode timesim -sdf_anno true -force "{timesim_v}"
write_sdf -force "{timesim_sdf}"
exit
"""
        with open(build_tcl, "w", encoding="utf-8") as f:
            f.write(tcl_code)
        
        cmd = [VIVADO, "-mode", "batch", "-source", build_tcl]
        log_file = f"{run_dir}/build_impl.log"
        with open(log_file, "w", encoding="utf-8") as lf:
            try:
                res = subprocess.run(cmd, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, stdout=lf, stderr=subprocess.STDOUT, timeout=PER_RUN_TIMEOUT_SEC)
            except subprocess.TimeoutExpired:
                log_progress(f"[{order.upper()}] {variant}: Implementation TIMED OUT (>90 min). FAILED.")
                return False
        if res.returncode != 0:
            log_progress(f"[{order.upper()}] {variant}: Implementation FAILED. Check {log_file}")
            return False

    # 2. Compile and Elaborate Simulation
    log_progress(f"[{order.upper()}] {variant}: Compiling and elaborating gate-level simulation...")
    if order == "rotated":
        tb_sv = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_saif_timesim_rotated.sv"
        tb_top = "tb_conv2d_engine_saif_timesim_rotated"
    else:
        tb_sv = f"{PROJECT_ROOT}/tb/tb_conv2d_engine_saif_timesim.sv"
        tb_top = "tb_conv2d_engine_saif_timesim"
    
    # Copy SDF to root so $sdf_annotate finds it
    local_sdf = f"{PROJECT_ROOT}/{variant}_timesim.sdf"
    shutil.copy2(timesim_sdf, local_sdf)
    
    cmd_xvlog = [XVLOG, "-sv", GLBL, timesim_v, tb_sv]
    r = subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=300)
    if r.returncode != 0:
        log_progress(f"[{order.upper()}] {variant}: xvlog FAILED: {r.stderr}")
        if os.path.exists(local_sdf): os.remove(local_sdf)
        return False
            
    cmd_xelab = [
        XELAB,
        "-top", tb_top,
        "-top", "glbl",
        "-s", "tb_timesim_snapshot",
        "-L", "simprims_ver",
        "-L", "unisims_ver",
        "-debug", "typical"
    ]
    r = subprocess.run(cmd_xelab, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=600)
    if r.returncode != 0:
        log_progress(f"[{order.upper()}] {variant}: xelab FAILED: {r.stderr}")
        if os.path.exists(local_sdf): os.remove(local_sdf)
        return False

    # 3. Run Simulation with SAIF logging
    log_progress(f"[{order.upper()}] {variant}: Running timing simulation for {dur_ns} ns (timeout {PER_RUN_TIMEOUT_SEC}s)...")
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
    
    cmd_xsim = [XSIM, "tb_timesim_snapshot", "-tclbatch", sim_tcl]
    sim_log = f"{run_dir}/xsim_timesim.log"
    with open(sim_log, "w", encoding="utf-8") as lf:
        try:
            res = subprocess.run(cmd_xsim, cwd=PROJECT_ROOT, stdin=subprocess.DEVNULL, stdout=lf, stderr=subprocess.STDOUT, timeout=PER_RUN_TIMEOUT_SEC)
        except subprocess.TimeoutExpired:
            log_progress(f"[{order.upper()}] {variant}: xsim TIMED OUT (>90 min). FAILED.")
            if os.path.exists(local_sdf): os.remove(local_sdf)
            return False
    
    if os.path.exists(local_sdf):
        os.remove(local_sdf)
        
    if res.returncode != 0:
        log_progress(f"[{order.upper()}] {variant}: xsim FAILED. Check {sim_log}")
        return False
        
    if os.path.exists(local_saif):
        shutil.copy2(local_saif, target_saif)
        os.remove(local_saif)
    else:
        log_progress(f"[{order.upper()}] {variant}: SAIF file was not produced!")
        return False

    # 4. Power Analysis in Vivado
    log_progress(f"[{order.upper()}] {variant}: Running Vivado report_power...")
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
            log_progress(f"[{order.upper()}] {variant}: Vivado report_power TIMED OUT. FAILED.")
            return False
    if res.returncode != 0:
        log_progress(f"[{order.upper()}] {variant}: Power analysis FAILED. Check {power_log}")
        return False

    # 5. Check Requirements & Parse Outputs
    if not os.path.exists(target_saif):
        log_progress(f"[{order.upper()}] {variant}: Target SAIF missing. FAILED.")
        return False

    if not os.path.exists(rpt_txt) or not os.path.exists(rpt_xml):
        log_progress(f"[{order.upper()}] {variant}: Report files missing. FAILED.")
        return False

    if os.path.getmtime(rpt_txt) < os.path.getmtime(target_saif):
        log_progress(f"[{order.upper()}] {variant}: Power report is older than SAIF file! FAILED.")
        return False
        
    txt_meta = parse_txt_report(rpt_txt)
    rails, tot_dyn_w, tot_stat_w = parse_xml_rails(rpt_xml)
    
    # Validation checks
    if txt_meta["coverage_pct"] < 90:
        log_progress(f"[{order.upper()}] {variant}: FAILED coverage check: {txt_meta['coverage_pct']}% < 90%")
        return False
    if txt_meta["confidence"] == "Low":
        log_progress(f"[{order.upper()}] {variant}: FAILED confidence check: Level is Low")
        return False

    window_s = dur_ns * 1e-9
    total_energy_j = tot_dyn_w * window_s
    energy_per_patch_uj = (total_energy_j / TOTAL_PATCHES) * 1e6
    energy_per_patch_nj = energy_per_patch_uj * 1000.0
    
    summary = {
        "order": order,
        "variant": variant,
        "design_select": design_sel,
        "wall_cycles": wall_cycles,
        "capture_window_ns": dur_ns,
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

    if not os.path.exists(summary_path) or os.path.getsize(summary_path) == 0:
        log_progress(f"[{order.upper()}] {variant}: Verification of run_summary.json failed! FAILED.")
        return False
        
    with open(marker_file, "w", encoding="utf-8") as f:
        f.write(f"COMPLETED {datetime.datetime.now().isoformat()}\n")
        
    log_progress(f"[{order.upper()}] {variant}: COMPLETED! Dyn Power = {tot_dyn_w*1000.0:.4f} mW, E/patch = {energy_per_patch_nj:.4f} nJ")
    return True

def copy_baseline_pilot():
    run_dir = f"{OUT_DIR}/natural/baseline"
    marker_file = f"{run_dir}/COMPLETED.marker"
    if os.path.exists(marker_file):
        return
        
    os.makedirs(run_dir, exist_ok=True)
    src_dcp = f"{OUT_DIR}/baseline_routed.dcp"
    src_v   = f"{OUT_DIR}/baseline_timesim.v"
    src_sdf = f"{OUT_DIR}/baseline_timesim.sdf"
    src_saif = f"{OUT_DIR}/switching_baseline_timesim.saif"
    src_rpt_txt = f"{PROJECT_ROOT}/results/final_run_20261030_1056/reports/power_saif_baseline_pilot.txt"
    src_rpt_xml = f"{PROJECT_ROOT}/results/final_run_20261030_1056/reports/power_saif_baseline_pilot.xml"
    
    if os.path.exists(src_dcp): shutil.copy2(src_dcp, f"{run_dir}/baseline_routed.dcp")
    if os.path.exists(src_v):   shutil.copy2(src_v, f"{run_dir}/baseline_timesim.v")
    if os.path.exists(src_sdf): shutil.copy2(src_sdf, f"{run_dir}/baseline_timesim.sdf")
    if os.path.exists(src_saif): shutil.copy2(src_saif, f"{run_dir}/switching_baseline_timesim.saif")
    
    dest_rpt_txt = f"{run_dir}/power_baseline_timesim.txt"
    dest_rpt_xml = f"{run_dir}/power_baseline_timesim.xml"
    if os.path.exists(src_rpt_txt): shutil.copy2(src_rpt_txt, dest_rpt_txt)
    if os.path.exists(src_rpt_xml): shutil.copy2(src_rpt_xml, dest_rpt_xml)
    
    txt_meta = parse_txt_report(dest_rpt_txt)
    rails, tot_dyn_w, tot_stat_w = parse_xml_rails(dest_rpt_xml)
    
    dur_ns = 9687160
    window_s = dur_ns * 1e-9
    total_energy_j = tot_dyn_w * window_s
    energy_per_patch_uj = (total_energy_j / TOTAL_PATCHES) * 1e6
    energy_per_patch_nj = energy_per_patch_uj * 1000.0
    
    summary = {
        "order": "natural",
        "variant": "baseline",
        "design_select": 0,
        "wall_cycles": 484352,
        "capture_window_ns": dur_ns,
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
    with open(f"{run_dir}/run_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
    with open(marker_file, "w", encoding="utf-8") as f:
        f.write(f"COMPLETED {datetime.datetime.now().isoformat()} (Reused from verified pilot)\n")
    log_progress("[NATURAL] baseline: Pilot copied and verified into natural/baseline/ directory.")

def main():
    log_progress("==================================================================")
    log_progress(" >>> STARTING FULL SAIF SWEEP: 13 RUNS (Spartan-7 @ 50 MHz) <<<")
    log_progress("==================================================================")
    
    copy_baseline_pilot()
    
    for variant, sel, cyc, dur in VARIANTS_NATURAL:
        success = run_single_variant("natural", variant, sel, cyc, dur)
        if not success:
            log_progress(f"[WARNING] Natural run for {variant} failed. Continuing with remaining runs.")
            
    for variant, sel, cyc, dur in VARIANTS_ROTATED:
        success = run_single_variant("rotated", variant, sel, cyc, dur)
        if not success:
            log_progress(f"[WARNING] Rotated run for {variant} failed. Continuing with remaining runs.")

    # Final queue item: Automated flow rerun of baseline under natural order
    log_progress("[NATURAL_RERUN] Starting automated flow rerun of baseline...")
    run_single_variant("natural_rerun", "baseline", 0, 484352, 9687160)
            
    log_progress("==================================================================")
    log_progress(" >>> SAIF SWEEP FINISHED ALL CONFIGURED RUNS <<<")
    log_progress("==================================================================")

if __name__ == "__main__":
    main()
