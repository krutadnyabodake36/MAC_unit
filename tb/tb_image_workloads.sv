// =============================================================================
// File: tb_image_workloads.sv
// Description: Multi-Workload Hardware Verification Testbench for All 5 Engines:
//                1. Baseline       (conv2d_serial_baseline)
//                2. OI-only        (conv2d_serial_oi)
//                3. CG-only        (conv2d_serial_cg)
//                4. ZS-only        (conv2d_serial_zs)
//                5. Combined (Full)(conv2d_serial_combined)
//
// Reads real image vector files (.vec) with zero-point shifted int8 pixels and
// compares RTL output against golden model across all patches.
// Measures:
//   - Output mismatches against golden model
//   - Sum of reported compute_cycles
//   - Sum of reported skip_count / zero products gated
//   - Sum of measured start-to-done wall-clock cycles
// =============================================================================

`timescale 1ns / 1ps

module tb_image_workloads;

    logic clk = 0;
    logic rst;
    logic start;

    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];
    logic signed [31:0] golden_out;

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

    // 50 MHz Clock (20 ns period)
    always #10 clk = ~clk;

    // -------------------------------------------------------------------------
    // Instantiations of all 5 engines
    // -------------------------------------------------------------------------
    conv2d_serial_baseline u_base (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_base), .conv_out(out_base), .compute_cycles(cyc_base)
    );

    conv2d_serial_oi u_oi (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_oi), .conv_out(out_oi), .compute_cycles(cyc_oi), .skip_count(gated_oi)
    );

    conv2d_serial_cg u_cg (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_cg), .conv_out(out_cg), .compute_cycles(cyc_cg), .skip_count(gated_cg)
    );

    conv2d_serial_zs u_zs (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_zs), .conv_out(out_zs), .compute_cycles(cyc_zs), .skip_count(skips_zs)
    );

    conv2d_serial_combined u_comb (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_comb), .conv_out(out_comb), .compute_cycles(cyc_comb), .skip_count(skips_comb)
    );

    // -------------------------------------------------------------------------
    // Independent Wall-Clock Cycle Counters (Active between start and done)
    // -------------------------------------------------------------------------
    integer wall_base, wall_oi, wall_cg, wall_zs, wall_comb;
    logic active_base, active_oi, active_cg, active_zs, active_comb;

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_base   <= 0;
            active_base <= 0;
        end else if (start) begin
            wall_base   <= 0;
            active_base <= 1;
        end else if (active_base) begin
            wall_base <= wall_base + 1;
            if (done_base) active_base <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_oi   <= 0;
            active_oi <= 0;
        end else if (start) begin
            wall_oi   <= 0;
            active_oi <= 1;
        end else if (active_oi) begin
            wall_oi <= wall_oi + 1;
            if (done_oi) active_oi <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_cg   <= 0;
            active_cg <= 0;
        end else if (start) begin
            wall_cg   <= 0;
            active_cg <= 1;
        end else if (active_cg) begin
            wall_cg <= wall_cg + 1;
            if (done_cg) active_cg <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_zs   <= 0;
            active_zs <= 0;
        end else if (start) begin
            wall_zs   <= 0;
            active_zs <= 1;
        end else if (active_zs) begin
            wall_zs <= wall_zs + 1;
            if (done_zs) active_zs <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wall_comb   <= 0;
            active_comb <= 0;
        end else if (start) begin
            wall_comb   <= 0;
            active_comb <= 1;
        end else if (active_comb) begin
            wall_comb <= wall_comb + 1;
            if (done_comb) active_comb <= 0;
        end
    end

    // -------------------------------------------------------------------------
    // Execution Task per Workload Image
    // -------------------------------------------------------------------------
    task run_image_file(input string file_path, input string image_label);
        integer fd;
        integer count;
        integer r;
        integer int_w[9];
        integer int_p[9];
        integer int_gold;
        integer wait_cycles;

        // Statistics accumulators (64-bit integer)
        longint total_patches;
        longint mismatches_base, mismatches_oi, mismatches_cg, mismatches_zs, mismatches_comb;
        longint sum_comp_base, sum_comp_oi, sum_comp_cg, sum_comp_zs, sum_comp_comb;
        longint sum_skip_base, sum_skip_oi, sum_skip_cg, sum_skip_zs, sum_skip_comb;
        longint sum_wall_base, sum_wall_oi, sum_wall_cg, sum_wall_zs, sum_wall_comb;

        begin
            fd = $fopen(file_path, "r");
            if (fd == 0) begin
                $display("[ERROR] Failed to open vector file: %s", file_path);
                $finish;
            end

            total_patches = 0;
            mismatches_base = 0; mismatches_oi = 0; mismatches_cg = 0; mismatches_zs = 0; mismatches_comb = 0;
            sum_comp_base = 0; sum_comp_oi = 0; sum_comp_cg = 0; sum_comp_zs = 0; sum_comp_comb = 0;
            sum_skip_base = 0; sum_skip_oi = 0; sum_skip_cg = 0; sum_skip_zs = 0; sum_skip_comb = 0;
            sum_wall_base = 0; sum_wall_oi = 0; sum_wall_cg = 0; sum_wall_zs = 0; sum_wall_comb = 0;

            $display("==================================================================================");
            $display(" >>> PROCESSING: %s (%s) <<<", image_label, file_path);
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

                    // Wait until all 5 engines complete (or timeout at 30 cycles)
                    wait_cycles = 30;
                    while ((active_base || active_oi || active_cg || active_zs || active_comb) && (wait_cycles > 0)) begin
                        @(posedge clk);
                        wait_cycles--;
                    end

                    // Accumulate metrics
                    sum_comp_base += cyc_base;
                    sum_comp_oi   += cyc_oi;
                    sum_comp_cg   += cyc_cg;
                    sum_comp_zs   += cyc_zs;
                    sum_comp_comb += cyc_comb;

                    sum_skip_base += 0;
                    sum_skip_oi   += gated_oi;
                    sum_skip_cg   += gated_cg;
                    sum_skip_zs   += skips_zs;
                    sum_skip_comb += skips_comb;

                    sum_wall_base += wall_base;
                    sum_wall_oi   += wall_oi;
                    sum_wall_cg   += wall_cg;
                    sum_wall_zs   += wall_zs;
                    sum_wall_comb += wall_comb;

                    // Check bit-exact correctness against golden
                    if (out_base !== golden_out) mismatches_base++;
                    if (out_oi   !== golden_out) mismatches_oi++;
                    if (out_cg   !== golden_out) mismatches_cg++;
                    if (out_zs   !== golden_out) mismatches_zs++;
                    if (out_comb !== golden_out) mismatches_comb++;

                    // Small inter-patch gap
                    @(posedge clk);
                end
            end

            $fclose(fd);

            $display("----------------------------------------------------------------------------------");
            $display(" RESULTS SUMMARY: %s (Total Patches: %0d)", image_label, total_patches);
            $display("----------------------------------------------------------------------------------");
            $display(" Variant  | Mismatches | Compute Cycles | Skips/Gated | Wall Cycles | Avg Wall Cyc/Patch");
            $display(" Baseline | %10d | %14d | %11d | %11d | %0.4f",
                mismatches_base, sum_comp_base, sum_skip_base, sum_wall_base, real'(sum_wall_base)/real'(total_patches));
            $display(" OI-only  | %10d | %14d | %11d | %11d | %0.4f",
                mismatches_oi, sum_comp_oi, sum_skip_oi, sum_wall_oi, real'(sum_wall_oi)/real'(total_patches));
            $display(" CG-only  | %10d | %14d | %11d | %11d | %0.4f",
                mismatches_cg, sum_comp_cg, sum_skip_cg, sum_wall_cg, real'(sum_wall_cg)/real'(total_patches));
            $display(" ZS-only  | %10d | %14d | %11d | %11d | %0.4f",
                mismatches_zs, sum_comp_zs, sum_skip_zs, sum_wall_zs, real'(sum_wall_zs)/real'(total_patches));
            $display(" Combined | %10d | %14d | %11d | %11d | %0.4f",
                mismatches_comb, sum_comp_comb, sum_skip_comb, sum_wall_comb, real'(sum_wall_comb)/real'(total_patches));
            $display("");

            if (mismatches_base != 0 || mismatches_oi != 0 || mismatches_cg != 0 || mismatches_zs != 0 || mismatches_comb != 0) begin
                $display("[ERROR] Output mismatches detected on %s!", image_label);
                $finish;
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Main Test Loop
    // -------------------------------------------------------------------------
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

        run_image_file({vec_dir, "/image1.vec"}, "Workload 1 (image1.jpg)");
        run_image_file({vec_dir, "/image2.vec"}, "Workload 2 (image2.jpg)");
        run_image_file({vec_dir, "/image3.vec"}, "Workload 3 (image3.jpg)");
        run_image_file({vec_dir, "/image4.vec"}, "Workload 4 (image4.jpg)");

        $display("==================================================================================");
        $display(" >>> ALL 4 IMAGE WORKLOADS COMPLETED: 100% BIT-EXACT ACROSS ALL 5 VARIANTS <<<");
        $display("==================================================================================");
        $finish;
    end

endmodule

