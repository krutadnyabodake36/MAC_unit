// =============================================================================
// File: mac_baseline.sv
// Design: Baseline Multiply-Accumulate (MAC) Unit (Design 1)
// Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz) / 7-Series
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Standard baseline Multiply-Accumulate unit running unconditionally.
//   Both the combinational multiplier and the sequential accumulator are
//   active whenever 'en' is asserted, regardless of whether inputs are zero.
//   Serves as the reference benchmark for switching activity and dynamic power.
//
// Datapath:
//   - Inputs: 8-bit signed Weight (in_a), 8-bit signed Activation (in_b)
//   - Multiplier: 16-bit signed product (mult_product = in_a * in_b)
//   - Accumulator: 32-bit signed register (accum_out = accum_out + mult_product)
// =============================================================================

`timescale 1ns / 1ps

module mac_baseline (
    input  logic               clk,        // System Clock
    input  logic               rst,        // Synchronous active-high reset
    input  logic               clr,        // Synchronous accumulator clear
    input  logic               en,         // Datapath enable / valid strobe
    input  logic signed [7:0]  in_a,       // 8-bit signed Weight operand
    input  logic signed [7:0]  in_b,       // 8-bit signed Activation operand
    output logic signed [31:0] accum_out   // 32-bit signed Accumulator output
);

    // -------------------------------------------------------------------------
    // Internal Signals
    // -------------------------------------------------------------------------
    logic signed [15:0] mult_product;

    // -------------------------------------------------------------------------
    // Combinational Multiplier (Unconditional switching)
    // Dynamic switching occurs whenever in_a or in_b transitions, even if
    // one operand is zero.
    // -------------------------------------------------------------------------
    always_comb begin
        mult_product = in_a * in_b;
    end

    // -------------------------------------------------------------------------
    // Sequential Accumulator (Unconditional accumulation on 'en')
    // Accumulator updates every active cycle, adding 0 when product is zero.
    // Standard always_ff construct without manual clock gating.
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
