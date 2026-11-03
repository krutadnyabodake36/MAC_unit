#!/usr/bin/env python3
"""
Power and Energy Telemetry Importer and Analyzer
Parses hardware power meter logs (or manual-entry template), aligns timestamps
to active board execution intervals, and computes trapezoidal energy metrics.
Implements the Strict Uncertainty Rule (O3).
"""

import os
import sys
import csv
import json
import argparse
from datetime import datetime
import numpy as np

METER_RESOLUTION_W = 0.005  # Default 5 mW meter resolution [MANUAL-ENTRY]

def parse_iso(ts_str):
    try:
        # Handle trailing Z or offsets
        s = ts_str.strip().replace("Z", "+00:00")
        return datetime.fromisoformat(s)
    except Exception:
        return None

def compute_trapezoidal_energy(timestamps, powers):
    """
    Computes energy in Joules using the trapezoidal rule:
    E = sum_{i=0}^{N-2} (P_i + P_{i+1}) / 2 * (t_{i+1} - t_i)
    """
    if len(timestamps) < 2:
        return 0.0
    energy_j = 0.0
    for i in range(len(timestamps) - 1):
        dt = (timestamps[i+1] - timestamps[i]).total_seconds()
        if dt > 0:
            avg_p = 0.5 * (powers[i] + powers[i+1])
            energy_j += avg_p * dt
    return energy_j

def process_power_logs(meter_csv_path, run_log_path, output_dir="power", meter_res=METER_RESOLUTION_W):
    os.makedirs(output_dir, exist_ok=True)
    summary_csv = os.path.join(output_dir, "power_summary.csv")
    summary_md = os.path.join(output_dir, "power_summary.md")

    if not os.path.exists(meter_csv_path):
        print(f"[POWER NOTICE] Meter log file not found at '{meter_csv_path}'. Leaving template intact (O4).")
        return False

    # Read meter log
    meter_records = []
    with open(meter_csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            dt = parse_iso(r.get("timestamp", ""))
            try:
                v = float(r.get("volts", 0.0))
                i = float(r.get("amps", 0.0))
                p = v * i
                meter_records.append((dt, v, i, p, r.get("source", "UNKNOWN")))
            except ValueError:
                continue

    if not meter_records:
        print("[POWER NOTICE] No valid numerical records found in meter CSV.")
        return False

    meter_records.sort(key=lambda x: x[0])

    # Read board run log if available
    run_records = []
    if os.path.exists(run_log_path):
        with open(run_log_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for r in reader:
                t_start = parse_iso(r.get("timestamp_start", r.get("timestamp", "")))
                t_end = parse_iso(r.get("timestamp_end", ""))
                design = r.get("design", "unknown")
                image = r.get("image", "unknown")
                patches = int(r.get("patches", 0))
                run_records.append({
                    "design": design,
                    "image": image,
                    "patches": patches,
                    "start": t_start,
                    "end": t_end
                })

    # Segment and summarize
    active_summaries = []
    baseline_powers = []

    # If run records exist, slice by window; otherwise analyze whole file as single segment
    if run_records:
        for r in run_records:
            if not r["start"] or not r["end"]:
                continue
            seg_samples = [m for m in meter_records if r["start"] <= m[0] <= r["end"]]
            if not seg_samples:
                continue
            ts = [m[0] for m in seg_samples]
            vs = np.array([m[1] for m in seg_samples])
            amps = np.array([m[2] for m in seg_samples])
            pws = np.array([m[3] for m in seg_samples])
            energy_j = compute_trapezoidal_energy(ts, pws)
            patches = r["patches"] if r["patches"] > 0 else 1
            e_per_patch_uj = (energy_j / patches) * 1e6

            row = {
                "design": r["design"],
                "image": r["image"],
                "segment_type": "ACTIVE [HOST-MEASURED]",
                "samples": len(seg_samples),
                "mean_volts": float(np.mean(vs)),
                "mean_amps": float(np.mean(amps)),
                "mean_power_w": float(np.mean(pws)),
                "std_power_w": float(np.std(pws)),
                "min_power_w": float(np.min(pws)),
                "max_power_w": float(np.max(pws)),
                "energy_j": energy_j,
                "energy_per_patch_uj": e_per_patch_uj,
                "patches": patches
            }
            active_summaries.append(row)
            if r["design"] == "baseline":
                baseline_powers.append(float(np.mean(pws)))
    else:
        # Generic summary from file
        vs = np.array([m[1] for m in meter_records])
        amps = np.array([m[2] for m in meter_records])
        pws = np.array([m[3] for m in meter_records])
        ts = [m[0] for m in meter_records]
        energy_j = compute_trapezoidal_energy(ts, pws)
        active_summaries.append({
            "design": "synthetic_or_unsegmented",
            "image": "all",
            "segment_type": "ACTIVE [HOST-MEASURED]",
            "samples": len(meter_records),
            "mean_volts": float(np.mean(vs)),
            "mean_amps": float(np.mean(amps)),
            "mean_power_w": float(np.mean(pws)),
            "std_power_w": float(np.std(pws)),
            "min_power_w": float(np.min(pws)),
            "max_power_w": float(np.max(pws)),
            "energy_j": energy_j,
            "energy_per_patch_uj": 0.0,
            "patches": 0
        })

    # Baseline drift calculation
    drift_w = 0.0
    if len(baseline_powers) >= 2:
        drift_w = max(abs(baseline_powers[i] - baseline_powers[i+1]) for i in range(len(baseline_powers)-1))

    # Write summary CSV
    fieldnames = [
        "design", "image", "segment_type", "samples", "mean_volts", "mean_amps",
        "mean_power_w", "std_power_w", "min_power_w", "max_power_w",
        "energy_j", "energy_per_patch_uj", "baseline_drift_w", "uncertainty_status"
    ]
    with open(summary_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in active_summaries:
            diff_from_bl = abs(r["mean_power_w"] - (baseline_powers[0] if baseline_powers else r["mean_power_w"]))
            if diff_from_bl <= drift_w or diff_from_bl <= meter_res:
                status = "UNRESOLVED"
            else:
                status = "SIGNIFICANT"
            r["baseline_drift_w"] = drift_w
            r["uncertainty_status"] = status
            writer.writerow(r)

    # Write Markdown summary
    with open(summary_md, "w", encoding="utf-8") as f:
        f.write("# Whole-Board Hardware Power & Energy Measurement Summary\n\n")
        f.write(f"- **Meter Resolution:** `{meter_res:.4f} W` [MANUAL-ENTRY]\n")
        f.write(f"- **Baseline Thermal Drift:** `{drift_w:.4f} W` [HOST-MEASURED]\n")
        f.write("- **Energy Integration Method:** Trapezoidal Riemann sum: $\\sum_{i} \\frac{P_i + P_{i+1}}{2} \\Delta t_i$ [DERIVED]\n\n")
        f.write("### Strict Uncertainty Rule (O3) Notice\n")
        f.write("> Any difference between two designs that is smaller than the meter resolution or smaller than the baseline-to-baseline drift is reported as **UNRESOLVED**, and no engine-level power or energy claim is made from board data. Post-implementation SAIF switching activity remains the authoritative engine-level power estimate.\n\n")
        f.write("| Design | Image | Samples | Mean V [V] | Mean I [A] | Mean P [W] | Energy [J] | Energy/Patch [uJ] | Status |\n")
        f.write("| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |\n")
        for r in active_summaries:
            f.write(f"| {r['design']} | {r['image']} | {r['samples']} | {r['mean_volts']:.3f} | {r['mean_amps']:.4f} | {r['mean_power_w']:.4f} | {r['energy_j']:.4f} | {r['energy_per_patch_uj']:.2f} | **{r.get('uncertainty_status', 'N/A')}** |\n")

    print(f"[POWER SUCCESS] Exported '{summary_csv}' and '{summary_md}'.")
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process board power meter logs.")
    parser.add_argument("--meter-csv", default="power/meter_log_template.csv", help="Path to meter CSV log")
    parser.add_argument("--run-log", default="logs/board_run_log.csv", help="Path to board run log")
    parser.add_argument("--out-dir", default="power", help="Output directory")
    args = parser.parse_args()
    process_power_logs(args.meter_csv, args.run_log, args.out_dir)

