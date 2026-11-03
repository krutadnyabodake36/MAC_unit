with open("results/final_run_20261030_1056/reports/utilization_benchmark_static_sobel.txt") as f:
    for idx, line in enumerate(f):
        if any(k in line for k in ["Slice LUTs", "LUT as Logic", "Slice Registers", "Register as Flip Flop", "DSPs", "Block RAM"]):
            print(f"utilization line {idx+1}: {line.rstrip()}")

with open("results/final_run_20261030_1056/reports/utilization_hierarchical_static_sobel.txt") as f:
    for idx, line in enumerate(f):
        if any(k in line for k in ["gen_static_sobel", "u_engine", "conv2d_serial_static_sobel"]):
            print(f"hierarchical line {idx+1}: {line.rstrip()}")

with open("results/final_run_20261030_1056/reports/timing_benchmark_static_sobel.txt") as f:
    for idx, line in enumerate(f):
        if "Worst Negative Slack" in line or "WNS(ns)" in line:
            print(f"timing line {idx+1}: {line.rstrip()}")
            # print next line too
            print(f"timing line {idx+2}: {next(f).rstrip()}")

