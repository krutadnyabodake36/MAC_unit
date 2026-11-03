// =============================================================================
// File: uart_rx.sv
// Target: Xilinx Spartan-7 (XC7S15) / Edge Spartan-7 Development Board
// Description: Fully Synthesizable Parameterized UART Receiver
// Clock: 50 MHz System Clock
// Baud Rate: 115200 bps (50,000,000 / 115,200 = 434 clocks per bit)
// Framing: 8 Data Bits, No Parity, 1 Stop Bit (8-N-1)
// =============================================================================

`timescale 1ns / 1ps

module uart_rx #(
    parameter int CLKS_PER_BIT = 434  // 50 MHz / 115200 baud = 434.027
)(
    input  logic       clk,           // 50 MHz system clock
    input  logic       rst,           // Active-high synchronous reset
    input  logic       rx,            // Asynchronous serial data line
    output logic [7:0] rx_data,       // Received 8-bit data byte
    output logic       rx_valid       // 1-cycle active-high pulse when byte is valid
);

    // -------------------------------------------------------------------------
    // Double-Flop Synchronizer for Metastability Mitigation
    // -------------------------------------------------------------------------
    logic rx_sync1;
    logic rx_sync2;

    always_ff @(posedge clk) begin
        if (rst) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    // -------------------------------------------------------------------------
    // FSM State Definitions
    // -------------------------------------------------------------------------
    typedef enum logic [1:0] {
        STATE_IDLE  = 2'b00,
        STATE_START = 2'b01,
        STATE_DATA  = 2'b10,
        STATE_STOP  = 2'b11
    } state_t;

    state_t state;

    // Internal counters and storage
    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [2:0]                      bit_index;
    logic [7:0]                      rx_shift;
    logic [7:0]                      rx_data_reg;
    logic                            rx_valid_reg;

    assign rx_data  = rx_data_reg;
    assign rx_valid = rx_valid_reg;

    // -------------------------------------------------------------------------
    // UART RX State Machine with Mid-Bit Sampling
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            state        <= STATE_IDLE;
            clk_count    <= '0;
            bit_index    <= '0;
            rx_shift     <= '0;
            rx_data_reg  <= '0;
            rx_valid_reg <= 1'b0;
        end else begin
            rx_valid_reg <= 1'b0; // Default: 1-cycle strobe

            case (state)
                // -------------------------------------------------------------
                // IDLE: Wait for falling edge indicating Start Bit (0)
                // -------------------------------------------------------------
                STATE_IDLE: begin
                    clk_count <= '0;
                    bit_index <= '0;
                    if (rx_sync2 == 1'b0) begin
                        // Advance to START and sample at half-bit center
                        state <= STATE_START;
                    end
                end

                // -------------------------------------------------------------
                // START: Mid-bit verification of Start Bit
                // -------------------------------------------------------------
                STATE_START: begin
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx_sync2 == 1'b0) begin
                            // Start bit confirmed, reset counter for full bit period
                            clk_count <= '0;
                            state     <= STATE_DATA;
                        end else begin
                            // False trigger/glitch, return to IDLE
                            state     <= STATE_IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                // -------------------------------------------------------------
                // DATA: Sample 8 Data Bits (LSB First)
                // -------------------------------------------------------------
                STATE_DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count            <= '0;
                        rx_shift[bit_index]  <= rx_sync2;

                        if (bit_index == 3'd7) begin
                            bit_index <= '0;
                            state     <= STATE_STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                // -------------------------------------------------------------
                // STOP: Verify Stop Bit (1) and assert valid flag
                // -------------------------------------------------------------
                STATE_STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        state     <= STATE_IDLE;
                        if (rx_sync2 == 1'b1) begin
                            rx_data_reg  <= rx_shift;
                            rx_valid_reg <= 1'b1; // Pulse valid for 1 clock cycle
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule
