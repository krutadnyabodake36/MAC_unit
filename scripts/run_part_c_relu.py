#!/usr/bin/env python3
"""
scripts/run_part_c_relu.py
Part C: Data-Dependent Sparsity from Real Images (ReLU Activation Maps).
- Processes all repo images (root image1-4.jpg + images_extra/*.jpg).
- Stage 1: Sobel-X conv on shifted int8 -> ReLU (clamp < 0 to 0).
- Rescaling Rule: scaled_map = round(relu_map * 127.0 / max_val).astype(int8) if max_val > 0 else 0.
- Measures achieved activation sparsity per image.
- Stage 2: Generates 3x3 patches from scaled_map with two dense kernels:
    (a) Dense Gaussian: [1, 2, 1, 2, 4, 2, 1, 2, 1]
    (b) Random Dense:   [-3, 2, 1, 4, -2, 5, 1, -4, 3]
- Exports decimal vector files to results/final_run_20261030_1056/vectors/relu/.
- Writes tb/tb_relu_workloads_8var.sv using exact $fscanf format.
"""

import os
import sys
import glob
import numpy as np
from PIL import Image

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
VEC_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "vectors", "relu")
LOG_DIR = os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "logs")

os.makedirs(VEC_DIR, exist_ok=True)
os.makedirs(LOG_DIR, exist_ok=True)

SOBEL_X = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], dtype=np.int32)
KERNELS = {
    "gaussian": [ 1,  2,  1,  2,  4,  2,  1,  2,  1],
    "random":   [-3,  2,  1,  4, -2,  5,  1, -4,  3],
}

def resize_aspect_preserved(img_gray, max_edge=128):
    raw_w, raw_h = img_gray.size
    longest = max(raw_w, raw_h)
    if longest > max_edge:
        scale = max_edge / float(longest)
        new_w = max(3, int(round(raw_w * scale)))
        new_h = max(3, int(round(raw_h * scale)))
        resized = img_gray.resize((new_w, new_h), Image.Resampling.BILINEAR)
    else:
        resized = img_gray
        new_w, new_h = raw_w, raw_h
    return np.asarray(resized, dtype=np.uint8), new_h, new_w

# Collect all images
image_paths = []
for f in ["image1.jpg", "image2.jpg", "image3.jpg", "image4.jpg"]:
    p = os.path.join(PROJECT_ROOT, f)
    if os.path.exists(p):
        image_paths.append((f, p))

extra_dir = os.path.join(PROJECT_ROOT, "images_extra")
if os.path.exists(extra_dir):
    for f in sorted(os.listdir(extra_dir)):
        p = os.path.join(extra_dir, f)
        if os.path.isfile(p) and f.lower().endswith((".jpg", ".jpeg", ".png")):
            image_paths.append((f"extra_{f}", p))

print(f"Found {len(image_paths)} real images to process.")

relu_manifest = []
activation_sparsity_table = []

for label, img_path in image_paths:
    img = Image.open(img_path).convert("L")
    raw_w, raw_h = img.size
    u8_arr, h, w = resize_aspect_preserved(img, max_edge=128)

    # 1. Zero-point shift
    int8_img = (u8_arr.astype(np.int16) - 128).astype(np.int8)

    # 2. 1st stage Sobel-X convolution (with 0-padding)
    padded_s1 = np.pad(int8_img.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)
    sobel_out = np.zeros((h, w), dtype=np.int32)
    for r in range(h):
        for c in range(w):
            patch = padded_s1[r:r+3, c:c+3]
            sobel_out[r, c] = np.sum(patch * SOBEL_X)

    # 3. ReLU: clamp negatives to 0
    relu_out = np.maximum(0, sobel_out)

    # 4. Rescale to INT8 [0, 127]
    max_val = np.max(relu_out)
    if max_val > 0:
        scaled_act = np.round((relu_out * 127.0) / max_val).astype(np.int8)
    else:
        scaled_act = np.zeros((h, w), dtype=np.int8)

    # 5. Measure activation sparsity
    total_pixels = h * w
    zero_pixels = int(np.sum(scaled_act == 0))
    act_sparsity = (zero_pixels / total_pixels) * 100.0

    activation_sparsity_table.append({
        "label": label,
        "raw_dim": f"{raw_w}x{raw_h}",
        "proc_dim": f"{w}x{h}",
        "total_pixels": total_pixels,
        "zero_pixels": zero_pixels,
        "sparsity": act_sparsity,
        "max_relu_val": int(max_val)
    })
    print(f"  Image: {label:25s} ({w}x{h}) | Zero Pixels: {zero_pixels:5d}/{total_pixels:5d} | Act Sparsity: {act_sparsity:6.2f}%")

    # 6. Extract 3x3 patches from scaled_act for 2nd stage convolution
    padded_s2 = np.pad(scaled_act.astype(np.int32), ((1, 1), (1, 1)), mode='constant', constant_values=0)
    patches = []
    for r in range(h):
        for c in range(w):
            p_flat = padded_s2[r:r+3, c:c+3].flatten().tolist()
            patches.append(p_flat)

    # Export decimal vector files
    clean_lbl = label.replace(" ", "_").replace("(", "").replace(")", "").replace(".jpg", "").replace(".png", "")
    for kname, kweights in KERNELS.items():
        vec_filename = f"relu_{clean_lbl}_{kname}.vec"
        vec_path = os.path.join(VEC_DIR, vec_filename)
        with open(vec_path, "w", encoding="utf-8") as vf:
            for p in patches:
                golden = sum(w * px for w, px in zip(kweights, p))
                w_str = " ".join(str(w) for w in kweights)
                p_str = " ".join(str(px) for px in p)
                vf.write(f"{w_str} {p_str} {golden}\n")
        relu_manifest.append((label, kname, vec_path, len(patches), act_sparsity))

print(f"Exported {len(relu_manifest)} vector datasets for Part C.")

with open(os.path.join(PROJECT_ROOT, "results", "final_run_20261030_1056", "activation_sparsity.json"), "w", encoding="utf-8") as jf:
    import json
    json.dump(activation_sparsity_table, jf, indent=2)

# Write SystemVerilog testbench for Part C
tb_path = os.path.join(PROJECT_ROOT, "tb", "tb_relu_workloads_8var.sv")
with open(tb_path, "w", encoding="utf-8") as tb:
    tb.write("""`timescale 1ns / 1ps

module tb_relu_workloads_8var;
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

    task automatic run_dataset(input string img_name, input string kname, input string filepath);
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
        $display("RELU_RESULT | Image=%-22s | Kernel=%-8s | Patches=%5d | Base_Wall=%7d | Comb_Wall=%7d | Mismatches=%0d", 
                 img_name, kname, patch_idx, total_w0, total_wc, total_mis);
    endtask

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        #100;
        rst = 0;
        #50;

        $display("==================================================================================");
        $display(" >>> STARTING PART C: REAL RELU ACTIVATION MAP 8-VARIANT SIMULATION <<<");
        $display("==================================================================================");
""")

    for lbl, kname, vpath, pcount, sp in relu_manifest:
        vpath_fwd = vpath.replace("\\", "/")
        tb.write(f'        run_dataset("{lbl}", "{kname}", "{vpath_fwd}");\n')

    tb.write("""
        $display("==================================================================================");
        $display(" >>> PART C SIMULATION COMPLETE <<<");
        $display("==================================================================================");
        $finish;
    end
endmodule
""")

print("Wrote testbench to: tb/tb_relu_workloads_8var.sv")
