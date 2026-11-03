// =============================================================================
// File: conv2d_serial_oi_cg.sv
// Design: 3x3 Convolution Engine with OPERAND ISOLATION + CLOCK GATING (Ablation)
// Target: Xilinx/AMD Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Ablation engine evaluating the joint combination of OPERAND ISOLATION (OI)
//   and CLOCK GATING (CG) on a fixed 9-cycle serial convolution datapath.
//
// Architectural Characteristics:
//   - Execution Schedule: Strictly 9 clock cycles per patch (identical to baseline).
//     NO cycle skipping (Zero-Skipping is disabled).
//   - Operand Isolation: An 8-input NOR reduction detector checks each product pair
//     (weights[idx], pixels[idx]). If either is zero, combinational clamping MUXes
//     force the multiplier inputs to 8'sd0. (Reused from conv2d_serial_oi.sv).
//   - Clock Gating: Inferred Clock Enable (CE) on the accumulator register.
//     When is_zero is asserted, the accumulator CE is de-asserted, preventing
//     flip-flop transitions and saving register toggle power. (Reused from conv2d_serial_cg.sv).
//
// Telemetry:
//   - compute_cycles: Always reports 9 (no latency compression).
//   - skip_count:     Reports the exact count of isolated & gated zero products (0..9).
// =============================================================================

`timescale 1ns / 1ps

module conv2d_serial_oi_cg (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,            // 1-cycle pulse to start
    input  logic signed [7:0]   weights [9],      // 3x3 kernel weights
    input  logic signed [7:0]   pixels  [9],      // 3x3 pixel window
    output logic                done,             // 1-cycle pulse when finished
    output logic signed [31:0]  conv_out,         // 32-bit accumulated result
    output logic [3:0]          compute_cycles,   // Compute cycles used (always 9)
    output logic [3:0]          skip_count        // Count of zero products gated
);

    typedef enum logic [1:0] {
        ST_IDLE    = 2'b00,
        ST_COMPUTE = 2'b01,
        ST_DONE    = 2'b10
    } state_t;

    state_t             state;
    logic [3:0]         idx;       // Product index (0..8)
    logic [3:0]         cycles;    // Compute cycle counter
    logic [3:0]         gated;     // Clock-gated & isolated counter
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
    // Step 1: Zero Detection via NOR Reduction (from conv2d_serial_oi.sv / cg.sv)
    // -------------------------------------------------------------------------
    logic is_zero;
    always_comb begin
        is_zero = (~|raw_w) | (~|raw_p);
    end

    // -------------------------------------------------------------------------
    // Step 2: Operand Isolation Clamping MUXes (from conv2d_serial_oi.sv)
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

    // Combinational Multiplier operating on isolated inputs
    logic signed [15:0] mult_product;
    always_comb begin
        mult_product = iso_w * iso_p;
    end

    // -------------------------------------------------------------------------
    // Step 3: Main FSM with Clock Enable Accumulator Gating (from conv2d_serial_cg.sv)
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
                    skip_count     <= gated;     // Number of gated/isolated zero products
                    done           <= 1'b1;
                    state          <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule

