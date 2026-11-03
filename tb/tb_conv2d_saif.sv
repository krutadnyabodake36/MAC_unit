// =============================================================================
// File: tb_conv2d_saif.sv
// Description: Testbench for SAIF (Switching Activity) Generation
//              Exercises the conv2d engine with realistic CNN sparse data
//              to capture accurate switching activity for Vivado power analysis.
//
// Usage: Run in Vivado Simulator with SAIF dumping enabled.
//        See scripts/saif_power_analysis.tcl for the automated flow.
// =============================================================================

`timescale 1ns / 1ps

module tb_conv2d_saif;

    // Clock and Reset
    logic clk = 0;
    logic rst;
    logic start;
    logic done;

    logic signed [7:0]  weights [9];
    logic signed [7:0]  pixels  [9];
    logic signed [31:0] conv_out;
    logic [3:0]         compute_cycles;

    // Proposed-only signals
`ifdef USE_PROPOSED
    logic [3:0] skip_count;

    conv2d_serial_proposed u_dut (
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
`else
    conv2d_serial_baseline u_dut (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .weights        (weights),
        .pixels         (pixels),
        .done           (done),
        .conv_out       (conv_out),
        .compute_cycles (compute_cycles)
    );
`endif

    // 50 MHz Clock (20ns period)
    always #10 clk = ~clk;

    // LFSR for pseudo-random data (matches stress test)
    logic [31:0] lfsr = 32'hDEAD_BEEF;
    always @(posedge clk) begin
        lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
    end

    // Sobel kernel (constant)
    initial begin
        weights[0] = -1; weights[1] = 0; weights[2] = 1;
        weights[3] = -2; weights[4] = 0; weights[5] = 2;
        weights[6] = -1; weights[7] = 0; weights[8] = 1;
    end

    // Test sequence: 500 convolutions with ~65% sparse pixel data
    integer i, patch;
    integer pass_count = 0;
    integer total_cycles_used = 0;

    initial begin
        rst   = 1;
        start = 0;
        for (i = 0; i < 9; i++) pixels[i] = 0;

        // Hold reset for 200ns
        #200;
        rst = 0;
        #40;

        // Run 500 convolution patches
        for (patch = 0; patch < 500; patch = patch + 1) begin

            // Generate sparse pixel data using LFSR bits
            @(posedge clk);
            for (i = 0; i < 9; i++) begin
                // ~65% sparsity: zero when 2 specific LFSR bits are both 0
                if (!lfsr[(i*3) % 32] && !lfsr[((i*3)+1) % 32])
                    pixels[i] = 8'sd0;
                else
                    pixels[i] = lfsr[((i*3)+8) % 32 +: 8];
            end

            // Pulse start
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            // Wait for done
            wait(done == 1);
            @(posedge clk);

            total_cycles_used = total_cycles_used + compute_cycles;
            pass_count = pass_count + 1;

            // Small gap between patches (realistic)
            repeat(2) @(posedge clk);
        end

        $display("==============================================");
        $display("  SAIF Simulation Complete");
        $display("  Patches processed: %0d", pass_count);
        $display("  Total compute cycles: %0d", total_cycles_used);
        $display("  Avg cycles/patch: %0.2f", real'(total_cycles_used) / real'(pass_count));
        $display("==============================================");

        #100;
        $finish;
    end

endmodule
