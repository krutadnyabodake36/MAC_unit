// =============================================================================
// File: tb/tb_uart_real_baud_all9.sv
// Target: Spartan-7 XC7S15 @ 50 MHz
// Description: Real-Baud Hardware-Accurate UART RTL Verification Testbench
//              Runs with CLKS_PER_BIT = 434 (exact 115,200 baud hardware timing)
//              over 25 consecutive real patches from image1.vec (including border
//              zero-padded patches and interior mask-change transitions).
//              Uses full-duplex background receiver queue to prevent dropped bytes.
// =============================================================================

`timescale 1ns / 1ps

module tb_uart_real_baud_runner #(
    parameter int DESIGN_SELECT = 0,
    parameter int NUM_PATCHES   = 25,
    parameter int CLKS_PER_BIT  = 434
);

    logic clk = 0;
    logic rst;
    logic RsRx = 1'b1;  // UART idle is high
    logic RsTx;

    // 50 MHz Clock (20.000 ns period)
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

    localparam time BIT_PERIOD = CLKS_PER_BIT * 20ns; // 8680 ns per bit @ 115200 baud

    // Host -> FPGA Transmitter Task
    task send_uart_byte(input [7:0] data);
        begin
            // Start bit (active low)
            RsRx = 1'b0;
            #(BIT_PERIOD);

            // 8 Data bits (LSB first)
            for (int i = 0; i < 8; i++) begin
                RsRx = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit (active high)
            RsRx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // Full-Duplex Background Receiver Queue
    logic [7:0] rx_queue [$];

    initial begin
        logic [7:0] captured_byte;
        forever begin
            // Wait for start bit falling edge
            @(negedge RsTx);
            // Sample in middle of start bit
            #(BIT_PERIOD / 2);

            // Sample 8 data bits at center of bit cells
            for (int i = 0; i < 8; i++) begin
                #(BIT_PERIOD);
                captured_byte[i] = RsTx;
            end

            // Wait through rest of bit 7 and stop bit
            #(BIT_PERIOD);
            rx_queue.push_back(captured_byte);
        end
    end

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
        #(BIT_PERIOD * 4);

        $display(">>> STARTING REAL-BAUD UART CHECK: DESIGN_SELECT = %0d, PATCHES = %0d, CLKS_PER_BIT = %0d <<<",
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
                    8: begin expected_cycles = 6; expected_skips = 0; end // static_sobel
                    default: begin expected_cycles = 9; expected_skips = 0; end
                endcase

                // Send 18 bytes: 9 weights, then 9 pixels
                for (int i = 0; i < 9; i++) send_uart_byte(8'(signed'(w[i])));
                for (int i = 0; i < 9; i++) send_uart_byte(8'(signed'(p[i])));

                // Await 6 response bytes in rx_queue
                while (rx_queue.size() < 6) begin
                    #(BIT_PERIOD);
                end

                rx_b0 = rx_queue.pop_front();
                rx_b1 = rx_queue.pop_front();
                rx_b2 = rx_queue.pop_front();
                rx_b3 = rx_queue.pop_front();
                rx_b4 = rx_queue.pop_front();
                rx_b5 = rx_queue.pop_front();

                rx_sum    = {rx_b3, rx_b2, rx_b1, rx_b0};
                rx_cycles = rx_b4[3:0];
                rx_skips  = rx_b5[3:0];

                if (rx_sum !== golden) begin
                    total_mismatches_sum++;
                    $display("[UART_MISMATCH_SUM] Patch %0d: Expected=%0d, Got=%0d", p_idx, golden, rx_sum);
                end

                if (rx_cycles !== expected_cycles[3:0]) begin
                    total_mismatches_cycles++;
                    $display("[UART_MISMATCH_CYCLES] Patch %0d: Expected=%0d, Got=%0d", p_idx, expected_cycles, rx_cycles);
                end

                if (rx_skips !== expected_skips[3:0]) begin
                    total_mismatches_skips++;
                    $display("[UART_MISMATCH_SKIPS] Patch %0d: Expected=%0d, Got=%0d", p_idx, expected_skips, rx_skips);
                end

                p_idx++;

                // Inter-frame idle guard time to allow FPGA FSM to return cleanly to ST_RX_WEIGHTS
                #(BIT_PERIOD * 2);
            end
        end
        $fclose(fd);

        $display(">>> REAL-BAUD UART CHECK COMPLETE: DESIGN_SELECT = %0d <<<", DESIGN_SELECT);
        $display("Patches Evaluated: %0d", p_idx);
        $display("Sum Mismatches   : %0d", total_mismatches_sum);
        $display("Cycle Mismatches : %0d", total_mismatches_cycles);
        $display("Skip Mismatches  : %0d", total_mismatches_skips);
        $display("Result           : %s", (total_mismatches_sum == 0 && total_mismatches_cycles == 0 && total_mismatches_skips == 0) ? "PASS" : "FAIL");
        $display("==================================================================");

        #1000;
        $finish;
    end

endmodule

module tb_uart_real_baud_0; tb_uart_real_baud_runner #(.DESIGN_SELECT(0)) u(); endmodule
module tb_uart_real_baud_1; tb_uart_real_baud_runner #(.DESIGN_SELECT(1)) u(); endmodule
module tb_uart_real_baud_2; tb_uart_real_baud_runner #(.DESIGN_SELECT(2)) u(); endmodule
module tb_uart_real_baud_3; tb_uart_real_baud_runner #(.DESIGN_SELECT(3)) u(); endmodule
module tb_uart_real_baud_4; tb_uart_real_baud_runner #(.DESIGN_SELECT(4)) u(); endmodule
module tb_uart_real_baud_5; tb_uart_real_baud_runner #(.DESIGN_SELECT(5)) u(); endmodule
module tb_uart_real_baud_6; tb_uart_real_baud_runner #(.DESIGN_SELECT(6)) u(); endmodule
module tb_uart_real_baud_7; tb_uart_real_baud_runner #(.DESIGN_SELECT(7)) u(); endmodule
module tb_uart_real_baud_8; tb_uart_real_baud_runner #(.DESIGN_SELECT(8)) u(); endmodule
