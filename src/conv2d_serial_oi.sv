// =============================================================================
// File: conv2d_serial_oi.sv
// Design: 3x3 Convolution Engine with ONLY Operand Isolation (Ablation Design 1)
// Target: Xilinx/AMD Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Ablation engine that evaluates the standalone effect of OPERAND ISOLATION
//   in a 3x3 convolution workload.
//
// Architectural Characteristics:
//   - Execution Schedule: Strictly 9 clock cycles per patch (identical to baseline).
//     NO cycle skipping (Zero-Skipping is disabled).
//   - Operand Isolation: An 8-input NOR reduction detector checks each product pair
//     (weights[idx], pixels[idx]). If either is zero, combinational clamping MUXes
//     force the multiplier inputs to 8'sd0.
//   - Accumulator: Clock gating is DISABLED. The accumulator register clocks every
//     cycle, adding 0 when an operand is isolated.
//
// Telemetry:
//   - compute_cycles: Always reports 9 (no latency compression).
//   - skip_count:     Reports the exact count of isolated zero products (0..9).
// =============================================================================

`timescale 1ns / 1ps

module conv2d_serial_oi (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,            // 1-cycle pulse to start
    input  logic signed [7:0]   weights [9],      // 3x3 kernel weights
    input  logic signed [7:0]   pixels  [9],      // 3x3 pixel window
    output logic                done,             // 1-cycle pulse when finished
    output logic signed [31:0]  conv_out,         // 32-bit accumulated result
    output logic [3:0]          compute_cycles,   // Compute cycles used (always 9)
    output logic [3:0]          skip_count        // Count of isolated zero products
);

    typedef enum logic [1:0] {
        ST_IDLE    = 2'b00,
        ST_COMPUTE = 2'b01,
        ST_DONE    = 2'b10
    } state_t;

    state_t             state;
    logic [3:0]         idx;       // Product index (0..8)
    logic [3:0]         cycles;    // Compute cycle counter
    logic [3:0]         isolated;  // Isolated product counter
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
    // Step 2: Operand Isolation Clamping MUXes
    // -------------------------------------------------------------------------
    logic signed [7:0] iso_w, iso_p;
    always_comb begin
        if (is_zero) begin
            iso_w = 8'sd0;
            iso_p = 8'sd0;
        end else begin
            iso_w = raw_w;
            iso_p = raw_p;
        end
    end

    // -------------------------------------------------------------------------
    // Step 3: Multiplier on Isolated Operands
    // -------------------------------------------------------------------------
    logic signed [15:0] mult_product;
    always_comb begin
        mult_product = iso_w * iso_p;
    end

    // -------------------------------------------------------------------------
    // Step 4: Main FSM (Strictly 9 compute cycles, no clock gating)
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
            isolated       <= 4'd0;
            accum          <= 32'sd0;
        end else begin
            done <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        accum    <= 32'sd0;
                        idx      <= 4'd0;
                        cycles   <= 4'd0;
                        isolated <= 4'd0;
                        state    <= ST_COMPUTE;
                    end
                end

                ST_COMPUTE: begin
                    // Accumulator clocks unconditionally (adds 0 if isolated)
                    accum  <= accum + 32'(mult_product);
                    cycles <= cycles + 4'd1;

                    if (is_zero) begin
                        isolated <= isolated + 4'd1;
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
                    skip_count     <= isolated;  // Number of isolated products
                    done           <= 1'b1;
                    state          <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule

