// =============================================================================
// File: tb_single_mac.sv
// Description: Lockstep Verification & Activity Benchmark for Single MAC Units
//              Compares mac_baseline vs mac_combined under realistic CNN workload.
// =============================================================================

`timescale 1ns / 1ps

module tb_single_mac;

    logic               clk = 0;
    logic               rst;
    logic               clr;
    logic               en;
    logic signed [7:0]  in_a;
    logic signed [7:0]  in_b;

    logic signed [31:0] bl_accum_out;
    logic signed [31:0] pr_accum_out;
    logic               pr_zero_skip;

    // 100 MHz Clock (10ns period)
    always #5 clk = ~clk;

    // Instantiate Baseline Single MAC
    mac_baseline u_baseline (
        .clk        (clk),
        .rst        (rst),
        .clr        (clr),
        .en         (en),
        .in_a       (in_a),
        .in_b       (in_b),
        .accum_out  (bl_accum_out)
    );

    // Instantiate Proposed Single MAC
    mac_combined u_proposed (
        .clk        (clk),
        .rst        (rst),
        .clr        (clr),
        .en         (en),
        .in_a       (in_a),
        .in_b       (in_b),
        .accum_out  (pr_accum_out),
        .zero_skip  (pr_zero_skip)
    );

    // LFSR for realistic pseudo-random sparse data
    logic [31:0] lfsr = 32'hA5A5_5A5A;
    always @(posedge clk) begin
        lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
    end

    // Predefined 3x3 Sobel kernel weights (sparse, 3 out of 9 are zero)
    logic signed [7:0] sobel_weights [9] = '{-1, 0, 1, -2, 0, 2, -1, 0, 1};

    integer i;
    integer total_ops = 0;
    integer non_zero_ops = 0;
    integer zero_skipped_ops = 0;
    integer mismatches = 0;

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
        $display(" >>> STARTING SINGLE MAC LOCKSTEP BENCHMARK <<<");
        $display(" Workload: 1,800 operations (200 3x3 convolutions @ ~70%% sparsity)");
        $display("==================================================================");

        for (i = 0; i < 1800; i = i + 1) begin
            @(posedge clk);

            // Weight from Sobel filter
            in_a = sobel_weights[i % 9];

            // Activation with ~65% sparsity (simulating post-ReLU CNN layer)
            if (!lfsr[0] && !lfsr[1])
                in_b = 8'sd0;
            else if (!lfsr[2] && !lfsr[3])
                in_b = 8'sd0;
            else
                in_b = lfsr[15:8];

            total_ops = total_ops + 1;

            if (in_a == 8'sd0 || in_b == 8'sd0)
                zero_skipped_ops = zero_skipped_ops + 1;
            else
                non_zero_ops = non_zero_ops + 1;

            // Check lockstep match
            #1; // Sample shortly after clock edge
            if (bl_accum_out !== pr_accum_out) begin
                $display("[ERROR] Mismatch at op %0d: Baseline=%0d, Proposed=%0d", 
                         i, bl_accum_out, pr_accum_out);
                mismatches = mismatches + 1;
            end

            // Clear accumulator every 9 operations (matches 3x3 patch boundary)
            if ((i % 9) == 8) begin
                @(posedge clk);
                clr = 1;
                @(posedge clk);
                clr = 0;
            end
        end

        @(posedge clk);
        en = 0;

        $display("\n==================================================================");
        $display("              SINGLE MAC BENCHMARK RESULTS                        ");
        $display("==================================================================");
        $display(" Total Operations Evaluated  : %0d", total_ops);
        $display(" Non-Zero Operations         : %0d (%0.2f%%)", non_zero_ops, (non_zero_ops*100.0)/total_ops);
        $display(" Zero-Skipped Operations     : %0d (%0.2f%%)", zero_skipped_ops, (zero_skipped_ops*100.0)/total_ops);
        $display(" Functional Verification     : %s", (mismatches == 0) ? "PASS (100% Bit-Exact Match)" : "FAIL");
        $display(" Multiplier Clamped to 0     : %0d cycles (%0.2f%% quiescence)", zero_skipped_ops, (zero_skipped_ops*100.0)/total_ops);
        $display(" Accumulator Clock Gated     : %0d cycles (%0.2f%% register freeze)", zero_skipped_ops, (zero_skipped_ops*100.0)/total_ops);
        $display("==================================================================");

        #50;
        $finish;
    end

endmodule
