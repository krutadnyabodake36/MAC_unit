#!/usr/bin/env python3
# ==============================================================================
# File: run_benchmark.py
# Description: Hardware-in-the-Loop Benchmark for Serial 3x3 Convolution Engine
# Target: Invent Logics EDGE Spartan-7 (XC7S15 @ 50 MHz)
# Protocol: 115200 Baud, 8-N-1
#   TX to FPGA : 18 Bytes [9 x Signed Weights, 9 x Signed Pixels]
#   RX from FPGA: 6 Bytes [4-byte Result (LE), 1-byte Cycles, 1-byte Skips]
#
# Usage:
#   Step 1: Program BASELINE bitstream, then run:
#       python run_benchmark.py --design baseline
#
#   Step 2: Program PROPOSED bitstream, then run:
#       python run_benchmark.py --design proposed
#
#   Step 3: Compare results:
#       python run_benchmark.py --compare
# ==============================================================================

import sys
import os
import time
import struct
import random
import argparse
import json

try:
    import serial
    import serial.tools.list_ports
except ImportError:
    print("\n[ERROR] 'pyserial' package is not installed.")
    print("Install: pip install pyserial\n")
    sys.exit(1)


def detect_com_port():
    """Auto-detects FTDI/USB-Serial COM port for Edge Spartan-7 board."""
    ports = list(serial.tools.list_ports.comports())
    if not ports:
        print("[WARNING] No COM ports detected. Defaulting to COM17.")
        return "COM17"

    print("\nDetected COM Ports:")
    ftdi_port = None
    for i, p in enumerate(ports):
        is_ftdi = ("FTDI" in (p.manufacturer or "") or
                   "USB Serial" in p.description or
                   "0403" in (p.hwid or ""))
        marker = " <-- [Edge Spartan-7]" if is_ftdi else ""
        print(f"  [{i+1}] {p.device} - {p.description}{marker}")
        if is_ftdi and not ftdi_port:
            ftdi_port = p.device

    chosen = ftdi_port if ftdi_port else ports[0].device
    print(f"[INFO] Auto-selected: {chosen}\n")
    return chosen


def generate_patches(num_patches, sparsity, seed=42):
    """
    Generates realistic 3x3 Convolution Patches using a Sobel Horizontal kernel.
    Uses a fixed seed so BOTH baseline and proposed tests use the EXACT same data.
    """
    rng = random.Random(seed)

    # Standard 3x3 Sobel Horizontal Edge Detection Filter
    sobel_kernel = [-1, 0, 1, -2, 0, 2, -1, 0, 1]

    patches = []
    for _ in range(num_patches):
        # Generate post-ReLU sparse pixel window
        pixels = []
        for _ in range(9):
            if rng.random() < sparsity:
                pixels.append(0)
            else:
                pixels.append(rng.randint(-128, 127))

        # Compute golden reference
        expected = sum(w * p for w, p in zip(sobel_kernel, pixels))

        # Count non-zero products (where both weight AND pixel are non-zero)
        nz_count = sum(1 for w, p in zip(sobel_kernel, pixels) if w != 0 and p != 0)

        patches.append({
            'weights': sobel_kernel,
            'pixels': pixels,
            'expected': expected,
            'nz_count': nz_count,
            'skip_count': 9 - nz_count
        })

    return patches


def run_benchmark(port_name, baud, patches, design_name):
    """Sends test patches to FPGA and records hardware cycle counts."""

    print("=" * 78)
    print("   SERIAL CONV2D BENCHMARK — REAL HARDWARE CYCLE COUNTER")
    print("=" * 78)
    print(f" Port         : {port_name}")
    print(f" Baud Rate    : {baud} bps (8-N-1)")
    print(f" Design       : {design_name.upper()}")
    print(f" Test Patches : {len(patches)}")
    print(f" Total MACs   : {len(patches) * 9}")
    print(f" Target       : Edge Spartan-7 (XC7S15 @ 50 MHz)")
    print("=" * 78 + "\n")

    try:
        ser = serial.Serial(
            port=port_name,
            baudrate=baud,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=2.0
        )
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        time.sleep(0.1)
    except Exception as e:
        print(f"[FATAL] Cannot open {port_name}: {e}")
        print("Ensure the Edge Spartan-7 board is connected and powered ON.")
        sys.exit(1)

    print(f"[INFO] Connected to {port_name}. Streaming test patches...\n")

    mismatches = 0
    total_hw_cycles = 0
    total_hw_skips = 0
    results = []
    start_time = time.time()

    for idx, patch in enumerate(patches, start=1):
        weights = patch['weights']
        pixels = patch['pixels']
        expected = patch['expected']

        # Pack 18 bytes: 9 weights + 9 pixels (signed 8-bit)
        tx_payload = struct.pack('<9b9b', *weights, *pixels)
        ser.write(tx_payload)

        # Read 6 bytes: 4-byte result + 1-byte cycles + 1-byte skips
        rx_response = ser.read(6)

        if len(rx_response) < 6:
            print(f"\n[ERROR] Timeout at patch {idx}! Got {len(rx_response)}/6 bytes.")
            mismatches += 1
            break

        # Unpack hardware response
        hw_result = struct.unpack('<i', rx_response[:4])[0]
        hw_cycles = rx_response[4]
        hw_skips  = rx_response[5]

        # Verify correctness
        if hw_result != expected:
            print(f"\n[MISMATCH] Patch #{idx}:")
            print(f"  Weights : {weights}")
            print(f"  Pixels  : {pixels}")
            print(f"  Expected: {expected}")
            print(f"  Hardware: {hw_result}")
            mismatches += 1
            if mismatches >= 5:
                print("[ABORT] Too many mismatches.")
                break

        total_hw_cycles += hw_cycles
        total_hw_skips += hw_skips
        results.append({
            'hw_cycles': hw_cycles,
            'hw_skips': hw_skips,
            'nz_count': patch['nz_count'],
            'expected_skips': patch['skip_count']
        })

        # Progress bar
        if idx % max(1, len(patches) // 20) == 0 or idx == len(patches):
            pct = idx / len(patches) * 100
            filled = int(40 * idx / len(patches))
            bar = '#' * filled + '-' * (40 - filled)
            sys.stdout.write(f"\r Progress: [{bar}] {pct:5.1f}% ({idx}/{len(patches)})")
            sys.stdout.flush()

    elapsed = time.time() - start_time
    ser.close()

    n = len(results)
    if n == 0:
        print("\n[ERROR] No results collected.")
        return None

    avg_cycles = total_hw_cycles / n
    avg_skips = total_hw_skips / n
    max_cycles = 9 * n

    print(f"\n\n{'=' * 78}")
    print(f"              BENCHMARK RESULTS — {design_name.upper()} DESIGN")
    print(f"{'=' * 78}")
    print(f" Patches Verified        : {n}")
    print(f" Total MAC Operations    : {n * 9}")
    print(f" Functional Errors       : {mismatches}")
    print(f"{'─' * 78}")
    print(f" Total Compute Cycles    : {total_hw_cycles:,} / {max_cycles:,} (max without skipping)")
    print(f" Average Cycles/Patch    : {avg_cycles:.2f} / 9.00")
    print(f" Total Products Skipped  : {total_hw_skips:,} ({total_hw_skips/(n*9)*100:.1f}%)")
    print(f" Cycle Reduction         : {(1 - total_hw_cycles/max_cycles)*100:.1f}%")
    print(f" Effective Speedup       : {max_cycles / max(total_hw_cycles, 1):.2f}x over baseline")
    print(f" UART Transfer Time      : {elapsed:.2f}s ({n/elapsed:.0f} patches/sec)")
    print(f"{'=' * 78}")

    if mismatches == 0:
        print(" >>> [PASS] 100% BIT-EXACT MATCH ON SILICON <<<")
    else:
        print(" >>> [FAIL] VERIFICATION ERRORS DETECTED <<<")
    print(f"{'=' * 78}")

    # Save results to JSON for comparison
    result_file = f"benchmark_{design_name}.json"
    save_data = {
        'design': design_name,
        'patches': n,
        'total_cycles': total_hw_cycles,
        'total_skips': total_hw_skips,
        'avg_cycles': avg_cycles,
        'avg_skips': avg_skips,
        'max_cycles': max_cycles,
        'mismatches': mismatches,
        'per_patch': results
    }
    with open(result_file, 'w') as f:
        json.dump(save_data, f, indent=2)
    print(f"\n Results saved to: {result_file}")
    print(f" To compare: python run_benchmark.py --compare\n")

    return save_data


def compare_results():
    """Loads baseline and proposed benchmark results and prints comparison."""
    baseline_file = "benchmark_baseline.json"
    proposed_file = "benchmark_proposed.json"

    if not os.path.exists(baseline_file):
        print(f"[ERROR] {baseline_file} not found. Run: python run_benchmark.py --design baseline")
        return 1
    if not os.path.exists(proposed_file):
        print(f"[ERROR] {proposed_file} not found. Run: python run_benchmark.py --design proposed")
        return 1

    with open(baseline_file) as f:
        baseline = json.load(f)
    with open(proposed_file) as f:
        proposed = json.load(f)

    bl_n = baseline['patches']
    pr_n = proposed['patches']

    print("\n" + "=" * 78)
    print("   *** BASELINE vs PROPOSED — HARDWARE CYCLE COUNT COMPARISON ***")
    print("=" * 78)
    print(f" {'Metric':<36} {'BASELINE':>15} {'PROPOSED':>15}")
    print(f" {'─' * 36} {'─' * 15} {'─' * 15}")
    print(f" {'Patches Tested':<36} {bl_n:>15,} {pr_n:>15,}")
    print(f" {'Total MAC Ops':<36} {bl_n*9:>15,} {pr_n*9:>15,}")
    print(f" {'Total Compute Cycles':<36} {baseline['total_cycles']:>15,} {proposed['total_cycles']:>15,}")
    print(f" {'Avg Cycles per Patch':<36} {baseline['avg_cycles']:>15.2f} {proposed['avg_cycles']:>15.2f}")
    print(f" {'Products Skipped':<36} {baseline['total_skips']:>15,} {proposed['total_skips']:>15,}")
    print(f" {'Functional Errors':<36} {baseline['mismatches']:>15} {proposed['mismatches']:>15}")

    # Compute speedup
    bl_cyc = baseline['total_cycles']
    pr_cyc = proposed['total_cycles']
    if pr_cyc > 0:
        speedup = bl_cyc / pr_cyc
        reduction = (1 - pr_cyc / bl_cyc) * 100
    else:
        speedup = float('inf')
        reduction = 100.0

    print(f"\n {'─' * 78}")
    print(f" {'CYCLE REDUCTION':<36} {'':>15} {reduction:>14.1f}%")
    print(f" {'SPEEDUP (Baseline / Proposed)':<36} {'':>15} {speedup:>14.2f}x")
    print(f" {'─' * 78}")

    if speedup > 1.0:
        print(f"\n ✅ PROPOSED is {speedup:.2f}x FASTER than BASELINE on real silicon!")
        print(f"    Saved {bl_cyc - pr_cyc:,} compute cycles across {min(bl_n,pr_n)} patches.")
    elif speedup == 1.0:
        print(f"\n ⚠️  Both designs use identical cycle counts.")
    else:
        print(f"\n ❌ PROPOSED is SLOWER than BASELINE.")

    # Per-patch histogram
    if len(baseline.get('per_patch', [])) > 0 and len(proposed.get('per_patch', [])) > 0:
        print(f"\n {'─' * 78}")
        print(" Per-Patch Cycle Distribution (first 20 patches):")
        print(f" {'Patch':>6} {'BL Cycles':>12} {'PR Cycles':>12} {'Skipped':>10} {'Speedup':>10}")
        print(f" {'─'*6} {'─'*12} {'─'*12} {'─'*10} {'─'*10}")

        n_show = min(20, len(baseline['per_patch']), len(proposed['per_patch']))
        for i in range(n_show):
            bl_c = baseline['per_patch'][i]['hw_cycles']
            pr_c = proposed['per_patch'][i]['hw_cycles']
            pr_s = proposed['per_patch'][i]['hw_skips']
            sp = bl_c / pr_c if pr_c > 0 else float('inf')
            print(f" {i+1:>6} {bl_c:>12} {pr_c:>12} {pr_s:>10} {sp:>9.1f}x")

    print(f"\n{'=' * 78}\n")
    return 0


def main():
    parser = argparse.ArgumentParser(
        description="Serial Conv2D Benchmark — Hardware Cycle Counter Comparison",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Step 1: Program BASELINE bitstream, then:
    python run_benchmark.py --design baseline

  Step 2: Program PROPOSED bitstream, then:
    python run_benchmark.py --design proposed

  Step 3: Compare results:
    python run_benchmark.py --compare
        """
    )
    parser.add_argument("--port", type=str, default=None,
                        help="Serial port (e.g. COM17)")
    parser.add_argument("--baud", type=int, default=115200,
                        help="Baud rate (default: 115200)")
    parser.add_argument("--patches", type=int, default=200,
                        help="Number of 3x3 patches to test (default: 200)")
    parser.add_argument("--sparsity", type=float, default=0.65,
                        help="Post-ReLU activation sparsity (default: 0.65)")
    parser.add_argument("--design", type=str, default=None,
                        choices=["baseline", "proposed"],
                        help="Which design is currently programmed on the FPGA")
    parser.add_argument("--compare", action="store_true",
                        help="Compare saved baseline vs proposed results")
    parser.add_argument("--seed", type=int, default=42,
                        help="Random seed (default: 42, ensures same data for both runs)")
    args = parser.parse_args()

    # Mode: Compare
    if args.compare:
        return compare_results()

    # Mode: Run benchmark
    if not args.design:
        print("[ERROR] Specify --design baseline or --design proposed")
        print("Or use --compare to compare saved results.")
        return 1

    port = args.port if args.port else detect_com_port()

    # Generate test data with fixed seed (identical for both runs)
    patches = generate_patches(args.patches, args.sparsity, args.seed)

    total_expected_nz = sum(p['nz_count'] for p in patches)
    total_expected_skip = sum(p['skip_count'] for p in patches)
    avg_sparsity = total_expected_skip / (len(patches) * 9) * 100

    print(f"[INFO] Generated {len(patches)} patches (seed={args.seed})")
    print(f"[INFO] Expected sparsity: {avg_sparsity:.1f}% zero-products")
    print(f"[INFO] Expected non-zero MACs: {total_expected_nz}/{len(patches)*9}\n")

    result = run_benchmark(port, args.baud, patches, args.design)
    return 0 if result and result['mismatches'] == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
