#!/usr/bin/env python3
"""
scripts/run_part_b_sweep.py
Part B: Sparsity and Kernel Sweep across all 8 variants.
- Fixed Seed: 42
- Sparsity levels: 0%, 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90% (2000 patches each)
- Kernels:
    1. Sobel-X: [-1, 0, 1, -2, 0, 2, -1, 0, 1] (3 structural zeros)
    2. Dense Gaussian: [1, 2, 1, 2, 4, 2, 1, 2, 1] (0 zeros)
    3. Random Dense: [-3, 2, 1, 4, -2, 5, 1, -4, 3] (0 zeros)
- Generates decimal vector files.
- Generates tb/tb_sparsity_sweep_8var.sv using exact $fscanf format from tb_image_workloads_8var.sv.
"""

import os
import sys
import random

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VEC_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "vectors", "sweep")
LOG_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "logs")

os.makedirs(VEC_DIR, exist_ok=True)
os.makedirs(LOG_DIR, exist_ok=True)

SEED = 42
random.seed(SEED)

KERNELS = {
    "sobel":    [-1,  0,  1, -2,  0,  2, -1,  0,  1],
    "gaussian": [ 1,  2,  1,  2,  4,  2,  1,  2,  1],
    "random":   [-3,  2,  1,  4, -2,  5,  1, -4,  3],
}

LEVELS = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
PATCHES_PER_LEVEL = 2000

print(f"Generating synthetic sweep datasets (Seed={SEED}, {PATCHES_PER_LEVEL} patches/level)...")
achieved_pixel_sparsity = {}
sweep_manifest = []

nonzero_pool = [v for v in range(-128, 128) if v != 0]

for lvl in LEVELS:
    prob_zero = lvl / 100.0
    total_zeros = 0
    total_pixels = PATCHES_PER_LEVEL * 9
    patches = []

    for _ in range(PATCHES_PER_LEVEL):
        patch = []
        for _ in range(9):
            if random.random() < prob_zero:
                patch.append(0)
                total_zeros += 1
            else:
                patch.append(random.choice(nonzero_pool))
        patches.append(patch)

    achieved = (total_zeros / total_pixels) * 100.0
    achieved_pixel_sparsity[lvl] = achieved
    print(f"  Target: {lvl:2d}% | Achieved Pixel Sparsity: {achieved:6.2f}% ({total_zeros}/{total_pixels} zeros)")

    for kname, kweights in KERNELS.items():
        vec_filename = f"sweep_{kname}_lvl{lvl}.vec"
        vec_path = os.path.join(VEC_DIR, vec_filename)
        with open(vec_path, "w", encoding="utf-8") as vf:
            for p in patches:
                golden = sum(w * px for w, px in zip(kweights, p))
                w_str = " ".join(str(w) for w in kweights)
                p_str = " ".join(str(px) for px in p)
                vf.write(f"{w_str} {p_str} {golden}\n")
        sweep_manifest.append((kname, lvl, vec_path, PATCHES_PER_LEVEL))

print(f"All {len(sweep_manifest)} vector files generated.")

# Write testbench tb/tb_sparsity_sweep_8var.sv
tb_path = os.path.join(PROJECT_ROOT, "tb", "tb_sparsity_sweep_8var.sv")
with open(tb_path, "w", encoding="utf-8") as tb:
    tb.write("""`timescale 1ns / 1ps

module tb_sparsity_sweep_8var;
    logic clk;
    logic rst;

    always #10 clk = ~clk; // 50 MHz

    logic        start;
    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];
    logic signed [31:0] golden_out;

    logic done_0, done_1, done_2, done_3, done_4, done_5, done_6, done_7;
    logic signed [31:0] out_0, out_1, out_2, out_3, out_4, out_5, out_6, out_7;
    logic [3:0] cyc_0, cyc_1, cyc_2, cyc_3, cyc_4, cyc_5, cyc_6, cyc_7;
    logic [3:0] skp_1, skp_2, skp_3, skp_4, skp_5, skp_6, skp_7;

    conv2d_serial_baseline u_0 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_0), .conv_out(out_0), .compute_cycles(cyc_0));
    conv2d_serial_oi       u_1 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_1), .conv_out(out_1), .compute_cycles(cyc_1), .skip_count(skp_1));
    conv2d_serial_cg       u_2 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_2), .conv_out(out_2), .compute_cycles(cyc_2), .skip_count(skp_2));
    conv2d_serial_zs       u_3 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_3), .conv_out(out_3), .compute_cycles(cyc_3), .skip_count(skp_3));
    conv2d_serial_combined u_4 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_4), .conv_out(out_4), .compute_cycles(cyc_4), .skip_count(skp_4));
    conv2d_serial_zs_oi    u_5 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_5), .conv_out(out_5), .compute_cycles(cyc_5), .skip_count(skp_5));
    conv2d_serial_zs_cg    u_6 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_6), .conv_out(out_6), .compute_cycles(cyc_6), .skip_count(skp_6));
    conv2d_serial_oi_cg    u_7 (.clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels), .done(done_7), .conv_out(out_7), .compute_cycles(cyc_7), .skip_count(skp_7));

    integer wall_0, wall_1, wall_2, wall_3, wall_4, wall_5, wall_6, wall_7;
    logic act_0, act_1, act_2, act_3, act_4, act_5, act_6, act_7;

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_0 <= 0; act_0 <= 0;
            wall_1 <= 0; act_1 <= 0;
            wall_2 <= 0; act_2 <= 0;
            wall_3 <= 0; act_3 <= 0;
            wall_4 <= 0; act_4 <= 0;
            wall_5 <= 0; act_5 <= 0;
            wall_6 <= 0; act_6 <= 0;
            wall_7 <= 0; act_7 <= 0;
        end else if (start) begin
            wall_0 <= 0; act_0 <= 1;
            wall_1 <= 0; act_1 <= 1;
            wall_2 <= 0; act_2 <= 1;
            wall_3 <= 0; act_3 <= 1;
            wall_4 <= 0; act_4 <= 1;
            wall_5 <= 0; act_5 <= 1;
            wall_6 <= 0; act_6 <= 1;
            wall_7 <= 0; act_7 <= 1;
        end else begin
            if (act_0) begin wall_0 <= wall_0 + 1; if (done_0) act_0 <= 0; end
            if (act_1) begin wall_1 <= wall_1 + 1; if (done_1) act_1 <= 0; end
            if (act_2) begin wall_2 <= wall_2 + 1; if (done_2) act_2 <= 0; end
            if (act_3) begin wall_3 <= wall_3 + 1; if (done_3) act_3 <= 0; end
            if (act_4) begin wall_4 <= wall_4 + 1; if (done_4) act_4 <= 0; end
            if (act_5) begin wall_5 <= wall_5 + 1; if (done_5) act_5 <= 0; end
            if (act_6) begin wall_6 <= wall_6 + 1; if (done_6) act_6 <= 0; end
            if (act_7) begin wall_7 <= wall_7 + 1; if (done_7) act_7 <= 0; end
        end
    end

    int fd, r;
    int int_w[9];
    int int_p[9];
    int int_gold;
    int wait_cycles;
    longint total_w0, total_wc, total_mis;
    int patch_idx;

    task automatic run_dataset(input string kname, input int lvl, input string filepath);
        fd = $fopen(filepath, "r");
        if (fd == 0) begin
            $display("[ERROR] Could not open %s", filepath);
            $finish;
        end
        total_w0 = 0;
        total_wc = 0;
        total_mis = 0;
        patch_idx = 0;

        while (!$feof(fd)) begin
            r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\\n",
                int_w[0], int_w[1], int_w[2], int_w[3], int_w[4], int_w[5], int_w[6], int_w[7], int_w[8],
                int_p[0], int_p[1], int_p[2], int_p[3], int_p[4], int_p[5], int_p[6], int_p[7], int_p[8],
                int_gold);

            if (r == 19) begin
                patch_idx++;
                for (int k = 0; k < 9; k++) begin
                    weights[k] = int_w[k][7:0];
                    pixels[k]  = int_p[k][7:0];
                end
                golden_out = int_gold;

                @(posedge clk);
                start = 1;
                @(posedge clk);
                start = 0;

                wait_cycles = 30;
                while ((act_0 || act_1 || act_2 || act_3 || act_4 || act_5 || act_6 || act_7) && (wait_cycles > 0)) begin
                    @(posedge clk);
                    wait_cycles--;
                end

                total_w0 += wall_0;
                total_wc += wall_4;

                if (out_0 !== golden_out) total_mis++;
                if (out_1 !== golden_out) total_mis++;
                if (out_2 !== golden_out) total_mis++;
                if (out_3 !== golden_out) total_mis++;
                if (out_4 !== golden_out) total_mis++;
                if (out_5 !== golden_out) total_mis++;
                if (out_6 !== golden_out) total_mis++;
                if (out_7 !== golden_out) total_mis++;

                @(posedge clk);
            end
        end
        $fclose(fd);
        $display("SWEEP_RESULT | Kernel=%-8s | Lvl=%2d%% | Patches=%0d | Base_Wall=%0d | Comb_Wall=%0d | Mismatches=%0d", 
                 kname, lvl, patch_idx, total_w0, total_wc, total_mis);
    endtask

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        #100;
        rst = 0;
        #50;

        $display("==================================================================================");
        $display(" >>> STARTING PART B: 8-VARIANT SPARSITY & KERNEL HARDWARE SWEEP <<<");
        $display("==================================================================================");
""")

    for kname, lvl, vpath, pcount in sweep_manifest:
        vpath_fwd = vpath.replace("\\", "/")
        tb.write(f'        run_dataset("{kname}", {lvl}, "{vpath_fwd}");\n')

    tb.write("""
        $display("==================================================================================");
        $display(" >>> PART B SWEEP COMPLETE <<<");
        $display("==================================================================================");
        $finish;
    end
endmodule
""")

print("Wrote testbench to: tb/tb_sparsity_sweep_8var.sv")
