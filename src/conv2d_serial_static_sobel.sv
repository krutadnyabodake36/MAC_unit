// =============================================================================
// File: conv2d_serial_static_sobel.sv
// Design: Static Sobel-X 6-Tap Serial 3x3 Convolution Engine (No Zero Detection)
// Target: Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Hardcoded 6-tap serial Multiply-Accumulate convolution engine tailored
//   statically for the 3x3 Sobel-X kernel.
//   Sobel-X kernel has static zeros at taps 1, 4, 7 (column 1):
//     [-1,  0, +1]
//     [-2,  0, +2]
//     [-1,  0, +1]
//   Processes only non-zero taps (0, 2, 3, 5, 6, 8) in a fixed 6-cycle schedule.
//   No dynamic zero detection, no comparator logic, no skip metadata.
//
// Interface:
//   - Same ports as conv2d_serial_baseline.sv
//   - start:  Pulse high for 1 cycle to begin computation
//   - done:   Pulses high for 1 cycle when result is ready
//   - compute_cycles: Reports the number of MAC cycles used (always 6)
//
// Latency: 8 clock cycles total (1 start + 6 compute + 1 output)
// =============================================================================

`timescale 1ns / 1ps

module conv2d_serial_static_sobel (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,            // Pulse to begin computation
    input  logic signed [7:0]   weights [9],      // Pre-loaded 3x3 kernel weights
    input  logic signed [7:0]   pixels  [9],      // Pre-loaded 3x3 pixel window
    output logic                done,             // Pulse when result is ready
    output logic signed [31:0]  conv_out,         // 32-bit signed convolution result
    output logic [3:0]          compute_cycles    // Compute cycles used (always 6)
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
    logic [2:0]          step;      // Step counter 0..5 (6 steps total)
    logic [3:0]          cycles;    // Compute cycle counter
    logic signed [31:0]  accum;     // Running accumulator

    // -------------------------------------------------------------------------
    // 6-Tap Static Selection: taps 0, 2, 3, 5, 6, 8
    // -------------------------------------------------------------------------
    logic signed [7:0] sel_w, sel_p;
    always_comb begin
        case (step)
            3'd0: begin sel_w = weights[0]; sel_p = pixels[0]; end
            3'd1: begin sel_w = weights[2]; sel_p = pixels[2]; end
            3'd2: begin sel_w = weights[3]; sel_p = pixels[3]; end
            3'd3: begin sel_w = weights[5]; sel_p = pixels[5]; end
            3'd4: begin sel_w = weights[6]; sel_p = pixels[6]; end
            3'd5: begin sel_w = weights[8]; sel_p = pixels[8]; end
            default: begin sel_w = weights[0]; sel_p = pixels[0]; end
        endcase
    end

    // -------------------------------------------------------------------------
    // Main FSM: Serial Multiply-Accumulate over 6 static taps
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            state          <= ST_IDLE;
            done           <= 1'b0;
            conv_out       <= 32'sd0;
            compute_cycles <= 4'd0;
            step           <= 3'd0;
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
                        step   <= 3'd0;
                        cycles <= 4'd0;
                        state  <= ST_COMPUTE;
                    end
                end

                // ---------------------------------------------------------
                // COMPUTE: Fixed 6-step MAC schedule
                // ---------------------------------------------------------
                ST_COMPUTE: begin
                    accum  <= accum + 32'(sel_w * sel_p);
                    cycles <= cycles + 4'd1;

                    if (step == 3'd5) begin
                        state <= ST_DONE;   // All 6 taps computed
                    end else begin
                        step  <= step + 3'd1;
                    end
                end

                // ---------------------------------------------------------
                // DONE: Output result and return to idle
                // ---------------------------------------------------------
                ST_DONE: begin
                    conv_out       <= accum;
                    compute_cycles <= cycles;  // Always 6
                    done           <= 1'b1;
                    state          <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule

