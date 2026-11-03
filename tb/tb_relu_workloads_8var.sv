`timescale 1ns / 1ps

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
            r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
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
        run_dataset("image1.jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image1_gaussian.vec");
        run_dataset("image1.jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image1_random.vec");
        run_dataset("image2.jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image2_gaussian.vec");
        run_dataset("image2.jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image2_random.vec");
        run_dataset("image3.jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image3_gaussian.vec");
        run_dataset("image3.jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image3_random.vec");
        run_dataset("image4.jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image4_gaussian.vec");
        run_dataset("image4.jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_image4_random.vec");
        run_dataset("extra_images (1).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_1_gaussian.vec");
        run_dataset("extra_images (1).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_1_random.vec");
        run_dataset("extra_images (2).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_2_gaussian.vec");
        run_dataset("extra_images (2).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_2_random.vec");
        run_dataset("extra_images (3).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_3_gaussian.vec");
        run_dataset("extra_images (3).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_3_random.vec");
        run_dataset("extra_images (4).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_4_gaussian.vec");
        run_dataset("extra_images (4).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_4_random.vec");
        run_dataset("extra_images (5).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_5_gaussian.vec");
        run_dataset("extra_images (5).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_5_random.vec");
        run_dataset("extra_images (6).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_6_gaussian.vec");
        run_dataset("extra_images (6).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_6_random.vec");
        run_dataset("extra_images (7).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_7_gaussian.vec");
        run_dataset("extra_images (7).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_7_random.vec");
        run_dataset("extra_images (8).jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_8_gaussian.vec");
        run_dataset("extra_images (8).jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_8_random.vec");
        run_dataset("extra_images.jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_gaussian.vec");
        run_dataset("extra_images.jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images_random.vec");
        run_dataset("extra_images1.jpg", "gaussian", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images1_gaussian.vec");
        run_dataset("extra_images1.jpg", "random", "C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/vectors/relu/relu_extra_images1_random.vec");

        $display("==================================================================================");
        $display(" >>> PART C SIMULATION COMPLETE <<<");
        $display("==================================================================================");
        $finish;
    end
endmodule
