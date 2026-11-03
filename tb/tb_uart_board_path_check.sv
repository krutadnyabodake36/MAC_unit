// =============================================================================
// File: tb/tb_uart_board_path_check.sv
// Description: G2 UART-Driven RTL Testbench for Board Top (All 9 Variants).
//              Sends real 18-byte request frames over UART RX at parameterized
//              CLKS_PER_BIT (e.g. 16 clocks/bit @ 50 MHz), deserializes 6-byte
//              reply frames over UART TX, and verifies against golden outputs.
// =============================================================================

`timescale 1ns / 1ps

module tb_uart_board_path_check #(
    parameter int DESIGN_SELECT = 0,
    parameter int NUM_PATCHES   = 300,
    parameter int CLKS_PER_BIT  = 16
);

    logic clk = 0;
    logic rst;
    logic RsRx = 1'b1;  // UART idle is high
    logic RsTx;

    // 50 MHz clock (20 ns period)
    always #10 clk = ~clk;

    // Instantiate board top
    conv2d_benchmark_top_static #(
        .DESIGN_SELECT(DESIGN_SELECT)
    ) u_top (
        .clk  (clk),
        .btnC (rst),
        .RsRx (RsRx),
        .RsTx (RsTx)
    );

    // Hierarchically parameterize UART RX and TX modules to match testbench baud
    defparam u_top.u_rx.CLKS_PER_BIT = CLKS_PER_BIT;
    defparam u_top.u_tx.CLKS_PER_BIT = CLKS_PER_BIT;

    localparam time BIT_PERIOD = CLKS_PER_BIT * 20ns;

    // UART Transmitter Task (Host -> FPGA)
    task send_uart_byte(input [7:0] data);
        begin
            // Start bit
            RsRx = 1'b0;
            #(BIT_PERIOD);

            // 8 Data bits (LSB first)
            for (int i = 0; i < 8; i++) begin
                RsRx = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit
            RsRx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // UART Receiver Task (FPGA -> Host)
    task recv_uart_byte(output [7:0] data);
        begin
            // Wait for start bit (falling edge)
            @(negedge RsTx);
            // Sample in middle of start bit
            #(BIT_PERIOD / 2);

            // Sample 8 data bits
            for (int i = 0; i < 8; i++) begin
                #(BIT_PERIOD);
                data[i] = RsTx;
            end

            // Wait through rest of bit 7 and through stop bit
            #(BIT_PERIOD);
        end
    endtask

    integer total_mismatches_sum    = 0;
    integer total_mismatches_cycles = 0;
    integer total_mismatches_skips  = 0;

    initial begin
        int fd, r;
        int w[9];
        int p[9];
        int golden;
        int p_idx = 0;

        logic [7:0] rx_b0, rx_b1, rx_b2, rx_b3, rx_b4, rx_b5;
        logic signed [31:0] rx_sum;
        logic [3:0] rx_cycles;
        logic [3:0] rx_skips;

        int expected_cycles;
        int expected_skips;
        int nz_count;

        rst  = 1'b1;
        RsRx = 1'b1;
        #200;
        @(negedge clk);
        rst  = 1'b0;
        #1000;

        $display(">>> STARTING UART BOARD PATH CHECK: DESIGN_SELECT = %0d, PATCHES = %0d, CLKS_PER_BIT = %0d <<<",
                 DESIGN_SELECT, NUM_PATCHES, CLKS_PER_BIT);

        fd = $fopen("results/final_run_20261030_1056/vectors/image1.vec", "r");
        if (!fd) begin
            $display("[ERROR] Cannot open image1.vec");
            $finish;
        end

        while (p_idx < NUM_PATCHES && !$feof(fd)) begin
            r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                        w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7], w[8],
                        p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8],
                        golden);
            if (r == 19) begin
                // Compute expected cycles and skips for this patch and design
                nz_count = 0;
                for (int i = 0; i < 9; i++) begin
                    if (w[i] != 0 && p[i] != 0) nz_count++;
                end

                case (DESIGN_SELECT)
                    0: begin expected_cycles = 9; expected_skips = 0; end // baseline
                    1: begin expected_cycles = 9; expected_skips = 9 - nz_count; end // oi
                    2: begin expected_cycles = 9; expected_skips = 9 - nz_count; end // cg
                    3: begin expected_cycles = nz_count; expected_skips = 9 - nz_count; end // zs
                    4: begin expected_cycles = nz_count; expected_skips = 9 - nz_count; end // combined
                    5: begin expected_cycles = nz_count; expected_skips = 9 - nz_count; end // zs_oi
                    6: begin expected_cycles = nz_count; expected_skips = 9 - nz_count; end // zs_cg
                    7: begin expected_cycles = 9; expected_skips = 9 - nz_count; end // oi_cg
                    8: begin expected_cycles = 6; expected_skips = 0; end // static_sobel (fixed 6 cycles, eng_skips=0)
                    default: begin expected_cycles = 9; expected_skips = 0; end
                endcase

                // Send 18 bytes: 9 weights, then 9 pixels
                for (int i = 0; i < 9; i++) send_uart_byte(8'(signed'(w[i])));
                for (int i = 0; i < 9; i++) send_uart_byte(8'(signed'(p[i])));

                // Receive 6-byte reply from FPGA
                recv_uart_byte(rx_b0);
                recv_uart_byte(rx_b1);
                recv_uart_byte(rx_b2);
                recv_uart_byte(rx_b3);
                recv_uart_byte(rx_b4);
                recv_uart_byte(rx_b5);

                rx_sum    = {rx_b3, rx_b2, rx_b1, rx_b0};
                rx_cycles = rx_b4[3:0];
                rx_skips  = rx_b5[3:0];

                if (rx_sum !== golden) begin
                    total_mismatches_sum++;
                    if (total_mismatches_sum <= 5) begin
                        $display("[UART_MISMATCH_SUM] Patch %0d: Expected=%0d, Got=%0d", p_idx, golden, rx_sum);
                    end
                end

                if (rx_cycles !== expected_cycles[3:0]) begin
                    total_mismatches_cycles++;
                    if (total_mismatches_cycles <= 5) begin
                        $display("[UART_MISMATCH_CYCLES] Patch %0d: Expected=%0d, Got=%0d", p_idx, expected_cycles, rx_cycles);
                    end
                end

                if (rx_skips !== expected_skips[3:0]) begin
                    total_mismatches_skips++;
                    if (total_mismatches_skips <= 5) begin
                        $display("[UART_MISMATCH_SKIPS] Patch %0d: Expected=%0d, Got=%0d", p_idx, expected_skips, rx_skips);
                    end
                end

                p_idx++;

                // Inter-frame idle guard time to allow FPGA FSM to return to ST_RX_WEIGHTS
                #(BIT_PERIOD * 2);
            end
        end
        $fclose(fd);

        $display(">>> UART BOARD PATH CHECK COMPLETE: DESIGN_SELECT = %0d <<<", DESIGN_SELECT);
        $display("Patches Evaluated: %0d", p_idx);
        $display("Sum Mismatches   : %0d", total_mismatches_sum);
        $display("Cycle Mismatches : %0d", total_mismatches_cycles);
        $display("Skip Mismatches  : %0d", total_mismatches_skips);
        $display("Result           : %s", (total_mismatches_sum == 0 && total_mismatches_cycles == 0 && total_mismatches_skips == 0) ? "PASS (100% Bit-Exact Match)" : "FAIL");
        $display("==================================================================");

        #1000;
        $finish;
    end

endmodule

module tb_uart_sel_0; tb_uart_board_path_check #(.DESIGN_SELECT(0)) u_tb(); endmodule
module tb_uart_sel_1; tb_uart_board_path_check #(.DESIGN_SELECT(1)) u_tb(); endmodule
module tb_uart_sel_2; tb_uart_board_path_check #(.DESIGN_SELECT(2)) u_tb(); endmodule
module tb_uart_sel_3; tb_uart_board_path_check #(.DESIGN_SELECT(3)) u_tb(); endmodule
module tb_uart_sel_4; tb_uart_board_path_check #(.DESIGN_SELECT(4)) u_tb(); endmodule
module tb_uart_sel_5; tb_uart_board_path_check #(.DESIGN_SELECT(5)) u_tb(); endmodule
module tb_uart_sel_6; tb_uart_board_path_check #(.DESIGN_SELECT(6)) u_tb(); endmodule
module tb_uart_sel_7; tb_uart_board_path_check #(.DESIGN_SELECT(7)) u_tb(); endmodule
module tb_uart_sel_8; tb_uart_board_path_check #(.DESIGN_SELECT(8)) u_tb(); endmodule
