`timescale 1ns / 1ps
module tb_diag_baseline;
    logic clk = 0;
    logic rst;
    logic start;
    logic signed [7:0] weights_in [9];
    logic signed [7:0] pixels_in  [9];
    logic done;
    logic signed [31:0] conv_out;
    logic [3:0] compute_cycles;
    logic [3:0] skip_count;

    always #10.0 clk = ~clk;

    conv2d_engine_wrapper_v2 u_dut (
        .clk(clk), .rst(rst), .start(start),
        .\weights_in[0] (weights_in[0]), .\weights_in[1] (weights_in[1]), .\weights_in[2] (weights_in[2]),
        .\weights_in[3] (weights_in[3]), .\weights_in[4] (weights_in[4]), .\weights_in[5] (weights_in[5]),
        .\weights_in[6] (weights_in[6]), .\weights_in[7] (weights_in[7]), .\weights_in[8] (weights_in[8]),
        .\pixels_in[0]  (pixels_in[0]),  .\pixels_in[1]  (pixels_in[1]),  .\pixels_in[2]  (pixels_in[2]),
        .\pixels_in[3]  (pixels_in[3]),  .\pixels_in[4]  (pixels_in[4]),  .\pixels_in[5]  (pixels_in[5]),
        .\pixels_in[6]  (pixels_in[6]),  .\pixels_in[7]  (pixels_in[7]),  .\pixels_in[8]  (pixels_in[8]),
        .done(done), .conv_out(conv_out), .compute_cycles(compute_cycles), .skip_count(skip_count)
    );

    initial begin
        rst = 1'b1;
        start = 1'b0;
        #100;
        @(negedge clk);
        rst = 1'b0;

        // Feed patch 370
        weights_in[0]=-1; weights_in[1]=0; weights_in[2]=1;
        weights_in[3]=-2; weights_in[4]=0; weights_in[5]=2;
        weights_in[6]=-1; weights_in[7]=0; weights_in[8]=1;
        pixels_in[0]=47;  pixels_in[1]=0;   pixels_in[2]=-84;
        pixels_in[3]=127; pixels_in[4]=123; pixels_in[5]=59;
        pixels_in[6]=127; pixels_in[7]=127; pixels_in[8]=118;
        start = 1'b1;
        @(posedge clk);
        @(negedge clk);
        start = 1'b0;
        while (!done) @(negedge clk);

        // Feed patch 371
        weights_in[0]=-1; weights_in[1]=0; weights_in[2]=1;
        weights_in[3]=-2; weights_in[4]=0; weights_in[5]=2;
        weights_in[6]=-1; weights_in[7]=0; weights_in[8]=1;
        pixels_in[0]=0;   pixels_in[1]=-84; pixels_in[2]=-120;
        pixels_in[3]=123; pixels_in[4]=59;  pixels_in[5]=-95;
        pixels_in[6]=127; pixels_in[7]=118; pixels_in[8]=-27;
        start = 1'b1;
        @(posedge clk);
        @(negedge clk);
        start = 1'b0;

        for (int c = 0; c < 15; c++) begin
            @(posedge clk);
            #19;
            if (c == 7) begin
                $display("Cyc 7 detail: CI=%b DI=%b S=%b O=%b",
                         u_dut.\gen_engine.u_core .accum1__85_carry__0_n_0,
                         {1'b0, u_dut.\gen_engine.u_core .accum1__59_carry__1_n_7, u_dut.\gen_engine.u_core .accum1__85_carry__1_i_1_n_0, u_dut.\gen_engine.u_core .accum1__85_carry__1_i_2_n_0},
                         {u_dut.\gen_engine.u_core .accum1__59_carry__1_n_6, u_dut.\gen_engine.u_core .accum1__85_carry__1_i_3_n_0, u_dut.\gen_engine.u_core .accum1__85_carry__1_i_4_n_0, u_dut.\gen_engine.u_core .accum1__85_carry__1_i_5_n_0},
                         u_dut.\gen_engine.u_core .p_0_in[15:12]);
            end
        end
        #100;
        $finish;
    end
endmodule
