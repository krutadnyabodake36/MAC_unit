// =============================================================================
// File: conv2d_serial_proposed.sv
// Design: Proposed Zero-Skipping Serial 3x3 Convolution Engine
// Target: Xilinx Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Language: SystemVerilog (Synthesizable RTL)
// -----------------------------------------------------------------------------
// Description:
//   High-efficiency serial 3x3 convolution engine with zero-skipping.
//   Instead of blindly processing all 9 products like the baseline, this
//   engine pre-computes a non-zero mask and uses a hardware priority encoder
//   to iterate ONLY through non-zero products.
//
// Zero-Skipping Mechanism:
//   1. Non-Zero Mask (combinational): For each of the 9 weight×pixel pairs,
//      a NOR-based detector flags whether either operand is zero.
//   2. Priority Encoder (Find-First-Set): Scans the remaining non-zero mask
//      to find the next product worth computing.
//   3. Selective MAC: Only multiplies and accumulates non-zero products.
//      Zero products are skipped entirely — zero clock cycles wasted on them.
//
// Performance:
//   - Baseline always takes 9 compute cycles
//   - Proposed takes only popcount(non_zero_mask) compute cycles
//   - At 75% sparsity: ~2-3 cycles vs 9 → 3-4× speedup
//   - At 100% sparsity (all zeros): 0 compute cycles → instant completion
//
// Telemetry:
//   - compute_cycles: Actual MAC cycles used (0 to 9)
//   - skip_count:     Number of products skipped (0 to 9)
// =============================================================================

`timescale 1ns / 1ps

module conv2d_serial_proposed (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,            // Pulse to begin computation
    input  logic signed [7:0]   weights [9],      // Pre-loaded 3x3 kernel weights
    input  logic signed [7:0]   pixels  [9],      // Pre-loaded 3x3 pixel window
    output logic                done,             // Pulse when result is ready
    output logic signed [31:0]  conv_out,         // 32-bit signed convolution result
    output logic [3:0]          compute_cycles,   // Actual MAC cycles used (0..9)
    output logic [3:0]          skip_count        // Zero-skipped products (0..9)
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
    logic [3:0]          cycles;     // Compute cycle counter
    logic [3:0]          skips;      // Skip counter
    logic signed [31:0]  accum;      // Running accumulator

    // =========================================================================
    // Step 1: Non-Zero Mask Generation (Combinational)
    //   For each product i: nz_mask[i] = 1 iff BOTH weight[i] and pixel[i]
    //   are non-zero. If either is zero, the product is zero and can be skipped.
    // =========================================================================
    logic [8:0] nz_mask;
    always_comb begin
        for (int i = 0; i < 9; i++) begin
            nz_mask[i] = (weights[i] != 8'sd0) && (pixels[i] != 8'sd0);
        end
    end

    // Popcount of nz_mask: number of non-zero products
    logic [3:0] total_nz;
    always_comb begin
        total_nz = 4'd0;
        for (int i = 0; i < 9; i++) begin
            if (nz_mask[i]) total_nz = total_nz + 4'd1;
        end
    end

    // =========================================================================
    // Step 2: Remaining-Element Tracker
    //   Tracks which non-zero products still need to be processed.
    //   After each MAC cycle, the processed bit is cleared.
    // =========================================================================
    logic [8:0] remaining;

    // =========================================================================
    // Step 3: Find-First-Set Priority Encoder
    //   Scans 'remaining' from bit 0 to bit 8 and returns the index of the
    //   first set bit. This determines which product to compute next.
    // =========================================================================
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

    // =========================================================================
    // Step 4: Bit-Clear Decoder
    //   Generates a one-hot mask to clear the processed bit from 'remaining'.
    // =========================================================================
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

    // Next remaining mask after clearing current element
    logic [8:0] next_remaining;
    assign next_remaining = remaining & ~bit_clear;

    // =========================================================================
    // Step 5: Operand Selection Mux (9:1 based on priority encoder output)
    // =========================================================================
    logic signed [7:0] sel_w, sel_p;
    always_comb begin
        sel_w = weights[ffs_idx];
        sel_p = pixels[ffs_idx];
    end

    // =========================================================================
    // Step 6: Main FSM — Zero-Skipping Serial MAC
    // =========================================================================
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
            done <= 1'b0;  // Default: done is single-cycle pulse

            case (state)
                // ---------------------------------------------------------
                // IDLE: Compute non-zero mask and decide if any work needed
                // ---------------------------------------------------------
                ST_IDLE: begin
                    if (start) begin
                        accum     <= 32'sd0;
                        cycles    <= 4'd0;
                        skips     <= 4'd9 - total_nz;
                        remaining <= nz_mask;

                        if (nz_mask == 9'd0) begin
                            // ALL 9 products are zero — skip computation entirely!
                            // Result is 0, computed in 0 MAC cycles.
                            state <= ST_DONE;
                        end else begin
                            state <= ST_COMPUTE;
                        end
                    end
                end

                // ---------------------------------------------------------
                // COMPUTE: Process only non-zero products via priority encoder
                //   - ffs_idx points to next non-zero product
                //   - Multiply and accumulate that product
                //   - Clear its bit from 'remaining'
                //   - If no more non-zero products → done
                // ---------------------------------------------------------
                ST_COMPUTE: begin
                    if (ffs_valid) begin
                        accum     <= accum + 32'(sel_w * sel_p);
                        cycles    <= cycles + 4'd1;
                        remaining <= next_remaining;

                        if (next_remaining == 9'd0) begin
                            state <= ST_DONE;  // Last non-zero product processed
                        end
                        // else: stay in ST_COMPUTE for next non-zero product
                    end else begin
                        // Safety: should not reach here (nz_mask==0 handled in IDLE)
                        state <= ST_DONE;
                    end
                end

                // ---------------------------------------------------------
                // DONE: Output result with telemetry
                // ---------------------------------------------------------
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
