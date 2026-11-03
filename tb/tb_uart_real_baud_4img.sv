// =============================================================================
// File: tb/tb_uart_real_baud_4img.sv
// Target: Spartan-7 XC7S15 @ 50 MHz
// Description: Real-Baud Hardware-Accurate UART RTL Verification Testbench
//              Extends verification across ALL 4 BENCHMARK IMAGES:
//              image1.vec, image2.vec, image3.vec, image4.vec
//              (25 patches per image = 100 patches total per design).
//              Runs with CLKS_PER_BIT = 434 (exact 115,200 baud hardware timing)
//              and full-duplex background receiver queue.
// =============================================================================

`timescale 1ns / 1ps

module tb_uart_real_baud_4img_runner #(
    parameter int DESIGN_SELECT = 0,
    parameter int PATCHES_PER_IMAGE = 25,
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
    integer total_tested_patches    = 0;

    task run_image_test(input string img_path, input string img_name);
        int fd, r;
        int w[9];
        int p[9];
        int golden;
        int p_idx;

        logic [7:0] rx_b0, rx_b1, rx_b2, rx_b3, rx_b4, rx_b5;
        logic signed [31:0] rx_sum;
        logic [3:0] rx_cycles;
        logic [3:0] rx_skips;

        int expected_cycles;
        int expected_skips;
        int nz_count;
        int img_mismatches_sum;
        int img_mismatches_cyc;
        int img_mismatches_skp;

        img_mismatches_sum = 0;
        img_mismatches_cyc = 0;
        img_mismatches_skp = 0;
        p_idx = 0;

        $display(">>> Starting Image: %s (Max %0d patches) <<<", img_name, PATCHES_PER_IMAGE);
        fd = $fopen(img_path, "r");
        if (!fd) begin
            $display("[ERROR] Cannot open vector file: %s", img_path);
            $finish;
        end

        while (p_idx < PATCHES_PER_IMAGE && !$feof(fd)) begin
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
                    $display("[FAIL][SUM] %s Patch %0d: Expected %0d, Got %0d", img_name, p_idx, golden, rx_sum);
                    img_mismatches_sum++;
                    total_mismatches_sum++;
                end

                if (rx_cycles !== expected_cycles[3:0]) begin
                    $display("[FAIL][CYCLES] %s Patch %0d: Expected %0d, Got %0d", img_name, p_idx, expected_cycles, rx_cycles);
                    img_mismatches_cyc++;
                    total_mismatches_cycles++;
                end

                if (rx_skips !== expected_skips[3:0]) begin
                    $display("[FAIL][SKIPS] %s Patch %0d: Expected %0d, Got %0d", img_name, p_idx, expected_skips, rx_skips);
                    img_mismatches_skp++;
                    total_mismatches_skips++;
                end

                p_idx++;
                total_tested_patches++;
            end
        end

        $fclose(fd);
        $display(">>> Completed %s: %0d patches, Sum Errors=%0d, Cycle Errors=%0d, Skip Errors=%0d <<<",
                 img_name, p_idx, img_mismatches_sum, img_mismatches_cyc, img_mismatches_skp);
    endtask

    initial begin
        rst  = 1'b1;
        RsRx = 1'b1;
        #200;
        @(negedge clk);
        rst  = 1'b0;
        #(BIT_PERIOD * 4);

        $display("================================================================================");
        $display(">>> STARTING REAL-BAUD 4-IMAGE UART CHECK: DESIGN_SELECT = %0d, CLKS_PER_BIT = %0d <<<",
                 DESIGN_SELECT, CLKS_PER_BIT);
        $display("================================================================================");

        run_image_test("results/final_run_20261030_1056/vectors/image1.vec", "image1");
        run_image_test("results/final_run_20261030_1056/vectors/image2.vec", "image2");
        run_image_test("results/final_run_20261030_1056/vectors/image3.vec", "image3");
        run_image_test("results/final_run_20261030_1056/vectors/image4.vec", "image4");

        $display("================================================================================");
        $display(">>> FINAL RESULTS FOR DESIGN_SELECT = %0d across all 4 images: <<<", DESIGN_SELECT);
        $display("Total Patches Tested   : %0d", total_tested_patches);
        $display("Total Sum Mismatches   : %0d", total_mismatches_sum);
        $display("Total Cycle Mismatches : %0d", total_mismatches_cycles);
        $display("Total Skip Mismatches  : %0d", total_mismatches_skips);
        if (total_mismatches_sum == 0 && total_mismatches_cycles == 0 && total_mismatches_skips == 0) begin
            $display("[RESULT: PASS] REAL-BAUD 4-IMAGE UART VERIFICATION SUCCESSFUL!");
        end else begin
            $display("[RESULT: FAIL] REAL-BAUD UART MISMATCHES DETECTED!");
        end
        $display("================================================================================");
        $finish;
    end

endmodule

// Wrapper instances for baseline and static_sobel
module tb_uart_real_baud_4img_baseline();
    tb_uart_real_baud_4img_runner #(.DESIGN_SELECT(0), .PATCHES_PER_IMAGE(25), .CLKS_PER_BIT(434)) u_runner();
endmodule

module tb_uart_real_baud_4img_static_sobel();
    tb_uart_real_baud_4img_runner #(.DESIGN_SELECT(8), .PATCHES_PER_IMAGE(25), .CLKS_PER_BIT(434)) u_runner();
endmodule

