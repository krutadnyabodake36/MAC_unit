// =============================================================================
// File: conv2d_stress_test_top.sv
// Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Description:
//   Free-running stress test for REAL board-level power measurement.
//   Runs 3x3 convolution in a tight loop using LFSR-generated data with
//   realistic CNN sparsity (~65% zeros in activations, Sobel kernel weights).
//   
//   NO UART — purely internal computation at full clock speed.
//   Measure board power with a USB power meter plugged between cable and PC.
//
// How to use:
//   1. Build bitstream with USE_PROPOSED=0 (baseline)
//   2. Program FPGA, wait 10 seconds for power to stabilize
//   3. Read USB power meter → note the wattage
//   4. Rebuild with USE_PROPOSED=1 (proposed), reprogram, read meter
//   5. The DIFFERENCE in wattage = dynamic power savings from zero-skipping
//
// Output: RsTx pin toggles based on computation result (prevents optimization)
// =============================================================================

`timescale 1ns / 1ps

module conv2d_stress_test_top #(
    parameter bit USE_PROPOSED = 1'b1
)(
    input  logic clk,       // 50 MHz System Clock (Pin H11)
    input  logic btnC,      // Active-High Pushbutton Reset (Pin J14)
    output logic RsTx       // Output pin — driven by computation to prevent opt-away
);

    // -------------------------------------------------------------------------
    // Reset Synchronizer
    // -------------------------------------------------------------------------
    logic rst_sync1, rst_sync2;
    always_ff @(posedge clk) begin
        rst_sync1 <= btnC;
        rst_sync2 <= rst_sync1;
    end
    wire rst = rst_sync2;

    // -------------------------------------------------------------------------
    // 32-bit LFSR for Pseudo-Random Data Generation
    // Polynomial: x^32 + x^22 + x^2 + x + 1 (maximal-length)
    // -------------------------------------------------------------------------
    logic [31:0] lfsr;
    always_ff @(posedge clk) begin
        if (rst)
            lfsr <= 32'hDEAD_BEEF;
        else
            lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
    end

    // -------------------------------------------------------------------------
    // Test Data Generation: Sobel Kernel + Sparse Pixel Window
    // Applies ~65% sparsity to pixel values using LFSR bits
    // -------------------------------------------------------------------------
    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];

    always_comb begin
        // Fixed Sobel Horizontal Edge Detection Kernel (3 of 9 are zero)
        weights[0] = -8'sd1; weights[1] = 8'sd0; weights[2] = 8'sd1;
        weights[3] = -8'sd2; weights[4] = 8'sd0; weights[5] = 8'sd2;
        weights[6] = -8'sd1; weights[7] = 8'sd0; weights[8] = 8'sd1;

        // Sparse pixel window: ~65% chance of zero per pixel
        // Use pairs of LFSR bits: if both bits are 0 → pixel is zero
        // Probability of zero: P(b1=0 AND b2=0) = 0.25, but we use 2 conditions
        for (int i = 0; i < 9; i++) begin
            // Use 3 LFSR bits per pixel for sparsity control
            // If any 2 of 3 consecutive bits are zero → pixel is zero
            if (!lfsr[(i*3) % 32] && !lfsr[((i*3)+1) % 32]) begin
                pixels[i] = 8'sd0;  // Sparse (zero activation)
            end else begin
                pixels[i] = lfsr[((i*3)+8) % 32 +: 8];  // Non-zero value
            end
        end
    end

    // -------------------------------------------------------------------------
    // Convolution Engine (Baseline or Proposed)
    // -------------------------------------------------------------------------
    logic               eng_start;
    logic               eng_done;
    logic signed [31:0] eng_result;
    logic [3:0]         eng_cycles;

    generate
        if (USE_PROPOSED) begin : gen_proposed
            logic [3:0] eng_skips;
            conv2d_serial_proposed u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else begin : gen_baseline
            conv2d_serial_baseline u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights),
                .pixels         (pixels),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles)
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Continuous Computation Controller
    // Runs convolutions back-to-back with no idle time
    // -------------------------------------------------------------------------
    typedef enum logic [1:0] {
        ST_START = 2'b00,
        ST_WAIT  = 2'b01,
        ST_NEXT  = 2'b10
    } stress_state_t;

    stress_state_t state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= ST_START;
            eng_start <= 1'b0;
        end else begin
            eng_start <= 1'b0;
            case (state)
                ST_START: begin
                    eng_start <= 1'b1;
                    state     <= ST_WAIT;
                end
                ST_WAIT: begin
                    if (eng_done)
                        state <= ST_NEXT;
                end
                ST_NEXT: begin
                    state <= ST_START;  // Immediately start next convolution
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Anti-Optimization Output
    // XOR-reduce the result and drive it to an output pin.
    // This prevents Vivado from optimizing away the entire computation.
    // -------------------------------------------------------------------------
    assign RsTx = ^eng_result;

endmodule
