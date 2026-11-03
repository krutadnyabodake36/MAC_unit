// =============================================================================
// File: tb_image_workloads_8var.sv
// Description: Multi-Workload Hardware Verification Testbench for All EIGHT (8) Engines:
//                1. Baseline       (conv2d_serial_baseline)
//                2. OI-only        (conv2d_serial_oi)
//                3. CG-only        (conv2d_serial_cg)
//                4. ZS-only        (conv2d_serial_zs)
//                5. ZS + OI        (conv2d_serial_zs_oi)
//                6. ZS + CG        (conv2d_serial_zs_cg)
//                7. OI + CG        (conv2d_serial_oi_cg)
//                8. Combined (Full)(conv2d_serial_combined)
//
// Tests:
//   Part 1: Dedicated Corner Cases:
//           - All-zero patch
//           - All-nonzero patch
//           - Single non-zero element at each of the 9 positions (0..8)
//           - Extreme -128 and +127 operand boundary cases
//   Part 2: All 4 Real Zero-Point Shifted Images (.vec files)
// =============================================================================

`timescale 1ns / 1ps

module tb_image_workloads_8var;

    logic clk = 0;
    logic rst;
    logic start;

    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];
    logic signed [31:0] golden_out;

    // Engine outputs
    logic signed [31:0] out_base, out_oi, out_cg, out_zs, out_zs_oi, out_zs_cg, out_oi_cg, out_comb;
    logic [3:0]         cyc_base, cyc_oi, cyc_cg, cyc_zs, cyc_zs_oi, cyc_zs_cg, cyc_oi_cg, cyc_comb;
    logic [3:0]         skp_oi, skp_cg, skp_zs, skp_zs_oi, skp_zs_cg, skp_oi_cg, skp_comb;
    logic               done_base, done_oi, done_cg, done_zs, done_zs_oi, done_zs_cg, done_oi_cg, done_comb;

    // 50 MHz Clock
    always #10 clk = ~clk;

    // Instantiations
    conv2d_serial_baseline u_base (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_base), .conv_out(out_base), .compute_cycles(cyc_base)
    );
    conv2d_serial_oi u_oi (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_oi), .conv_out(out_oi), .compute_cycles(cyc_oi), .skip_count(skp_oi)
    );
    conv2d_serial_cg u_cg (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_cg), .conv_out(out_cg), .compute_cycles(cyc_cg), .skip_count(skp_cg)
    );
    conv2d_serial_zs u_zs (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_zs), .conv_out(out_zs), .compute_cycles(cyc_zs), .skip_count(skp_zs)
    );
    conv2d_serial_zs_oi u_zs_oi (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_zs_oi), .conv_out(out_zs_oi), .compute_cycles(cyc_zs_oi), .skip_count(skp_zs_oi)
    );
    conv2d_serial_zs_cg u_zs_cg (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_zs_cg), .conv_out(out_zs_cg), .compute_cycles(cyc_zs_cg), .skip_count(skp_zs_cg)
    );
    conv2d_serial_oi_cg u_oi_cg (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_oi_cg), .conv_out(out_oi_cg), .compute_cycles(cyc_oi_cg), .skip_count(skp_oi_cg)
    );
    conv2d_serial_combined u_comb (
        .clk(clk), .rst(rst), .start(start), .weights(weights), .pixels(pixels),
        .done(done_comb), .conv_out(out_comb), .compute_cycles(cyc_comb), .skip_count(skp_comb)
    );

    // Wall-clock counters
    integer wall_base, wall_oi, wall_cg, wall_zs, wall_zs_oi, wall_zs_cg, wall_oi_cg, wall_comb;
    logic act_base, act_oi, act_cg, act_zs, act_zs_oi, act_zs_cg, act_oi_cg, act_comb;

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_base <= 0; act_base <= 0;
            wall_oi   <= 0; act_oi   <= 0;
            wall_cg   <= 0; act_cg   <= 0;
            wall_zs   <= 0; act_zs   <= 0;
            wall_zs_oi<= 0; act_zs_oi<= 0;
            wall_zs_cg<= 0; act_zs_cg<= 0;
            wall_oi_cg<= 0; act_oi_cg<= 0;
            wall_comb <= 0; act_comb <= 0;
        end else if (start) begin
            wall_base <= 0; act_base <= 1;
            wall_oi   <= 0; act_oi   <= 1;
            wall_cg   <= 0; act_cg   <= 1;
            wall_zs   <= 0; act_zs   <= 1;
            wall_zs_oi<= 0; act_zs_oi<= 1;
            wall_zs_cg<= 0; act_zs_cg<= 1;
            wall_oi_cg<= 0; act_oi_cg<= 1;
            wall_comb <= 0; act_comb <= 1;
        end else begin
            if (act_base)  begin wall_base  <= wall_base  + 1; if (done_base)  act_base  <= 0; end
            if (act_oi)    begin wall_oi    <= wall_oi    + 1; if (done_oi)    act_oi    <= 0; end
            if (act_cg)    begin wall_cg    <= wall_cg    + 1; if (done_cg)    act_cg    <= 0; end
            if (act_zs)    begin wall_zs    <= wall_zs    + 1; if (done_zs)    act_zs    <= 0; end
            if (act_zs_oi) begin wall_zs_oi <= wall_zs_oi + 1; if (done_zs_oi) act_zs_oi <= 0; end
            if (act_zs_cg) begin wall_zs_cg <= wall_zs_cg + 1; if (done_zs_cg) act_zs_cg <= 0; end
            if (act_oi_cg) begin wall_oi_cg <= wall_oi_cg + 1; if (done_oi_cg) act_oi_cg <= 0; end
            if (act_comb)  begin wall_comb  <= wall_comb  + 1; if (done_comb)  act_comb  <= 0; end
        end
    end

    // Corner test task
    task run_corner(
        input string test_name,
        input logic signed [7:0] w[9],
        input logic signed [7:0] p[9],
        input logic signed [31:0] expected_out
    );
        int wait_c;
        int mismatches;
        begin
            mismatches = 0;
            for (int k = 0; k < 9; k++) begin
                weights[k] = w[k];
                pixels[k]  = p[k];
            end
            golden_out = expected_out;

            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            wait_c = 30;
            while ((act_base || act_oi || act_cg || act_zs || act_zs_oi || act_zs_cg || act_oi_cg || act_comb) && (wait_c > 0)) begin
                @(posedge clk);
                wait_c--;
            end

            if (out_base !== golden_out) mismatches++;
            if (out_oi   !== golden_out) mismatches++;
            if (out_cg   !== golden_out) mismatches++;
            if (out_zs   !== golden_out) mismatches++;
            if (out_zs_oi!== golden_out) mismatches++;
            if (out_zs_cg!== golden_out) mismatches++;
            if (out_oi_cg!== golden_out) mismatches++;
            if (out_comb !== golden_out) mismatches++;

            $display(" Corner: %-35s | Golden: %8d | Mismatches across 8: %0d", test_name, golden_out, mismatches);
            if (mismatches > 0) begin
                $display("   Outputs: Base=%0d OI=%0d CG=%0d ZS=%0d ZS_OI=%0d ZS_CG=%0d OI_CG=%0d Comb=%0d",
                    out_base, out_oi, out_cg, out_zs, out_zs_oi, out_zs_cg, out_oi_cg, out_comb);
            end
            repeat(1) @(posedge clk);
        end
    endtask

    // Image vector runner task
    task run_image_file_8var(input string file_path, input string image_label);
        integer fd;
        integer r;
        integer int_w[9];
        integer int_p[9];
        integer int_gold;
        integer wait_cycles;

        longint total_patches;
        longint mis_base, mis_oi, mis_cg, mis_zs, mis_zs_oi, mis_zs_cg, mis_oi_cg, mis_comb;
        longint cmp_base, cmp_oi, cmp_cg, cmp_zs, cmp_zs_oi, cmp_zs_cg, cmp_oi_cg, cmp_comb;
        longint skp_base_s, skp_oi_s, skp_cg_s, skp_zs_s, skp_zs_oi_s, skp_zs_cg_s, skp_oi_cg_s, skp_comb_s;
        longint wal_base, wal_oi, wal_cg, wal_zs, wal_zs_oi, wal_zs_cg, wal_oi_cg, wal_comb;

        begin
            fd = $fopen(file_path, "r");
            if (fd == 0) begin
                $display("[ERROR] Failed to open vector file: %s", file_path);
                $finish;
            end

            total_patches = 0;
            mis_base = 0; mis_oi = 0; mis_cg = 0; mis_zs = 0; mis_zs_oi = 0; mis_zs_cg = 0; mis_oi_cg = 0; mis_comb = 0;
            cmp_base = 0; cmp_oi = 0; cmp_cg = 0; cmp_zs = 0; cmp_zs_oi = 0; cmp_zs_cg = 0; cmp_oi_cg = 0; cmp_comb = 0;
            skp_base_s = 0; skp_oi_s = 0; skp_cg_s = 0; skp_zs_s = 0; skp_zs_oi_s = 0; skp_zs_cg_s = 0; skp_oi_cg_s = 0; skp_comb_s = 0;
            wal_base = 0; wal_oi = 0; wal_cg = 0; wal_zs = 0; wal_zs_oi = 0; wal_zs_cg = 0; wal_oi_cg = 0; wal_comb = 0;

            $display("==================================================================================");
            $display(" >>> 8-VARIANT PROCESSING: %s (%s) <<<", image_label, file_path);
            $display("==================================================================================");

            while (!$feof(fd)) begin
                r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                    int_w[0], int_w[1], int_w[2], int_w[3], int_w[4], int_w[5], int_w[6], int_w[7], int_w[8],
                    int_p[0], int_p[1], int_p[2], int_p[3], int_p[4], int_p[5], int_p[6], int_p[7], int_p[8],
                    int_gold);

                if (r == 19) begin
                    total_patches++;
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
                    while ((act_base || act_oi || act_cg || act_zs || act_zs_oi || act_zs_cg || act_oi_cg || act_comb) && (wait_cycles > 0)) begin
                        @(posedge clk);
                        wait_cycles--;
                    end

                    cmp_base  += cyc_base;
                    cmp_oi    += cyc_oi;
                    cmp_cg    += cyc_cg;
                    cmp_zs    += cyc_zs;
                    cmp_zs_oi += cyc_zs_oi;
                    cmp_zs_cg += cyc_zs_cg;
                    cmp_oi_cg += cyc_oi_cg;
                    cmp_comb  += cyc_comb;

                    skp_base_s += 0;
                    skp_oi_s   += skp_oi;
                    skp_cg_s   += skp_cg;
                    skp_zs_s   += skp_zs;
                    skp_zs_oi_s+= skp_zs_oi;
                    skp_zs_cg_s+= skp_zs_cg;
                    skp_oi_cg_s+= skp_oi_cg;
                    skp_comb_s += skp_comb;

                    wal_base  += wall_base;
                    wal_oi    += wall_oi;
                    wal_cg    += wall_cg;
                    wal_zs    += wall_zs;
                    wal_zs_oi += wall_zs_oi;
                    wal_zs_cg += wall_zs_cg;
                    wal_oi_cg += wall_oi_cg;
                    wal_comb  += wall_comb;

                    if (out_base  !== golden_out) mis_base++;
                    if (out_oi    !== golden_out) mis_oi++;
                    if (out_cg    !== golden_out) mis_cg++;
                    if (out_zs    !== golden_out) mis_zs++;
                    if (out_zs_oi !== golden_out) mis_zs_oi++;
                    if (out_zs_cg !== golden_out) mis_zs_cg++;
                    if (out_oi_cg !== golden_out) mis_oi_cg++;
                    if (out_comb  !== golden_out) mis_comb++;

                    @(posedge clk);
                end
            end

            $fclose(fd);

            $display("----------------------------------------------------------------------------------");
            $display(" 8-VARIANT RESULTS SUMMARY: %s (Total Patches: %0d)", image_label, total_patches);
            $display("----------------------------------------------------------------------------------");
            $display(" Variant   | Mismatches | Compute Cycles | Skips/Gated | Wall Cycles | Avg Wall Cyc/Patch");
            $display(" Baseline  | %10d | %14d | %11d | %11d | %0.4f", mis_base,  cmp_base,  skp_base_s,  wal_base,  real'(wal_base)/real'(total_patches));
            $display(" OI-only   | %10d | %14d | %11d | %11d | %0.4f", mis_oi,    cmp_oi,    skp_oi_s,    wal_oi,    real'(wal_oi)/real'(total_patches));
            $display(" CG-only   | %10d | %14d | %11d | %11d | %0.4f", mis_cg,    cmp_cg,    skp_cg_s,    wal_cg,    real'(wal_cg)/real'(total_patches));
            $display(" ZS-only   | %10d | %14d | %11d | %11d | %0.4f", mis_zs,    cmp_zs,    skp_zs_s,    wal_zs,    real'(wal_zs)/real'(total_patches));
            $display(" ZS + OI   | %10d | %14d | %11d | %11d | %0.4f", mis_zs_oi, cmp_zs_oi, skp_zs_oi_s, wal_zs_oi, real'(wal_zs_oi)/real'(total_patches));
            $display(" ZS + CG   | %10d | %14d | %11d | %11d | %0.4f", mis_zs_cg, cmp_zs_cg, skp_zs_cg_s, wal_zs_cg, real'(wal_zs_cg)/real'(total_patches));
            $display(" OI + CG   | %10d | %14d | %11d | %11d | %0.4f", mis_oi_cg, cmp_oi_cg, skp_oi_cg_s, wal_oi_cg, real'(wal_oi_cg)/real'(total_patches));
            $display(" Combined  | %10d | %14d | %11d | %11d | %0.4f", mis_comb,  cmp_comb,  skp_comb_s,  wal_comb,  real'(wal_comb)/real'(total_patches));
            $display("");

            if (mis_base!=0 || mis_oi!=0 || mis_cg!=0 || mis_zs!=0 || mis_zs_oi!=0 || mis_zs_cg!=0 || mis_oi_cg!=0 || mis_comb!=0) begin
                $display("[ERROR] Mismatches detected across 8 variants on %s!", image_label);
                $finish;
            end
        end
    endtask

    // Corner stimulus setups
    logic signed [7:0] w_sobel[9] = '{-8'sd1,  8'sd0,  8'sd1, -8'sd2,  8'sd0,  8'sd2, -8'sd1,  8'sd0,  8'sd1};
    logic signed [7:0] w_ones[9]  = '{ 8'sd1,  8'sd1,  8'sd1,  8'sd1,  8'sd1,  8'sd1,  8'sd1,  8'sd1,  8'sd1};
    logic signed [7:0] p_zero[9]  = '{ 8'sd0,  8'sd0,  8'sd0,  8'sd0,  8'sd0,  8'sd0,  8'sd0,  8'sd0,  8'sd0};
    logic signed [7:0] p_ones[9]  = '{ 8'sd10, 8'sd20, 8'sd30, 8'sd40, 8'sd50, 8'sd60, 8'sd70, 8'sd80, 8'sd90};
    logic signed [7:0] p_temp[9];
    logic signed [7:0] w_temp[9];

    string vec_dir = "results/final_run_20261030_1056/vectors";

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

        void'($value$plusargs("VEC_DIR=%s", vec_dir));

        $display("==================================================================================");
        $display(" >>> STAGE 2A: CORNER CASE VERIFICATION ACROSS ALL 8 VARIANTS <<<");
        $display("==================================================================================");

        // 1. All-zero patch
        run_corner("All-Zero Patch", w_sobel, p_zero, 32'sd0);

        // 2. All-nonzero patch
        run_corner("All-NonZero Dense Patch", w_ones, p_ones, 32'sd450);

        // 3. Single non-zero element at each of the 9 positions (0..8)
        for (int pos = 0; pos < 9; pos++) begin
            for (int k = 0; k < 9; k++) begin
                w_temp[k] = (k == pos) ? 8'sd3 : 8'sd0;
                p_temp[k] = (k == pos) ? 8'sd7 : 8'sd0;
            end
            run_corner($sformatf("Single Non-Zero at pos %0d", pos), w_temp, p_temp, 32'sd21);
        end

        // 4. Extreme operands (-128 and +127)
        for (int k = 0; k < 9; k++) begin
            w_temp[k] = (k % 2 == 0) ? -8'sd128 : 8'sd127;
            p_temp[k] = (k % 2 == 0) ? -8'sd128 : 8'sd127;
        end
        // Expected: 5 elements of (-128 * -128 = 16384) + 4 elements of (127 * 127 = 16129) = 5*16384 + 4*16129 = 81920 + 64516 = 146436
        run_corner("Extreme Operands: (-128, +127)", w_temp, p_temp, 32'sd146436);

        // Mixed extreme: -128 * +127 = -16256 for all 9 elements = -146304
        for (int k = 0; k < 9; k++) begin
            w_temp[k] = -8'sd128;
            p_temp[k] = 8'sd127;
        end
        run_corner("Extreme Operands: -128 * +127", w_temp, p_temp, -32'sd146304);

        $display("\n==================================================================================");
        $display(" >>> STAGE 2B: 4 REAL SHIFTED IMAGE WORKLOADS ACROSS ALL 8 VARIANTS <<<");
        $display("==================================================================================");

        run_image_file_8var({vec_dir, "/image1.vec"}, "Workload 1 (image1.jpg)");
        run_image_file_8var({vec_dir, "/image2.vec"}, "Workload 2 (image2.jpg)");
        run_image_file_8var({vec_dir, "/image3.vec"}, "Workload 3 (image3.jpg)");
        run_image_file_8var({vec_dir, "/image4.vec"}, "Workload 4 (image4.jpg)");

        $display("==================================================================================");
        $display(" >>> COMPLETE 8-VARIANT VERIFICATION FINISHED: ZERO MISMATCHES DETECTED <<<");
        $display("==================================================================================");
        $finish;
    end

endmodule

