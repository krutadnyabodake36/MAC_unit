// =============================================================================
// File: tb_cycle_measurement.sv
// Description: Direct Wall-Clock and Compute-Cycle Measurement Testbench for all
//              5 Conv2D Serial Engines on Spartan-7:
//                1. Baseline       (conv2d_serial_baseline)
//                2. OI-only        (conv2d_serial_oi)
//                3. CG-only        (conv2d_serial_cg)
//                4. ZS-only        (conv2d_serial_zs)
//                5. Combined (Full)(conv2d_serial_combined)
//
// Measures:
//   - Wall-clock start-to-done cycles (counted cycle-by-cycle from start to done)
//   - Hardware compute_cycles (reported by each module's internal counter)
//   - Hardware skip_count / zero_products_gated
//   - FSM latency overhead (Wall Cycles - Compute Cycles)
//   - Verification of conv_out bit-exact equality across all variants
// =============================================================================

`timescale 1ns / 1ps

module tb_cycle_measurement;

    logic clk = 0;
    logic rst;
    logic start;

    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];

    // Engine 0: Baseline
    logic signed [31:0] out_base;
    logic [3:0]         cyc_base;
    logic               done_base;

    // Engine 1: OI-only
    logic signed [31:0] out_oi;
    logic [3:0]         cyc_oi;
    logic [3:0]         gated_oi;
    logic               done_oi;

    // Engine 2: CG-only
    logic signed [31:0] out_cg;
    logic [3:0]         cyc_cg;
    logic [3:0]         gated_cg;
    logic               done_cg;

    // Engine 3: ZS-only
    logic signed [31:0] out_zs;
    logic [3:0]         cyc_zs;
    logic [3:0]         skips_zs;
    logic               done_zs;

    // Engine 4: Combined
    logic signed [31:0] out_comb;
    logic [3:0]         cyc_comb;
    logic [3:0]         skips_comb;
    logic               done_comb;

    // 50 MHz system clock (20 ns period)
    always #10 clk = ~clk;

    // -------------------------------------------------------------------------
    // Instantiations
    // -------------------------------------------------------------------------
    conv2d_serial_baseline u_base (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .weights        (weights),
        .pixels         (pixels),
        .done           (done_base),
        .conv_out       (out_base),
        .compute_cycles (cyc_base)
    );

    conv2d_serial_oi u_oi (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .weights        (weights),
        .pixels         (pixels),
        .done           (done_oi),
        .conv_out       (out_oi),
        .compute_cycles (cyc_oi),
        .skip_count     (gated_oi)
    );

    conv2d_serial_cg u_cg (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .weights        (weights),
        .pixels         (pixels),
        .done           (done_cg),
        .conv_out       (out_cg),
        .compute_cycles (cyc_cg),
        .skip_count     (gated_cg)
    );

    conv2d_serial_zs u_zs (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .weights        (weights),
        .pixels         (pixels),
        .done           (done_zs),
        .conv_out       (out_zs),
        .compute_cycles (cyc_zs),
        .skip_count     (skips_zs)
    );

    conv2d_serial_combined u_comb (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .weights        (weights),
        .pixels         (pixels),
        .done           (done_comb),
        .conv_out       (out_comb),
        .compute_cycles (cyc_comb),
        .skip_count     (skips_comb)
    );

    // -------------------------------------------------------------------------
    // Wall-Clock Cycle Counters (Active from start pulse until each done pulse)
    // -------------------------------------------------------------------------
    integer wall_base, wall_oi, wall_cg, wall_zs, wall_comb;
    logic active_base, active_oi, active_cg, active_zs, active_comb;

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_base   <= 0;
            active_base <= 0;
        end else begin
            if (start) begin
                wall_base   <= 0;
                active_base <= 1;
            end else if (active_base) begin
                wall_base <= wall_base + 1;
                if (done_base) active_base <= 0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_oi   <= 0;
            active_oi <= 0;
        end else begin
            if (start) begin
                wall_oi   <= 0;
                active_oi <= 1;
            end else if (active_oi) begin
                wall_oi <= wall_oi + 1;
                if (done_oi) active_oi <= 0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_cg   <= 0;
            active_cg <= 0;
        end else begin
            if (start) begin
                wall_cg   <= 0;
                active_cg <= 1;
            end else if (active_cg) begin
                wall_cg <= wall_cg + 1;
                if (done_cg) active_cg <= 0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_zs   <= 0;
            active_zs <= 0;
        end else begin
            if (start) begin
                wall_zs   <= 0;
                active_zs <= 1;
            end else if (active_zs) begin
                wall_zs <= wall_zs + 1;
                if (done_zs) active_zs <= 0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_comb   <= 0;
            active_comb <= 0;
        end else begin
            if (start) begin
                wall_comb   <= 0;
                active_comb <= 1;
            end else if (active_comb) begin
                wall_comb <= wall_comb + 1;
                if (done_comb) active_comb <= 0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Test Task
    // -------------------------------------------------------------------------
    task run_patch(
        input string desc,
        input logic signed [7:0] w[9],
        input logic signed [7:0] p[9]
    );
        int expected_nz;
        int max_wait;
        begin
            expected_nz = 0;
            for (int k = 0; k < 9; k++) begin
                weights[k] = w[k];
                pixels[k]  = p[k];
                if (w[k] != 8'sd0 && p[k] != 8'sd0) expected_nz++;
            end

            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            // Wait until all engines complete (or timeout at 25 cycles)
            max_wait = 25;
            while ((active_base || active_oi || active_cg || active_zs || active_comb) && (max_wait > 0)) begin
                @(posedge clk);
                max_wait--;
            end

            // Check correctness
            if (out_oi !== out_base || out_cg !== out_base || out_zs !== out_base || out_comb !== out_base) begin
                $display("[ERROR] Output mismatch on '%s'!", desc);
                $display("  Base=%0d, OI=%0d, CG=%0d, ZS=%0d, Comb=%0d",
                         out_base, out_oi, out_cg, out_zs, out_comb);
            end

            $display("----------------------------------------------------------------------------------");
            $display(" Patch: %-25s | Non-Zero MACs: %0d/9", desc, expected_nz);
            $display("----------------------------------------------------------------------------------");
            $display(" Config    | Wall Cycles | Compute Cyc | Overhead Cyc | Skips/Gated | Output");
            $display(" Baseline  | %11d | %11d | %12d | %11d | %d",
                     wall_base, cyc_base, (wall_base - cyc_base), 0, out_base);
            $display(" OI-only   | %11d | %11d | %12d | %11d | %d",
                     wall_oi, cyc_oi, (wall_oi - cyc_oi), gated_oi, out_oi);
            $display(" CG-only   | %11d | %11d | %12d | %11d | %d",
                     wall_cg, cyc_cg, (wall_cg - cyc_cg), gated_cg, out_cg);
            $display(" ZS-only   | %11d | %11d | %12d | %11d | %d",
                     wall_zs, cyc_zs, (wall_zs - cyc_zs), skips_zs, out_zs);
            $display(" Combined  | %11d | %11d | %12d | %11d | %d",
                     wall_comb, cyc_comb, (wall_comb - cyc_comb), skips_comb, out_comb);
            $display("");

            repeat(2) @(posedge clk);
        end
    endtask

    // -------------------------------------------------------------------------
    // Test Sequence
    // -------------------------------------------------------------------------
    logic signed [7:0] sobel_x[9] = '{-8'sd1,  8'sd0,  8'sd1,
                                      -8'sd2,  8'sd0,  8'sd2,
                                      -8'sd1,  8'sd0,  8'sd1};

    logic signed [7:0] sobel_y[9] = '{-8'sd1, -8'sd2, -8'sd1,
                                       8'sd0,  8'sd0,  8'sd0,
                                       8'sd1,  8'sd2,  8'sd1};

    logic signed [7:0] p_zero[9]  = '{ 8'sd0,  8'sd0,  8'sd0,
                                       8'sd0,  8'sd0,  8'sd0,
                                       8'sd0,  8'sd0,  8'sd0};

    // Typical shifted pixel values (around 0 after uint8 - 128)
    logic signed [7:0] p_shift1[9] = '{-8'sd12,  8'sd0,  8'sd15,
                                       -8'sd20,  8'sd5,  8'sd22,
                                       -8'sd10,  8'sd0,  8'sd18};

    // Single non-zero product
    logic signed [7:0] p_single[9] = '{ 8'sd0,  8'sd0,  8'sd0,
                                        8'sd0,  8'sd0,  8'sd42,
                                        8'sd0,  8'sd0,  8'sd0};

    // Fully dense non-zero (non-Sobel all-ones kernel)
    logic signed [7:0] w_dense[9]  = '{ 8'sd1,  8'sd1,  8'sd1,
                                        8'sd1,  8'sd1,  8'sd1,
                                        8'sd1,  8'sd1,  8'sd1};
    logic signed [7:0] p_dense[9]  = '{ 8'sd10, 8'sd20, 8'sd30,
                                        8'sd40, 8'sd50, 8'sd60,
                                        8'sd70, 8'sd80, 8'sd90};

    initial begin
        rst   = 1;
        start = 0;
        for (int k = 0; k < 9; k++) begin
            weights[k] = 8'sd0;
            pixels[k]  = 8'sd0;
        end

        #100;
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        $display("==================================================================================");
        $display(" >>> SERIAL CONV2D HARDWARE CYCLE ACCURACY SIMULATION AUDIT <<<");
        $display(" Comparing 5 Engines: Baseline vs OI-only vs CG-only vs ZS-only vs Combined");
        $display("==================================================================================");

        run_patch("All-Zero (100% Sparse)", sobel_x, p_zero);
        run_patch("Sobel-X Natural Shifted", sobel_x, p_shift1);
        run_patch("Sobel-Y Natural Shifted", sobel_y, p_shift1);
        run_patch("Single Non-Zero MAC",     sobel_x, p_single);
        run_patch("Dense 9-MAC (0% Sparse)", w_dense, p_dense);

        $display("==================================================================================");
        $display(" >>> SIMULATION AUDIT COMPLETE <<<");
        $display("==================================================================================");
        $finish;
    end

endmodule

