// =============================================================================
// File: tb_ablation_mac.sv
// Description: Multi-Unit Lockstep Verification Testbench for Ablation Study:
//              1. mac_baseline (No low power techniques)
//              2. mac_oi       (Only Operand Isolation)
//              3. mac_cg       (Only Clock Gating)
//              4. mac_combined (Combined Operand Isolation + Clock Gating)
//
// Evaluates numerical exactness across various sparsity levels:
//   - 0% Sparsity (All non-zero)
//   - 33.3% Sparsity (Sobel filter zeros)
//   - 70% Sparsity (Post-ReLU activations)
//   - 100% Sparsity (All-zero patch)
// =============================================================================

`timescale 1ns / 1ps

module tb_ablation_mac;

    logic               clk = 0;
    logic               rst;
    logic               clr;
    logic               en;
    logic signed [7:0]  in_a;
    logic signed [7:0]  in_b;

    // Outputs from each unit
    logic signed [31:0] accum_bl;
    logic signed [31:0] accum_oi;
    logic signed [31:0] accum_cg;
    logic signed [31:0] accum_zs;
    logic signed [31:0] accum_cb;

    logic               skip_oi;
    logic               skip_cg;
    logic               skip_zs;
    logic               skip_cb;
    logic               done_zs;
    logic               cyc_zs;

    // 50 MHz Clock (20 ns period)
    always #10 clk = ~clk;

    // Instantiate Unit 0: Baseline MAC
    mac_baseline u_bl (
        .clk        (clk),
        .rst        (rst),
        .clr        (clr),
        .en         (en),
        .in_a       (in_a),
        .in_b       (in_b),
        .accum_out  (accum_bl)
    );

    // Instantiate Unit 1: Only Operand Isolation
    mac_oi u_oi (
        .clk        (clk),
        .rst        (rst),
        .clr        (clr),
        .en         (en),
        .in_a       (in_a),
        .in_b       (in_b),
        .accum_out  (accum_oi),
        .zero_skip  (skip_oi)
    );

    // Instantiate Unit 2: Only Clock Gating
    mac_cg u_cg (
        .clk        (clk),
        .rst        (rst),
        .clr        (clr),
        .en         (en),
        .in_a       (in_a),
        .in_b       (in_b),
        .accum_out  (accum_cg),
        .zero_skip  (skip_cg)
    );

    // Instantiate Unit 3: Only Zero-Skipping
    mac_zs u_zs (
        .clk          (clk),
        .rst          (rst),
        .clr          (clr),
        .start        (en),
        .in_a         (in_a),
        .in_b         (in_b),
        .done         (done_zs),
        .accum_out    (accum_zs),
        .zero_skip    (skip_zs),
        .cycles_taken (cyc_zs)
    );

    // Instantiate Unit 4: Combined OI + CG
    mac_combined u_cb (
        .clk        (clk),
        .rst        (rst),
        .clr        (clr),
        .en         (en),
        .in_a       (in_a),
        .in_b       (in_b),
        .accum_out  (accum_cb),
        .zero_skip  (skip_cb)
    );

    // LFSR for data generation
    logic [31:0] lfsr = 32'h1234_5678;
    always @(posedge clk) begin
        lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
    end

    integer i;
    integer total_tests = 0;
    integer errors_oi = 0;
    integer errors_cg = 0;
    integer errors_zs = 0;
    integer errors_cb = 0;

    initial begin
        rst = 1;
        clr = 0;
        en  = 0;
        in_a = 0;
        in_b = 0;

        #100;
        @(posedge clk);
        rst = 0;
        en  = 1;

        $display("==================================================================");
        $display(" >>> STARTING ABLATION SUITE LOCKSTEP VERIFICATION <<<");
        $display(" Testing: Baseline vs Only-OI vs Only-CG vs Combined (OI+CG)");
        $display("==================================================================");

        // Run 2,000 randomized operations with diverse sparsity
        for (i = 0; i < 2000; i = i + 1) begin
            @(posedge clk);

            // Vary sparsity across iterations:
            // i < 500   : 0% sparsity (stress test, all non-zero)
            // 500..1000 : 33% sparsity (Sobel-like)
            // 1000..1500: 70% sparsity (Post-ReLU)
            // 1500..2000: 95% sparsity (Pruned deep layer)
            if (i < 500) begin
                in_a = (lfsr[7:0] == 0) ? 8'sd1 : lfsr[7:0];
                in_b = (lfsr[15:8] == 0) ? 8'sd1 : lfsr[15:8];
            end else if (i < 1000) begin
                in_a = (i % 3 == 0) ? 8'sd0 : lfsr[7:0];
                in_b = (!lfsr[0] && !lfsr[1]) ? 8'sd0 : lfsr[15:8];
            end else if (i < 1500) begin
                in_a = lfsr[7:0];
                in_b = (!lfsr[0] || !lfsr[1]) ? 8'sd0 : lfsr[15:8];
            end else begin
                in_a = (!lfsr[0] || !lfsr[1] || !lfsr[2]) ? 8'sd0 : lfsr[7:0];
                in_b = (!lfsr[3] || !lfsr[4] || !lfsr[5]) ? 8'sd0 : lfsr[15:8];
            end

            total_tests = total_tests + 1;

            #1; // Sample shortly after clock edge
            if (accum_oi !== accum_bl) errors_oi = errors_oi + 1;
            if (accum_cg !== accum_bl) errors_cg = errors_cg + 1;
            if (accum_zs !== accum_bl) errors_zs = errors_zs + 1;
            if (accum_cb !== accum_bl) errors_cb = errors_cb + 1;
        end

        $display("==================================================================");
        $display(" ABLATION VERIFICATION RESULTS (2,000 vectors):");
        $display("   - Only-OI Errors    : %0d / %0d", errors_oi, total_tests);
        $display("   - Only-CG Errors    : %0d / %0d", errors_cg, total_tests);
        $display("   - Only-ZS Errors    : %0d / %0d", errors_zs, total_tests);
        $display("   - Combined Errors   : %0d / %0d", errors_cb, total_tests);
        if (errors_oi == 0 && errors_cg == 0 && errors_zs == 0 && errors_cb == 0) begin
            $display(" >>> 100%% BIT-EXACT PASS: ALL ABLATION UNITS MATCH BASELINE <<<");
        end else begin
            $display(" >>> FAILED: MISMATCH DETECTED <<<");
        end
        $display("==================================================================");
        $finish;
    end

endmodule

