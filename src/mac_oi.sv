// =============================================================================
// File: mac_oi.sv
// Design: Ablation Unit 1 — MAC with ONLY Operand Isolation (OI)
// Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz) / 7-Series
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Ablation study design evaluating the isolated impact of Operand Isolation.
//   Includes NOR-based zero detection and combinational clamping gates before
//   the multiplier tree.
//   DOES NOT implement Clock Gating: the accumulator updates unconditionally
//   whenever 'en' is asserted, adding 0 to the accumulator during zero cycles.
// =============================================================================

`timescale 1ns / 1ps

module mac_oi (
    input  logic               clk,          // System Clock
    input  logic               rst,          // Synchronous active-high reset
    input  logic               clr,          // Synchronous accumulator clear
    input  logic               en,           // Datapath enable / valid strobe
    input  logic signed [7:0]  in_a,         // 8-bit signed Weight operand
    input  logic signed [7:0]  in_b,         // 8-bit signed Activation operand
    output logic signed [31:0] accum_out,    // 32-bit signed Accumulator output
    output logic               zero_skip     // Zero-detection status flag
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

    // -------------------------------------------------------------------------
    // Step 1: Activity Detector (NOR Logic)
    // -------------------------------------------------------------------------
    always_comb begin
        zero_act    = ~|in_b;                  // 8-input NOR reduction on Activation
        zero_wgt    = ~|in_a;                  // 8-input NOR reduction on Weight
        zero_detect = zero_act | zero_wgt;     // Active if either operand is zero
    end

    assign zero_skip = zero_detect;

    // -------------------------------------------------------------------------
    // Step 2: Operand Isolation (OI) Active
    // Clamps multiplier inputs to 0 when zero_detect is active or when en is low.
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
    // Step 3: Accumulator WITHOUT Clock Gating (Ablation Condition)
    // Accumulator updates every active cycle on 'en' (adding 0 when isolated).
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            accum_out <= 32'sd0;
        end else if (clr) begin
            accum_out <= 32'sd0;
        end else if (en) begin
            accum_out <= accum_out + 32'(mult_product);
        end
    end

endmodule

