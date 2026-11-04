#!/usr/bin/env python3
"""
Dump all factual parameters for all 27 runs into structured Markdown.
Zero assumed or guessed values.
"""

import json

with open("board_results/all_27_runs_raw_dump.json", "r", encoding="utf-8") as f:
    data = json.load(f)

variants = ["baseline", "zs", "oi", "cg", "zs_cg", "oi_cg", "zs_oi", "combined", "static_sobel"]
images = ["image1", "image2", "image3"]

print("| Variant | Image | Patches | Wall Time (s) | Throughput (pps) | Total Cyc | Mean Cyc | Min Cyc | Max Cyc | Total Skp | Mean Skp | RT Mean (ms) | RT Med (ms) | RT p95 (ms) | RT Max (ms) | Sum Mis | Cyc Mis | Skp Mis | Diff Px | Timeouts | Status |")
print("| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |")

for v in variants:
    for img in images:
        s = data[v][img]["run_summary"]
        c = data[v][img]["compare"]
        p = s["patches"]
        t = s["total_host_time_s"]
        pps = s["patches_per_second"]
        t_cyc = s["total_compute_cycles"]
        m_cyc = s["mean_compute_cycles_per_patch"]
        min_c = s["min_compute_cycles_per_patch"]
        max_c = s["max_compute_cycles_per_patch"]
        t_skp = s["total_skip_count"]
        m_skp = s["mean_skip_count_per_patch"]
        rt_m = s["per_patch_round_trip_s"]["mean"] * 1000.0
        rt_med = s["per_patch_round_trip_s"]["median"] * 1000.0
        rt_p95 = s["per_patch_round_trip_s"]["p95"] * 1000.0
        rt_max = s["per_patch_round_trip_s"]["max"] * 1000.0
        sum_m = c["sum_mismatches"]
        cyc_m = c["cycle_mismatches"]
        skp_m = c["skip_mismatches"]
        diff_px = c["differing_pixels"]
        tout = s["uart_metrics"]["timeouts"]
        stat = c["status"]
        print(f"| `{v}` | `{img}` | {p:,} | {t:.2f} | {pps:.2f} | {t_cyc:,} | {m_cyc:.3f} | {min_c} | {max_c} | {t_skp:,} | {m_skp:.3f} | {rt_m:.2f} | {rt_med:.2f} | {rt_p95:.2f} | {rt_max:.2f} | {sum_m} | {cyc_m} | {skp_m} | {diff_px} | {tout} | **{stat}** |")


