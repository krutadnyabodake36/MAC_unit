// =============================================================================
// File: tb/tb_conv2d_engine_part_c_saif_v2.sv
// Target: Spartan-7 XC7S15 @ 50 MHz
// Description: Corrected SAIF Switching Activity Capture & Functional Verification
//              Testbench for Part C Dense Gaussian Workload (Rule 2 Rescaling)
//              using conv2d_engine_wrapper_v2 post-implementation netlist.
// Stimulus: 44,032 real Gaussian patches (image1..4 back-to-back)
// =============================================================================

`timescale 1ns / 1ps

module tb_conv2d_engine_part_c_saif_v2;

    logic clk = 0;
    logic rst;
    logic start;

    logic signed [7:0] weights_in [9];
    logic signed [7:0] pixels_in  [9];
    logic              done;
    logic signed [31:0] conv_out;
    logic [3:0]         compute_cycles;
    logic [3:0]         skip_count;

    // 50 MHz Clock (20.000 ns period)
    always #10.0 clk = ~clk;

    // Connect to post-implementation netlist with escaped port names
    conv2d_engine_wrapper_v2 u_dut (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .\weights_in[0]  (weights_in[0]),
        .\weights_in[1]  (weights_in[1]),
        .\weights_in[2]  (weights_in[2]),
        .\weights_in[3]  (weights_in[3]),
        .\weights_in[4]  (weights_in[4]),
        .\weights_in[5]  (weights_in[5]),
        .\weights_in[6]  (weights_in[6]),
        .\weights_in[7]  (weights_in[7]),
        .\weights_in[8]  (weights_in[8]),
        .\pixels_in[0]   (pixels_in[0]),
        .\pixels_in[1]   (pixels_in[1]),
        .\pixels_in[2]   (pixels_in[2]),
        .\pixels_in[3]   (pixels_in[3]),
        .\pixels_in[4]   (pixels_in[4]),
        .\pixels_in[5]   (pixels_in[5]),
        .\pixels_in[6]   (pixels_in[6]),
        .\pixels_in[7]   (pixels_in[7]),
        .\pixels_in[8]   (pixels_in[8]),
        .done           (done),
        .conv_out       (conv_out),
        .compute_cycles (compute_cycles),
        .skip_count     (skip_count)
    );

    // Monitoring and metrics
    integer total_patches_processed = 0;
    integer total_mismatches        = 0;
    realtime window_start_ns        = 0.0;
    realtime window_end_ns          = 0.0;
    realtime window_dur_ns          = 0.0;
    integer  window_cycles          = 0;

    task feed_file(input string filepath);
        int fd, r;
        int w0, w1, w2, w3, w4, w5, w6, w7, w8;
        int p0, p1, p2, p3, p4, p5, p6, p7, p8;
        int golden;
        begin
            fd = $fopen(filepath, "r");
            if (!fd) begin
                $display("[ERROR] Failed to open vector file: %s", filepath);
                $finish;
            end

            while (!$feof(fd)) begin
                r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                            w0, w1, w2, w3, w4, w5, w6, w7, w8,
                            p0, p1, p2, p3, p4, p5, p6, p7, p8,
                            golden);
                if (r == 19) begin
                    // Drive inputs and assert start on negedge clk
                    weights_in[0] = 8'(signed'(w0));
                    weights_in[1] = 8'(signed'(w1));
                    weights_in[2] = 8'(signed'(w2));
                    weights_in[3] = 8'(signed'(w3));
                    weights_in[4] = 8'(signed'(w4));
                    weights_in[5] = 8'(signed'(w5));
                    weights_in[6] = 8'(signed'(w6));
                    weights_in[7] = 8'(signed'(w7));
                    weights_in[8] = 8'(signed'(w8));

                    pixels_in[0]  = 8'(signed'(p0));
                    pixels_in[1]  = 8'(signed'(p1));
                    pixels_in[2]  = 8'(signed'(p2));
                    pixels_in[3]  = 8'(signed'(p3));
                    pixels_in[4]  = 8'(signed'(p4));
                    pixels_in[5]  = 8'(signed'(p5));
                    pixels_in[6]  = 8'(signed'(p6));
                    pixels_in[7]  = 8'(signed'(p7));
                    pixels_in[8]  = 8'(signed'(p8));

                    start = 1'b1;

                    @(posedge clk);
                    if (total_patches_processed == 0) begin
                        window_start_ns = $realtime;
                    end

                    @(negedge clk);
                    start = 1'b0;

                    // Wait for core computation and done strobe
                    while (!done) begin
                        @(negedge clk);
                    end

                    // Sample and verify golden result at done cycle
                    if (conv_out !== golden) begin
                        total_mismatches++;
                        if (total_mismatches <= 10) begin
                            $display("[MISMATCH] Patch %0d: Expected=%0d, Got=%0d",
                                     total_patches_processed, golden, conv_out);
                        end
                    end

                    total_patches_processed++;
                end
            end
            $fclose(fd);
        end
    endtask

    initial begin
        int fd_json;

        rst   = 1'b1;
        start = 1'b0;
        for (int i = 0; i < 9; i++) begin
            weights_in[i] = 8'sd0;
            pixels_in[i]  = 8'sd0;
        end

        #100;
        @(negedge clk);
        rst = 1'b0;

        $display("==================================================================");
        $display(" >>> STARTING SAIF STIMULUS V2: 44,032 GAUSSIAN PATCHES (PART C) <<<");
        $display(" Target        : Post-Implementation Netlist (Wrapper v2)");
        $display(" Workload      : GAUSSIAN (Rule 2 Rescaling)");
        $display(" Order Select  : NATURAL");
        $display(" Clock Period  : 20.000 ns (50 MHz)");
        $display("==================================================================");

        feed_file("results/final_run_20261030_1056/vectors/relu_r2/image1_gaussian.vec");
        feed_file("results/final_run_20261030_1056/vectors/relu_r2/image2_gaussian.vec");
        feed_file("results/final_run_20261030_1056/vectors/relu_r2/image3_gaussian.vec");
        feed_file("results/final_run_20261030_1056/vectors/relu_r2/image4_gaussian.vec");

        @(posedge clk);
        window_end_ns = $realtime;
        window_dur_ns = window_end_ns - window_start_ns;
        window_cycles = int'(window_dur_ns / 20.0);

        $display("==================================================================");
        $display(" >>> SAIF STIMULUS V2 RUN COMPLETE <<<");
        $display(" Total Patches Processed : %0d", total_patches_processed);
        $display(" Total Mismatches        : %0d", total_mismatches);
        $display(" Verification Status     : %s", (total_mismatches == 0) ? "PASS (100% Bit-Exact)" : "FAILED");
        $display(" Capture Window Start    : %0.3f ns", window_start_ns);
        $display(" Capture Window End      : %0.3f ns", window_end_ns);
        $display(" Capture Window Duration : %0.3f ns", window_dur_ns);
        $display(" Measured Wall Cycles    : %0d cycles", window_cycles);
        $display(" Check: Window == Cycles x 20ns: %s", (window_dur_ns == window_cycles * 20.0) ? "PASS" : "FAIL");
        $display("==================================================================");

        // Write summary JSON for automated flow verification
        fd_json = $fopen("run_summary.json", "w");
        if (fd_json) begin
            $fdisplay(fd_json, "{");
            $fdisplay(fd_json, "  \"workload\": \"GAUSSIAN\",");
            $fdisplay(fd_json, "  \"order\": \"NATURAL\",");
            $fdisplay(fd_json, "  \"total_patches\": %0d,", total_patches_processed);
            $fdisplay(fd_json, "  \"total_mismatches\": %0d,", total_mismatches);
            $fdisplay(fd_json, "  \"status\": \"%s\",", (total_mismatches == 0) ? "PASS" : "FAILED");
            $fdisplay(fd_json, "  \"window_start_ns\": %0.3f,", window_start_ns);
            $fdisplay(fd_json, "  \"window_end_ns\": %0.3f,", window_end_ns);
            $fdisplay(fd_json, "  \"window_dur_ns\": %0.3f,", window_dur_ns);
            $fdisplay(fd_json, "  \"measured_wall_cycles\": %0d", window_cycles);
            $fdisplay(fd_json, "}");
            $fclose(fd_json);
        end

        #1000;
        $finish;
    end

endmodule

