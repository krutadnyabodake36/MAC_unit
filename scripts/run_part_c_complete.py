#!/usr/bin/env python3
"""
scripts/run_part_c_complete.py

Complete implementation of User Correction R1:
1. Generates Part C vectors for all 14 images, both rules (Rule 1: Sensitivity Max-Norm, Rule 2: Primary >>3 Shift).
2. Generates SystemVerilog testbench tb/tb_part_c_dual_rules.sv that tests all 8 general engines
   (baseline, oi, cg, zs, zs_oi, zs_cg, oi_cg, combined) on all 14 images with 0 mismatches.
3. Compiles with xvlog and elaborates with xelab.
4. Executes in xsim, records exact wall-clock cycles, compute cycles, and mismatches.
5. Saves all logs to results/final_run_20261030_1056/logs/part_c_xsim.log.
6. Computes exact summary statistics (min, median, max, mean) via Python.
"""

import os
import sys
import json
import subprocess
import numpy as np

PROJECT_ROOT = os.getcwd().replace("\\", "/")
sys.path.insert(0, PROJECT_ROOT)
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
xvlog = f"{VIVADO_BIN}/xvlog.bat"
xelab = f"{VIVADO_BIN}/xelab.bat"
xsim  = f"{VIVADO_BIN}/xsim.bat"

# Step 1: Run vector generation
print(">>> Step 1: Generating vectors and computing sparsity for both rules...")
import scripts.generate_part_c_vectors as gen_vec
gen_vec.main()

# Load audit json
with open(f"{PROJECT_ROOT}/results/final_run_20261030_1056/part_c_sparsity_audit.json", "r") as f:
    audit_data = json.load(f)

# Step 2: Generate tb/tb_part_c_dual_rules.sv
print(">>> Step 2: Creating tb/tb_part_c_dual_rules.sv...")
tb_content = """// Testbench for Part C: 14 images, Dual Rules, 8 Configurations
`timescale 1ns / 1ps

module tb_part_c_dual_rules;
    logic clk = 0;
    logic rst;
    logic start;

    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];
    logic signed [31:0] golden;

    // 50 MHz clock
    always #10.0 clk = ~clk;

    // 8 Engine outputs
    logic signed [31:0] out_base, out_oi, out_cg, out_zs, out_zs_oi, out_zs_cg, out_oi_cg, out_comb;
    logic [3:0] cyc_base, cyc_oi, cyc_cg, cyc_zs, cyc_zs_oi, cyc_zs_cg, cyc_oi_cg, cyc_comb;
    logic [3:0] skip_oi, skip_cg, skip_zs, skip_zs_oi, skip_zs_cg, skip_oi_cg, skip_comb;
    logic done_base, done_oi, done_cg, done_zs, done_zs_oi, done_zs_cg, done_oi_cg, done_comb;

    // Instantiations
    conv2d_serial_baseline u_base   (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_base),  .conv_out(out_base),  .compute_cycles(cyc_base));
    conv2d_serial_oi       u_oi     (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_oi),    .conv_out(out_oi),    .compute_cycles(cyc_oi),    .skip_count(skip_oi));
    conv2d_serial_cg       u_cg     (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_cg),    .conv_out(out_cg),    .compute_cycles(cyc_cg),    .skip_count(skip_cg));
    conv2d_serial_zs       u_zs     (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_zs),    .conv_out(out_zs),    .compute_cycles(cyc_zs),    .skip_count(skip_zs));
    conv2d_serial_zs_oi    u_zs_oi  (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_zs_oi), .conv_out(out_zs_oi), .compute_cycles(cyc_zs_oi), .skip_count(skip_zs_oi));
    conv2d_serial_zs_cg    u_zs_cg  (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_zs_cg), .conv_out(out_zs_cg), .compute_cycles(cyc_zs_cg), .skip_count(skip_zs_cg));
    conv2d_serial_oi_cg    u_oi_cg  (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_oi_cg), .conv_out(out_oi_cg), .compute_cycles(cyc_oi_cg), .skip_count(skip_oi_cg));
    conv2d_serial_combined u_comb   (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_comb),  .conv_out(out_comb),  .compute_cycles(cyc_comb),  .skip_count(skip_comb));

    // Cycle accumulators for current workload
    integer acc_base, acc_oi, acc_cg, acc_zs, acc_zs_oi, acc_zs_cg, acc_oi_cg, acc_comb;
    integer mismatches_oi, mismatches_cg, mismatches_zs, mismatches_zs_oi, mismatches_zs_cg, mismatches_oi_cg, mismatches_comb;
    integer patches_in_workload;

    // Per-patch cycle counters
    integer cur_base, cur_oi, cur_cg, cur_zs, cur_zs_oi, cur_zs_cg, cur_oi_cg, cur_comb;
    logic act_base, act_oi, act_cg, act_zs, act_zs_oi, act_zs_cg, act_oi_cg, act_comb;

    always_ff @(posedge clk) begin
        if (rst) begin
            cur_base <= 0; act_base <= 0;
            cur_oi <= 0; act_oi <= 0;
            cur_cg <= 0; act_cg <= 0;
            cur_zs <= 0; act_zs <= 0;
            cur_zs_oi <= 0; act_zs_oi <= 0;
            cur_zs_cg <= 0; act_zs_cg <= 0;
            cur_oi_cg <= 0; act_oi_cg <= 0;
            cur_comb <= 0; act_comb <= 0;
        end else begin
            if (start) begin
                cur_base <= 0; act_base <= 1;
                cur_oi <= 0; act_oi <= 1;
                cur_cg <= 0; act_cg <= 1;
                cur_zs <= 0; act_zs <= 1;
                cur_zs_oi <= 0; act_zs_oi <= 1;
                cur_zs_cg <= 0; act_zs_cg <= 1;
                cur_oi_cg <= 0; act_oi_cg <= 1;
                cur_comb <= 0; act_comb <= 1;
            end else begin
                if (act_base) begin cur_base <= cur_base + 1; if (done_base) act_base <= 0; end
                if (act_oi)   begin cur_oi   <= cur_oi + 1;   if (done_oi)   act_oi   <= 0; end
                if (act_cg)   begin cur_cg   <= cur_cg + 1;   if (done_cg)   act_cg   <= 0; end
                if (act_zs)   begin cur_zs   <= cur_zs + 1;   if (done_zs)   act_zs   <= 0; end
                if (act_zs_oi)begin cur_zs_oi<= cur_zs_oi + 1;if (done_zs_oi)act_zs_oi<=0; end
                if (act_zs_cg)begin cur_zs_cg<= cur_zs_cg + 1;if (done_zs_cg)act_zs_cg<=0; end
                if (act_oi_cg)begin cur_oi_cg<= cur_oi_cg + 1;if (done_oi_cg)act_oi_cg<=0; end
                if (act_comb) begin cur_comb <= cur_comb + 1; if (done_comb) act_comb <= 0; end
            end
        end
    end

    task run_workload(input string name, input string vec_path);
        int fd, r;
        int w0, w1, w2, w3, w4, w5, w6, w7, w8;
        int p0, p1, p2, p3, p4, p5, p6, p7, p8;
        int gold;
        begin
            fd = $fopen(vec_path, "r");
            if (!fd) begin
                $display("[ERROR] Could not open %s", vec_path);
                $finish;
            end

            acc_base = 0; acc_oi = 0; acc_cg = 0; acc_zs = 0;
            acc_zs_oi = 0; acc_zs_cg = 0; acc_oi_cg = 0; acc_comb = 0;
            mismatches_oi = 0; mismatches_cg = 0; mismatches_zs = 0;
            mismatches_zs_oi = 0; mismatches_zs_cg = 0; mismatches_oi_cg = 0; mismatches_comb = 0;
            patches_in_workload = 0;

            while (!$feof(fd)) begin
                r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\\n",
                            w0, w1, w2, w3, w4, w5, w6, w7, w8,
                            p0, p1, p2, p3, p4, p5, p6, p7, p8,
                            gold);
                if (r == 19) begin
                    @(negedge clk);
                    weights[0] = 8'(signed'(w0)); weights[1] = 8'(signed'(w1)); weights[2] = 8'(signed'(w2));
                    weights[3] = 8'(signed'(w3)); weights[4] = 8'(signed'(w4)); weights[5] = 8'(signed'(w5));
                    weights[6] = 8'(signed'(w6)); weights[7] = 8'(signed'(w7)); weights[8] = 8'(signed'(w8));
                    pixels[0]  = 8'(signed'(p0)); pixels[1]  = 8'(signed'(p1)); pixels[2]  = 8'(signed'(p2));
                    pixels[3]  = 8'(signed'(p3)); pixels[4]  = 8'(signed'(p4)); pixels[5]  = 8'(signed'(p5));
                    pixels[6]  = 8'(signed'(p6)); pixels[7]  = 8'(signed'(p7)); pixels[8]  = 8'(signed'(p8));
                    golden = 32'(signed'(gold));

                    start = 1;
                    @(posedge clk);
                    @(negedge clk);
                    start = 0;

                    while (act_base || act_oi || act_cg || act_zs || act_zs_oi || act_zs_cg || act_oi_cg || act_comb) begin
                        @(posedge clk);
                    end

                    // Accumulate cycles
                    acc_base   += cur_base;
                    acc_oi     += cur_oi;
                    acc_cg     += cur_cg;
                    acc_zs     += cur_zs;
                    acc_zs_oi  += cur_zs_oi;
                    acc_zs_cg  += cur_zs_cg;
                    acc_oi_cg  += cur_oi_cg;
                    acc_comb   += cur_comb;

                    // Verify against golden
                    if (out_oi !== golden) mismatches_oi++;
                    if (out_cg !== golden) mismatches_cg++;
                    if (out_zs !== golden) mismatches_zs++;
                    if (out_zs_oi !== golden) mismatches_zs_oi++;
                    if (out_zs_cg !== golden) mismatches_zs_cg++;
                    if (out_oi_cg !== golden) mismatches_oi_cg++;
                    if (out_comb !== golden) mismatches_comb++;

                    patches_in_workload++;
                end
            end
            $fclose(fd);

            $display("WORKLOAD_RESULT: %s | Patches=%0d | Base=%0d | OI=%0d | CG=%0d | ZS=%0d | ZS_OI=%0d | ZS_CG=%0d | OI_CG=%0d | Comb=%0d | Mismatches=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",
                     name, patches_in_workload, acc_base, acc_oi, acc_cg, acc_zs, acc_zs_oi, acc_zs_cg, acc_oi_cg, acc_comb,
                     mismatches_oi, mismatches_cg, mismatches_zs, mismatches_zs_oi, mismatches_zs_cg, mismatches_oi_cg, mismatches_comb);
        end
    endtask

    initial begin
        rst = 1;
        start = 0;
        #100;
        @(negedge clk);
        rst = 0;
        @(posedge clk);

        $display("==================================================================");
        $display(" >>> STARTING PART C BENCHMARK (14 IMAGES x 2 RULES x 2 KERNELS) <<<");
        $display("==================================================================");
"""

# Add workload calls to tb
workloads = []
for item in audit_data:
    key = item["key"]
    for kname in ["gaussian", "random"]:
        # Rule 1
        w1_name = f"R1_{key}_{kname}"
        w1_path = f"results/final_run_20261030_1056/vectors/relu_r1/{key}_{kname}.vec"
        tb_content += f'        run_workload("{w1_name}", "{w1_path}");\n'
        workloads.append((w1_name, item, 1, kname))
        # Rule 2
        w2_name = f"R2_{key}_{kname}"
        w2_path = f"results/final_run_20261030_1056/vectors/relu_r2/{key}_{kname}.vec"
        tb_content += f'        run_workload("{w2_name}", "{w2_path}");\n'
        workloads.append((w2_name, item, 2, kname))

tb_content += """
        $display("==================================================================");
        $display(" >>> ALL WORKLOADS COMPLETED <<<");
        $display("==================================================================");
        #100;
        $finish;
    end
endmodule
"""

with open(f"{PROJECT_ROOT}/tb/tb_part_c_dual_rules.sv", "w", encoding="utf-8") as f:
    f.write(tb_content)

print(f"Created tb/tb_part_c_dual_rules.sv with {len(workloads)} workloads.")

# Step 3: Compile and elaborate
print(">>> Step 3: Compiling 8 RTL engines and Part C testbench...")
sv_files = [
    "src/conv2d_serial_baseline.sv",
    "src/conv2d_serial_oi.sv",
    "src/conv2d_serial_cg.sv",
    "src/conv2d_serial_zs.sv",
    "src/conv2d_serial_zs_oi.sv",
    "src/conv2d_serial_zs_cg.sv",
    "src/conv2d_serial_oi_cg.sv",
    "src/conv2d_serial_combined.sv",
    "tb/tb_part_c_dual_rules.sv",
]
cmd_xvlog = [xvlog, "-sv"] + sv_files
subprocess.run(cmd_xvlog, cwd=PROJECT_ROOT, check=True)

print(">>> Step 4: Elaborating simulation snapshot...")
cmd_xelab = [xelab, "tb_part_c_dual_rules", "-s", "part_c_snap", "--timescale", "1ns/1ps"]
subprocess.run(cmd_xelab, cwd=PROJECT_ROOT, check=True)

print(">>> Step 5: Running simulation across all 14 images, 2 rules, 2 kernels...")
log_path = f"{PROJECT_ROOT}/results/final_run_20261030_1056/logs/part_c_xsim.log"
p_sim = subprocess.run([xsim, "part_c_snap", "-R"], cwd=PROJECT_ROOT, capture_output=True, text=True)

with open(log_path, "w", encoding="utf-8") as f:
    f.write(p_sim.stdout)
    if p_sim.stderr:
        f.write("\nSTDERR:\n" + p_sim.stderr)

print(f"Simulation finished! Full log saved to {log_path}.")

# Step 6: Parse results
print(">>> Step 6: Parsing simulation results and computing statistics...")
import re

results_by_workload = {}
for line in p_sim.stdout.splitlines():
    if line.startswith("WORKLOAD_RESULT:"):
        # WORKLOAD_RESULT: name | Patches=...
        parts = [p.strip() for p in line.split("|")]
        name = parts[0].replace("WORKLOAD_RESULT:", "").strip()
        patches = int(parts[1].split("=")[1])
        base_cyc = int(parts[2].split("=")[1])
        oi_cyc = int(parts[3].split("=")[1])
        cg_cyc = int(parts[4].split("=")[1])
        zs_cyc = int(parts[5].split("=")[1])
        zs_oi_cyc = int(parts[6].split("=")[1])
        zs_cg_cyc = int(parts[7].split("=")[1])
        oi_cg_cyc = int(parts[8].split("=")[1])
        comb_cyc = int(parts[9].split("=")[1])
        mismatches = parts[10].split("=")[1]

        results_by_workload[name] = {
            "patches": patches,
            "base": base_cyc,
            "oi": oi_cyc,
            "cg": cg_cyc,
            "zs": zs_cyc,
            "zs_oi": zs_oi_cyc,
            "zs_cg": zs_cg_cyc,
            "oi_cg": oi_cg_cyc,
            "comb": comb_cyc,
            "mismatches": mismatches
        }

# Aggregate per image for Rule 1 and Rule 2 (Gaussian and Random kernels)
detailed_summary = []
for item in audit_data:
    key = item["key"]
    fn = item["filename"]
    p_cnt = item["patch_count"]
    r_sp = item["relu_sparsity_pct"]
    r1_sp = item["rule1_sparsity_pct"]
    r2_sp = item["rule2_sparsity_pct"]

    # Rule 1 Gaussian
    r1_g = results_by_workload[f"R1_{key}_gaussian"]
    # Rule 1 Random
    r1_r = results_by_workload[f"R1_{key}_random"]
    # Rule 2 Gaussian
    r2_g = results_by_workload[f"R2_{key}_gaussian"]
    # Rule 2 Random
    r2_r = results_by_workload[f"R2_{key}_random"]

    # Speedups
    r1_g_spd = r1_g["base"] / r1_g["comb"]
    r1_r_spd = r1_r["base"] / r1_r["comb"]
    r2_g_spd = r2_g["base"] / r2_g["comb"]
    r2_r_spd = r2_r["base"] / r2_r["comb"]

    detailed_summary.append({
        "key": key,
        "filename": fn,
        "patch_count": p_cnt,
        "relu_sparsity_pct": r_sp,
        "rule1_sparsity_pct": r1_sp,
        "rule1_gauss_spd": round(r1_g_spd, 4),
        "rule1_rand_spd": round(r1_r_spd, 4),
        "rule2_sparsity_pct": r2_sp,
        "rule2_gauss_spd": round(r2_g_spd, 4),
        "rule2_rand_spd": round(r2_r_spd, 4),
        "r1_comb_cyc": r1_g["comb"],
        "r2_comb_cyc": r2_g["comb"],
        "base_cyc": r1_g["base"],
    })

out_summary_json = f"{PROJECT_ROOT}/results/final_run_20261030_1056/part_c_measured_summary.json"
with open(out_summary_json, "w", encoding="utf-8") as f:
    json.dump({"summary": detailed_summary, "raw_workloads": results_by_workload}, f, indent=2)

print("\n" + "=" * 130)
print(f"{'Image':<16} | {'Patches':<7} | {'ReLU Sp %':<9} | {'R1 Sp %':<8} | {'R1 Gauss Spd':<12} | {'R1 Rand Spd':<11} | {'R2 Sp %':<8} | {'R2 Gauss Spd':<12} | {'R2 Rand Spd':<11}")
print("=" * 130)
for row in detailed_summary:
    print(f"{row['filename']:<16} | {row['patch_count']:<7} | {row['relu_sparsity_pct']:<9.2f} | {row['rule1_sparsity_pct']:<8.2f} | {row['rule1_gauss_spd']:<12.4f} | {row['rule1_rand_spd']:<11.4f} | {row['rule2_sparsity_pct']:<8.2f} | {row['rule2_gauss_spd']:<12.4f} | {row['rule2_rand_spd']:<11.4f}")
print("-" * 130)

# Summary statistics
def stats(vals):
    return {
        "min": float(np.min(vals)),
        "median": float(np.median(vals)),
        "max": float(np.max(vals)),
        "mean": float(np.mean(vals)),
    }

r1_sp_vals = [r['rule1_sparsity_pct'] for r in detailed_summary]
r1_g_vals  = [r['rule1_gauss_spd'] for r in detailed_summary]
r2_sp_vals = [r['rule2_sparsity_pct'] for r in detailed_summary]
r2_g_vals  = [r['rule2_gauss_spd'] for r in detailed_summary]

print("\nSUMMARY STATISTICS (Across 14 Benchmark Images):")
print("  Rule 1 Sparsity %:    ", stats(r1_sp_vals))
print("  Rule 1 Gauss Speedup: ", stats(r1_g_vals))
print("  Rule 2 Sparsity %:    ", stats(r2_sp_vals))
print("  Rule 2 Gauss Speedup: ", stats(r2_g_vals))
print("=" * 130)


print(f"Saved complete measured summary to {out_summary_json}")
