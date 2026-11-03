#!/usr/bin/env python3
"""
scripts/board_patch_runner.py
Physical FPGA Hardware & Software Model Vector File Runner.

Streams 18-byte vector frames (9 weights + 9 pixels) over USB-UART to the
Invent Logics EDGE Spartan-7 board at 115,200 baud, reads 6-byte responses,
and logs:
- Patch index
- Received convolution sum vs golden
- Received hardware compute cycles
- Received hardware skip count

Supports:
- Any arbitrary .vec file (W1 real images or Part C Gaussian sweeps)
- Simulation (--sim) or Physical Board (--port COMx)
- Output CSV log and JSON summary
"""

import os
import sys
import time
import argparse
import struct
import json

def parse_args():
    parser = argparse.ArgumentParser(description="FPGA Board Vector Streamer")
    parser.add_argument("vec_file", help="Path to input .vec file")
    parser.add_argument("--port", default="COM17", help="Serial port (default: COM17)")
    parser.add_argument("--baud", type=int, default=115200, help="Baud rate (default: 115200)")
    parser.add_argument("--design", default="static_sobel", help="Target design name")
    parser.add_argument("--sim", action="store_true", help="Software simulation mode")
    parser.add_argument("--out-csv", default=None, help="Output CSV log file path")
    parser.add_argument("--max-patches", type=int, default=None, help="Max patches to process")
    return parser.parse_args()

def run_simulation(vec_lines, design, max_patches):
    results = []
    sobel_w = [-1, 0, 1, -2, 0, 2, -1, 0, 1]

    count = 0
    for line in vec_lines:
        parts = line.strip().split()
        if len(parts) < 19:
            continue
        w = [int(x) for x in parts[0:9]]
        p = [int(x) for x in parts[9:18]]
        golden = int(parts[18])

        nz_count = sum(1 for i in range(9) if w[i] != 0 and p[i] != 0)
        prod_sum = sum(w[i] * p[i] for i in range(9))

        if design == "baseline":
            cyc = 9
            skp = 0
        elif design in ["oi", "cg", "oi_cg"]:
            cyc = 9
            skp = 9 - nz_count
        elif design in ["zs", "combined", "zs_oi", "zs_cg"]:
            cyc = nz_count
            skp = 9 - nz_count
        elif design == "static_sobel":
            cyc = 6
            skp = 0
        else:
            cyc = 9
            skp = 0

        results.append({
            "patch_idx": count,
            "golden": golden,
            "hw_sum": prod_sum,
            "hw_cycles": cyc,
            "hw_skips": skp,
            "match": (prod_sum == golden)
        })
        count += 1
        if max_patches and count >= max_patches:
            break

    return results

def run_hardware(port, baud, vec_lines, max_patches):
    try:
        import serial
    except ImportError:
        print("[ERROR] pyserial is required for hardware runs. Install via: pip install pyserial")
        sys.exit(1)

    print(f"[HW] Opening {port} at {baud} baud...")
    ser = serial.Serial(port, baud, timeout=2.0)
    time.sleep(0.1)
    ser.reset_input_buffer()
    ser.reset_output_buffer()

    results = []
    count = 0
    t0 = time.time()

    for line in vec_lines:
        parts = line.strip().split()
        if len(parts) < 19:
            continue
        w = [int(x) for x in parts[0:9]]
        p = [int(x) for x in parts[9:18]]
        golden = int(parts[18])

        # Pack 18 signed int8 bytes
        req_bytes = struct.pack("9b9b", *w, *p)
        ser.write(req_bytes)

        # Read 6 response bytes
        resp_bytes = ser.read(6)
        if len(resp_bytes) < 6:
            print(f"[TIMEOUT] Received only {len(resp_bytes)} bytes on patch {count}")
            break

        hw_sum, hw_cyc, hw_skp = struct.unpack("<ibb", resp_bytes)

        results.append({
            "patch_idx": count,
            "golden": golden,
            "hw_sum": hw_sum,
            "hw_cycles": hw_cyc,
            "hw_skips": hw_skp,
            "match": (hw_sum == golden)
        })

        count += 1
        if max_patches and count >= max_patches:
            break

        if count % 1000 == 0:
            print(f"  Processed {count} patches ({time.time() - t0:.1f}s)...")

    ser.close()
    return results

def main():
    args = parse_args()

    if not os.path.exists(args.vec_file):
        print(f"[ERROR] Vector file not found: {args.vec_file}")
        sys.exit(1)

    with open(args.vec_file, "r") as f:
        lines = f.readlines()

    print(f"Loaded {len(lines)} vectors from {args.vec_file}")

    if args.sim:
        print(f"Running SIMULATION mode for design: {args.design}")
        results = run_simulation(lines, args.design, args.max_patches)
    else:
        print(f"Running PHYSICAL HARDWARE mode on {args.port} at {args.baud} baud")
        results = run_hardware(args.port, args.baud, lines, args.max_patches)

    total_patches = len(results)
    mismatches = sum(1 for r in results if not r["match"])
    total_cyc = sum(r["hw_cycles"] for r in results)
    total_skp = sum(r["hw_skips"] for r in results)

    print("\n================ RUN SUMMARY ================")
    print(f"Target Design  : {args.design}")
    print(f"Patches Tested : {total_patches}")
    print(f"Sum Mismatches : {mismatches}")
    print(f"Total Cycles   : {total_cyc} (Avg: {total_cyc/total_patches:.2f} cyc/patch)")
    print(f"Total Skips    : {total_skp} (Avg: {total_skp/total_patches:.2f} skips/patch)")
    print(f"Result         : {'PASS' if mismatches == 0 else 'FAIL'}")
    print("=============================================")

    if args.out_csv:
        import csv
        with open(args.out_csv, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["patch_idx", "golden", "hw_sum", "hw_cycles", "hw_skips", "match"])
            writer.writeheader()
            writer.writerows(results)
        print(f"Wrote CSV log to: {args.out_csv}")

if __name__ == "__main__":
    main()

