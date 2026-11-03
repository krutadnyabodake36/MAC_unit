`timescale 1ns / 1ps

module test_patch_6466;
    logic clk = 0;
    logic rst;
    logic start;
    logic signed [7:0] w[9];
    logic signed [7:0] p[9];
    logic done_rtl;
    logic signed [31:0] out_rtl;
    logic [3:0] cyc_rtl, skip_rtl;

    logic done_v2;
    logic signed [31:0] out_v2;
    logic [3:0] cyc_v2, skip_v2;

    always #10 clk = ~clk;

    // Direct RTL instantiation of conv2d_serial_zs
    conv2d_serial_zs u_rtl (
        .clk(clk), .rst(rst), .start(start),
        .weights(w), .pixels(p),
        .done(done_rtl), .conv_out(out_rtl),
        .compute_cycles(cyc_rtl), .skip_count(skip_rtl)
    );

    // Wrapper v2 instantiation of conv2d_engine_wrapper_v2
    conv2d_engine_wrapper_v2 #(.DESIGN_SELECT(3)) u_v2 (
        .clk(clk), .rst(rst), .start(start),
        .weights_in(w), .pixels_in(p),
        .done(done_v2), .conv_out(out_v2),
        .compute_cycles(cyc_v2), .skip_count(skip_v2)
    );

    task automatic test_p(input int idx, input logic signed [7:0] pw[9], input logic signed [7:0] pp[9], input int exp);
        begin
            @(negedge clk);
            w = pw;
            p = pp;
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            // Wait for both done
            fork
                begin while (!done_rtl) @(negedge clk); end
                begin while (!done_v2)  @(negedge clk); end
            join

            $display("Patch %0d: Expected=%0d | RTL_out=%0d (cyc=%0d) | V2_out=%0d (cyc=%0d)",
                     idx, exp, out_rtl, cyc_rtl, out_v2, cyc_v2);
        end
    endtask

    initial begin
        logic signed [7:0] w_sobel[9] = '{-1, 0, 1, -2, 0, 2, -1, 0, 1};
        logic signed [7:0] p6465[9]   = '{41, 24, -4, 30, 12, 4, 21, 11, -23};
        logic signed [7:0] p6466[9]   = '{24, -4, -33, 12, 4, -26, 11, -23, -44};
        logic signed [7:0] p6467[9]   = '{-4, -33, -48, 4, -26, -49, -23, -44, -55};

        rst = 1;
        start = 0;
        #100;
        @(negedge clk);
        rst = 0;
        #40;

        test_p(6465, w_sobel, p6465, -141);
        test_p(6466, w_sobel, p6466, -188);
        test_p(6467, w_sobel, p6467, -182);

        #100;
        $finish;
    end
endmodule
