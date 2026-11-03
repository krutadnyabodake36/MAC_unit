// =============================================================================
// File: tb/tb_conv2d_engine_funcsim_check.sv
// Description: Zero-Delay Post-Implementation Functional Netlist Verification
//              Evaluates 44,032 real Sobel patches against golden outputs.
// =============================================================================

`timescale 1ns / 1ps

module tb_conv2d_engine_funcsim_check;

    logic clk = 0;
    logic rst;
    logic start;
    logic signed [7:0] weights_in [9];
    logic signed [7:0] pixels_in  [9];
    logic done;
    logic signed [31:0] conv_out;
    logic [3:0] compute_cycles;
    logic [3:0] skip_count;

    // 50 MHz clock
    always #10 clk = ~clk;

    // DUT: post-implementation functional netlist (top: conv2d_engine_wrapper)
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

    integer total_patches = 0;
    integer total_mismatches = 0;

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
                    @(negedge clk);
                    start = 1'b0;

                    while (!done) begin
                        @(negedge clk);
                    end

                    // Check output on completion
                    if (conv_out !== golden) begin
                        total_mismatches++;
                        if (total_mismatches <= 5) begin
                            $display("[MISMATCH] Patch %0d: Expected=%0d, Got=%0d", total_patches, golden, conv_out);
                        end
                    end
                    total_patches++;
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

        $display("=== STARTING ZERO-DELAY POST-IMPLEMENTATION FUNCTIONAL VERIFICATION ===");
        feed_file("results/final_run_20261030_1056/vectors/image1.vec");
        feed_file("results/final_run_20261030_1056/vectors/image2.vec");
        feed_file("results/final_run_20261030_1056/vectors/image3.vec");
        feed_file("results/final_run_20261030_1056/vectors/image4.vec");

        $display("==================================================================");
        $display(" >>> POST-IMPLEMENTATION FUNCTIONAL VERIFICATION COMPLETE <<<");
        $display(" Total Evaluated Patches : %0d", total_patches);
        $display(" Total Output Mismatches : %0d", total_mismatches);
        $display(" Functional Test Result  : %s", (total_mismatches == 0 && total_patches == 44032) ? "PASS (100% Match)" : "FAIL");
        $display("==================================================================");

        #100;
        $finish;
    end

endmodule

