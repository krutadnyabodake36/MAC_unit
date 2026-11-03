// =============================================================================
// File: conv2d_serial_baseline.sv
// Design: Baseline Serial 3x3 Convolution Engine (No Zero-Skipping)
// Target: Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Serial Multiply-Accumulate convolution engine for a 3x3 kernel.
//   Processes all 9 weight×pixel products sequentially, one per clock cycle.
//   Always takes exactly 9 compute cycles regardless of data values.
//
// Interface:
//   - start:  Pulse high for 1 cycle to begin computation
//   - done:   Pulses high for 1 cycle when result is ready
//   - compute_cycles: Reports the number of MAC cycles used (always 9)
//
// Latency: 11 clock cycles total (1 start + 9 compute + 1 output)
// =============================================================================

`timescale 1ns / 1ps

module conv2d_serial_baseline (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,            // Pulse to begin computation
    input  logic signed [7:0]   weights [9],      // Pre-loaded 3x3 kernel weights
    input  logic signed [7:0]   pixels  [9],      // Pre-loaded 3x3 pixel window
    output logic                done,             // Pulse when result is ready
    output logic signed [31:0]  conv_out,         // 32-bit signed convolution result
    output logic [3:0]          compute_cycles    // Compute cycles used (always 9)
);

    // -------------------------------------------------------------------------
    // FSM States
    // -------------------------------------------------------------------------
    typedef enum logic [1:0] {
        ST_IDLE    = 2'b00,
        ST_COMPUTE = 2'b01,
        ST_DONE    = 2'b10
    } state_t;

    state_t              state;
    logic [3:0]          idx;       // Current product index (0..8)
    logic [3:0]          cycles;    // Compute cycle counter
    logic signed [31:0]  accum;     // Running accumulator

    // -------------------------------------------------------------------------
    // Operand Selection Mux (9:1 based on current index)
    // -------------------------------------------------------------------------
    logic signed [7:0] sel_w, sel_p;
    always_comb begin
        sel_w = weights[idx];
        sel_p = pixels[idx];
    end

    // -------------------------------------------------------------------------
    // Main FSM: Serial Multiply-Accumulate
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            state          <= ST_IDLE;
            done           <= 1'b0;
            conv_out       <= 32'sd0;
            compute_cycles <= 4'd0;
            idx            <= 4'd0;
            cycles         <= 4'd0;
            accum          <= 32'sd0;
        end else begin
            done <= 1'b0;  // Default: done is single-cycle pulse

            case (state)
                // ---------------------------------------------------------
                // IDLE: Wait for start pulse
                // ---------------------------------------------------------
                ST_IDLE: begin
                    if (start) begin
                        accum  <= 32'sd0;
                        idx    <= 4'd0;
                        cycles <= 4'd0;
                        state  <= ST_COMPUTE;
                    end
                end

                // ---------------------------------------------------------
                // COMPUTE: Unconditional MAC on every product (9 cycles)
                //   - Always multiplies weights[idx] * pixels[idx]
                //   - Always accumulates, even when product is zero
                //   - Advances index every cycle
                // ---------------------------------------------------------
                ST_COMPUTE: begin
                    accum  <= accum + 32'(sel_w * sel_p);
                    cycles <= cycles + 4'd1;

                    if (idx == 4'd8) begin
                        state <= ST_DONE;   // All 9 products computed
                    end else begin
                        idx <= idx + 4'd1;  // Next product
                    end
                end

                // ---------------------------------------------------------
                // DONE: Output result and return to idle
                // ---------------------------------------------------------
                ST_DONE: begin
                    conv_out       <= accum;
                    compute_cycles <= cycles;  // Always 9
                    done           <= 1'b1;
                    state          <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
