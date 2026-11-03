// =============================================================================
// File: uart_tx.sv
// Target: Xilinx Spartan-7 (XC7S15) / Edge Spartan-7 Development Board
// Description: Fully Synthesizable Parameterized UART Transmitter
// Clock: 50 MHz System Clock
// Baud Rate: 115200 bps (50,000,000 / 115,200 = 434 clocks per bit)
// Framing: 8 Data Bits, No Parity, 1 Stop Bit (8-N-1)
// =============================================================================

`timescale 1ns / 1ps

module uart_tx #(
    parameter int CLKS_PER_BIT = 434  // 50 MHz / 115200 baud = 434.027
)(
    input  logic       clk,           // 50 MHz system clock
    input  logic       rst,           // Active-high synchronous reset
    input  logic [7:0] tx_data,       // Data byte to transmit
    input  logic       tx_start,      // 1-cycle active-high pulse to trigger transmission
    output logic       tx,            // Serial transmit line
    output logic       tx_busy        // High while actively transmitting a byte
);

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

    // Internal counters and registers
    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [2:0]                      bit_index;
    logic [7:0]                      tx_shift;
    logic                            tx_reg;
    logic                            busy_reg;

    assign tx      = tx_reg;
    assign tx_busy = busy_reg;

    // -------------------------------------------------------------------------
    // UART TX State Machine
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= STATE_IDLE;
            clk_count <= '0;
            bit_index <= '0;
            tx_shift  <= '0;
            tx_reg    <= 1'b1; // Idle high
            busy_reg  <= 1'b0;
        end else begin
            case (state)
                // -------------------------------------------------------------
                // IDLE: Wait for tx_start trigger pulse
                // -------------------------------------------------------------
                STATE_IDLE: begin
                    tx_reg    <= 1'b1;
                    clk_count <= '0;
                    bit_index <= '0;

                    if (tx_start) begin
                        tx_shift <= tx_data;
                        busy_reg <= 1'b1;
                        state    <= STATE_START;
                    end else begin
                        busy_reg <= 1'b0;
                    end
                end

                // -------------------------------------------------------------
                // START: Drive Start Bit (0) for 1 bit period (434 cycles)
                // -------------------------------------------------------------
                STATE_START: begin
                    tx_reg <= 1'b0;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        state     <= STATE_DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                // -------------------------------------------------------------
                // DATA: Drive 8 Data Bits (LSB first) for 1 bit period each
                // -------------------------------------------------------------
                STATE_DATA: begin
                    tx_reg <= tx_shift[bit_index];

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
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
                // STOP: Drive Stop Bit (1) for 1 bit period
                // -------------------------------------------------------------
                STATE_STOP: begin
                    tx_reg <= 1'b1;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        busy_reg  <= 1'b0; // Transmission complete
                        state     <= STATE_IDLE;
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
