import os
import subprocess
import shutil

PROJECT_ROOT = r"C:/Users/Krutadnye/Downloads/Projects/MAC".replace("\\", "/")
VIVADO_BIN = r"C:/AMDDesignTools/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat").replace("\\", "/")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat").replace("\\", "/")
XSIM  = os.path.join(VIVADO_BIN, "xsim.bat").replace("\\", "/")
GLBL  = r"C:/AMDDesignTools/2026.1/Vivado/data/verilog/src/glbl.v".replace("\\", "/")

# Write diagnostic testbench that only simulates Image 3 patches around 371 (total 24307)
# and checks signals cycle by cycle
tb_diag = f"""`timescale 1ns / 1ps
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
        .\\weights_in[0] (weights_in[0]), .\\weights_in[1] (weights_in[1]), .\\weights_in[2] (weights_in[2]),
        .\\weights_in[3] (weights_in[3]), .\\weights_in[4] (weights_in[4]), .\\weights_in[5] (weights_in[5]),
        .\\weights_in[6] (weights_in[6]), .\\weights_in[7] (weights_in[7]), .\\weights_in[8] (weights_in[8]),
        .\\pixels_in[0]  (pixels_in[0]),  .\\pixels_in[1]  (pixels_in[1]),  .\\pixels_in[2]  (pixels_in[2]),
        .\\pixels_in[3]  (pixels_in[3]),  .\\pixels_in[4]  (pixels_in[4]),  .\\pixels_in[5]  (pixels_in[5]),
        .\\pixels_in[6]  (pixels_in[6]),  .\\pixels_in[7]  (pixels_in[7]),  .\\pixels_in[8]  (pixels_in[8]),
        .done(done), .conv_out(conv_out), .compute_cycles(compute_cycles), .skip_count(skip_count)
    );

    initial begin
        rst = 1'b1;
        start = 1'b0;
        #100;
        @(negedge clk);
        rst = 1'b0;

        // Feed patch 370 then 371
        // Patch 370: -1 0 1 -2 0 2 -1 0 1 47 0 -84 127 123 59 127 127 118 -276
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
        $display("Patch 370 done! conv_out=%0d (hex %h), expected=-276", conv_out, conv_out);

        // Patch 371: -1 0 1 -2 0 2 -1 0 1 0 -84 -120 123 59 -95 127 118 -27 -710
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
        while (!done) begin
            $display("Time %0t ns: clk=%b done=%b conv_out=%0d (%h)", $realtime, clk, done, conv_out, conv_out);
            @(negedge clk);
        end
        $display("Patch 371 DONE at %0t ns: done=%b, conv_out=%0d (%h), expected=-710", $realtime, done, conv_out, conv_out);
        @(posedge clk);
        $display("Patch 371 next posedge at %0t ns: conv_out=%0d (%h)", $realtime, conv_out, conv_out);
        #100;
        $finish;
    end
endmodule
"""
with open("tb/tb_diag_baseline.sv", "w", encoding="utf-8") as f:
    f.write(tb_diag)

v = f"{PROJECT_ROOT}/results/final_run_20261030_1056/netlists_v2/baseline/baseline_timesim.v"
sdf = f"{PROJECT_ROOT}/results/final_run_20261030_1056/netlists_v2/baseline/baseline_timesim.sdf"
shutil.copy2(sdf, f"{PROJECT_ROOT}/baseline_timesim.sdf")

subprocess.run([XVLOG, "-sv", GLBL, v, "tb/tb_diag_baseline.sv"], cwd=PROJECT_ROOT, check=True)
subprocess.run([XELAB, "-top", "tb_diag_baseline", "-top", "glbl", "-s", "snap_diag_base", "-L", "simprims_ver", "-L", "unisims_ver", "-debug", "typical"], cwd=PROJECT_ROOT, check=True)
r = subprocess.run([XSIM, "snap_diag_base", "-R"], cwd=PROJECT_ROOT, capture_output=True, text=True)
print(r.stdout)

