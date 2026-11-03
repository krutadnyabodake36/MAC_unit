// Testbench for Part C: 14 images, Dual Rules, 8 Configurations
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
                r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
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
        run_workload("R1_image1_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/image1_gaussian.vec");
        run_workload("R2_image1_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/image1_gaussian.vec");
        run_workload("R1_image1_random", "results/final_run_20261030_1056/vectors/relu_r1/image1_random.vec");
        run_workload("R2_image1_random", "results/final_run_20261030_1056/vectors/relu_r2/image1_random.vec");
        run_workload("R1_image2_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/image2_gaussian.vec");
        run_workload("R2_image2_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/image2_gaussian.vec");
        run_workload("R1_image2_random", "results/final_run_20261030_1056/vectors/relu_r1/image2_random.vec");
        run_workload("R2_image2_random", "results/final_run_20261030_1056/vectors/relu_r2/image2_random.vec");
        run_workload("R1_image3_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/image3_gaussian.vec");
        run_workload("R2_image3_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/image3_gaussian.vec");
        run_workload("R1_image3_random", "results/final_run_20261030_1056/vectors/relu_r1/image3_random.vec");
        run_workload("R2_image3_random", "results/final_run_20261030_1056/vectors/relu_r2/image3_random.vec");
        run_workload("R1_image4_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/image4_gaussian.vec");
        run_workload("R2_image4_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/image4_gaussian.vec");
        run_workload("R1_image4_random", "results/final_run_20261030_1056/vectors/relu_r1/image4_random.vec");
        run_workload("R2_image4_random", "results/final_run_20261030_1056/vectors/relu_r2/image4_random.vec");
        run_workload("R1_extra_img1_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img1_gaussian.vec");
        run_workload("R2_extra_img1_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img1_gaussian.vec");
        run_workload("R1_extra_img1_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img1_random.vec");
        run_workload("R2_extra_img1_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img1_random.vec");
        run_workload("R1_extra_img2_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img2_gaussian.vec");
        run_workload("R2_extra_img2_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img2_gaussian.vec");
        run_workload("R1_extra_img2_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img2_random.vec");
        run_workload("R2_extra_img2_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img2_random.vec");
        run_workload("R1_extra_img3_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img3_gaussian.vec");
        run_workload("R2_extra_img3_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img3_gaussian.vec");
        run_workload("R1_extra_img3_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img3_random.vec");
        run_workload("R2_extra_img3_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img3_random.vec");
        run_workload("R1_extra_img4_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img4_gaussian.vec");
        run_workload("R2_extra_img4_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img4_gaussian.vec");
        run_workload("R1_extra_img4_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img4_random.vec");
        run_workload("R2_extra_img4_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img4_random.vec");
        run_workload("R1_extra_img5_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img5_gaussian.vec");
        run_workload("R2_extra_img5_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img5_gaussian.vec");
        run_workload("R1_extra_img5_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img5_random.vec");
        run_workload("R2_extra_img5_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img5_random.vec");
        run_workload("R1_extra_img6_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img6_gaussian.vec");
        run_workload("R2_extra_img6_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img6_gaussian.vec");
        run_workload("R1_extra_img6_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img6_random.vec");
        run_workload("R2_extra_img6_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img6_random.vec");
        run_workload("R1_extra_img7_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img7_gaussian.vec");
        run_workload("R2_extra_img7_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img7_gaussian.vec");
        run_workload("R1_extra_img7_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img7_random.vec");
        run_workload("R2_extra_img7_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img7_random.vec");
        run_workload("R1_extra_img8_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img8_gaussian.vec");
        run_workload("R2_extra_img8_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img8_gaussian.vec");
        run_workload("R1_extra_img8_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img8_random.vec");
        run_workload("R2_extra_img8_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img8_random.vec");
        run_workload("R1_extra_img_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img_gaussian.vec");
        run_workload("R2_extra_img_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img_gaussian.vec");
        run_workload("R1_extra_img_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img_random.vec");
        run_workload("R2_extra_img_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img_random.vec");
        run_workload("R1_extra_img1b_gaussian", "results/final_run_20261030_1056/vectors/relu_r1/extra_img1b_gaussian.vec");
        run_workload("R2_extra_img1b_gaussian", "results/final_run_20261030_1056/vectors/relu_r2/extra_img1b_gaussian.vec");
        run_workload("R1_extra_img1b_random", "results/final_run_20261030_1056/vectors/relu_r1/extra_img1b_random.vec");
        run_workload("R2_extra_img1b_random", "results/final_run_20261030_1056/vectors/relu_r2/extra_img1b_random.vec");

        $display("==================================================================");
        $display(" >>> ALL WORKLOADS COMPLETED <<<");
        $display("==================================================================");
        #100;
        $finish;
    end
endmodule
