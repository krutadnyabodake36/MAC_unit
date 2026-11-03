// =============================================================================
// File: mac_combined.sv
// Design: Proposed Low-Power Zero-Skipping MAC Architecture (Design 4)
// Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz) / 7-Series
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   The Proposed Architecture combining NOR-based Activity Detection with both
//   Operand Isolation (OI) and Integrated Clock Gating (CG) for sparse CNN workloads.
//
// Operational Mechanism:
//   1. Activity Detector (NOR Logic):
//      Employs multi-bit NOR reduction trees to instantly detect zero activations
//      (from post-ReLU sparsity) and zero weights (from sparse kernels).
//   2. Operand Isolation (OI):
//      When a zero is detected, multiplier inputs are clamped to 8'sd0 via
//      combinational isolation gates, completely silencing dynamic switching
//      across partial product generators and adder trees.
//   3. Inferred Clock Gating (CG):
//      Simultaneously de-asserts the accumulator Clock Enable (CE), preventing
//      redundant flip-flop toggling and clock distribution switching in the
//      accumulator datapath.
//
// Engineering Constraints:
//   - Synthesizable SystemVerilog constructs (always_ff, always_comb, logic).
//   - No manual clock gating (no 'clk & enable'); standard 'always_ff' CE inference
//     is utilized to map to FPGA Slice / DSP48 primitives.
// =============================================================================

`timescale 1ns / 1ps

module mac_combined (
    input  logic               clk,          // System Clock
    input  logic               rst,          // Synchronous active-high reset
    input  logic               clr,          // Synchronous accumulator clear
    input  logic               en,           // Datapath enable / valid strobe
    input  logic signed [7:0]  in_a,         // 8-bit signed Weight operand
    input  logic signed [7:0]  in_b,         // 8-bit signed Activation operand
    output logic signed [31:0] accum_out,    // 32-bit signed Accumulator output
    output logic               zero_skip     // Zero-detection / zero-skip status flag
);

    // -------------------------------------------------------------------------
    // Internal Signals
    // -------------------------------------------------------------------------
    logic               zero_act;      // NOR-reduced activation zero indicator
    logic               zero_wgt;      // NOR-reduced weight zero indicator
    logic               zero_detect;   // Combined zero detection flag
    logic signed [7:0]  iso_a;         // Isolated Weight operand
    logic signed [7:0]  iso_b;         // Isolated Activation operand
    logic signed [15:0] mult_product;  // Multiplier product
    logic               accum_ce;      // Inferred clock enable for accumulator

    // -------------------------------------------------------------------------
    // Step 1: Activity Detector (NOR Logic)
    // Multi-bit NOR reduction: an operand is zero iff all of its bits are 0.
    // In CMOS / FPGA logic, NOR reduction produces low latency and minimal area.
    // -------------------------------------------------------------------------
    always_comb begin
        zero_act    = ~|in_b;                  // 8-input NOR reduction on Activation
        zero_wgt    = ~|in_a;                  // 8-input NOR reduction on Weight
        zero_detect = zero_act | zero_wgt;     // Active if either operand is zero
    end

    assign zero_skip = zero_detect;

    // -------------------------------------------------------------------------
    // Step 2: Operand Isolation (OI)
    // Clamps multiplier inputs to 0 when zero_detect is active or when en is low.
    // Stops internal combinational switching within the multiplier array.
    // -------------------------------------------------------------------------
    always_comb begin
        if (zero_detect || !en) begin
            iso_a = 8'sd0;
            iso_b = 8'sd0;
        end else begin
            iso_a = in_a;
            iso_b = in_b;
        end
    end

    // Combinational Multiplier operating on isolated operands
    always_comb begin
        mult_product = iso_a * iso_b;
    end

    // -------------------------------------------------------------------------
    // Step 3: Sequential Clock Gating (CG)
    // Clock enable for accumulator is pulled low when zero is detected.
    // Standard always_ff enable condition infers native CE on FPGA Slice/DSP48.
    // -------------------------------------------------------------------------
    assign accum_ce = en && (!zero_detect);

    always_ff @(posedge clk) begin
        if (rst) begin
            accum_out <= 32'sd0;
        end else if (clr) begin
            accum_out <= 32'sd0;
        end else if (accum_ce) begin
            accum_out <= accum_out + 32'(mult_product);
        end
    end

endmodule
