`timescale 1ns / 1ps

module tb_debug_uart_one_patch;
    logic clk = 0;
    logic rst;
    logic RsRx = 1'b1;
    logic RsTx;

    always #10 clk = ~clk;

    conv2d_benchmark_top_static #(
        .DESIGN_SELECT(0)
    ) u_top (
        .clk  (clk),
        .btnC (rst),
        .RsRx (RsRx),
        .RsTx (RsTx)
    );

    localparam time BIT_PERIOD = 434 * 20ns;

    task send_byte(input [7:0] d);
        begin
            RsRx = 1'b0;
            #(BIT_PERIOD);
            for (int i = 0; i < 8; i++) begin
                RsRx = d[i];
                #(BIT_PERIOD);
            end
            RsRx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    logic [7:0] rx_fifo [$];

    // Background Full-Duplex UART Receiver
    initial begin
        logic [7:0] d;
        forever begin
            @(negedge RsTx);
            #(BIT_PERIOD / 2);
            for (int i = 0; i < 8; i++) begin
                #(BIT_PERIOD);
                d[i] = RsTx;
            end
            #(BIT_PERIOD);
            rx_fifo.push_back(d);
            $display("[%0t] RX_MONITOR captured byte 0x%02h (%0d)", $realtime, d, d);
        end
    end

    initial begin
        logic [7:0] b0, b1, b2, b3, b4, b5;
        rst = 1'b1;
        #200;
        @(negedge clk);
        rst = 1'b0;
        #(BIT_PERIOD * 4);

        $display("[%0t] Sending 9 weights...", $realtime);
        // Sobel-X weights: -1 0 1 -2 0 2 -1 0 1
        send_byte(8'hFF); send_byte(8'h00); send_byte(8'h01);
        send_byte(8'hFE); send_byte(8'h00); send_byte(8'h02);
        send_byte(8'hFF); send_byte(8'h00); send_byte(8'h01);

        $display("[%0t] Sending 9 pixels...", $realtime);
        send_byte(8'd0); send_byte(8'd0); send_byte(8'd0);
        send_byte(8'd0); send_byte(8'h91); send_byte(8'h90);
        send_byte(8'd0); send_byte(8'h90); send_byte(8'h92);

        // Wait for all 6 response bytes to arrive in FIFO
        while (rx_fifo.size() < 6) begin
            #(BIT_PERIOD);
        end

        b0 = rx_fifo.pop_front();
        b1 = rx_fifo.pop_front();
        b2 = rx_fifo.pop_front();
        b3 = rx_fifo.pop_front();
        b4 = rx_fifo.pop_front();
        b5 = rx_fifo.pop_front();

        $display("[%0t] ALL 6 BYTES RECEIVED SUCCESSFULLY!", $realtime);
        $display("conv_out = %0d (Expected: -334)", signed'({b3, b2, b1, b0}));
        $display("cycles   = %0d (Expected: 9)", b4);
        $display("skips    = %0d (Expected: 0)", b5);

        if (signed'({b3, b2, b1, b0}) == -334 && b4 == 9 && b5 == 0) begin
            $display(">>> TEST PASSED BIT-EXACT! <<<");
        end else begin
            $display(">>> TEST FAILED! <<<");
        end

        $finish;
    end
endmodule
