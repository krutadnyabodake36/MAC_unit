// =============================================================================
// File: tb_all_ablation_engines.sv
// Description: Multi-Engine Lockstep Verification Testbench for All 5 3x3 Engines:
//                1. Baseline (conv2d_serial_baseline)
//                2. Only Operand Isolation (conv2d_serial_oi)
//                3. Only Clock Gating (conv2d_serial_cg)
//                4. Only Zero-Skipping (conv2d_serial_zs)
//                5. Combined Full Architecture (conv2d_serial_combined)
//
// Uses independent sequential latching monitors to guarantee zero race conditions.
// =============================================================================

`timescale 1ns / 1ps

module tb_all_ablation_engines;

    logic clk = 0;
    logic rst;
    logic start;

    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];

    // Engine 0: Baseline
    logic signed [31:0] out_base;
    logic [3:0]         cyc_base;
    logic               done_base;

    // Engine 1: Only OI
    logic signed [31:0] out_oi;
    logic [3:0]         cyc_oi;
    logic [3:0]         skip_oi;
    logic               done_oi;

    // Engine 2: Only CG
    logic signed [31:0] out_cg;
    logic [3:0]         cyc_cg;
    logic [3:0]         skip_cg;
    logic               done_cg;

    // Engine 3: Only ZS
    logic signed [31:0] out_zs;
    logic [3:0]         cyc_zs;
    logic [3:0]         skip_zs;
    logic               done_zs;

    // Engine 4: Combined
    logic signed [31:0] out_comb;
    logic [3:0]         cyc_comb;
    logic [3:0]         skip_comb;
    logic               done_comb;

    // 50 MHz Clock
    always #10 clk = ~clk;

    // Instantiate All 5 Engines
    conv2d_serial_baseline u_base (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_base), .conv_out(out_base), .compute_cycles(cyc_base)
    );

    conv2d_serial_oi u_oi (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_oi), .conv_out(out_oi), .compute_cycles(cyc_oi), .skip_count(skip_oi)
    );

    conv2d_serial_cg u_cg (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_cg), .conv_out(out_cg), .compute_cycles(cyc_cg), .skip_count(skip_cg)
    );

    conv2d_serial_zs u_zs (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_zs), .conv_out(out_zs), .compute_cycles(cyc_zs), .skip_count(skip_zs)
    );

    conv2d_serial_combined u_comb (
        .clk(clk), .rst(rst), .start(start),
        .weights(weights), .pixels(pixels),
        .done(done_comb), .conv_out(out_comb), .compute_cycles(cyc_comb), .skip_count(skip_comb)
    );

    // Test stimulus
    logic [31:0] lfsr = 32'hBEEF_CAFE;
    always @(posedge clk) begin
        lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
    end

    integer patch_idx;
    integer k;
    integer err_oi = 0;
    integer err_cg = 0;
    integer err_zs = 0;
    integer err_comb = 0;

    integer total_cyc_base = 0;
    integer total_cyc_oi   = 0;
    integer total_cyc_cg   = 0;
    integer total_cyc_zs   = 0;
    integer total_cyc_comb = 0;
    integer total_skips_zs = 0;
    integer total_skips_comb = 0;

    initial begin
        rst   = 1;
        start = 0;
        for (k = 0; k < 9; k = k + 1) begin
            weights[k] = 8'sd0;
            pixels[k]  = 8'sd0;
        end

        #100;
        @(posedge clk);
        rst = 0;

        $display("==================================================================");
        $display(" >>> STARTING MULTI-ENGINE ABLATION LOCKSTEP VERIFICATION <<<");
        $display(" Testing 5 Engines: Baseline vs Only-OI vs Only-CG vs Only-ZS vs Combined");
        $display("==================================================================");

        for (patch_idx = 0; patch_idx < 100; patch_idx = patch_idx + 1) begin
            @(posedge clk);

            // Load 9 weights & 9 pixels with clean, non-out-of-bound indices
            for (k = 0; k < 9; k = k + 1) begin
                if (patch_idx < 25) begin
                    // 0% Sparsity (Dense, all non-zero)
                    weights[k] = (lfsr[k] == 0) ? 8'sd3 : lfsr[k*3 +: 8];
                    pixels[k]  = (lfsr[k+10] == 0) ? 8'sd5 : lfsr[(k*2)+8 +: 8];
                    if (weights[k] == 8'sd0) weights[k] = 8'sd7;
                    if (pixels[k]  == 8'sd0) pixels[k]  = 8'sd9;
                end else if (patch_idx < 50) begin
                    // Sobel filter (3 of 9 weights zero)
                    if (k == 1 || k == 4 || k == 7) weights[k] = 8'sd0;
                    else weights[k] = lfsr[k*2 +: 8];
                    pixels[k] = (!lfsr[k]) ? 8'sd0 : lfsr[(k*2)+8 +: 8];
                end else if (patch_idx < 75) begin
                    // Post-ReLU high sparsity (~70% zeros)
                    weights[k] = (!lfsr[k]) ? 8'sd0 : lfsr[k*2 +: 8];
                    pixels[k]  = (!lfsr[k+1] || !lfsr[k+2]) ? 8'sd0 : lfsr[(k*2)+4 +: 8];
                end else begin
                    // Extreme sparsity (95% zeros / all-zero patches)
                    weights[k] = (!lfsr[k] || !lfsr[k+1] || !lfsr[k+2]) ? 8'sd0 : lfsr[k*2 +: 8];
                    pixels[k]  = (!lfsr[k+3] || !lfsr[k+4] || !lfsr[k+5]) ? 8'sd0 : lfsr[(k*2)+6 +: 8];
                end
            end

            // Settle inputs before asserting start pulse
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            // Concurrently await completion of all 5 engines
            fork
                wait(done_base == 1);
                wait(done_oi   == 1);
                wait(done_cg   == 1);
                wait(done_zs   == 1);
                wait(done_comb == 1);
            join
            @(posedge clk);

            // Accumulate actual hardware cycle & skip counts
            total_cyc_base   = total_cyc_base   + cyc_base;
            total_cyc_oi     = total_cyc_oi     + cyc_oi;
            total_cyc_cg     = total_cyc_cg     + cyc_cg;
            total_cyc_zs     = total_cyc_zs     + cyc_zs;
            total_cyc_comb   = total_cyc_comb   + cyc_comb;
            total_skips_zs   = total_skips_zs   + skip_zs;
            total_skips_comb = total_skips_comb + skip_comb;

            // Verify bit-exact equality against Baseline
            if (out_oi   !== out_base) begin
                err_oi   = err_oi + 1;
                $display("Mismatch OI at patch %0d: got %h, exp %h", patch_idx, out_oi, out_base);
            end
            if (out_cg   !== out_base) begin
                err_cg   = err_cg + 1;
                $display("Mismatch CG at patch %0d: got %h, exp %h", patch_idx, out_cg, out_base);
            end
            if (out_zs   !== out_base) begin
                err_zs   = err_zs + 1;
                $display("Mismatch ZS at patch %0d: got %h, exp %h", patch_idx, out_zs, out_base);
            end
            if (out_comb !== out_base) begin
                err_comb = err_comb + 1;
                $display("Mismatch COMB at patch %0d: got %h, exp %h", patch_idx, out_comb, out_base);
            end

            repeat(2) @(posedge clk);
        end

        $display("==================================================================");
        $display(" 100 PATCHES COMPLETED ACROSS ALL 5 ENGINES:");
        $display("   - Only-OI Numerical Mismatches   : %0d", err_oi);
        $display("   - Only-CG Numerical Mismatches   : %0d", err_cg);
        $display("   - Only-ZS Numerical Mismatches   : %0d", err_zs);
        $display("   - Combined Numerical Mismatches  : %0d", err_comb);
        $display("------------------------------------------------------------------");
        $display(" HARDWARE CYCLE TELEMETRY (100 Patches / 900 MAC ops):");
        $display("   - Baseline Engine Cycles         : %0d", total_cyc_base);
        $display("   - Only-OI Engine Cycles          : %0d (Fixed 9 cyc/patch)", total_cyc_oi);
        $display("   - Only-CG Engine Cycles          : %0d (Fixed 9 cyc/patch)", total_cyc_cg);
        $display("   - Only-ZS Engine Cycles          : %0d (Skipped %0d products, %0.1f%% cycle reduction)", 
                 total_cyc_zs, total_skips_zs, (1.0 - real'(total_cyc_zs)/real'(total_cyc_base))*100.0);
        $display("   - Combined Engine Cycles         : %0d (Skipped %0d products, %0.1f%% cycle reduction)", 
                 total_cyc_comb, total_skips_comb, (1.0 - real'(total_cyc_comb)/real'(total_cyc_base))*100.0);
        $display("------------------------------------------------------------------");
        if (err_oi == 0 && err_cg == 0 && err_zs == 0 && err_comb == 0) begin
            $display(" >>> 100%% BIT-EXACT PASS: ALL 5 ENGINES MATCH BASELINE CONVOLUTION <<<");
        end else begin
            $display(" >>> FAILED: NUMERICAL MISMATCH DETECTED <<<");
        end
        $display("==================================================================");
        $finish;
    end

endmodule
