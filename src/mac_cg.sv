// =============================================================================
// File: mac_cg.sv
// Design: Ablation Unit 2 — MAC with ONLY Inferred Clock Gating (CG)
// Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz) / 7-Series
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Ablation study design evaluating the isolated impact of Clock Gating.
//   Includes NOR-based zero detection and disables the accumulator Clock
//   Enable (accum_ce) whenever either operand is zero.
//   DOES NOT implement Operand Isolation: the multiplier receives the raw,
//   unclamped operands, allowing partial-product logic and adder nets to toggle.
// =============================================================================

`timescale 1ns / 1ps

module mac_cg (
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
    logic signed [15:0] mult_product;  // Multiplier product
    logic               accum_ce;      // Inferred clock enable for accumulator

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
    // Step 2: Multiplier WITHOUT Operand Isolation (Ablation Condition)
    // Operands enter the multiplier directly without clamping MUXes.
    // -------------------------------------------------------------------------
    always_comb begin
        mult_product = in_a * in_b;
    end

    // -------------------------------------------------------------------------
    // Step 3: Inferred Clock Gating (CG) Active
    // Clock enable for accumulator is de-asserted when zero is detected.
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

