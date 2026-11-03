// =============================================================================
// File: tb/tb_diag_zs_mismatches.sv
// Description: Diagnostic testbench for G1 to record detailed mismatch data
//              for the first mismatching patches in ZS post-impl funcsim netlist.
// =============================================================================

`timescale 1ns / 1ps

module tb_diag_zs_mismatches;

    logic clk = 0;
    logic rst;
    logic start;
    logic signed [7:0] weights_in [9];
    logic signed [7:0] pixels_in  [9];
    logic done;
    logic signed [31:0] conv_out;
    logic [3:0] compute_cycles;
    logic [3:0] skip_count;

    always #10 clk = ~clk;

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
    logic [8:0] prev_nz_mask = 9'b0;
    logic [8:0] curr_nz_mask = 9'b0;

    task feed_file(input string filepath);
        int fd, r;
        int w[9];
        int p[9];
        int golden;
        begin
            fd = $fopen(filepath, "r");
            if (!fd) begin
                $display("[ERROR] Failed to open vector file: %s", filepath);
                $finish;
            end

            while (!$feof(fd)) begin
                r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                            w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7], w[8],
                            p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8],
                            golden);
                if (r == 19) begin
                    curr_nz_mask = 9'b0;
                    for (int i = 0; i < 9; i++) begin
                        weights_in[i] = 8'(signed'(w[i]));
                        pixels_in[i]  = 8'(signed'(p[i]));
                        if (w[i] != 0 && p[i] != 0) begin
                            curr_nz_mask[i] = 1'b1;
                        end
                    end

                    start = 1'b1;
                    @(posedge clk);
                    @(negedge clk);
                    start = 1'b0;

                    while (!done) begin
                        @(negedge clk);
                    end

                    if (conv_out !== golden) begin
                        total_mismatches++;
                        if (total_mismatches <= 15) begin
                            $display("[G1_MISMATCH] Patch=%0d | Expected=%0d | Actual=%0d | PrevMask=9'b%09b (0x%03h) | CurrMask=9'b%09b (0x%03h) | MaskChanged=%0d",
                                     total_patches, golden, conv_out, prev_nz_mask, prev_nz_mask, curr_nz_mask, curr_nz_mask, (prev_nz_mask != curr_nz_mask));
                        end
                    end
                    
                    prev_nz_mask = curr_nz_mask;
                    total_patches++;
                    if (total_patches >= 500) begin
                        // Stop after 500 patches since we only need first 10 mismatches
                        $fclose(fd);
                        return;
                    end
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

        $display("=== G1 DIAGNOSTIC RUN: FIRST MISMATCHES IN ZS FUNCSIM ===");
        feed_file("results/final_run_20261030_1056/vectors/image1.vec");
        $display("Total Patches Evaluated: %0d | Total Mismatches: %0d", total_patches, total_mismatches);
        #100;
        $finish;
    end

endmodule

