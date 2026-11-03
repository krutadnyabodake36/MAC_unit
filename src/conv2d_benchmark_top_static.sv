// =============================================================================
// File: conv2d_benchmark_top_static.sv
// Target: Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C @ 50 MHz)
// Design: Serial Conv2D Benchmark UART Top with Hardware Cycle Counter
// Description:
//   Connects the Serial Conv2D Engine (Baseline or Proposed) to the PC via
//   USB-UART at 115200 Baud. Reports the HARDWARE CYCLE COUNT back to the PC,
//   enabling direct, undeniable comparison of computation time on silicon.
//
// Protocol:
//   1. Host sends 18 bytes: 9 Signed 8-bit Weights + 9 Signed 8-bit Pixels
//   2. Core processes the 3x3 convolution (serial MAC)
//   3. Core transmits 6 bytes back to Host:
//      - Bytes 0..3: Signed 32-bit Convolution Result (Little-Endian)
//      - Byte 4    : Compute Cycles used (0 to 9 for Proposed, always 9 for Baseline)
//      - Byte 5    : Products Skipped   (0 to 9 for Proposed, always 0 for Baseline)
//
// Usage:
//   - Synthesize with USE_PROPOSED=1 for Zero-Skipping engine
//   - Synthesize with USE_PROPOSED=0 for Baseline engine
//   - Program FPGA, run run_benchmark.py, compare cycle counts
// =============================================================================

`timescale 1ns / 1ps

module conv2d_benchmark_top_static #(
    // -------------------------------------------------------------------------
    // DESIGN_SELECT Architectural Variants:
    //   0 = Baseline (conv2d_serial_baseline, fixed 9 cycles, no gating)
    //   1 = Only Operand Isolation (conv2d_serial_oi, fixed 9 cycles, OI clamped)
    //   2 = Only Clock Gating (conv2d_serial_cg, fixed 9 cycles, accumulator CG)
    //   3 = Only Zero-Skipping (conv2d_serial_zs, variable 0..9 cycles via FFS)
    //   4 = Combined Full Architecture (conv2d_serial_combined, ZS + idle OI + CG)
    //   5 = ZS + OI (conv2d_serial_zs_oi, variable cycles, idle OI, no CG)
    //   6 = ZS + CG (conv2d_serial_zs_cg, variable cycles, accumulator CG, no OI)
    //   7 = OI + CG (conv2d_serial_oi_cg, fixed 9 cycles, OI clamped + accumulator CG)
//   8 = Static Sobel-X 6-Tap (conv2d_serial_static_sobel, fixed 6 cycles, no zero detection)
    // -------------------------------------------------------------------------
    parameter int DESIGN_SELECT = 8,
    parameter bit USE_PROPOSED  = 1'b1  // Backward compatibility flag
)(
    input  logic clk,       // 50 MHz System Clock (Pin H11)
    input  logic btnC,      // Active-High Pushbutton Reset (Pin J14)
    input  logic RsRx,      // UART RX Input (Pin G1)
    output logic RsTx       // UART TX Output (Pin F2)
);

    // -------------------------------------------------------------------------
    // Reset Synchronizer (2-stage metastability filter)
    // -------------------------------------------------------------------------
    logic rst_sync1, rst_sync2;
    always_ff @(posedge clk) begin
        rst_sync1 <= btnC;
        rst_sync2 <= rst_sync1;
    end
    wire rst = rst_sync2;

    // -------------------------------------------------------------------------
    // UART RX Module (50 MHz / 115200 = 434 Clocks per bit)
    // -------------------------------------------------------------------------
    logic [7:0] rx_data;
    logic       rx_valid;

    uart_rx #(
        .CLKS_PER_BIT(434)
    ) u_rx (
        .clk      (clk),
        .rst      (rst),
        .rx       (RsRx),
        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

    // -------------------------------------------------------------------------
    // UART TX Module
    // -------------------------------------------------------------------------
    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_busy;

    uart_tx #(
        .CLKS_PER_BIT(434)
    ) u_tx (
        .clk      (clk),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (RsTx),
        .tx_busy  (tx_busy)
    );

    // -------------------------------------------------------------------------
    // Data Registers (Loaded via UART)
    // -------------------------------------------------------------------------
    logic signed [7:0] weights_reg [9];
    logic signed [7:0] pixels_reg  [9];

    // -------------------------------------------------------------------------
    // Compute Engine Instance (Baseline or Proposed based on parameter)
    // -------------------------------------------------------------------------
    logic               eng_start;
    logic               eng_done;
    logic signed [31:0] eng_result;
    logic [3:0]         eng_cycles;
    logic [3:0]         eng_skips;

    generate
        // Resolve effective design selection with backward compatibility
        localparam int EFF_DESIGN = (!USE_PROPOSED && DESIGN_SELECT == 4) ? 0 : DESIGN_SELECT;

        if (EFF_DESIGN == 0) begin : gen_baseline
            conv2d_serial_baseline u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles)
            );
            assign eng_skips = 4'd0;  // Baseline never skips
        end else if (EFF_DESIGN == 1) begin : gen_oi_only
            conv2d_serial_oi u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else if (EFF_DESIGN == 2) begin : gen_cg_only
            conv2d_serial_cg u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else if (EFF_DESIGN == 3) begin : gen_zs_only
            conv2d_serial_zs u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else if (EFF_DESIGN == 4) begin : gen_combined
            conv2d_serial_combined u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else if (EFF_DESIGN == 5) begin : gen_zs_oi
            conv2d_serial_zs_oi u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else if (EFF_DESIGN == 6) begin : gen_zs_cg
            conv2d_serial_zs_cg u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else if (EFF_DESIGN == 7) begin : gen_oi_cg
            conv2d_serial_oi_cg u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end else if (EFF_DESIGN == 8) begin : gen_static_sobel
            conv2d_serial_static_sobel u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles)
            );
            assign eng_skips = 4'd0;  // Static Sobel has fixed schedule, no dynamic skip logic
        end else begin : gen_default
            conv2d_serial_combined u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles),
                .skip_count     (eng_skips)
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // FSM Controller: Receive 18 bytes → Compute → Transmit 6 bytes
    // -------------------------------------------------------------------------
    typedef enum logic [2:0] {
        ST_RX_WEIGHTS   = 3'd0,
        ST_RX_PIXELS    = 3'd1,
        ST_ENG_START    = 3'd2,
        ST_ENG_WAIT     = 3'd3,
        ST_TX_LOAD      = 3'd4,
        ST_TX_WAIT_STRT = 3'd5,
        ST_TX_WAIT_DONE = 3'd6
    } bench_state_t;

    bench_state_t state;
    logic [3:0]   byte_cnt;
    logic [31:0]  result_latch;
    logic [7:0]   cycles_latch;
    logic [7:0]   skips_latch;
    logic [2:0]   tx_index;  // 0..5 (6 bytes total to transmit)

    always_ff @(posedge clk) begin
        if (rst) begin
            state         <= ST_RX_WEIGHTS;
            byte_cnt      <= 4'd0;
            eng_start     <= 1'b0;
            tx_start      <= 1'b0;
            tx_data       <= 8'd0;
            tx_index      <= 3'd0;
            result_latch  <= 32'd0;
            cycles_latch  <= 8'd0;
            skips_latch   <= 8'd0;
            for (int i = 0; i < 9; i++) begin
                weights_reg[i] <= 8'sd0;
                pixels_reg[i]  <= 8'sd0;
            end
        end else begin
            eng_start <= 1'b0;  // Default: single-cycle strobe
            tx_start  <= 1'b0;

            case (state)
                // 1. Receive 9 weights (Byte 0..8)
                ST_RX_WEIGHTS: begin
                    if (rx_valid) begin
                        weights_reg[byte_cnt] <= rx_data;
                        if (byte_cnt == 4'd8) begin
                            byte_cnt <= 4'd0;
                            state    <= ST_RX_PIXELS;
                        end else begin
                            byte_cnt <= byte_cnt + 4'd1;
                        end
                    end
                end

                // 2. Receive 9 pixels (Byte 9..17)
                ST_RX_PIXELS: begin
                    if (rx_valid) begin
                        pixels_reg[byte_cnt] <= rx_data;
                        if (byte_cnt == 4'd8) begin
                            byte_cnt <= 4'd0;
                            state    <= ST_ENG_START;
                        end else begin
                            byte_cnt <= byte_cnt + 4'd1;
                        end
                    end
                end

                // 3. Start the compute engine
                ST_ENG_START: begin
                    eng_start <= 1'b1;
                    state     <= ST_ENG_WAIT;
                end

                // 4. Wait for compute engine to finish
                ST_ENG_WAIT: begin
                    if (eng_done) begin
                        result_latch <= eng_result;
                        cycles_latch <= {4'd0, eng_cycles};
                        skips_latch  <= {4'd0, eng_skips};
                        tx_index     <= 3'd0;
                        state        <= ST_TX_LOAD;
                    end
                end

                // 5. Load next TX byte (6 bytes total, Little-Endian result)
                ST_TX_LOAD: begin
                    if (!tx_busy) begin
                        case (tx_index)
                            3'd0: tx_data <= result_latch[7:0];
                            3'd1: tx_data <= result_latch[15:8];
                            3'd2: tx_data <= result_latch[23:16];
                            3'd3: tx_data <= result_latch[31:24];
                            3'd4: tx_data <= cycles_latch;    // Compute cycles
                            3'd5: tx_data <= skips_latch;     // Skip count
                        endcase
                        tx_start <= 1'b1;
                        state    <= ST_TX_WAIT_STRT;
                    end
                end

                // 6. Wait for TX to start
                ST_TX_WAIT_STRT: begin
                    state <= ST_TX_WAIT_DONE;
                end

                // 7. Wait for TX byte to finish, then loop or return to RX
                ST_TX_WAIT_DONE: begin
                    if (!tx_busy) begin
                        if (tx_index == 3'd5) begin
                            state <= ST_RX_WEIGHTS;  // Ready for next patch
                        end else begin
                            tx_index <= tx_index + 3'd1;
                            state    <= ST_TX_LOAD;
                        end
                    end
                end

                default: state <= ST_RX_WEIGHTS;
            endcase
        end
    end

endmodule
