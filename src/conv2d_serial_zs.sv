// =============================================================================
// File: conv2d_serial_zs.sv
// Design: 3x3 Convolution Engine with ONLY Zero-Skipping (Ablation Design 3)
// Target: Xilinx/AMD Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   Ablation engine that evaluates the standalone effect of ZERO-SKIPPING
//   LATENCY COMPRESSION in a 3x3 convolution workload.
//
// Architectural Characteristics:
//   - Zero-Skipping: Pre-computes 9-bit non-zero mask and employs a hardware
//     Find-First-Set (FFS) priority encoder to schedule ONLY active products.
//   - Fast Finish: All-zero patches finish immediately in 0 compute cycles (1 FSM cycle).
//   - Multiplier Datapath: NO operand isolation clamping MUXes on the multiplier.
//   - Accumulator: Updates normally for each dispatched non-zero term.
//
// Performance:
//   - Compute cycles: Exactly equal to non-zero product count (0 to 9 cycles).
//   - Ineffectual zero products are physically bypassed — zero clock cycles spent.
//
// Telemetry:
//   - compute_cycles: Actual MAC cycles used (0..9).
//   - skip_count:     Number of products bypassed (0..9).
// =============================================================================

`timescale 1ns / 1ps

module conv2d_serial_zs (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,            // 1-cycle pulse to start
    input  logic signed [7:0]   weights [9],      // 3x3 kernel weights
    input  logic signed [7:0]   pixels  [9],      // 3x3 pixel window
    output logic                done,             // 1-cycle pulse when finished
    output logic signed [31:0]  conv_out,         // 32-bit accumulated result
    output logic [3:0]          compute_cycles,   // Compute cycles used (0..9)
    output logic [3:0]          skip_count        // Count of zero products skipped
);

    typedef enum logic [1:0] {
        ST_IDLE    = 2'b00,
        ST_COMPUTE = 2'b01,
        ST_DONE    = 2'b10
    } state_t;

    state_t             state;
    logic [3:0]         cycles;    // Compute cycle counter
    logic [3:0]         skips;     // Skip counter
    logic signed [31:0] accum;
    logic [8:0]         remaining; // Remaining active products tracker

    // -------------------------------------------------------------------------
    // Step 1: Parallel Non-Zero Mask Generation (Combinational)
    // -------------------------------------------------------------------------
    logic [8:0] nz_mask;
    always_comb begin
        for (int i = 0; i < 9; i++) begin
            nz_mask[i] = (weights[i] != 8'sd0) && (pixels[i] != 8'sd0);
        end
    end

    // Popcount of nz_mask: number of non-zero active products
    logic [3:0] total_nz;
    always_comb begin
        total_nz = 4'd0;
        for (int i = 0; i < 9; i++) begin
            if (nz_mask[i]) total_nz = total_nz + 4'd1;
        end
    end

    // -------------------------------------------------------------------------
    // Step 2: Find-First-Set (FFS) Priority Encoder
    // -------------------------------------------------------------------------
    logic [3:0] ffs_idx;
    logic       ffs_valid;

    always_comb begin
        ffs_idx   = 4'd0;
        ffs_valid = 1'b0;
        for (int i = 0; i < 9; i++) begin
            if (remaining[i] && !ffs_valid) begin
                ffs_idx   = i[3:0];
                ffs_valid = 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Step 3: Bit-Clear Mask Decoder
    // -------------------------------------------------------------------------
    logic [8:0] bit_clear;
    always_comb begin
        case (ffs_idx)
            4'd0:    bit_clear = 9'b000000001;
            4'd1:    bit_clear = 9'b000000010;
            4'd2:    bit_clear = 9'b000000100;
            4'd3:    bit_clear = 9'b000001000;
            4'd4:    bit_clear = 9'b000010000;
            4'd5:    bit_clear = 9'b000100000;
            4'd6:    bit_clear = 9'b001000000;
            4'd7:    bit_clear = 9'b010000000;
            4'd8:    bit_clear = 9'b100000000;
            default: bit_clear = 9'b000000000;
        endcase
    end

    logic [8:0] next_remaining;
    assign next_remaining = remaining & ~bit_clear;

    // -------------------------------------------------------------------------
    // Step 4: Operand Muxing based on FFS index (Raw, Unclamped)
    // -------------------------------------------------------------------------
    logic signed [7:0] sel_w, sel_p;
    always_comb begin
        sel_w = weights[ffs_idx];
        sel_p = pixels[ffs_idx];
    end

    // -------------------------------------------------------------------------
    // Step 5: Main FSM with Zero-Skipping Latency Compression
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            state          <= ST_IDLE;
            done           <= 1'b0;
            conv_out       <= 32'sd0;
            compute_cycles <= 4'd0;
            skip_count     <= 4'd0;
            cycles         <= 4'd0;
            skips          <= 4'd0;
            accum          <= 32'sd0;
            remaining      <= 9'd0;
        end else begin
            done <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        accum     <= 32'sd0;
                        cycles    <= 4'd0;
                        skips     <= 4'd9 - total_nz;
                        remaining <= nz_mask;

                        if (nz_mask == 9'd0) begin
                            // Fast Finish: all 9 products are zero
                            state <= ST_DONE;
                        end else begin
                            state <= ST_COMPUTE;
                        end
                    end
                end

                ST_COMPUTE: begin
                    if (ffs_valid) begin
                        accum     <= accum + 32'(sel_w * sel_p);
                        cycles    <= cycles + 4'd1;
                        remaining <= next_remaining;

                        if (next_remaining == 9'd0) begin
                            state <= ST_DONE;
                        end
                    end else begin
                        state <= ST_DONE;
                    end
                end

                ST_DONE: begin
                    conv_out       <= accum;
                    compute_cycles <= cycles;
                    skip_count     <= skips;
                    done           <= 1'b1;
                    state          <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule

