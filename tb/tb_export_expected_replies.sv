// =============================================================================
// File: tb/tb_export_expected_replies.sv
// Target: Spartan-7 XC7S15 @ 50 MHz
// Description: Behavioral RTL Simulation Exporter for Golden Ground-Truth Replies
//              Directly clocks each architectural engine (DESIGN_SELECT 0..8)
//              over all 4 benchmark images (image1..image4) and dumps:
//                patch_idx,conv_out,compute_cycles,skip_count
//              to results/final_run_20261030_1056/expected/expected_{design}_{img}.csv
// =============================================================================

`timescale 1ns / 1ps

module tb_export_expected_runner #(
    parameter int    DESIGN_SELECT = 0,
    parameter string DESIGN_NAME   = "baseline"
);

    logic clk = 0;
    logic rst;
    logic start = 0;

    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];
    logic              done;
    logic signed [31:0] conv_out;
    logic [3:0]         compute_cycles;
    logic [3:0]         skip_count;

    // 50 MHz Clock (20 ns period)
    always #10.0 clk = ~clk;

    // Architectural Engine Generate Block
    generate
        if (DESIGN_SELECT == 0) begin : gen_baseline
            conv2d_serial_baseline u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles)
            );
            assign skip_count = 4'd0;
        end else if (DESIGN_SELECT == 1) begin : gen_oi
            conv2d_serial_oi u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 2) begin : gen_cg
            conv2d_serial_cg u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 3) begin : gen_zs
            conv2d_serial_zs u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 4) begin : gen_combined
            conv2d_serial_combined u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 5) begin : gen_zs_oi
            conv2d_serial_zs_oi u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 6) begin : gen_zs_cg
            conv2d_serial_zs_cg u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 7) begin : gen_oi_cg
            conv2d_serial_oi_cg u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 8) begin : gen_static_sobel
            conv2d_serial_static_sobel u_eng (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles)
            );
            assign skip_count = 4'd0;
        end
    endgenerate

    task export_image(input string img_name);
        string vec_file;
        string out_file;
        int fd_in, fd_out, r;
        int w0, w1, w2, w3, w4, w5, w6, w7, w8;
        int p0, p1, p2, p3, p4, p5, p6, p7, p8;
        int golden;
        int p_idx;
        begin
            vec_file = {"results/final_run_20261030_1056/vectors/", img_name, ".vec"};
            out_file = {"results/final_run_20261030_1056/expected/expected_", DESIGN_NAME, "_", img_name, ".csv"};
            p_idx = 0;

            $display(">>> Processing %s for %s -> %s <<<", img_name, DESIGN_NAME, out_file);

            fd_in = $fopen(vec_file, "r");
            if (!fd_in) begin
                $display("[ERROR] Failed to open vector file: %s", vec_file);
                $finish;
            end

            fd_out = $fopen(out_file, "w");
            if (!fd_out) begin
                $display("[ERROR] Failed to open output file: %s", out_file);
                $finish;
            end

            // CSV Header
            $fdisplay(fd_out, "patch_idx,conv_out,compute_cycles,skip_count");

            while (!$feof(fd_in)) begin
                r = $fscanf(fd_in, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                            w0, w1, w2, w3, w4, w5, w6, w7, w8,
                            p0, p1, p2, p3, p4, p5, p6, p7, p8,
                            golden);
                if (r == 19) begin
                    weights[0] = 8'(signed'(w0));
                    weights[1] = 8'(signed'(w1));
                    weights[2] = 8'(signed'(w2));
                    weights[3] = 8'(signed'(w3));
                    weights[4] = 8'(signed'(w4));
                    weights[5] = 8'(signed'(w5));
                    weights[6] = 8'(signed'(w6));
                    weights[7] = 8'(signed'(w7));
                    weights[8] = 8'(signed'(w8));

                    pixels[0]  = 8'(signed'(p0));
                    pixels[1]  = 8'(signed'(p1));
                    pixels[2]  = 8'(signed'(p2));
                    pixels[3]  = 8'(signed'(p3));
                    pixels[4]  = 8'(signed'(p4));
                    pixels[5]  = 8'(signed'(p5));
                    pixels[6]  = 8'(signed'(p6));
                    pixels[7]  = 8'(signed'(p7));
                    pixels[8]  = 8'(signed'(p8));

                    start <= 1'b1;
                    @(posedge clk);
                    start <= 1'b0;

                    // Wait for engine done pulse
                    while (!done) begin
                        @(posedge clk);
                    end

                    // Write sampled output to CSV
                    $fdisplay(fd_out, "%0d,%0d,%0d,%0d", p_idx, conv_out, compute_cycles, skip_count);

                    p_idx++;
                    @(negedge clk);
                end
            end

            $fclose(fd_in);
            $fclose(fd_out);

            $display(">>> %s complete: %0d patches written to %s <<<", img_name, p_idx, out_file);
        end
    endtask

    initial begin
        rst   = 1'b1;
        start = 1'b0;
        for (int i = 0; i < 9; i++) begin
            weights[i] = 8'sd0;
            pixels[i]  = 8'sd0;
        end

        #100;
        @(negedge clk);
        rst = 1'b0;
        @(negedge clk);

        export_image("image1");
        export_image("image2");
        export_image("image3");
        export_image("image4");

        $display(">>> ALL 4 IMAGES COMPLETE FOR DESIGN %s <<<", DESIGN_NAME);
        $finish;
    end

endmodule

module tb_export_expected_0; tb_export_expected_runner #(.DESIGN_SELECT(0), .DESIGN_NAME("baseline")) u(); endmodule
module tb_export_expected_1; tb_export_expected_runner #(.DESIGN_SELECT(1), .DESIGN_NAME("oi")) u(); endmodule
module tb_export_expected_2; tb_export_expected_runner #(.DESIGN_SELECT(2), .DESIGN_NAME("cg")) u(); endmodule
module tb_export_expected_3; tb_export_expected_runner #(.DESIGN_SELECT(3), .DESIGN_NAME("zs")) u(); endmodule
module tb_export_expected_4; tb_export_expected_runner #(.DESIGN_SELECT(4), .DESIGN_NAME("combined")) u(); endmodule
module tb_export_expected_5; tb_export_expected_runner #(.DESIGN_SELECT(5), .DESIGN_NAME("zs_oi")) u(); endmodule
module tb_export_expected_6; tb_export_expected_runner #(.DESIGN_SELECT(6), .DESIGN_NAME("zs_cg")) u(); endmodule
module tb_export_expected_7; tb_export_expected_runner #(.DESIGN_SELECT(7), .DESIGN_NAME("oi_cg")) u(); endmodule
module tb_export_expected_8; tb_export_expected_runner #(.DESIGN_SELECT(8), .DESIGN_NAME("static_sobel")) u(); endmodule
