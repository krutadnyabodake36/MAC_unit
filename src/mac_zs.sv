// =============================================================================
// File: mac_zs.sv
// Design: Single MAC Unit with Handshake ZERO-SKIPPING (Ablation Design 3)
// Target: Xilinx/AMD Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   A standalone Single MAC unit featuring zero-skipping via a start/done
//   handshake protocol.
//
// Operational Mechanism:
//   - An 8-input NOR reduction detects whether in_a == 0 or in_b == 0.
//   - If either operand is zero:
//       * The operation is skipped entirely.
//       * The multiplier and accumulator are NOT evaluated.
//       * 'zero_skip' is asserted high.
//       * 'done' completes immediately with cycles_taken = 0.
//   - If both operands are non-zero:
//       * The product (in_a * in_b) is computed and added to the accumulator.
//       * 'done' completes with cycles_taken = 1.
// =============================================================================

`timescale 1ns / 1ps

module mac_zs (
    input  logic               clk,
    input  logic               rst,
    input  logic               clr,          // Synchronous accumulator clear
    input  logic               start,        // Valid start strobe
    input  logic signed [7:0]  in_a,         // 8-bit signed Weight operand
    input  logic signed [7:0]  in_b,         // 8-bit signed Activation operand
    output logic               done,         // 1-cycle completion strobe
    output logic signed [31:0] accum_out,    // 32-bit accumulated sum
    output logic               zero_skip,    // Real-time zero-skip flag
    output logic               cycles_taken  // 0 = skipped, 1 = computed
);

    // -------------------------------------------------------------------------
    // NOR-based Zero Detection
    // -------------------------------------------------------------------------
    logic is_zero;
    always_comb begin
        is_zero = (~|in_a) | (~|in_b);
    end

    // -------------------------------------------------------------------------
    // Multiplier (Evaluated only on non-zero valid requests)
    // -------------------------------------------------------------------------
    logic signed [15:0] mult_product;
    always_comb begin
        mult_product = in_a * in_b;
    end

    // -------------------------------------------------------------------------
    // Sequential Controller & Accumulator
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            accum_out    <= 32'sd0;
            done         <= 1'b0;
            zero_skip    <= 1'b0;
            cycles_taken <= 1'b0;
        end else if (clr) begin
            accum_out    <= 32'sd0;
            done         <= 1'b0;
            zero_skip    <= 1'b0;
            cycles_taken <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start) begin
                done      <= 1'b1;
                zero_skip <= is_zero;

                if (is_zero) begin
                    // Zero-Skip: do not update accumulator, 0 compute cycles
                    cycles_taken <= 1'b0;
                end else begin
                    // Non-zero: accumulate product, 1 compute cycle
                    accum_out    <= accum_out + 32'(mult_product);
                    cycles_taken <= 1'b1;
                end
            end
        end
    end

endmodule

