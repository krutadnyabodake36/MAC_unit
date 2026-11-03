// =============================================================================
// File: tb/tb_conv2d_engine_saif_timesim.sv
// Target: Spartan-7 XC7S15 @ 50 MHz
// Description: SAIF Switching Activity Capture Testbench for Netlist Simulation.
// Connects to the post-implementation netlist with flattened escaped ports.
// Handshake: Inputs and start driven on negedge clk; done sampled on negedge clk.
// Zero idle cycle gap between consecutive patches (cycle 11 start).
// =============================================================================

`timescale 1ns / 1ps

module tb_conv2d_engine_saif_timesim #(
    parameter string ORDER_SELECT = "NATURAL" // "NATURAL" or "ROTATED"
);

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

    // Connect to flattened netlist module
    conv2d_engine_wrapper u_dut (
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

    // Monitoring
    integer total_patches_processed = 0;
    realtime window_start_ns = 0.0;
    realtime window_end_ns   = 0.0;
    realtime window_dur_ns   = 0.0;
    integer  window_cycles   = 0;

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
                    // Currently at negedge clk
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

                    while (!done) begin
                        @(negedge clk);
                    end
                    total_patches_processed++;
                end
            end
            $fclose(fd);
        end
    endtask

    initial begin
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
        $display(" >>> STARTING SAIF STIMULUS: 44,032 BACK-TO-BACK REAL PATCHES <<<");
        $display(" Target        : Post-Implementation Netlist");
        $display(" Order Select  : %s", ORDER_SELECT);
        $display(" Clock Period  : 20.000 ns (50 MHz)");
        $display("==================================================================");

        if (ORDER_SELECT == "ROTATED") begin
            feed_file("results/final_run_20261030_1056/vectors/image2.vec");
            feed_file("results/final_run_20261030_1056/vectors/image3.vec");
            feed_file("results/final_run_20261030_1056/vectors/image4.vec");
            feed_file("results/final_run_20261030_1056/vectors/image1.vec");
        end else begin
            feed_file("results/final_run_20261030_1056/vectors/image1.vec");
            feed_file("results/final_run_20261030_1056/vectors/image2.vec");
            feed_file("results/final_run_20261030_1056/vectors/image3.vec");
            feed_file("results/final_run_20261030_1056/vectors/image4.vec");
        end

        @(posedge clk);
        window_end_ns = $realtime;
        window_dur_ns = window_end_ns - window_start_ns;
        window_cycles = int'(window_dur_ns / 20.0);

        $display("==================================================================");
        $display(" >>> SAIF STIMULUS RUN COMPLETE <<<");
        $display(" Total Patches Processed : %0d", total_patches_processed);
        $display(" Capture Window Start    : %0.3f ns", window_start_ns);
        $display(" Capture Window End      : %0.3f ns", window_end_ns);
        $display(" Capture Window Duration : %0.3f ns", window_dur_ns);
        $display(" Measured Wall Cycles    : %0d cycles", window_cycles);
        $display(" Check: Window == Cycles x 20ns: %s", (window_dur_ns == window_cycles * 20.0) ? "PASS" : "FAIL");
        $display(" Check: Window == 484352 x 20ns: %s", (window_cycles == 484352) ? "PASS" : "FAIL");
        $display("==================================================================");

        #1000;
    end

endmodule
