`timescale 1ns / 1ps

module tb_test_handshake;
    logic clk = 0;
    logic rst;
    logic start;
    logic signed [7:0] weights [9];
    logic signed [7:0] pixels  [9];
    logic done;
    logic signed [31:0] conv_out;
    logic [3:0] compute_cycles;

    always #10.0 clk = ~clk;

    conv2d_serial_baseline u_dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .weights(weights),
        .pixels(pixels),
        .done(done),
        .conv_out(conv_out),
        .compute_cycles(compute_cycles)
    );

    realtime t_start, t_end;
    integer patches = 0;

    initial begin
        rst = 1;
        start = 0;
        for (int i=0; i<9; i++) begin
            weights[i] = 1;
            pixels[i] = 2;
        end
        #100;
        @(negedge clk);
        rst = 0;

        // Drive patch 0 at negedge before posedge 0
        @(negedge clk);
        start = 1;
        @(posedge clk);
        t_start = $realtime;

        for (int p = 0; p < 4; p++) begin
            @(negedge clk);
            start = 0;

            // Wait until done is asserted
            while (!done) begin
                @(negedge clk);
            end
            patches++;
            $display("[Patch %0d] Done at negedge %0.1f ns, done=%b", p, $realtime, done);

            if (p < 3) begin
                // Start next patch immediately at this same negedge
                start = 1;
                @(posedge clk);
            end
        end

        @(posedge clk);
        t_end = $realtime;

        $display("Duration: %0.1f ns, Cycles: %0d, Patches: %0d, Cyc/Patch: %0.2f",
                 t_end - t_start, int'((t_end - t_start)/20.0), patches, (t_end - t_start)/(20.0 * patches));
        $finish;
    end
endmodule
