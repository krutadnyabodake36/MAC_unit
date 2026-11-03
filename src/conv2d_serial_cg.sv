// =============================================================================
// File: conv2d_serial_cg.sv
// Design: 3x3 Convolution Engine with ONLY Clock Gating (Ablation Design 2)
// Target: Xilinx/AMD Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Ablation engine that evaluates the standalone effect of CLOCK GATING
//   in a 3x3 convolution workload.
//
// Architectural Characteristics:
//   - Execution Schedule: Strictly 9 clock cycles per patch (identical to baseline).
//     NO cycle skipping (Zero-Skipping is disabled).
//   - Multiplier Datapath: Raw operands feed the multiplier unconditionally.
//     NO operand isolation clamping MUXes. Internal partial products switch.
//   - Clock Gating: Inferred Clock Enable (CE) on the accumulator register.
//     If (weights[idx] == 0 || pixels[idx] == 0), the accumulator CE is de-asserted,
//     preventing flip-flop transitions and saving register toggle power.
//
// Telemetry:
//   - compute_cycles: Always reports 9 (no latency compression).
//   - skip_count:     Reports the exact count of clock-gated zero cycles (0..9).
// =============================================================================

`timescale 1ns / 1ps

module conv2d_serial_cg (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,            // 1-cycle pulse to start
    input  logic signed [7:0]   weights [9],      // 3x3 kernel weights
    input  logic signed [7:0]   pixels  [9],      // 3x3 pixel window
    output logic                done,             // 1-cycle pulse when finished
    output logic signed [31:0]  conv_out,         // 32-bit accumulated result
    output logic [3:0]          compute_cycles,   // Compute cycles used (always 9)
    output logic [3:0]          skip_count        // Count of clock-gated zero cycles
);

    typedef enum logic [1:0] {
        ST_IDLE    = 2'b00,
        ST_COMPUTE = 2'b01,
        ST_DONE    = 2'b10
    } state_t;

    state_t             state;
    logic [3:0]         idx;       // Product index (0..8)
    logic [3:0]         cycles;    // Compute cycle counter
    logic [3:0]         gated;     // Clock-gated cycle counter
    logic signed [31:0] accum;

    // -------------------------------------------------------------------------
    // Operand Selection MUX (9:1 based on current index)
    // -------------------------------------------------------------------------
    logic signed [7:0] raw_w, raw_p;
    always_comb begin
        raw_w = weights[idx];
        raw_p = pixels[idx];
    end

    // -------------------------------------------------------------------------
    // Step 1: Zero Detection via NOR Reduction
    // -------------------------------------------------------------------------
    logic is_zero;
    always_comb begin
        is_zero = (~|raw_w) | (~|raw_p);
    end

    // -------------------------------------------------------------------------
    // Step 2: Unconstrained Multiplier (NO Operand Isolation Clamping)
    // -------------------------------------------------------------------------
    logic signed [15:0] mult_product;
    always_comb begin
        mult_product = raw_w * raw_p;
    end

    // -------------------------------------------------------------------------
    // Step 3: Main FSM with Inferred Accumulator Clock Enable
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            state          <= ST_IDLE;
            done           <= 1'b0;
            conv_out       <= 32'sd0;
            compute_cycles <= 4'd0;
            skip_count     <= 4'd0;
            idx            <= 4'd0;
            cycles         <= 4'd0;
            gated          <= 4'd0;
            accum          <= 32'sd0;
        end else begin
            done <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        accum  <= 32'sd0;
                        idx    <= 4'd0;
                        cycles <= 4'd0;
                        gated  <= 4'd0;
                        state  <= ST_COMPUTE;
                    end
                end

                ST_COMPUTE: begin
                    cycles <= cycles + 4'd1;

                    // Clock Enable Gating: only update accumulator if product is non-zero
                    if (!is_zero) begin
                        accum <= accum + 32'(mult_product);
                    end else begin
                        gated <= gated + 4'd1;
                    end

                    if (idx == 4'd8) begin
                        state <= ST_DONE;
                    end else begin
                        idx <= idx + 4'd1;
                    end
                end

                ST_DONE: begin
                    conv_out       <= accum;
                    compute_cycles <= cycles;    // Always 9
                    skip_count     <= gated;     // Number of gated cycles
                    done           <= 1'b1;
                    state          <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule

