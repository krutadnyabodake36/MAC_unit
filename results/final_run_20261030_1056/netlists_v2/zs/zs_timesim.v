// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
// Date        : Sun Nov  1 04:52:50 2026
// Host        : LAPTOP-NBHBH25N running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -sdf_anno true -force
//               C:/Users/Krutadnye/Downloads/Projects/MAC/results/final_run_20261030_1056/netlists_v2/zs/zs_timesim.v
// Design      : conv2d_engine_wrapper_v2
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7s15ftgb196-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* DESIGN_SELECT = "3" *) (* ECO_CHECKSUM = "2468bedd" *) 
(* NotValidForBitStream *)
module conv2d_engine_wrapper_v2
   (clk,
    rst,
    start,
    \weights_in[0] ,
    \weights_in[1] ,
    \weights_in[2] ,
    \weights_in[3] ,
    \weights_in[4] ,
    \weights_in[5] ,
    \weights_in[6] ,
    \weights_in[7] ,
    \weights_in[8] ,
    \pixels_in[0] ,
    \pixels_in[1] ,
    \pixels_in[2] ,
    \pixels_in[3] ,
    \pixels_in[4] ,
    \pixels_in[5] ,
    \pixels_in[6] ,
    \pixels_in[7] ,
    \pixels_in[8] ,
    done,
    conv_out,
    compute_cycles,
    skip_count);
  input clk;
  input rst;
  input start;
  input [7:0]\weights_in[0] ;
  input [7:0]\weights_in[1] ;
  input [7:0]\weights_in[2] ;
  input [7:0]\weights_in[3] ;
  input [7:0]\weights_in[4] ;
  input [7:0]\weights_in[5] ;
  input [7:0]\weights_in[6] ;
  input [7:0]\weights_in[7] ;
  input [7:0]\weights_in[8] ;
  input [7:0]\pixels_in[0] ;
  input [7:0]\pixels_in[1] ;
  input [7:0]\pixels_in[2] ;
  input [7:0]\pixels_in[3] ;
  input [7:0]\pixels_in[4] ;
  input [7:0]\pixels_in[5] ;
  input [7:0]\pixels_in[6] ;
  input [7:0]\pixels_in[7] ;
  input [7:0]\pixels_in[8] ;
  output done;
  output [31:0]conv_out;
  output [3:0]compute_cycles;
  output [3:0]skip_count;

  wire clk;
  wire [3:0]compute_cycles;
  wire [31:0]conv_out;
  wire core_start;
  wire core_start_i_1_n_0;
  wire done;
  wire [7:0]\p_reg_reg[0] ;
  wire [7:0]\p_reg_reg[1] ;
  wire [7:0]\p_reg_reg[2] ;
  wire [7:0]\p_reg_reg[3] ;
  wire [7:0]\p_reg_reg[4] ;
  wire [7:0]\p_reg_reg[5] ;
  wire [7:0]\p_reg_reg[6] ;
  wire [7:0]\p_reg_reg[7] ;
  wire [7:0]\p_reg_reg[8] ;
  wire pending;
  wire pending_i_1_n_0;
  wire [7:0]\pixels_in[0] ;
  wire [7:0]\pixels_in[1] ;
  wire [7:0]\pixels_in[2] ;
  wire [7:0]\pixels_in[3] ;
  wire [7:0]\pixels_in[4] ;
  wire [7:0]\pixels_in[5] ;
  wire [7:0]\pixels_in[6] ;
  wire [7:0]\pixels_in[7] ;
  wire [7:0]\pixels_in[8] ;
  wire rst;
  wire [3:0]skip_count;
  wire start;
  wire [7:0]\w_reg_reg[0] ;
  wire [7:0]\w_reg_reg[1] ;
  wire [7:0]\w_reg_reg[2] ;
  wire [7:0]\w_reg_reg[3] ;
  wire [7:0]\w_reg_reg[4] ;
  wire [7:0]\w_reg_reg[5] ;
  wire [7:0]\w_reg_reg[6] ;
  wire [7:0]\w_reg_reg[7] ;
  wire [7:0]\w_reg_reg[8] ;
  wire [7:0]\weights_in[0] ;
  wire [7:0]\weights_in[1] ;
  wire [7:0]\weights_in[2] ;
  wire [7:0]\weights_in[3] ;
  wire [7:0]\weights_in[4] ;
  wire [7:0]\weights_in[5] ;
  wire [7:0]\weights_in[6] ;
  wire [7:0]\weights_in[7] ;
  wire [7:0]\weights_in[8] ;

initial begin
 $sdf_annotate("zs_timesim.sdf",,,,"tool_control");
end
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'h02)) 
    core_start_i_1
       (.I0(pending),
        .I1(rst),
        .I2(start),
        .O(core_start_i_1_n_0));
  FDRE core_start_reg
       (.C(clk),
        .CE(1'b1),
        .D(core_start_i_1_n_0),
        .Q(core_start),
        .R(1'b0));
  conv2d_serial_zs \gen_engine.u_core 
       (.Q(\p_reg_reg[8] ),
        .clk(clk),
        .compute_cycles(compute_cycles),
        .conv_out(conv_out),
        .core_start(core_start),
        .done(done),
        .\remaining[0]_i_2_0 (\w_reg_reg[0] ),
        .\remaining[0]_i_4_0 (\p_reg_reg[0] ),
        .\remaining[1]_i_2_0 (\w_reg_reg[1] ),
        .\remaining[1]_i_4_0 (\p_reg_reg[1] ),
        .\remaining[2]_i_2_0 (\w_reg_reg[2] ),
        .\remaining[2]_i_4_0 (\p_reg_reg[2] ),
        .\remaining[3]_i_3_0 (\w_reg_reg[3] ),
        .\remaining[3]_i_5_0 (\p_reg_reg[3] ),
        .\remaining[4]_i_3_0 (\w_reg_reg[4] ),
        .\remaining[4]_i_5_0 (\p_reg_reg[4] ),
        .\remaining[5]_i_2_0 (\w_reg_reg[5] ),
        .\remaining[5]_i_4_0 (\p_reg_reg[5] ),
        .\remaining[6]_i_11_0 (\p_reg_reg[6] ),
        .\remaining[6]_i_4_0 (\w_reg_reg[6] ),
        .\remaining[7]_i_4_0 (\w_reg_reg[7] ),
        .\remaining[7]_i_6_0 (\p_reg_reg[7] ),
        .\remaining[8]_i_5_0 (\w_reg_reg[8] ),
        .rst(rst),
        .skip_count(skip_count));
  FDRE \p_reg_reg[0][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [0]),
        .Q(\p_reg_reg[0] [0]),
        .R(rst));
  FDRE \p_reg_reg[0][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [1]),
        .Q(\p_reg_reg[0] [1]),
        .R(rst));
  FDRE \p_reg_reg[0][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [2]),
        .Q(\p_reg_reg[0] [2]),
        .R(rst));
  FDRE \p_reg_reg[0][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [3]),
        .Q(\p_reg_reg[0] [3]),
        .R(rst));
  FDRE \p_reg_reg[0][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [4]),
        .Q(\p_reg_reg[0] [4]),
        .R(rst));
  FDRE \p_reg_reg[0][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [5]),
        .Q(\p_reg_reg[0] [5]),
        .R(rst));
  FDRE \p_reg_reg[0][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [6]),
        .Q(\p_reg_reg[0] [6]),
        .R(rst));
  FDRE \p_reg_reg[0][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [7]),
        .Q(\p_reg_reg[0] [7]),
        .R(rst));
  FDRE \p_reg_reg[1][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [0]),
        .Q(\p_reg_reg[1] [0]),
        .R(rst));
  FDRE \p_reg_reg[1][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [1]),
        .Q(\p_reg_reg[1] [1]),
        .R(rst));
  FDRE \p_reg_reg[1][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [2]),
        .Q(\p_reg_reg[1] [2]),
        .R(rst));
  FDRE \p_reg_reg[1][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [3]),
        .Q(\p_reg_reg[1] [3]),
        .R(rst));
  FDRE \p_reg_reg[1][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [4]),
        .Q(\p_reg_reg[1] [4]),
        .R(rst));
  FDRE \p_reg_reg[1][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [5]),
        .Q(\p_reg_reg[1] [5]),
        .R(rst));
  FDRE \p_reg_reg[1][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [6]),
        .Q(\p_reg_reg[1] [6]),
        .R(rst));
  FDRE \p_reg_reg[1][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [7]),
        .Q(\p_reg_reg[1] [7]),
        .R(rst));
  FDRE \p_reg_reg[2][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [0]),
        .Q(\p_reg_reg[2] [0]),
        .R(rst));
  FDRE \p_reg_reg[2][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [1]),
        .Q(\p_reg_reg[2] [1]),
        .R(rst));
  FDRE \p_reg_reg[2][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [2]),
        .Q(\p_reg_reg[2] [2]),
        .R(rst));
  FDRE \p_reg_reg[2][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [3]),
        .Q(\p_reg_reg[2] [3]),
        .R(rst));
  FDRE \p_reg_reg[2][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [4]),
        .Q(\p_reg_reg[2] [4]),
        .R(rst));
  FDRE \p_reg_reg[2][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [5]),
        .Q(\p_reg_reg[2] [5]),
        .R(rst));
  FDRE \p_reg_reg[2][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [6]),
        .Q(\p_reg_reg[2] [6]),
        .R(rst));
  FDRE \p_reg_reg[2][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [7]),
        .Q(\p_reg_reg[2] [7]),
        .R(rst));
  FDRE \p_reg_reg[3][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [0]),
        .Q(\p_reg_reg[3] [0]),
        .R(rst));
  FDRE \p_reg_reg[3][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [1]),
        .Q(\p_reg_reg[3] [1]),
        .R(rst));
  FDRE \p_reg_reg[3][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [2]),
        .Q(\p_reg_reg[3] [2]),
        .R(rst));
  FDRE \p_reg_reg[3][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [3]),
        .Q(\p_reg_reg[3] [3]),
        .R(rst));
  FDRE \p_reg_reg[3][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [4]),
        .Q(\p_reg_reg[3] [4]),
        .R(rst));
  FDRE \p_reg_reg[3][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [5]),
        .Q(\p_reg_reg[3] [5]),
        .R(rst));
  FDRE \p_reg_reg[3][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [6]),
        .Q(\p_reg_reg[3] [6]),
        .R(rst));
  FDRE \p_reg_reg[3][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [7]),
        .Q(\p_reg_reg[3] [7]),
        .R(rst));
  FDRE \p_reg_reg[4][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [0]),
        .Q(\p_reg_reg[4] [0]),
        .R(rst));
  FDRE \p_reg_reg[4][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [1]),
        .Q(\p_reg_reg[4] [1]),
        .R(rst));
  FDRE \p_reg_reg[4][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [2]),
        .Q(\p_reg_reg[4] [2]),
        .R(rst));
  FDRE \p_reg_reg[4][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [3]),
        .Q(\p_reg_reg[4] [3]),
        .R(rst));
  FDRE \p_reg_reg[4][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [4]),
        .Q(\p_reg_reg[4] [4]),
        .R(rst));
  FDRE \p_reg_reg[4][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [5]),
        .Q(\p_reg_reg[4] [5]),
        .R(rst));
  FDRE \p_reg_reg[4][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [6]),
        .Q(\p_reg_reg[4] [6]),
        .R(rst));
  FDRE \p_reg_reg[4][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [7]),
        .Q(\p_reg_reg[4] [7]),
        .R(rst));
  FDRE \p_reg_reg[5][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [0]),
        .Q(\p_reg_reg[5] [0]),
        .R(rst));
  FDRE \p_reg_reg[5][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [1]),
        .Q(\p_reg_reg[5] [1]),
        .R(rst));
  FDRE \p_reg_reg[5][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [2]),
        .Q(\p_reg_reg[5] [2]),
        .R(rst));
  FDRE \p_reg_reg[5][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [3]),
        .Q(\p_reg_reg[5] [3]),
        .R(rst));
  FDRE \p_reg_reg[5][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [4]),
        .Q(\p_reg_reg[5] [4]),
        .R(rst));
  FDRE \p_reg_reg[5][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [5]),
        .Q(\p_reg_reg[5] [5]),
        .R(rst));
  FDRE \p_reg_reg[5][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [6]),
        .Q(\p_reg_reg[5] [6]),
        .R(rst));
  FDRE \p_reg_reg[5][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [7]),
        .Q(\p_reg_reg[5] [7]),
        .R(rst));
  FDRE \p_reg_reg[6][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [0]),
        .Q(\p_reg_reg[6] [0]),
        .R(rst));
  FDRE \p_reg_reg[6][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [1]),
        .Q(\p_reg_reg[6] [1]),
        .R(rst));
  FDRE \p_reg_reg[6][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [2]),
        .Q(\p_reg_reg[6] [2]),
        .R(rst));
  FDRE \p_reg_reg[6][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [3]),
        .Q(\p_reg_reg[6] [3]),
        .R(rst));
  FDRE \p_reg_reg[6][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [4]),
        .Q(\p_reg_reg[6] [4]),
        .R(rst));
  FDRE \p_reg_reg[6][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [5]),
        .Q(\p_reg_reg[6] [5]),
        .R(rst));
  FDRE \p_reg_reg[6][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [6]),
        .Q(\p_reg_reg[6] [6]),
        .R(rst));
  FDRE \p_reg_reg[6][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [7]),
        .Q(\p_reg_reg[6] [7]),
        .R(rst));
  FDRE \p_reg_reg[7][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [0]),
        .Q(\p_reg_reg[7] [0]),
        .R(rst));
  FDRE \p_reg_reg[7][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [1]),
        .Q(\p_reg_reg[7] [1]),
        .R(rst));
  FDRE \p_reg_reg[7][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [2]),
        .Q(\p_reg_reg[7] [2]),
        .R(rst));
  FDRE \p_reg_reg[7][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [3]),
        .Q(\p_reg_reg[7] [3]),
        .R(rst));
  FDRE \p_reg_reg[7][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [4]),
        .Q(\p_reg_reg[7] [4]),
        .R(rst));
  FDRE \p_reg_reg[7][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [5]),
        .Q(\p_reg_reg[7] [5]),
        .R(rst));
  FDRE \p_reg_reg[7][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [6]),
        .Q(\p_reg_reg[7] [6]),
        .R(rst));
  FDRE \p_reg_reg[7][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [7]),
        .Q(\p_reg_reg[7] [7]),
        .R(rst));
  FDRE \p_reg_reg[8][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [0]),
        .Q(\p_reg_reg[8] [0]),
        .R(rst));
  FDRE \p_reg_reg[8][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [1]),
        .Q(\p_reg_reg[8] [1]),
        .R(rst));
  FDRE \p_reg_reg[8][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [2]),
        .Q(\p_reg_reg[8] [2]),
        .R(rst));
  FDRE \p_reg_reg[8][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [3]),
        .Q(\p_reg_reg[8] [3]),
        .R(rst));
  FDRE \p_reg_reg[8][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [4]),
        .Q(\p_reg_reg[8] [4]),
        .R(rst));
  FDRE \p_reg_reg[8][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [5]),
        .Q(\p_reg_reg[8] [5]),
        .R(rst));
  FDRE \p_reg_reg[8][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [6]),
        .Q(\p_reg_reg[8] [6]),
        .R(rst));
  FDRE \p_reg_reg[8][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [7]),
        .Q(\p_reg_reg[8] [7]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT2 #(
    .INIT(4'h2)) 
    pending_i_1
       (.I0(start),
        .I1(rst),
        .O(pending_i_1_n_0));
  FDRE pending_reg
       (.C(clk),
        .CE(1'b1),
        .D(pending_i_1_n_0),
        .Q(pending),
        .R(1'b0));
  FDRE \w_reg_reg[0][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [0]),
        .Q(\w_reg_reg[0] [0]),
        .R(rst));
  FDRE \w_reg_reg[0][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [1]),
        .Q(\w_reg_reg[0] [1]),
        .R(rst));
  FDRE \w_reg_reg[0][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [2]),
        .Q(\w_reg_reg[0] [2]),
        .R(rst));
  FDRE \w_reg_reg[0][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [3]),
        .Q(\w_reg_reg[0] [3]),
        .R(rst));
  FDRE \w_reg_reg[0][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [4]),
        .Q(\w_reg_reg[0] [4]),
        .R(rst));
  FDRE \w_reg_reg[0][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [5]),
        .Q(\w_reg_reg[0] [5]),
        .R(rst));
  FDRE \w_reg_reg[0][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [6]),
        .Q(\w_reg_reg[0] [6]),
        .R(rst));
  FDRE \w_reg_reg[0][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [7]),
        .Q(\w_reg_reg[0] [7]),
        .R(rst));
  FDRE \w_reg_reg[1][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [0]),
        .Q(\w_reg_reg[1] [0]),
        .R(rst));
  FDRE \w_reg_reg[1][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [1]),
        .Q(\w_reg_reg[1] [1]),
        .R(rst));
  FDRE \w_reg_reg[1][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [2]),
        .Q(\w_reg_reg[1] [2]),
        .R(rst));
  FDRE \w_reg_reg[1][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [3]),
        .Q(\w_reg_reg[1] [3]),
        .R(rst));
  FDRE \w_reg_reg[1][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [4]),
        .Q(\w_reg_reg[1] [4]),
        .R(rst));
  FDRE \w_reg_reg[1][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [5]),
        .Q(\w_reg_reg[1] [5]),
        .R(rst));
  FDRE \w_reg_reg[1][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [6]),
        .Q(\w_reg_reg[1] [6]),
        .R(rst));
  FDRE \w_reg_reg[1][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [7]),
        .Q(\w_reg_reg[1] [7]),
        .R(rst));
  FDRE \w_reg_reg[2][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [0]),
        .Q(\w_reg_reg[2] [0]),
        .R(rst));
  FDRE \w_reg_reg[2][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [1]),
        .Q(\w_reg_reg[2] [1]),
        .R(rst));
  FDRE \w_reg_reg[2][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [2]),
        .Q(\w_reg_reg[2] [2]),
        .R(rst));
  FDRE \w_reg_reg[2][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [3]),
        .Q(\w_reg_reg[2] [3]),
        .R(rst));
  FDRE \w_reg_reg[2][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [4]),
        .Q(\w_reg_reg[2] [4]),
        .R(rst));
  FDRE \w_reg_reg[2][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [5]),
        .Q(\w_reg_reg[2] [5]),
        .R(rst));
  FDRE \w_reg_reg[2][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [6]),
        .Q(\w_reg_reg[2] [6]),
        .R(rst));
  FDRE \w_reg_reg[2][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [7]),
        .Q(\w_reg_reg[2] [7]),
        .R(rst));
  FDRE \w_reg_reg[3][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [0]),
        .Q(\w_reg_reg[3] [0]),
        .R(rst));
  FDRE \w_reg_reg[3][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [1]),
        .Q(\w_reg_reg[3] [1]),
        .R(rst));
  FDRE \w_reg_reg[3][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [2]),
        .Q(\w_reg_reg[3] [2]),
        .R(rst));
  FDRE \w_reg_reg[3][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [3]),
        .Q(\w_reg_reg[3] [3]),
        .R(rst));
  FDRE \w_reg_reg[3][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [4]),
        .Q(\w_reg_reg[3] [4]),
        .R(rst));
  FDRE \w_reg_reg[3][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [5]),
        .Q(\w_reg_reg[3] [5]),
        .R(rst));
  FDRE \w_reg_reg[3][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [6]),
        .Q(\w_reg_reg[3] [6]),
        .R(rst));
  FDRE \w_reg_reg[3][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [7]),
        .Q(\w_reg_reg[3] [7]),
        .R(rst));
  FDRE \w_reg_reg[4][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [0]),
        .Q(\w_reg_reg[4] [0]),
        .R(rst));
  FDRE \w_reg_reg[4][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [1]),
        .Q(\w_reg_reg[4] [1]),
        .R(rst));
  FDRE \w_reg_reg[4][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [2]),
        .Q(\w_reg_reg[4] [2]),
        .R(rst));
  FDRE \w_reg_reg[4][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [3]),
        .Q(\w_reg_reg[4] [3]),
        .R(rst));
  FDRE \w_reg_reg[4][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [4]),
        .Q(\w_reg_reg[4] [4]),
        .R(rst));
  FDRE \w_reg_reg[4][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [5]),
        .Q(\w_reg_reg[4] [5]),
        .R(rst));
  FDRE \w_reg_reg[4][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [6]),
        .Q(\w_reg_reg[4] [6]),
        .R(rst));
  FDRE \w_reg_reg[4][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [7]),
        .Q(\w_reg_reg[4] [7]),
        .R(rst));
  FDRE \w_reg_reg[5][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [0]),
        .Q(\w_reg_reg[5] [0]),
        .R(rst));
  FDRE \w_reg_reg[5][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [1]),
        .Q(\w_reg_reg[5] [1]),
        .R(rst));
  FDRE \w_reg_reg[5][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [2]),
        .Q(\w_reg_reg[5] [2]),
        .R(rst));
  FDRE \w_reg_reg[5][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [3]),
        .Q(\w_reg_reg[5] [3]),
        .R(rst));
  FDRE \w_reg_reg[5][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [4]),
        .Q(\w_reg_reg[5] [4]),
        .R(rst));
  FDRE \w_reg_reg[5][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [5]),
        .Q(\w_reg_reg[5] [5]),
        .R(rst));
  FDRE \w_reg_reg[5][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [6]),
        .Q(\w_reg_reg[5] [6]),
        .R(rst));
  FDRE \w_reg_reg[5][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [7]),
        .Q(\w_reg_reg[5] [7]),
        .R(rst));
  FDRE \w_reg_reg[6][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [0]),
        .Q(\w_reg_reg[6] [0]),
        .R(rst));
  FDRE \w_reg_reg[6][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [1]),
        .Q(\w_reg_reg[6] [1]),
        .R(rst));
  FDRE \w_reg_reg[6][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [2]),
        .Q(\w_reg_reg[6] [2]),
        .R(rst));
  FDRE \w_reg_reg[6][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [3]),
        .Q(\w_reg_reg[6] [3]),
        .R(rst));
  FDRE \w_reg_reg[6][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [4]),
        .Q(\w_reg_reg[6] [4]),
        .R(rst));
  FDRE \w_reg_reg[6][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [5]),
        .Q(\w_reg_reg[6] [5]),
        .R(rst));
  FDRE \w_reg_reg[6][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [6]),
        .Q(\w_reg_reg[6] [6]),
        .R(rst));
  FDRE \w_reg_reg[6][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [7]),
        .Q(\w_reg_reg[6] [7]),
        .R(rst));
  FDRE \w_reg_reg[7][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [0]),
        .Q(\w_reg_reg[7] [0]),
        .R(rst));
  FDRE \w_reg_reg[7][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [1]),
        .Q(\w_reg_reg[7] [1]),
        .R(rst));
  FDRE \w_reg_reg[7][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [2]),
        .Q(\w_reg_reg[7] [2]),
        .R(rst));
  FDRE \w_reg_reg[7][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [3]),
        .Q(\w_reg_reg[7] [3]),
        .R(rst));
  FDRE \w_reg_reg[7][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [4]),
        .Q(\w_reg_reg[7] [4]),
        .R(rst));
  FDRE \w_reg_reg[7][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [5]),
        .Q(\w_reg_reg[7] [5]),
        .R(rst));
  FDRE \w_reg_reg[7][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [6]),
        .Q(\w_reg_reg[7] [6]),
        .R(rst));
  FDRE \w_reg_reg[7][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [7]),
        .Q(\w_reg_reg[7] [7]),
        .R(rst));
  FDRE \w_reg_reg[8][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [0]),
        .Q(\w_reg_reg[8] [0]),
        .R(rst));
  FDRE \w_reg_reg[8][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [1]),
        .Q(\w_reg_reg[8] [1]),
        .R(rst));
  FDRE \w_reg_reg[8][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [2]),
        .Q(\w_reg_reg[8] [2]),
        .R(rst));
  FDRE \w_reg_reg[8][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [3]),
        .Q(\w_reg_reg[8] [3]),
        .R(rst));
  FDRE \w_reg_reg[8][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [4]),
        .Q(\w_reg_reg[8] [4]),
        .R(rst));
  FDRE \w_reg_reg[8][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [5]),
        .Q(\w_reg_reg[8] [5]),
        .R(rst));
  FDRE \w_reg_reg[8][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [6]),
        .Q(\w_reg_reg[8] [6]),
        .R(rst));
  FDRE \w_reg_reg[8][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [7]),
        .Q(\w_reg_reg[8] [7]),
        .R(rst));
endmodule

module conv2d_serial_zs
   (done,
    conv_out,
    compute_cycles,
    skip_count,
    clk,
    rst,
    core_start,
    Q,
    \remaining[8]_i_5_0 ,
    \remaining[7]_i_6_0 ,
    \remaining[5]_i_4_0 ,
    \remaining[6]_i_11_0 ,
    \remaining[4]_i_5_0 ,
    \remaining[3]_i_5_0 ,
    \remaining[1]_i_4_0 ,
    \remaining[2]_i_4_0 ,
    \remaining[0]_i_4_0 ,
    \remaining[7]_i_4_0 ,
    \remaining[5]_i_2_0 ,
    \remaining[6]_i_4_0 ,
    \remaining[4]_i_3_0 ,
    \remaining[3]_i_3_0 ,
    \remaining[1]_i_2_0 ,
    \remaining[2]_i_2_0 ,
    \remaining[0]_i_2_0 );
  output done;
  output [31:0]conv_out;
  output [3:0]compute_cycles;
  output [3:0]skip_count;
  input clk;
  input rst;
  input core_start;
  input [7:0]Q;
  input [7:0]\remaining[8]_i_5_0 ;
  input [7:0]\remaining[7]_i_6_0 ;
  input [7:0]\remaining[5]_i_4_0 ;
  input [7:0]\remaining[6]_i_11_0 ;
  input [7:0]\remaining[4]_i_5_0 ;
  input [7:0]\remaining[3]_i_5_0 ;
  input [7:0]\remaining[1]_i_4_0 ;
  input [7:0]\remaining[2]_i_4_0 ;
  input [7:0]\remaining[0]_i_4_0 ;
  input [7:0]\remaining[7]_i_4_0 ;
  input [7:0]\remaining[5]_i_2_0 ;
  input [7:0]\remaining[6]_i_4_0 ;
  input [7:0]\remaining[4]_i_3_0 ;
  input [7:0]\remaining[3]_i_3_0 ;
  input [7:0]\remaining[1]_i_2_0 ;
  input [7:0]\remaining[2]_i_2_0 ;
  input [7:0]\remaining[0]_i_2_0 ;

  wire \FSM_sequential_state[0]_i_1_n_0 ;
  wire \FSM_sequential_state[1]_i_10_n_0 ;
  wire \FSM_sequential_state[1]_i_11_n_0 ;
  wire \FSM_sequential_state[1]_i_12_n_0 ;
  wire \FSM_sequential_state[1]_i_1_n_0 ;
  wire \FSM_sequential_state[1]_i_2_n_0 ;
  wire \FSM_sequential_state[1]_i_3_n_0 ;
  wire \FSM_sequential_state[1]_i_4_n_0 ;
  wire \FSM_sequential_state[1]_i_5_n_0 ;
  wire \FSM_sequential_state[1]_i_6_n_0 ;
  wire \FSM_sequential_state[1]_i_7_n_0 ;
  wire \FSM_sequential_state[1]_i_8_n_0 ;
  wire \FSM_sequential_state[1]_i_9_n_0 ;
  wire [7:0]Q;
  wire accum;
  wire [31:0]accum0;
  wire accum0_carry__0_i_1_n_0;
  wire accum0_carry__0_i_2_n_0;
  wire accum0_carry__0_i_3_n_0;
  wire accum0_carry__0_i_4_n_0;
  wire accum0_carry__0_n_0;
  wire accum0_carry__1_i_1_n_0;
  wire accum0_carry__1_i_2_n_0;
  wire accum0_carry__1_i_3_n_0;
  wire accum0_carry__1_i_4_n_0;
  wire accum0_carry__1_n_0;
  wire accum0_carry__2_i_1_n_0;
  wire accum0_carry__2_i_2_n_0;
  wire accum0_carry__2_i_3_n_0;
  wire accum0_carry__2_i_4_n_0;
  wire accum0_carry__2_n_0;
  wire accum0_carry__3_i_1_n_0;
  wire accum0_carry__3_i_2_n_0;
  wire accum0_carry__3_i_3_n_0;
  wire accum0_carry__3_i_4_n_0;
  wire accum0_carry__3_i_5_n_0;
  wire accum0_carry__3_n_0;
  wire accum0_carry__4_i_1_n_0;
  wire accum0_carry__4_i_2_n_0;
  wire accum0_carry__4_i_3_n_0;
  wire accum0_carry__4_i_4_n_0;
  wire accum0_carry__4_n_0;
  wire accum0_carry__5_i_1_n_0;
  wire accum0_carry__5_i_2_n_0;
  wire accum0_carry__5_i_3_n_0;
  wire accum0_carry__5_i_4_n_0;
  wire accum0_carry__5_n_0;
  wire accum0_carry__6_i_1_n_0;
  wire accum0_carry__6_i_2_n_0;
  wire accum0_carry__6_i_3_n_0;
  wire accum0_carry__6_i_4_n_0;
  wire accum0_carry_i_1_n_0;
  wire accum0_carry_i_2_n_0;
  wire accum0_carry_i_3_n_0;
  wire accum0_carry_i_4_n_0;
  wire accum0_carry_n_0;
  wire [31:0]accum0_in;
  wire accum1__0_carry__0_i_10_n_0;
  wire accum1__0_carry__0_i_11_n_0;
  wire accum1__0_carry__0_i_12_n_0;
  wire accum1__0_carry__0_i_13_n_0;
  wire accum1__0_carry__0_i_14_n_0;
  wire accum1__0_carry__0_i_15_n_0;
  wire accum1__0_carry__0_i_16_n_0;
  wire accum1__0_carry__0_i_17_n_0;
  wire accum1__0_carry__0_i_1_n_0;
  wire accum1__0_carry__0_i_20_n_0;
  wire accum1__0_carry__0_i_21_n_0;
  wire accum1__0_carry__0_i_22_n_0;
  wire accum1__0_carry__0_i_23_n_0;
  wire accum1__0_carry__0_i_24_n_0;
  wire accum1__0_carry__0_i_2_n_0;
  wire accum1__0_carry__0_i_3_n_0;
  wire accum1__0_carry__0_i_4_n_0;
  wire accum1__0_carry__0_i_5_n_0;
  wire accum1__0_carry__0_i_6_n_0;
  wire accum1__0_carry__0_i_7_n_0;
  wire accum1__0_carry__0_i_8_n_0;
  wire accum1__0_carry__0_i_9_n_0;
  wire accum1__0_carry__0_n_0;
  wire accum1__0_carry__0_n_4;
  wire accum1__0_carry__0_n_5;
  wire accum1__0_carry__0_n_6;
  wire accum1__0_carry__0_n_7;
  wire accum1__0_carry__1_i_1_n_0;
  wire accum1__0_carry__1_i_2_n_0;
  wire accum1__0_carry__1_i_3_n_0;
  wire accum1__0_carry__1_i_4_n_0;
  wire accum1__0_carry__1_i_6_n_0;
  wire accum1__0_carry__1_i_7_n_0;
  wire accum1__0_carry__1_n_1;
  wire accum1__0_carry__1_n_6;
  wire accum1__0_carry__1_n_7;
  wire accum1__0_carry_i_10_n_0;
  wire accum1__0_carry_i_17_n_0;
  wire accum1__0_carry_i_18_n_0;
  wire accum1__0_carry_i_19_n_0;
  wire accum1__0_carry_i_1_n_0;
  wire accum1__0_carry_i_20_n_0;
  wire accum1__0_carry_i_21_n_0;
  wire accum1__0_carry_i_22_n_0;
  wire accum1__0_carry_i_23_n_0;
  wire accum1__0_carry_i_24_n_0;
  wire accum1__0_carry_i_25_n_0;
  wire accum1__0_carry_i_26_n_0;
  wire accum1__0_carry_i_27_n_0;
  wire accum1__0_carry_i_28_n_0;
  wire accum1__0_carry_i_2_n_0;
  wire accum1__0_carry_i_3_n_0;
  wire accum1__0_carry_i_4_n_0;
  wire accum1__0_carry_i_5_n_0;
  wire accum1__0_carry_i_6_n_0;
  wire accum1__0_carry_i_7_n_0;
  wire accum1__0_carry_i_8_n_0;
  wire accum1__0_carry_i_9_n_0;
  wire accum1__0_carry_n_0;
  wire accum1__0_carry_n_4;
  wire accum1__30_carry__0_i_10_n_0;
  wire accum1__30_carry__0_i_11_n_0;
  wire accum1__30_carry__0_i_12_n_0;
  wire accum1__30_carry__0_i_13_n_0;
  wire accum1__30_carry__0_i_14_n_0;
  wire accum1__30_carry__0_i_15_n_0;
  wire accum1__30_carry__0_i_16_n_0;
  wire accum1__30_carry__0_i_17_n_0;
  wire accum1__30_carry__0_i_18_n_0;
  wire accum1__30_carry__0_i_1_n_0;
  wire accum1__30_carry__0_i_2_n_0;
  wire accum1__30_carry__0_i_3_n_0;
  wire accum1__30_carry__0_i_4_n_0;
  wire accum1__30_carry__0_i_5_n_0;
  wire accum1__30_carry__0_i_6_n_0;
  wire accum1__30_carry__0_i_7_n_0;
  wire accum1__30_carry__0_i_8_n_0;
  wire accum1__30_carry__0_i_9_n_0;
  wire accum1__30_carry__0_n_0;
  wire accum1__30_carry__0_n_4;
  wire accum1__30_carry__0_n_5;
  wire accum1__30_carry__0_n_6;
  wire accum1__30_carry__0_n_7;
  wire accum1__30_carry__1_i_1_n_0;
  wire accum1__30_carry__1_i_2_n_0;
  wire accum1__30_carry__1_i_3_n_0;
  wire accum1__30_carry__1_i_4_n_0;
  wire accum1__30_carry__1_n_1;
  wire accum1__30_carry__1_n_6;
  wire accum1__30_carry__1_n_7;
  wire accum1__30_carry_i_10_n_0;
  wire accum1__30_carry_i_14_n_0;
  wire accum1__30_carry_i_15_n_0;
  wire accum1__30_carry_i_16_n_0;
  wire accum1__30_carry_i_17_n_0;
  wire accum1__30_carry_i_18_n_0;
  wire accum1__30_carry_i_19_n_0;
  wire accum1__30_carry_i_1_n_0;
  wire accum1__30_carry_i_2_n_0;
  wire accum1__30_carry_i_3_n_0;
  wire accum1__30_carry_i_4_n_0;
  wire accum1__30_carry_i_5_n_0;
  wire accum1__30_carry_i_6_n_0;
  wire accum1__30_carry_i_7_n_0;
  wire accum1__30_carry_i_8_n_0;
  wire accum1__30_carry_i_9_n_0;
  wire accum1__30_carry_n_0;
  wire accum1__30_carry_n_4;
  wire accum1__30_carry_n_5;
  wire accum1__30_carry_n_6;
  wire accum1__30_carry_n_7;
  wire accum1__59_carry__0_i_10_n_0;
  wire accum1__59_carry__0_i_11_n_0;
  wire accum1__59_carry__0_i_1_n_0;
  wire accum1__59_carry__0_i_2_n_0;
  wire accum1__59_carry__0_i_3_n_0;
  wire accum1__59_carry__0_i_4_n_0;
  wire accum1__59_carry__0_i_5_n_0;
  wire accum1__59_carry__0_i_6_n_0;
  wire accum1__59_carry__0_i_7_n_0;
  wire accum1__59_carry__0_i_8_n_0;
  wire accum1__59_carry__0_n_0;
  wire accum1__59_carry__0_n_4;
  wire accum1__59_carry__0_n_5;
  wire accum1__59_carry__0_n_6;
  wire accum1__59_carry__0_n_7;
  wire accum1__59_carry__1_i_1_n_0;
  wire accum1__59_carry__1_i_2_n_0;
  wire accum1__59_carry__1_n_6;
  wire accum1__59_carry__1_n_7;
  wire accum1__59_carry_i_11_n_0;
  wire accum1__59_carry_i_12_n_0;
  wire accum1__59_carry_i_13_n_0;
  wire accum1__59_carry_i_14_n_0;
  wire accum1__59_carry_i_15_n_0;
  wire accum1__59_carry_i_16_n_0;
  wire accum1__59_carry_i_1_n_0;
  wire accum1__59_carry_i_2_n_0;
  wire accum1__59_carry_i_3_n_0;
  wire accum1__59_carry_i_4_n_0;
  wire accum1__59_carry_i_5_n_0;
  wire accum1__59_carry_i_6_n_0;
  wire accum1__59_carry_i_7_n_0;
  wire accum1__59_carry_n_0;
  wire accum1__59_carry_n_4;
  wire accum1__59_carry_n_5;
  wire accum1__59_carry_n_6;
  wire accum1__59_carry_n_7;
  wire accum1__85_carry__0_i_1_n_0;
  wire accum1__85_carry__0_i_2_n_0;
  wire accum1__85_carry__0_i_3_n_0;
  wire accum1__85_carry__0_i_4_n_0;
  wire accum1__85_carry__0_i_5_n_0;
  wire accum1__85_carry__0_i_6_n_0;
  wire accum1__85_carry__0_i_7_n_0;
  wire accum1__85_carry__0_i_8_n_0;
  wire accum1__85_carry__0_n_0;
  wire accum1__85_carry__1_i_1_n_0;
  wire accum1__85_carry__1_i_2_n_0;
  wire accum1__85_carry__1_i_3_n_0;
  wire accum1__85_carry__1_i_4_n_0;
  wire accum1__85_carry__1_i_5_n_0;
  wire accum1__85_carry_i_1_n_0;
  wire accum1__85_carry_i_2_n_0;
  wire accum1__85_carry_i_3_n_0;
  wire accum1__85_carry_i_4_n_0;
  wire accum1__85_carry_i_5_n_0;
  wire accum1__85_carry_i_6_n_0;
  wire accum1__85_carry_i_7_n_0;
  wire accum1__85_carry_i_8_n_0;
  wire accum1__85_carry_n_0;
  wire \accum_reg_n_0_[0] ;
  wire \accum_reg_n_0_[10] ;
  wire \accum_reg_n_0_[11] ;
  wire \accum_reg_n_0_[12] ;
  wire \accum_reg_n_0_[13] ;
  wire \accum_reg_n_0_[14] ;
  wire \accum_reg_n_0_[15] ;
  wire \accum_reg_n_0_[16] ;
  wire \accum_reg_n_0_[17] ;
  wire \accum_reg_n_0_[18] ;
  wire \accum_reg_n_0_[19] ;
  wire \accum_reg_n_0_[1] ;
  wire \accum_reg_n_0_[20] ;
  wire \accum_reg_n_0_[21] ;
  wire \accum_reg_n_0_[22] ;
  wire \accum_reg_n_0_[23] ;
  wire \accum_reg_n_0_[24] ;
  wire \accum_reg_n_0_[25] ;
  wire \accum_reg_n_0_[26] ;
  wire \accum_reg_n_0_[27] ;
  wire \accum_reg_n_0_[28] ;
  wire \accum_reg_n_0_[29] ;
  wire \accum_reg_n_0_[2] ;
  wire \accum_reg_n_0_[30] ;
  wire \accum_reg_n_0_[31] ;
  wire \accum_reg_n_0_[3] ;
  wire \accum_reg_n_0_[4] ;
  wire \accum_reg_n_0_[5] ;
  wire \accum_reg_n_0_[6] ;
  wire \accum_reg_n_0_[7] ;
  wire \accum_reg_n_0_[8] ;
  wire \accum_reg_n_0_[9] ;
  wire clk;
  wire [3:0]compute_cycles;
  wire [31:0]conv_out;
  wire \conv_out[31]_i_1_n_0 ;
  wire core_start;
  wire [3:0]cycles;
  wire \cycles_reg_n_0_[0] ;
  wire \cycles_reg_n_0_[1] ;
  wire \cycles_reg_n_0_[2] ;
  wire \cycles_reg_n_0_[3] ;
  wire done;
  wire done_i_1_n_0;
  wire [0:0]ffs_idx__30;
  wire ffs_valid__0;
  wire [15:0]p_0_in;
  wire p_0_in12_in;
  wire p_0_in15_in;
  wire p_0_in18_in;
  wire p_0_in3_in;
  wire p_0_in6_in;
  wire p_0_in9_in;
  wire p_0_in_0;
  wire [7:0]pixels__63;
  wire [8:0]remaining;
  wire [7:0]\remaining[0]_i_2_0 ;
  wire \remaining[0]_i_3_n_0 ;
  wire [7:0]\remaining[0]_i_4_0 ;
  wire \remaining[0]_i_5_n_0 ;
  wire [7:0]\remaining[1]_i_2_0 ;
  wire \remaining[1]_i_3_n_0 ;
  wire [7:0]\remaining[1]_i_4_0 ;
  wire \remaining[1]_i_5_n_0 ;
  wire [7:0]\remaining[2]_i_2_0 ;
  wire \remaining[2]_i_3_n_0 ;
  wire [7:0]\remaining[2]_i_4_0 ;
  wire \remaining[2]_i_5_n_0 ;
  wire \remaining[3]_i_2_n_0 ;
  wire [7:0]\remaining[3]_i_3_0 ;
  wire \remaining[3]_i_4_n_0 ;
  wire [7:0]\remaining[3]_i_5_0 ;
  wire \remaining[3]_i_6_n_0 ;
  wire \remaining[4]_i_2_n_0 ;
  wire [7:0]\remaining[4]_i_3_0 ;
  wire \remaining[4]_i_4_n_0 ;
  wire [7:0]\remaining[4]_i_5_0 ;
  wire \remaining[4]_i_6_n_0 ;
  wire [7:0]\remaining[5]_i_2_0 ;
  wire \remaining[5]_i_3_n_0 ;
  wire [7:0]\remaining[5]_i_4_0 ;
  wire \remaining[5]_i_5_n_0 ;
  wire \remaining[6]_i_10_n_0 ;
  wire [7:0]\remaining[6]_i_11_0 ;
  wire \remaining[6]_i_12_n_0 ;
  wire \remaining[6]_i_3_n_0 ;
  wire [7:0]\remaining[6]_i_4_0 ;
  wire \remaining[6]_i_5_n_0 ;
  wire \remaining[6]_i_6_n_0 ;
  wire \remaining[6]_i_7_n_0 ;
  wire \remaining[6]_i_8_n_0 ;
  wire \remaining[6]_i_9_n_0 ;
  wire \remaining[7]_i_2_n_0 ;
  wire \remaining[7]_i_3_n_0 ;
  wire [7:0]\remaining[7]_i_4_0 ;
  wire \remaining[7]_i_5_n_0 ;
  wire [7:0]\remaining[7]_i_6_0 ;
  wire \remaining[7]_i_7_n_0 ;
  wire \remaining[8]_i_11_n_0 ;
  wire \remaining[8]_i_4_n_0 ;
  wire [7:0]\remaining[8]_i_5_0 ;
  wire \remaining[8]_i_6_n_0 ;
  wire \remaining[8]_i_7_n_0 ;
  wire \remaining[8]_i_8_n_0 ;
  wire \remaining[8]_i_9_n_0 ;
  wire \remaining_reg_n_0_[0] ;
  wire \remaining_reg_n_0_[1] ;
  wire rst;
  wire [3:0]skip_count;
  wire [3:0]skips;
  wire [3:0]skips0;
  wire \skips[0]_i_2_n_0 ;
  wire \skips[0]_i_3_n_0 ;
  wire \skips[3]_i_3_n_0 ;
  wire \skips[3]_i_4_n_0 ;
  wire \skips[3]_i_5_n_0 ;
  wire [0:0]skips_1;
  wire [1:0]state;
  wire state123_out;
  wire state126_out;
  wire state129_out;
  wire state132_out;
  wire state135_out;
  wire state138_out;
  wire state141_out;
  wire state144_out;
  wire state1__0;
  wire state221_in;
  wire state224_in;
  wire state227_in;
  wire state230_in;
  wire state233_in;
  wire state236_in;
  wire state239_in;
  wire state242_in;
  wire state2__6;
  wire [7:0]weights__63;
  wire [2:0]NLW_accum0_carry_CO_UNCONNECTED;
  wire [2:0]NLW_accum0_carry__0_CO_UNCONNECTED;
  wire [2:0]NLW_accum0_carry__1_CO_UNCONNECTED;
  wire [2:0]NLW_accum0_carry__2_CO_UNCONNECTED;
  wire [2:0]NLW_accum0_carry__3_CO_UNCONNECTED;
  wire [2:0]NLW_accum0_carry__4_CO_UNCONNECTED;
  wire [2:0]NLW_accum0_carry__5_CO_UNCONNECTED;
  wire [3:0]NLW_accum0_carry__6_CO_UNCONNECTED;
  wire [2:0]NLW_accum1__0_carry_CO_UNCONNECTED;
  wire [2:0]NLW_accum1__0_carry__0_CO_UNCONNECTED;
  wire [3:0]NLW_accum1__0_carry__1_CO_UNCONNECTED;
  wire [3:2]NLW_accum1__0_carry__1_O_UNCONNECTED;
  wire [2:0]NLW_accum1__30_carry_CO_UNCONNECTED;
  wire [2:0]NLW_accum1__30_carry__0_CO_UNCONNECTED;
  wire [3:0]NLW_accum1__30_carry__1_CO_UNCONNECTED;
  wire [3:2]NLW_accum1__30_carry__1_O_UNCONNECTED;
  wire [2:0]NLW_accum1__59_carry_CO_UNCONNECTED;
  wire [2:0]NLW_accum1__59_carry__0_CO_UNCONNECTED;
  wire [3:0]NLW_accum1__59_carry__1_CO_UNCONNECTED;
  wire [3:2]NLW_accum1__59_carry__1_O_UNCONNECTED;
  wire [2:0]NLW_accum1__85_carry_CO_UNCONNECTED;
  wire [2:0]NLW_accum1__85_carry__0_CO_UNCONNECTED;
  wire [3:0]NLW_accum1__85_carry__1_CO_UNCONNECTED;

  LUT6 #(
    .INIT(64'h0000000000CC03CE)) 
    \FSM_sequential_state[0]_i_1 
       (.I0(core_start),
        .I1(state[0]),
        .I2(state[1]),
        .I3(\FSM_sequential_state[1]_i_2_n_0 ),
        .I4(\FSM_sequential_state[1]_i_3_n_0 ),
        .I5(rst),
        .O(\FSM_sequential_state[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h000000000FC20CC0)) 
    \FSM_sequential_state[1]_i_1 
       (.I0(core_start),
        .I1(state[0]),
        .I2(state[1]),
        .I3(\FSM_sequential_state[1]_i_2_n_0 ),
        .I4(\FSM_sequential_state[1]_i_3_n_0 ),
        .I5(rst),
        .O(\FSM_sequential_state[1]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h01)) 
    \FSM_sequential_state[1]_i_10 
       (.I0(state1__0),
        .I1(state123_out),
        .I2(state141_out),
        .O(\FSM_sequential_state[1]_i_10_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \FSM_sequential_state[1]_i_11 
       (.I0(\remaining[6]_i_3_n_0 ),
        .I1(\remaining[8]_i_8_n_0 ),
        .I2(\remaining[8]_i_7_n_0 ),
        .O(\FSM_sequential_state[1]_i_11_n_0 ));
  LUT5 #(
    .INIT(32'hA2000000)) 
    \FSM_sequential_state[1]_i_12 
       (.I0(\remaining[8]_i_8_n_0 ),
        .I1(\remaining_reg_n_0_[1] ),
        .I2(\remaining_reg_n_0_[0] ),
        .I3(\remaining[8]_i_7_n_0 ),
        .I4(\remaining[6]_i_3_n_0 ),
        .O(\FSM_sequential_state[1]_i_12_n_0 ));
  LUT6 #(
    .INIT(64'h5555555700000000)) 
    \FSM_sequential_state[1]_i_2 
       (.I0(ffs_valid__0),
        .I1(\FSM_sequential_state[1]_i_4_n_0 ),
        .I2(\FSM_sequential_state[1]_i_5_n_0 ),
        .I3(\FSM_sequential_state[1]_i_6_n_0 ),
        .I4(\FSM_sequential_state[1]_i_7_n_0 ),
        .I5(\FSM_sequential_state[1]_i_8_n_0 ),
        .O(\FSM_sequential_state[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000001000000000)) 
    \FSM_sequential_state[1]_i_3 
       (.I0(state144_out),
        .I1(state138_out),
        .I2(\FSM_sequential_state[1]_i_9_n_0 ),
        .I3(state126_out),
        .I4(state129_out),
        .I5(\FSM_sequential_state[1]_i_10_n_0 ),
        .O(\FSM_sequential_state[1]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF70F0)) 
    \FSM_sequential_state[1]_i_4 
       (.I0(ffs_idx__30),
        .I1(\remaining[6]_i_3_n_0 ),
        .I2(\remaining_reg_n_0_[1] ),
        .I3(\remaining[3]_i_2_n_0 ),
        .I4(p_0_in_0),
        .O(\FSM_sequential_state[1]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h22F2FFFF22F222F2)) 
    \FSM_sequential_state[1]_i_5 
       (.I0(p_0_in15_in),
        .I1(\FSM_sequential_state[1]_i_11_n_0 ),
        .I2(p_0_in18_in),
        .I3(\remaining[8]_i_4_n_0 ),
        .I4(\FSM_sequential_state[1]_i_12_n_0 ),
        .I5(\remaining_reg_n_0_[0] ),
        .O(\FSM_sequential_state[1]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF70F0)) 
    \FSM_sequential_state[1]_i_6 
       (.I0(ffs_idx__30),
        .I1(\remaining[6]_i_3_n_0 ),
        .I2(p_0_in9_in),
        .I3(\remaining[7]_i_2_n_0 ),
        .I4(p_0_in12_in),
        .O(\FSM_sequential_state[1]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h70FFFFFF70707070)) 
    \FSM_sequential_state[1]_i_7 
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(\remaining[7]_i_3_n_0 ),
        .I2(p_0_in3_in),
        .I3(\remaining[7]_i_2_n_0 ),
        .I4(\remaining[4]_i_2_n_0 ),
        .I5(p_0_in6_in),
        .O(\FSM_sequential_state[1]_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \FSM_sequential_state[1]_i_8 
       (.I0(state[0]),
        .I1(state[1]),
        .O(\FSM_sequential_state[1]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \FSM_sequential_state[1]_i_9 
       (.I0(state135_out),
        .I1(state132_out),
        .O(\FSM_sequential_state[1]_i_9_n_0 ));
  (* FSM_ENCODED_STATES = "ST_IDLE:00,ST_COMPUTE:01,ST_DONE:10" *) 
  FDRE \FSM_sequential_state_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_sequential_state[0]_i_1_n_0 ),
        .Q(state[0]),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "ST_IDLE:00,ST_COMPUTE:01,ST_DONE:10" *) 
  FDRE \FSM_sequential_state_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_sequential_state[1]_i_1_n_0 ),
        .Q(state[1]),
        .R(1'b0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry
       (.CI(1'b0),
        .CO({accum0_carry_n_0,NLW_accum0_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({\accum_reg_n_0_[3] ,\accum_reg_n_0_[2] ,\accum_reg_n_0_[1] ,\accum_reg_n_0_[0] }),
        .O(accum0[3:0]),
        .S({accum0_carry_i_1_n_0,accum0_carry_i_2_n_0,accum0_carry_i_3_n_0,accum0_carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__0
       (.CI(accum0_carry_n_0),
        .CO({accum0_carry__0_n_0,NLW_accum0_carry__0_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({\accum_reg_n_0_[7] ,\accum_reg_n_0_[6] ,\accum_reg_n_0_[5] ,\accum_reg_n_0_[4] }),
        .O(accum0[7:4]),
        .S({accum0_carry__0_i_1_n_0,accum0_carry__0_i_2_n_0,accum0_carry__0_i_3_n_0,accum0_carry__0_i_4_n_0}));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_1
       (.I0(\accum_reg_n_0_[7] ),
        .I1(p_0_in[7]),
        .O(accum0_carry__0_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_2
       (.I0(\accum_reg_n_0_[6] ),
        .I1(p_0_in[6]),
        .O(accum0_carry__0_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_3
       (.I0(\accum_reg_n_0_[5] ),
        .I1(p_0_in[5]),
        .O(accum0_carry__0_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_4
       (.I0(\accum_reg_n_0_[4] ),
        .I1(p_0_in[4]),
        .O(accum0_carry__0_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__1
       (.CI(accum0_carry__0_n_0),
        .CO({accum0_carry__1_n_0,NLW_accum0_carry__1_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({\accum_reg_n_0_[11] ,\accum_reg_n_0_[10] ,\accum_reg_n_0_[9] ,\accum_reg_n_0_[8] }),
        .O(accum0[11:8]),
        .S({accum0_carry__1_i_1_n_0,accum0_carry__1_i_2_n_0,accum0_carry__1_i_3_n_0,accum0_carry__1_i_4_n_0}));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_1
       (.I0(\accum_reg_n_0_[11] ),
        .I1(p_0_in[11]),
        .O(accum0_carry__1_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_2
       (.I0(\accum_reg_n_0_[10] ),
        .I1(p_0_in[10]),
        .O(accum0_carry__1_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_3
       (.I0(\accum_reg_n_0_[9] ),
        .I1(p_0_in[9]),
        .O(accum0_carry__1_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_4
       (.I0(\accum_reg_n_0_[8] ),
        .I1(p_0_in[8]),
        .O(accum0_carry__1_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__2
       (.CI(accum0_carry__1_n_0),
        .CO({accum0_carry__2_n_0,NLW_accum0_carry__2_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({p_0_in[15],\accum_reg_n_0_[14] ,\accum_reg_n_0_[13] ,\accum_reg_n_0_[12] }),
        .O(accum0[15:12]),
        .S({accum0_carry__2_i_1_n_0,accum0_carry__2_i_2_n_0,accum0_carry__2_i_3_n_0,accum0_carry__2_i_4_n_0}));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_1
       (.I0(p_0_in[15]),
        .I1(\accum_reg_n_0_[15] ),
        .O(accum0_carry__2_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_2
       (.I0(\accum_reg_n_0_[14] ),
        .I1(p_0_in[14]),
        .O(accum0_carry__2_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_3
       (.I0(\accum_reg_n_0_[13] ),
        .I1(p_0_in[13]),
        .O(accum0_carry__2_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_4
       (.I0(\accum_reg_n_0_[12] ),
        .I1(p_0_in[12]),
        .O(accum0_carry__2_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__3
       (.CI(accum0_carry__2_n_0),
        .CO({accum0_carry__3_n_0,NLW_accum0_carry__3_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({\accum_reg_n_0_[18] ,\accum_reg_n_0_[17] ,\accum_reg_n_0_[16] ,accum0_carry__3_i_1_n_0}),
        .O(accum0[19:16]),
        .S({accum0_carry__3_i_2_n_0,accum0_carry__3_i_3_n_0,accum0_carry__3_i_4_n_0,accum0_carry__3_i_5_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    accum0_carry__3_i_1
       (.I0(p_0_in[15]),
        .O(accum0_carry__3_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__3_i_2
       (.I0(\accum_reg_n_0_[18] ),
        .I1(\accum_reg_n_0_[19] ),
        .O(accum0_carry__3_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__3_i_3
       (.I0(\accum_reg_n_0_[17] ),
        .I1(\accum_reg_n_0_[18] ),
        .O(accum0_carry__3_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__3_i_4
       (.I0(\accum_reg_n_0_[16] ),
        .I1(\accum_reg_n_0_[17] ),
        .O(accum0_carry__3_i_4_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__3_i_5
       (.I0(p_0_in[15]),
        .I1(\accum_reg_n_0_[16] ),
        .O(accum0_carry__3_i_5_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__4
       (.CI(accum0_carry__3_n_0),
        .CO({accum0_carry__4_n_0,NLW_accum0_carry__4_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({\accum_reg_n_0_[22] ,\accum_reg_n_0_[21] ,\accum_reg_n_0_[20] ,\accum_reg_n_0_[19] }),
        .O(accum0[23:20]),
        .S({accum0_carry__4_i_1_n_0,accum0_carry__4_i_2_n_0,accum0_carry__4_i_3_n_0,accum0_carry__4_i_4_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_1
       (.I0(\accum_reg_n_0_[22] ),
        .I1(\accum_reg_n_0_[23] ),
        .O(accum0_carry__4_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_2
       (.I0(\accum_reg_n_0_[21] ),
        .I1(\accum_reg_n_0_[22] ),
        .O(accum0_carry__4_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_3
       (.I0(\accum_reg_n_0_[20] ),
        .I1(\accum_reg_n_0_[21] ),
        .O(accum0_carry__4_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_4
       (.I0(\accum_reg_n_0_[19] ),
        .I1(\accum_reg_n_0_[20] ),
        .O(accum0_carry__4_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__5
       (.CI(accum0_carry__4_n_0),
        .CO({accum0_carry__5_n_0,NLW_accum0_carry__5_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({\accum_reg_n_0_[26] ,\accum_reg_n_0_[25] ,\accum_reg_n_0_[24] ,\accum_reg_n_0_[23] }),
        .O(accum0[27:24]),
        .S({accum0_carry__5_i_1_n_0,accum0_carry__5_i_2_n_0,accum0_carry__5_i_3_n_0,accum0_carry__5_i_4_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_1
       (.I0(\accum_reg_n_0_[26] ),
        .I1(\accum_reg_n_0_[27] ),
        .O(accum0_carry__5_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_2
       (.I0(\accum_reg_n_0_[25] ),
        .I1(\accum_reg_n_0_[26] ),
        .O(accum0_carry__5_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_3
       (.I0(\accum_reg_n_0_[24] ),
        .I1(\accum_reg_n_0_[25] ),
        .O(accum0_carry__5_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_4
       (.I0(\accum_reg_n_0_[23] ),
        .I1(\accum_reg_n_0_[24] ),
        .O(accum0_carry__5_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__6
       (.CI(accum0_carry__5_n_0),
        .CO(NLW_accum0_carry__6_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,\accum_reg_n_0_[29] ,\accum_reg_n_0_[28] ,\accum_reg_n_0_[27] }),
        .O(accum0[31:28]),
        .S({accum0_carry__6_i_1_n_0,accum0_carry__6_i_2_n_0,accum0_carry__6_i_3_n_0,accum0_carry__6_i_4_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_1
       (.I0(\accum_reg_n_0_[30] ),
        .I1(\accum_reg_n_0_[31] ),
        .O(accum0_carry__6_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_2
       (.I0(\accum_reg_n_0_[29] ),
        .I1(\accum_reg_n_0_[30] ),
        .O(accum0_carry__6_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_3
       (.I0(\accum_reg_n_0_[28] ),
        .I1(\accum_reg_n_0_[29] ),
        .O(accum0_carry__6_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_4
       (.I0(\accum_reg_n_0_[27] ),
        .I1(\accum_reg_n_0_[28] ),
        .O(accum0_carry__6_i_4_n_0));
  LUT3 #(
    .INIT(8'h96)) 
    accum0_carry_i_1
       (.I0(\accum_reg_n_0_[3] ),
        .I1(accum1__30_carry_n_7),
        .I2(accum1__0_carry_n_4),
        .O(accum0_carry_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry_i_2
       (.I0(\accum_reg_n_0_[2] ),
        .I1(p_0_in[2]),
        .O(accum0_carry_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry_i_3
       (.I0(\accum_reg_n_0_[1] ),
        .I1(p_0_in[1]),
        .O(accum0_carry_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry_i_4
       (.I0(\accum_reg_n_0_[0] ),
        .I1(p_0_in[0]),
        .O(accum0_carry_i_4_n_0));
  (* OPT_MODIFIED = "PROPCONST" *) 
  CARRY4 accum1__0_carry
       (.CI(1'b0),
        .CO({accum1__0_carry_n_0,NLW_accum1__0_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__0_carry_i_1_n_0,accum1__0_carry_i_2_n_0,accum1__0_carry_i_3_n_0,1'b0}),
        .O({accum1__0_carry_n_4,p_0_in[2:0]}),
        .S({accum1__0_carry_i_4_n_0,accum1__0_carry_i_5_n_0,accum1__0_carry_i_6_n_0,accum1__0_carry_i_7_n_0}));
  CARRY4 accum1__0_carry__0
       (.CI(accum1__0_carry_n_0),
        .CO({accum1__0_carry__0_n_0,NLW_accum1__0_carry__0_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__0_carry__0_i_1_n_0,accum1__0_carry__0_i_2_n_0,accum1__0_carry__0_i_3_n_0,accum1__0_carry__0_i_4_n_0}),
        .O({accum1__0_carry__0_n_4,accum1__0_carry__0_n_5,accum1__0_carry__0_n_6,accum1__0_carry__0_n_7}),
        .S({accum1__0_carry__0_i_5_n_0,accum1__0_carry__0_i_6_n_0,accum1__0_carry__0_i_7_n_0,accum1__0_carry__0_i_8_n_0}));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__0_carry__0_i_1
       (.I0(accum1__0_carry__0_i_9_n_0),
        .I1(accum1__0_carry__0_i_10_n_0),
        .I2(accum1__0_carry__0_i_11_n_0),
        .O(accum1__0_carry__0_i_1_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_10
       (.I0(weights__63[4]),
        .I1(pixels__63[2]),
        .O(accum1__0_carry__0_i_10_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_11
       (.I0(weights__63[5]),
        .I1(pixels__63[1]),
        .O(accum1__0_carry__0_i_11_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_12
       (.I0(weights__63[5]),
        .I1(pixels__63[0]),
        .O(accum1__0_carry__0_i_12_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_13
       (.I0(weights__63[3]),
        .I1(pixels__63[2]),
        .O(accum1__0_carry__0_i_13_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_14
       (.I0(weights__63[4]),
        .I1(pixels__63[1]),
        .O(accum1__0_carry__0_i_14_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_15
       (.I0(weights__63[4]),
        .I1(pixels__63[0]),
        .O(accum1__0_carry__0_i_15_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_16
       (.I0(weights__63[2]),
        .I1(pixels__63[2]),
        .O(accum1__0_carry__0_i_16_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_17
       (.I0(weights__63[3]),
        .I1(pixels__63[1]),
        .O(accum1__0_carry__0_i_17_n_0));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry__0_i_18
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry__0_i_21_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry__0_i_22_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [5]),
        .O(weights__63[5]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry__0_i_19
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry__0_i_23_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry__0_i_24_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [6]),
        .O(weights__63[6]));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__0_carry__0_i_2
       (.I0(accum1__0_carry__0_i_12_n_0),
        .I1(accum1__0_carry__0_i_13_n_0),
        .I2(accum1__0_carry__0_i_14_n_0),
        .O(accum1__0_carry__0_i_2_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_20
       (.I0(weights__63[7]),
        .I1(pixels__63[0]),
        .O(accum1__0_carry__0_i_20_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry__0_i_21
       (.I0(\remaining[3]_i_3_0 [5]),
        .I1(\remaining[1]_i_2_0 [5]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [5]),
        .I5(\remaining[0]_i_2_0 [5]),
        .O(accum1__0_carry__0_i_21_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry__0_i_22
       (.I0(\remaining[7]_i_4_0 [5]),
        .I1(\remaining[5]_i_2_0 [5]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [5]),
        .I5(\remaining[4]_i_3_0 [5]),
        .O(accum1__0_carry__0_i_22_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry__0_i_23
       (.I0(\remaining[3]_i_3_0 [6]),
        .I1(\remaining[1]_i_2_0 [6]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [6]),
        .I5(\remaining[0]_i_2_0 [6]),
        .O(accum1__0_carry__0_i_23_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry__0_i_24
       (.I0(\remaining[7]_i_4_0 [6]),
        .I1(\remaining[5]_i_2_0 [6]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [6]),
        .I5(\remaining[4]_i_3_0 [6]),
        .O(accum1__0_carry__0_i_24_n_0));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__0_carry__0_i_3
       (.I0(accum1__0_carry__0_i_15_n_0),
        .I1(accum1__0_carry__0_i_16_n_0),
        .I2(accum1__0_carry__0_i_17_n_0),
        .O(accum1__0_carry__0_i_3_n_0));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__0_carry__0_i_4
       (.I0(accum1__0_carry_i_8_n_0),
        .I1(accum1__0_carry_i_9_n_0),
        .I2(accum1__0_carry_i_10_n_0),
        .O(accum1__0_carry__0_i_4_n_0));
  LUT6 #(
    .INIT(64'h7888877787777888)) 
    accum1__0_carry__0_i_5
       (.I0(weights__63[5]),
        .I1(pixels__63[2]),
        .I2(weights__63[6]),
        .I3(pixels__63[1]),
        .I4(accum1__0_carry__0_i_1_n_0),
        .I5(accum1__0_carry__0_i_20_n_0),
        .O(accum1__0_carry__0_i_5_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__0_carry__0_i_6
       (.I0(accum1__0_carry__0_i_14_n_0),
        .I1(accum1__0_carry__0_i_13_n_0),
        .I2(accum1__0_carry__0_i_12_n_0),
        .I3(accum1__0_carry__0_i_11_n_0),
        .I4(accum1__0_carry__0_i_10_n_0),
        .I5(accum1__0_carry__0_i_9_n_0),
        .O(accum1__0_carry__0_i_6_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__0_carry__0_i_7
       (.I0(accum1__0_carry__0_i_17_n_0),
        .I1(accum1__0_carry__0_i_16_n_0),
        .I2(accum1__0_carry__0_i_15_n_0),
        .I3(accum1__0_carry__0_i_14_n_0),
        .I4(accum1__0_carry__0_i_13_n_0),
        .I5(accum1__0_carry__0_i_12_n_0),
        .O(accum1__0_carry__0_i_7_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__0_carry__0_i_8
       (.I0(accum1__0_carry_i_10_n_0),
        .I1(accum1__0_carry_i_9_n_0),
        .I2(accum1__0_carry_i_8_n_0),
        .I3(accum1__0_carry__0_i_17_n_0),
        .I4(accum1__0_carry__0_i_16_n_0),
        .I5(accum1__0_carry__0_i_15_n_0),
        .O(accum1__0_carry__0_i_8_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry__0_i_9
       (.I0(weights__63[6]),
        .I1(pixels__63[0]),
        .O(accum1__0_carry__0_i_9_n_0));
  CARRY4 accum1__0_carry__1
       (.CI(accum1__0_carry__0_n_0),
        .CO({NLW_accum1__0_carry__1_CO_UNCONNECTED[3],accum1__0_carry__1_n_1,NLW_accum1__0_carry__1_CO_UNCONNECTED[1:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,accum1__0_carry__1_i_1_n_0,accum1__0_carry__1_i_2_n_0}),
        .O({NLW_accum1__0_carry__1_O_UNCONNECTED[3:2],accum1__0_carry__1_n_6,accum1__0_carry__1_n_7}),
        .S({1'b0,1'b1,accum1__0_carry__1_i_3_n_0,accum1__0_carry__1_i_4_n_0}));
  LUT4 #(
    .INIT(16'h0888)) 
    accum1__0_carry__1_i_1
       (.I0(weights__63[6]),
        .I1(pixels__63[2]),
        .I2(weights__63[7]),
        .I3(pixels__63[1]),
        .O(accum1__0_carry__1_i_1_n_0));
  LUT5 #(
    .INIT(32'hF8888000)) 
    accum1__0_carry__1_i_2
       (.I0(weights__63[5]),
        .I1(pixels__63[2]),
        .I2(weights__63[6]),
        .I3(pixels__63[1]),
        .I4(accum1__0_carry__0_i_20_n_0),
        .O(accum1__0_carry__1_i_2_n_0));
  LUT4 #(
    .INIT(16'h2F5F)) 
    accum1__0_carry__1_i_3
       (.I0(weights__63[6]),
        .I1(pixels__63[1]),
        .I2(pixels__63[2]),
        .I3(weights__63[7]),
        .O(accum1__0_carry__1_i_3_n_0));
  LUT6 #(
    .INIT(64'h2450F30F4BFFC3FF)) 
    accum1__0_carry__1_i_4
       (.I0(pixels__63[0]),
        .I1(weights__63[5]),
        .I2(weights__63[6]),
        .I3(pixels__63[2]),
        .I4(weights__63[7]),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__1_i_4_n_0));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry__1_i_5
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry__1_i_6_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry__1_i_7_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [7]),
        .O(weights__63[7]));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry__1_i_6
       (.I0(\remaining[3]_i_3_0 [7]),
        .I1(\remaining[1]_i_2_0 [7]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [7]),
        .I5(\remaining[0]_i_2_0 [7]),
        .O(accum1__0_carry__1_i_6_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry__1_i_7
       (.I0(\remaining[7]_i_4_0 [7]),
        .I1(\remaining[5]_i_2_0 [7]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [7]),
        .I5(\remaining[4]_i_3_0 [7]),
        .O(accum1__0_carry__1_i_7_n_0));
  LUT3 #(
    .INIT(8'h69)) 
    accum1__0_carry_i_1
       (.I0(accum1__0_carry_i_8_n_0),
        .I1(accum1__0_carry_i_9_n_0),
        .I2(accum1__0_carry_i_10_n_0),
        .O(accum1__0_carry_i_1_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry_i_10
       (.I0(weights__63[2]),
        .I1(pixels__63[1]),
        .O(accum1__0_carry_i_10_n_0));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry_i_11
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry_i_17_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry_i_18_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [0]),
        .O(weights__63[0]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry_i_12
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry_i_19_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry_i_20_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[2]),
        .O(pixels__63[2]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry_i_13
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry_i_21_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry_i_22_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [1]),
        .O(weights__63[1]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry_i_14
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry_i_23_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry_i_24_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[1]),
        .O(pixels__63[1]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry_i_15
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry_i_25_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry_i_26_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[0]),
        .O(pixels__63[0]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__0_carry_i_16
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__0_carry_i_27_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__0_carry_i_28_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [2]),
        .O(weights__63[2]));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_17
       (.I0(\remaining[3]_i_3_0 [0]),
        .I1(\remaining[1]_i_2_0 [0]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [0]),
        .I5(\remaining[0]_i_2_0 [0]),
        .O(accum1__0_carry_i_17_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_18
       (.I0(\remaining[7]_i_4_0 [0]),
        .I1(\remaining[5]_i_2_0 [0]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [0]),
        .I5(\remaining[4]_i_3_0 [0]),
        .O(accum1__0_carry_i_18_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_19
       (.I0(\remaining[3]_i_5_0 [2]),
        .I1(\remaining[1]_i_4_0 [2]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [2]),
        .I5(\remaining[0]_i_4_0 [2]),
        .O(accum1__0_carry_i_19_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    accum1__0_carry_i_2
       (.I0(weights__63[0]),
        .I1(pixels__63[2]),
        .I2(weights__63[1]),
        .I3(pixels__63[1]),
        .O(accum1__0_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_20
       (.I0(\remaining[7]_i_6_0 [2]),
        .I1(\remaining[5]_i_4_0 [2]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [2]),
        .I5(\remaining[4]_i_5_0 [2]),
        .O(accum1__0_carry_i_20_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_21
       (.I0(\remaining[3]_i_3_0 [1]),
        .I1(\remaining[1]_i_2_0 [1]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [1]),
        .I5(\remaining[0]_i_2_0 [1]),
        .O(accum1__0_carry_i_21_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_22
       (.I0(\remaining[7]_i_4_0 [1]),
        .I1(\remaining[5]_i_2_0 [1]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [1]),
        .I5(\remaining[4]_i_3_0 [1]),
        .O(accum1__0_carry_i_22_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_23
       (.I0(\remaining[3]_i_5_0 [1]),
        .I1(\remaining[1]_i_4_0 [1]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [1]),
        .I5(\remaining[0]_i_4_0 [1]),
        .O(accum1__0_carry_i_23_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_24
       (.I0(\remaining[7]_i_6_0 [1]),
        .I1(\remaining[5]_i_4_0 [1]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [1]),
        .I5(\remaining[4]_i_5_0 [1]),
        .O(accum1__0_carry_i_24_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_25
       (.I0(\remaining[3]_i_5_0 [0]),
        .I1(\remaining[1]_i_4_0 [0]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [0]),
        .I5(\remaining[0]_i_4_0 [0]),
        .O(accum1__0_carry_i_25_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_26
       (.I0(\remaining[7]_i_6_0 [0]),
        .I1(\remaining[5]_i_4_0 [0]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [0]),
        .I5(\remaining[4]_i_5_0 [0]),
        .O(accum1__0_carry_i_26_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_27
       (.I0(\remaining[3]_i_3_0 [2]),
        .I1(\remaining[1]_i_2_0 [2]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [2]),
        .I5(\remaining[0]_i_2_0 [2]),
        .O(accum1__0_carry_i_27_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__0_carry_i_28
       (.I0(\remaining[7]_i_4_0 [2]),
        .I1(\remaining[5]_i_2_0 [2]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [2]),
        .I5(\remaining[4]_i_3_0 [2]),
        .O(accum1__0_carry_i_28_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__0_carry_i_3
       (.I0(weights__63[1]),
        .I1(pixels__63[0]),
        .O(accum1__0_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h99C369C399339933)) 
    accum1__0_carry_i_4
       (.I0(weights__63[2]),
        .I1(accum1__0_carry_i_8_n_0),
        .I2(weights__63[1]),
        .I3(pixels__63[1]),
        .I4(weights__63[0]),
        .I5(pixels__63[2]),
        .O(accum1__0_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    accum1__0_carry_i_5
       (.I0(weights__63[0]),
        .I1(pixels__63[2]),
        .I2(weights__63[1]),
        .I3(pixels__63[1]),
        .I4(pixels__63[0]),
        .I5(weights__63[2]),
        .O(accum1__0_carry_i_5_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    accum1__0_carry_i_6
       (.I0(weights__63[1]),
        .I1(pixels__63[0]),
        .I2(pixels__63[1]),
        .I3(weights__63[0]),
        .O(accum1__0_carry_i_6_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__0_carry_i_7
       (.I0(weights__63[0]),
        .I1(pixels__63[0]),
        .O(accum1__0_carry_i_7_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry_i_8
       (.I0(weights__63[3]),
        .I1(pixels__63[0]),
        .O(accum1__0_carry_i_8_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__0_carry_i_9
       (.I0(weights__63[1]),
        .I1(pixels__63[2]),
        .O(accum1__0_carry_i_9_n_0));
  (* OPT_MODIFIED = "PROPCONST" *) 
  CARRY4 accum1__30_carry
       (.CI(1'b0),
        .CO({accum1__30_carry_n_0,NLW_accum1__30_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__30_carry_i_1_n_0,accum1__30_carry_i_2_n_0,accum1__30_carry_i_3_n_0,1'b0}),
        .O({accum1__30_carry_n_4,accum1__30_carry_n_5,accum1__30_carry_n_6,accum1__30_carry_n_7}),
        .S({accum1__30_carry_i_4_n_0,accum1__30_carry_i_5_n_0,accum1__30_carry_i_6_n_0,accum1__30_carry_i_7_n_0}));
  CARRY4 accum1__30_carry__0
       (.CI(accum1__30_carry_n_0),
        .CO({accum1__30_carry__0_n_0,NLW_accum1__30_carry__0_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__30_carry__0_i_1_n_0,accum1__30_carry__0_i_2_n_0,accum1__30_carry__0_i_3_n_0,accum1__30_carry__0_i_4_n_0}),
        .O({accum1__30_carry__0_n_4,accum1__30_carry__0_n_5,accum1__30_carry__0_n_6,accum1__30_carry__0_n_7}),
        .S({accum1__30_carry__0_i_5_n_0,accum1__30_carry__0_i_6_n_0,accum1__30_carry__0_i_7_n_0,accum1__30_carry__0_i_8_n_0}));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__30_carry__0_i_1
       (.I0(accum1__30_carry__0_i_9_n_0),
        .I1(accum1__30_carry__0_i_10_n_0),
        .I2(accum1__30_carry__0_i_11_n_0),
        .O(accum1__30_carry__0_i_1_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_10
       (.I0(weights__63[4]),
        .I1(pixels__63[5]),
        .O(accum1__30_carry__0_i_10_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_11
       (.I0(weights__63[5]),
        .I1(pixels__63[4]),
        .O(accum1__30_carry__0_i_11_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_12
       (.I0(weights__63[5]),
        .I1(pixels__63[3]),
        .O(accum1__30_carry__0_i_12_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_13
       (.I0(weights__63[3]),
        .I1(pixels__63[5]),
        .O(accum1__30_carry__0_i_13_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_14
       (.I0(weights__63[4]),
        .I1(pixels__63[4]),
        .O(accum1__30_carry__0_i_14_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_15
       (.I0(weights__63[4]),
        .I1(pixels__63[3]),
        .O(accum1__30_carry__0_i_15_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_16
       (.I0(weights__63[2]),
        .I1(pixels__63[5]),
        .O(accum1__30_carry__0_i_16_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_17
       (.I0(weights__63[3]),
        .I1(pixels__63[4]),
        .O(accum1__30_carry__0_i_17_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_18
       (.I0(weights__63[5]),
        .I1(pixels__63[5]),
        .O(accum1__30_carry__0_i_18_n_0));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__30_carry__0_i_2
       (.I0(accum1__30_carry__0_i_12_n_0),
        .I1(accum1__30_carry__0_i_13_n_0),
        .I2(accum1__30_carry__0_i_14_n_0),
        .O(accum1__30_carry__0_i_2_n_0));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__30_carry__0_i_3
       (.I0(accum1__30_carry__0_i_15_n_0),
        .I1(accum1__30_carry__0_i_16_n_0),
        .I2(accum1__30_carry__0_i_17_n_0),
        .O(accum1__30_carry__0_i_3_n_0));
  LUT3 #(
    .INIT(8'h17)) 
    accum1__30_carry__0_i_4
       (.I0(accum1__30_carry_i_8_n_0),
        .I1(accum1__30_carry_i_9_n_0),
        .I2(accum1__30_carry_i_10_n_0),
        .O(accum1__30_carry__0_i_4_n_0));
  LUT6 #(
    .INIT(64'h7888877787777888)) 
    accum1__30_carry__0_i_5
       (.I0(weights__63[6]),
        .I1(pixels__63[4]),
        .I2(weights__63[7]),
        .I3(pixels__63[3]),
        .I4(accum1__30_carry__0_i_1_n_0),
        .I5(accum1__30_carry__0_i_18_n_0),
        .O(accum1__30_carry__0_i_5_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__30_carry__0_i_6
       (.I0(accum1__30_carry__0_i_14_n_0),
        .I1(accum1__30_carry__0_i_13_n_0),
        .I2(accum1__30_carry__0_i_12_n_0),
        .I3(accum1__30_carry__0_i_11_n_0),
        .I4(accum1__30_carry__0_i_10_n_0),
        .I5(accum1__30_carry__0_i_9_n_0),
        .O(accum1__30_carry__0_i_6_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__30_carry__0_i_7
       (.I0(accum1__30_carry__0_i_17_n_0),
        .I1(accum1__30_carry__0_i_16_n_0),
        .I2(accum1__30_carry__0_i_15_n_0),
        .I3(accum1__30_carry__0_i_14_n_0),
        .I4(accum1__30_carry__0_i_13_n_0),
        .I5(accum1__30_carry__0_i_12_n_0),
        .O(accum1__30_carry__0_i_7_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__30_carry__0_i_8
       (.I0(accum1__30_carry_i_10_n_0),
        .I1(accum1__30_carry_i_9_n_0),
        .I2(accum1__30_carry_i_8_n_0),
        .I3(accum1__30_carry__0_i_17_n_0),
        .I4(accum1__30_carry__0_i_16_n_0),
        .I5(accum1__30_carry__0_i_15_n_0),
        .O(accum1__30_carry__0_i_8_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry__0_i_9
       (.I0(weights__63[6]),
        .I1(pixels__63[3]),
        .O(accum1__30_carry__0_i_9_n_0));
  CARRY4 accum1__30_carry__1
       (.CI(accum1__30_carry__0_n_0),
        .CO({NLW_accum1__30_carry__1_CO_UNCONNECTED[3],accum1__30_carry__1_n_1,NLW_accum1__30_carry__1_CO_UNCONNECTED[1:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,accum1__30_carry__1_i_1_n_0,accum1__30_carry__1_i_2_n_0}),
        .O({NLW_accum1__30_carry__1_O_UNCONNECTED[3:2],accum1__30_carry__1_n_6,accum1__30_carry__1_n_7}),
        .S({1'b0,1'b1,accum1__30_carry__1_i_3_n_0,accum1__30_carry__1_i_4_n_0}));
  LUT4 #(
    .INIT(16'h7000)) 
    accum1__30_carry__1_i_1
       (.I0(weights__63[7]),
        .I1(pixels__63[4]),
        .I2(weights__63[6]),
        .I3(pixels__63[5]),
        .O(accum1__30_carry__1_i_1_n_0));
  LUT5 #(
    .INIT(32'h08888FFF)) 
    accum1__30_carry__1_i_2
       (.I0(weights__63[6]),
        .I1(pixels__63[4]),
        .I2(weights__63[7]),
        .I3(pixels__63[3]),
        .I4(accum1__30_carry__0_i_18_n_0),
        .O(accum1__30_carry__1_i_2_n_0));
  LUT4 #(
    .INIT(16'h2F5F)) 
    accum1__30_carry__1_i_3
       (.I0(weights__63[6]),
        .I1(pixels__63[4]),
        .I2(pixels__63[5]),
        .I3(weights__63[7]),
        .O(accum1__30_carry__1_i_3_n_0));
  LUT6 #(
    .INIT(64'h2450F30F4BFFC3FF)) 
    accum1__30_carry__1_i_4
       (.I0(pixels__63[3]),
        .I1(weights__63[5]),
        .I2(weights__63[6]),
        .I3(pixels__63[5]),
        .I4(weights__63[7]),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__1_i_4_n_0));
  LUT3 #(
    .INIT(8'h69)) 
    accum1__30_carry_i_1
       (.I0(accum1__30_carry_i_8_n_0),
        .I1(accum1__30_carry_i_9_n_0),
        .I2(accum1__30_carry_i_10_n_0),
        .O(accum1__30_carry_i_1_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry_i_10
       (.I0(weights__63[2]),
        .I1(pixels__63[4]),
        .O(accum1__30_carry_i_10_n_0));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__30_carry_i_11
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__30_carry_i_14_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__30_carry_i_15_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[4]),
        .O(pixels__63[4]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__30_carry_i_12
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__30_carry_i_16_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__30_carry_i_17_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[5]),
        .O(pixels__63[5]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__30_carry_i_13
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__30_carry_i_18_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__30_carry_i_19_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[3]),
        .O(pixels__63[3]));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__30_carry_i_14
       (.I0(\remaining[3]_i_5_0 [4]),
        .I1(\remaining[1]_i_4_0 [4]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [4]),
        .I5(\remaining[0]_i_4_0 [4]),
        .O(accum1__30_carry_i_14_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__30_carry_i_15
       (.I0(\remaining[7]_i_6_0 [4]),
        .I1(\remaining[5]_i_4_0 [4]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [4]),
        .I5(\remaining[4]_i_5_0 [4]),
        .O(accum1__30_carry_i_15_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__30_carry_i_16
       (.I0(\remaining[3]_i_5_0 [5]),
        .I1(\remaining[1]_i_4_0 [5]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [5]),
        .I5(\remaining[0]_i_4_0 [5]),
        .O(accum1__30_carry_i_16_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__30_carry_i_17
       (.I0(\remaining[7]_i_6_0 [5]),
        .I1(\remaining[5]_i_4_0 [5]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [5]),
        .I5(\remaining[4]_i_5_0 [5]),
        .O(accum1__30_carry_i_17_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__30_carry_i_18
       (.I0(\remaining[3]_i_5_0 [3]),
        .I1(\remaining[1]_i_4_0 [3]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [3]),
        .I5(\remaining[0]_i_4_0 [3]),
        .O(accum1__30_carry_i_18_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__30_carry_i_19
       (.I0(\remaining[7]_i_6_0 [3]),
        .I1(\remaining[5]_i_4_0 [3]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [3]),
        .I5(\remaining[4]_i_5_0 [3]),
        .O(accum1__30_carry_i_19_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    accum1__30_carry_i_2
       (.I0(pixels__63[4]),
        .I1(weights__63[1]),
        .I2(pixels__63[5]),
        .I3(weights__63[0]),
        .O(accum1__30_carry_i_2_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__30_carry_i_3
       (.I0(weights__63[1]),
        .I1(pixels__63[3]),
        .O(accum1__30_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h96999999CC333333)) 
    accum1__30_carry_i_4
       (.I0(weights__63[2]),
        .I1(accum1__30_carry_i_8_n_0),
        .I2(weights__63[0]),
        .I3(weights__63[1]),
        .I4(pixels__63[5]),
        .I5(pixels__63[4]),
        .O(accum1__30_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    accum1__30_carry_i_5
       (.I0(pixels__63[4]),
        .I1(weights__63[1]),
        .I2(pixels__63[5]),
        .I3(weights__63[0]),
        .I4(pixels__63[3]),
        .I5(weights__63[2]),
        .O(accum1__30_carry_i_5_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    accum1__30_carry_i_6
       (.I0(weights__63[1]),
        .I1(pixels__63[3]),
        .I2(pixels__63[4]),
        .I3(weights__63[0]),
        .O(accum1__30_carry_i_6_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__30_carry_i_7
       (.I0(weights__63[0]),
        .I1(pixels__63[3]),
        .O(accum1__30_carry_i_7_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry_i_8
       (.I0(weights__63[3]),
        .I1(pixels__63[3]),
        .O(accum1__30_carry_i_8_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__30_carry_i_9
       (.I0(weights__63[1]),
        .I1(pixels__63[5]),
        .O(accum1__30_carry_i_9_n_0));
  (* OPT_MODIFIED = "PROPCONST" *) 
  CARRY4 accum1__59_carry
       (.CI(1'b0),
        .CO({accum1__59_carry_n_0,NLW_accum1__59_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__59_carry_i_1_n_0,accum1__59_carry_i_2_n_0,accum1__59_carry_i_3_n_0,1'b0}),
        .O({accum1__59_carry_n_4,accum1__59_carry_n_5,accum1__59_carry_n_6,accum1__59_carry_n_7}),
        .S({accum1__59_carry_i_4_n_0,accum1__59_carry_i_5_n_0,accum1__59_carry_i_6_n_0,accum1__59_carry_i_7_n_0}));
  CARRY4 accum1__59_carry__0
       (.CI(accum1__59_carry_n_0),
        .CO({accum1__59_carry__0_n_0,NLW_accum1__59_carry__0_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__59_carry__0_i_1_n_0,accum1__59_carry__0_i_2_n_0,accum1__59_carry__0_i_3_n_0,accum1__59_carry__0_i_4_n_0}),
        .O({accum1__59_carry__0_n_4,accum1__59_carry__0_n_5,accum1__59_carry__0_n_6,accum1__59_carry__0_n_7}),
        .S({accum1__59_carry__0_i_5_n_0,accum1__59_carry__0_i_6_n_0,accum1__59_carry__0_i_7_n_0,accum1__59_carry__0_i_8_n_0}));
  LUT4 #(
    .INIT(16'h7000)) 
    accum1__59_carry__0_i_1
       (.I0(weights__63[5]),
        .I1(pixels__63[7]),
        .I2(weights__63[6]),
        .I3(pixels__63[6]),
        .O(accum1__59_carry__0_i_1_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry__0_i_10
       (.I0(\remaining[3]_i_3_0 [4]),
        .I1(\remaining[1]_i_2_0 [4]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [4]),
        .I5(\remaining[0]_i_2_0 [4]),
        .O(accum1__59_carry__0_i_10_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry__0_i_11
       (.I0(\remaining[7]_i_4_0 [4]),
        .I1(\remaining[5]_i_2_0 [4]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [4]),
        .I5(\remaining[4]_i_3_0 [4]),
        .O(accum1__59_carry__0_i_11_n_0));
  LUT4 #(
    .INIT(16'h7000)) 
    accum1__59_carry__0_i_2
       (.I0(weights__63[4]),
        .I1(pixels__63[7]),
        .I2(weights__63[5]),
        .I3(pixels__63[6]),
        .O(accum1__59_carry__0_i_2_n_0));
  LUT4 #(
    .INIT(16'h7000)) 
    accum1__59_carry__0_i_3
       (.I0(weights__63[3]),
        .I1(pixels__63[7]),
        .I2(weights__63[4]),
        .I3(pixels__63[6]),
        .O(accum1__59_carry__0_i_3_n_0));
  LUT4 #(
    .INIT(16'h7000)) 
    accum1__59_carry__0_i_4
       (.I0(weights__63[2]),
        .I1(pixels__63[7]),
        .I2(weights__63[3]),
        .I3(pixels__63[6]),
        .O(accum1__59_carry__0_i_4_n_0));
  LUT5 #(
    .INIT(32'h738CC0C0)) 
    accum1__59_carry__0_i_5
       (.I0(weights__63[5]),
        .I1(weights__63[6]),
        .I2(pixels__63[7]),
        .I3(weights__63[7]),
        .I4(pixels__63[6]),
        .O(accum1__59_carry__0_i_5_n_0));
  LUT5 #(
    .INIT(32'h8C733F3F)) 
    accum1__59_carry__0_i_6
       (.I0(weights__63[4]),
        .I1(weights__63[5]),
        .I2(pixels__63[7]),
        .I3(weights__63[6]),
        .I4(pixels__63[6]),
        .O(accum1__59_carry__0_i_6_n_0));
  LUT5 #(
    .INIT(32'h8C733F3F)) 
    accum1__59_carry__0_i_7
       (.I0(weights__63[3]),
        .I1(weights__63[4]),
        .I2(pixels__63[7]),
        .I3(weights__63[5]),
        .I4(pixels__63[6]),
        .O(accum1__59_carry__0_i_7_n_0));
  LUT5 #(
    .INIT(32'h8C733F3F)) 
    accum1__59_carry__0_i_8
       (.I0(weights__63[2]),
        .I1(weights__63[3]),
        .I2(pixels__63[7]),
        .I3(weights__63[4]),
        .I4(pixels__63[6]),
        .O(accum1__59_carry__0_i_8_n_0));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__59_carry__0_i_9
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__59_carry__0_i_10_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__59_carry__0_i_11_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [4]),
        .O(weights__63[4]));
  CARRY4 accum1__59_carry__1
       (.CI(accum1__59_carry__0_n_0),
        .CO(NLW_accum1__59_carry__1_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,accum1__59_carry__1_i_1_n_0}),
        .O({NLW_accum1__59_carry__1_O_UNCONNECTED[3:2],accum1__59_carry__1_n_6,accum1__59_carry__1_n_7}),
        .S({1'b0,1'b0,1'b1,accum1__59_carry__1_i_2_n_0}));
  LUT4 #(
    .INIT(16'h0777)) 
    accum1__59_carry__1_i_1
       (.I0(weights__63[6]),
        .I1(pixels__63[7]),
        .I2(weights__63[7]),
        .I3(pixels__63[6]),
        .O(accum1__59_carry__1_i_1_n_0));
  LUT4 #(
    .INIT(16'hE53F)) 
    accum1__59_carry__1_i_2
       (.I0(pixels__63[6]),
        .I1(weights__63[6]),
        .I2(pixels__63[7]),
        .I3(weights__63[7]),
        .O(accum1__59_carry__1_i_2_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__59_carry_i_1
       (.I0(weights__63[1]),
        .I1(pixels__63[7]),
        .O(accum1__59_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__59_carry_i_10
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__59_carry_i_15_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__59_carry_i_16_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[6]),
        .O(pixels__63[6]));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry_i_11
       (.I0(\remaining[3]_i_5_0 [7]),
        .I1(\remaining[1]_i_4_0 [7]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [7]),
        .I5(\remaining[0]_i_4_0 [7]),
        .O(accum1__59_carry_i_11_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry_i_12
       (.I0(\remaining[7]_i_6_0 [7]),
        .I1(\remaining[5]_i_4_0 [7]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [7]),
        .I5(\remaining[4]_i_5_0 [7]),
        .O(accum1__59_carry_i_12_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry_i_13
       (.I0(\remaining[3]_i_3_0 [3]),
        .I1(\remaining[1]_i_2_0 [3]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_2_0 [3]),
        .I5(\remaining[0]_i_2_0 [3]),
        .O(accum1__59_carry_i_13_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry_i_14
       (.I0(\remaining[7]_i_4_0 [3]),
        .I1(\remaining[5]_i_2_0 [3]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_4_0 [3]),
        .I5(\remaining[4]_i_3_0 [3]),
        .O(accum1__59_carry_i_14_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry_i_15
       (.I0(\remaining[3]_i_5_0 [6]),
        .I1(\remaining[1]_i_4_0 [6]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[2]_i_4_0 [6]),
        .I5(\remaining[0]_i_4_0 [6]),
        .O(accum1__59_carry_i_15_n_0));
  LUT6 #(
    .INIT(64'hCAFFCAF0CA0FCA00)) 
    accum1__59_carry_i_16
       (.I0(\remaining[7]_i_6_0 [6]),
        .I1(\remaining[5]_i_4_0 [6]),
        .I2(\remaining[6]_i_3_n_0 ),
        .I3(ffs_idx__30),
        .I4(\remaining[6]_i_11_0 [6]),
        .I5(\remaining[4]_i_5_0 [6]),
        .O(accum1__59_carry_i_16_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__59_carry_i_2
       (.I0(weights__63[1]),
        .I1(pixels__63[7]),
        .O(accum1__59_carry_i_2_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    accum1__59_carry_i_3
       (.I0(weights__63[0]),
        .I1(pixels__63[7]),
        .O(accum1__59_carry_i_3_n_0));
  LUT5 #(
    .INIT(32'hB7484848)) 
    accum1__59_carry_i_4
       (.I0(weights__63[1]),
        .I1(pixels__63[7]),
        .I2(weights__63[2]),
        .I3(weights__63[3]),
        .I4(pixels__63[6]),
        .O(accum1__59_carry_i_4_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    accum1__59_carry_i_5
       (.I0(weights__63[1]),
        .I1(pixels__63[7]),
        .I2(pixels__63[6]),
        .I3(weights__63[2]),
        .O(accum1__59_carry_i_5_n_0));
  LUT4 #(
    .INIT(16'h8777)) 
    accum1__59_carry_i_6
       (.I0(weights__63[0]),
        .I1(pixels__63[7]),
        .I2(pixels__63[6]),
        .I3(weights__63[1]),
        .O(accum1__59_carry_i_6_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__59_carry_i_7
       (.I0(weights__63[0]),
        .I1(pixels__63[6]),
        .O(accum1__59_carry_i_7_n_0));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__59_carry_i_8
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__59_carry_i_11_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__59_carry_i_12_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(Q[7]),
        .O(pixels__63[7]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    accum1__59_carry_i_9
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(accum1__59_carry_i_13_n_0),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(accum1__59_carry_i_14_n_0),
        .I4(\remaining[8]_i_4_n_0 ),
        .I5(\remaining[8]_i_5_0 [3]),
        .O(weights__63[3]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum1__85_carry
       (.CI(1'b0),
        .CO({accum1__85_carry_n_0,NLW_accum1__85_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__85_carry_i_1_n_0,accum1__85_carry_i_2_n_0,accum1__85_carry_i_3_n_0,accum1__85_carry_i_4_n_0}),
        .O(p_0_in[7:4]),
        .S({accum1__85_carry_i_5_n_0,accum1__85_carry_i_6_n_0,accum1__85_carry_i_7_n_0,accum1__85_carry_i_8_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum1__85_carry__0
       (.CI(accum1__85_carry_n_0),
        .CO({accum1__85_carry__0_n_0,NLW_accum1__85_carry__0_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum1__85_carry__0_i_1_n_0,accum1__85_carry__0_i_2_n_0,accum1__85_carry__0_i_3_n_0,accum1__85_carry__0_i_4_n_0}),
        .O(p_0_in[11:8]),
        .S({accum1__85_carry__0_i_5_n_0,accum1__85_carry__0_i_6_n_0,accum1__85_carry__0_i_7_n_0,accum1__85_carry__0_i_8_n_0}));
  LUT3 #(
    .INIT(8'hE8)) 
    accum1__85_carry__0_i_1
       (.I0(accum1__0_carry__1_n_1),
        .I1(accum1__59_carry__0_n_7),
        .I2(accum1__30_carry__0_n_4),
        .O(accum1__85_carry__0_i_1_n_0));
  LUT3 #(
    .INIT(8'hE8)) 
    accum1__85_carry__0_i_2
       (.I0(accum1__0_carry__1_n_6),
        .I1(accum1__59_carry_n_4),
        .I2(accum1__30_carry__0_n_5),
        .O(accum1__85_carry__0_i_2_n_0));
  LUT3 #(
    .INIT(8'hE8)) 
    accum1__85_carry__0_i_3
       (.I0(accum1__0_carry__1_n_7),
        .I1(accum1__59_carry_n_5),
        .I2(accum1__30_carry__0_n_6),
        .O(accum1__85_carry__0_i_3_n_0));
  LUT3 #(
    .INIT(8'hE8)) 
    accum1__85_carry__0_i_4
       (.I0(accum1__0_carry__0_n_4),
        .I1(accum1__59_carry_n_6),
        .I2(accum1__30_carry__0_n_7),
        .O(accum1__85_carry__0_i_4_n_0));
  LUT5 #(
    .INIT(32'hE81717E8)) 
    accum1__85_carry__0_i_5
       (.I0(accum1__30_carry__0_n_4),
        .I1(accum1__59_carry__0_n_7),
        .I2(accum1__0_carry__1_n_1),
        .I3(accum1__59_carry__0_n_6),
        .I4(accum1__30_carry__1_n_7),
        .O(accum1__85_carry__0_i_5_n_0));
  LUT4 #(
    .INIT(16'h6996)) 
    accum1__85_carry__0_i_6
       (.I0(accum1__85_carry__0_i_2_n_0),
        .I1(accum1__30_carry__0_n_4),
        .I2(accum1__59_carry__0_n_7),
        .I3(accum1__0_carry__1_n_1),
        .O(accum1__85_carry__0_i_6_n_0));
  LUT4 #(
    .INIT(16'h6996)) 
    accum1__85_carry__0_i_7
       (.I0(accum1__0_carry__1_n_6),
        .I1(accum1__59_carry_n_4),
        .I2(accum1__30_carry__0_n_5),
        .I3(accum1__85_carry__0_i_3_n_0),
        .O(accum1__85_carry__0_i_7_n_0));
  LUT4 #(
    .INIT(16'h6996)) 
    accum1__85_carry__0_i_8
       (.I0(accum1__0_carry__1_n_7),
        .I1(accum1__59_carry_n_5),
        .I2(accum1__30_carry__0_n_6),
        .I3(accum1__85_carry__0_i_4_n_0),
        .O(accum1__85_carry__0_i_8_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum1__85_carry__1
       (.CI(accum1__85_carry__0_n_0),
        .CO(NLW_accum1__85_carry__1_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,accum1__59_carry__1_n_7,accum1__85_carry__1_i_1_n_0,accum1__85_carry__1_i_2_n_0}),
        .O(p_0_in[15:12]),
        .S({accum1__59_carry__1_n_6,accum1__85_carry__1_i_3_n_0,accum1__85_carry__1_i_4_n_0,accum1__85_carry__1_i_5_n_0}));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__85_carry__1_i_1
       (.I0(accum1__59_carry__0_n_5),
        .I1(accum1__30_carry__1_n_6),
        .O(accum1__85_carry__1_i_1_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__85_carry__1_i_2
       (.I0(accum1__59_carry__0_n_6),
        .I1(accum1__30_carry__1_n_7),
        .O(accum1__85_carry__1_i_2_n_0));
  LUT3 #(
    .INIT(8'h78)) 
    accum1__85_carry__1_i_3
       (.I0(accum1__30_carry__1_n_1),
        .I1(accum1__59_carry__0_n_4),
        .I2(accum1__59_carry__1_n_7),
        .O(accum1__85_carry__1_i_3_n_0));
  LUT4 #(
    .INIT(16'h8778)) 
    accum1__85_carry__1_i_4
       (.I0(accum1__30_carry__1_n_6),
        .I1(accum1__59_carry__0_n_5),
        .I2(accum1__59_carry__0_n_4),
        .I3(accum1__30_carry__1_n_1),
        .O(accum1__85_carry__1_i_4_n_0));
  LUT4 #(
    .INIT(16'h8778)) 
    accum1__85_carry__1_i_5
       (.I0(accum1__30_carry__1_n_7),
        .I1(accum1__59_carry__0_n_6),
        .I2(accum1__59_carry__0_n_5),
        .I3(accum1__30_carry__1_n_6),
        .O(accum1__85_carry__1_i_5_n_0));
  (* HLUTNM = "lutpair1" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    accum1__85_carry_i_1
       (.I0(accum1__0_carry__0_n_5),
        .I1(accum1__59_carry_n_7),
        .I2(accum1__30_carry_n_4),
        .O(accum1__85_carry_i_1_n_0));
  (* HLUTNM = "lutpair0" *) 
  LUT2 #(
    .INIT(4'h8)) 
    accum1__85_carry_i_2
       (.I0(accum1__30_carry_n_5),
        .I1(accum1__0_carry__0_n_6),
        .O(accum1__85_carry_i_2_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__85_carry_i_3
       (.I0(accum1__30_carry_n_6),
        .I1(accum1__0_carry__0_n_7),
        .O(accum1__85_carry_i_3_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    accum1__85_carry_i_4
       (.I0(accum1__30_carry_n_7),
        .I1(accum1__0_carry_n_4),
        .O(accum1__85_carry_i_4_n_0));
  LUT4 #(
    .INIT(16'h6996)) 
    accum1__85_carry_i_5
       (.I0(accum1__0_carry__0_n_4),
        .I1(accum1__59_carry_n_6),
        .I2(accum1__30_carry__0_n_7),
        .I3(accum1__85_carry_i_1_n_0),
        .O(accum1__85_carry_i_5_n_0));
  (* HLUTNM = "lutpair1" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    accum1__85_carry_i_6
       (.I0(accum1__0_carry__0_n_5),
        .I1(accum1__59_carry_n_7),
        .I2(accum1__30_carry_n_4),
        .I3(accum1__85_carry_i_2_n_0),
        .O(accum1__85_carry_i_6_n_0));
  (* HLUTNM = "lutpair0" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    accum1__85_carry_i_7
       (.I0(accum1__30_carry_n_5),
        .I1(accum1__0_carry__0_n_6),
        .I2(accum1__0_carry__0_n_7),
        .I3(accum1__30_carry_n_6),
        .O(accum1__85_carry_i_7_n_0));
  LUT4 #(
    .INIT(16'h8778)) 
    accum1__85_carry_i_8
       (.I0(accum1__0_carry_n_4),
        .I1(accum1__30_carry_n_7),
        .I2(accum1__30_carry_n_6),
        .I3(accum1__0_carry__0_n_7),
        .O(accum1__85_carry_i_8_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    \accum[0]_i_1 
       (.I0(state[0]),
        .I1(accum0[0]),
        .O(accum0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[10]_i_1 
       (.I0(state[0]),
        .I1(accum0[10]),
        .O(accum0_in[10]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[11]_i_1 
       (.I0(state[0]),
        .I1(accum0[11]),
        .O(accum0_in[11]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[12]_i_1 
       (.I0(state[0]),
        .I1(accum0[12]),
        .O(accum0_in[12]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[13]_i_1 
       (.I0(state[0]),
        .I1(accum0[13]),
        .O(accum0_in[13]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[14]_i_1 
       (.I0(state[0]),
        .I1(accum0[14]),
        .O(accum0_in[14]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[15]_i_1 
       (.I0(state[0]),
        .I1(accum0[15]),
        .O(accum0_in[15]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[16]_i_1 
       (.I0(state[0]),
        .I1(accum0[16]),
        .O(accum0_in[16]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[17]_i_1 
       (.I0(state[0]),
        .I1(accum0[17]),
        .O(accum0_in[17]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[18]_i_1 
       (.I0(state[0]),
        .I1(accum0[18]),
        .O(accum0_in[18]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[19]_i_1 
       (.I0(state[0]),
        .I1(accum0[19]),
        .O(accum0_in[19]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[1]_i_1 
       (.I0(state[0]),
        .I1(accum0[1]),
        .O(accum0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[20]_i_1 
       (.I0(state[0]),
        .I1(accum0[20]),
        .O(accum0_in[20]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[21]_i_1 
       (.I0(state[0]),
        .I1(accum0[21]),
        .O(accum0_in[21]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[22]_i_1 
       (.I0(state[0]),
        .I1(accum0[22]),
        .O(accum0_in[22]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[23]_i_1 
       (.I0(state[0]),
        .I1(accum0[23]),
        .O(accum0_in[23]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[24]_i_1 
       (.I0(state[0]),
        .I1(accum0[24]),
        .O(accum0_in[24]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[25]_i_1 
       (.I0(state[0]),
        .I1(accum0[25]),
        .O(accum0_in[25]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[26]_i_1 
       (.I0(state[0]),
        .I1(accum0[26]),
        .O(accum0_in[26]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[27]_i_1 
       (.I0(state[0]),
        .I1(accum0[27]),
        .O(accum0_in[27]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[28]_i_1 
       (.I0(state[0]),
        .I1(accum0[28]),
        .O(accum0_in[28]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[29]_i_1 
       (.I0(state[0]),
        .I1(accum0[29]),
        .O(accum0_in[29]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[2]_i_1 
       (.I0(state[0]),
        .I1(accum0[2]),
        .O(accum0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[30]_i_1 
       (.I0(state[0]),
        .I1(accum0[30]),
        .O(accum0_in[30]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[31]_i_1 
       (.I0(state[0]),
        .I1(accum0[31]),
        .O(accum0_in[31]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[3]_i_1 
       (.I0(state[0]),
        .I1(accum0[3]),
        .O(accum0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[4]_i_1 
       (.I0(state[0]),
        .I1(accum0[4]),
        .O(accum0_in[4]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[5]_i_1 
       (.I0(state[0]),
        .I1(accum0[5]),
        .O(accum0_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[6]_i_1 
       (.I0(state[0]),
        .I1(accum0[6]),
        .O(accum0_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[7]_i_1 
       (.I0(state[0]),
        .I1(accum0[7]),
        .O(accum0_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[8]_i_1 
       (.I0(state[0]),
        .I1(accum0[8]),
        .O(accum0_in[8]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[9]_i_1 
       (.I0(state[0]),
        .I1(accum0[9]),
        .O(accum0_in[9]));
  FDRE \accum_reg[0] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[0]),
        .Q(\accum_reg_n_0_[0] ),
        .R(rst));
  FDRE \accum_reg[10] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[10]),
        .Q(\accum_reg_n_0_[10] ),
        .R(rst));
  FDRE \accum_reg[11] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[11]),
        .Q(\accum_reg_n_0_[11] ),
        .R(rst));
  FDRE \accum_reg[12] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[12]),
        .Q(\accum_reg_n_0_[12] ),
        .R(rst));
  FDRE \accum_reg[13] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[13]),
        .Q(\accum_reg_n_0_[13] ),
        .R(rst));
  FDRE \accum_reg[14] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[14]),
        .Q(\accum_reg_n_0_[14] ),
        .R(rst));
  FDRE \accum_reg[15] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[15]),
        .Q(\accum_reg_n_0_[15] ),
        .R(rst));
  FDRE \accum_reg[16] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[16]),
        .Q(\accum_reg_n_0_[16] ),
        .R(rst));
  FDRE \accum_reg[17] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[17]),
        .Q(\accum_reg_n_0_[17] ),
        .R(rst));
  FDRE \accum_reg[18] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[18]),
        .Q(\accum_reg_n_0_[18] ),
        .R(rst));
  FDRE \accum_reg[19] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[19]),
        .Q(\accum_reg_n_0_[19] ),
        .R(rst));
  FDRE \accum_reg[1] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[1]),
        .Q(\accum_reg_n_0_[1] ),
        .R(rst));
  FDRE \accum_reg[20] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[20]),
        .Q(\accum_reg_n_0_[20] ),
        .R(rst));
  FDRE \accum_reg[21] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[21]),
        .Q(\accum_reg_n_0_[21] ),
        .R(rst));
  FDRE \accum_reg[22] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[22]),
        .Q(\accum_reg_n_0_[22] ),
        .R(rst));
  FDRE \accum_reg[23] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[23]),
        .Q(\accum_reg_n_0_[23] ),
        .R(rst));
  FDRE \accum_reg[24] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[24]),
        .Q(\accum_reg_n_0_[24] ),
        .R(rst));
  FDRE \accum_reg[25] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[25]),
        .Q(\accum_reg_n_0_[25] ),
        .R(rst));
  FDRE \accum_reg[26] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[26]),
        .Q(\accum_reg_n_0_[26] ),
        .R(rst));
  FDRE \accum_reg[27] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[27]),
        .Q(\accum_reg_n_0_[27] ),
        .R(rst));
  FDRE \accum_reg[28] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[28]),
        .Q(\accum_reg_n_0_[28] ),
        .R(rst));
  FDRE \accum_reg[29] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[29]),
        .Q(\accum_reg_n_0_[29] ),
        .R(rst));
  FDRE \accum_reg[2] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[2]),
        .Q(\accum_reg_n_0_[2] ),
        .R(rst));
  FDRE \accum_reg[30] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[30]),
        .Q(\accum_reg_n_0_[30] ),
        .R(rst));
  FDRE \accum_reg[31] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[31]),
        .Q(\accum_reg_n_0_[31] ),
        .R(rst));
  FDRE \accum_reg[3] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[3]),
        .Q(\accum_reg_n_0_[3] ),
        .R(rst));
  FDRE \accum_reg[4] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[4]),
        .Q(\accum_reg_n_0_[4] ),
        .R(rst));
  FDRE \accum_reg[5] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[5]),
        .Q(\accum_reg_n_0_[5] ),
        .R(rst));
  FDRE \accum_reg[6] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[6]),
        .Q(\accum_reg_n_0_[6] ),
        .R(rst));
  FDRE \accum_reg[7] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[7]),
        .Q(\accum_reg_n_0_[7] ),
        .R(rst));
  FDRE \accum_reg[8] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[8]),
        .Q(\accum_reg_n_0_[8] ),
        .R(rst));
  FDRE \accum_reg[9] 
       (.C(clk),
        .CE(accum),
        .D(accum0_in[9]),
        .Q(\accum_reg_n_0_[9] ),
        .R(rst));
  FDRE \compute_cycles_reg[0] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\cycles_reg_n_0_[0] ),
        .Q(compute_cycles[0]),
        .R(rst));
  FDRE \compute_cycles_reg[1] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\cycles_reg_n_0_[1] ),
        .Q(compute_cycles[1]),
        .R(rst));
  FDRE \compute_cycles_reg[2] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\cycles_reg_n_0_[2] ),
        .Q(compute_cycles[2]),
        .R(rst));
  FDRE \compute_cycles_reg[3] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\cycles_reg_n_0_[3] ),
        .Q(compute_cycles[3]),
        .R(rst));
  LUT2 #(
    .INIT(4'h2)) 
    \conv_out[31]_i_1 
       (.I0(state[1]),
        .I1(state[0]),
        .O(\conv_out[31]_i_1_n_0 ));
  FDRE \conv_out_reg[0] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[0] ),
        .Q(conv_out[0]),
        .R(rst));
  FDRE \conv_out_reg[10] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[10] ),
        .Q(conv_out[10]),
        .R(rst));
  FDRE \conv_out_reg[11] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[11] ),
        .Q(conv_out[11]),
        .R(rst));
  FDRE \conv_out_reg[12] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[12] ),
        .Q(conv_out[12]),
        .R(rst));
  FDRE \conv_out_reg[13] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[13] ),
        .Q(conv_out[13]),
        .R(rst));
  FDRE \conv_out_reg[14] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[14] ),
        .Q(conv_out[14]),
        .R(rst));
  FDRE \conv_out_reg[15] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[15] ),
        .Q(conv_out[15]),
        .R(rst));
  FDRE \conv_out_reg[16] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[16] ),
        .Q(conv_out[16]),
        .R(rst));
  FDRE \conv_out_reg[17] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[17] ),
        .Q(conv_out[17]),
        .R(rst));
  FDRE \conv_out_reg[18] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[18] ),
        .Q(conv_out[18]),
        .R(rst));
  FDRE \conv_out_reg[19] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[19] ),
        .Q(conv_out[19]),
        .R(rst));
  FDRE \conv_out_reg[1] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[1] ),
        .Q(conv_out[1]),
        .R(rst));
  FDRE \conv_out_reg[20] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[20] ),
        .Q(conv_out[20]),
        .R(rst));
  FDRE \conv_out_reg[21] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[21] ),
        .Q(conv_out[21]),
        .R(rst));
  FDRE \conv_out_reg[22] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[22] ),
        .Q(conv_out[22]),
        .R(rst));
  FDRE \conv_out_reg[23] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[23] ),
        .Q(conv_out[23]),
        .R(rst));
  FDRE \conv_out_reg[24] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[24] ),
        .Q(conv_out[24]),
        .R(rst));
  FDRE \conv_out_reg[25] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[25] ),
        .Q(conv_out[25]),
        .R(rst));
  FDRE \conv_out_reg[26] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[26] ),
        .Q(conv_out[26]),
        .R(rst));
  FDRE \conv_out_reg[27] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[27] ),
        .Q(conv_out[27]),
        .R(rst));
  FDRE \conv_out_reg[28] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[28] ),
        .Q(conv_out[28]),
        .R(rst));
  FDRE \conv_out_reg[29] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[29] ),
        .Q(conv_out[29]),
        .R(rst));
  FDRE \conv_out_reg[2] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[2] ),
        .Q(conv_out[2]),
        .R(rst));
  FDRE \conv_out_reg[30] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[30] ),
        .Q(conv_out[30]),
        .R(rst));
  FDRE \conv_out_reg[31] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[31] ),
        .Q(conv_out[31]),
        .R(rst));
  FDRE \conv_out_reg[3] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[3] ),
        .Q(conv_out[3]),
        .R(rst));
  FDRE \conv_out_reg[4] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[4] ),
        .Q(conv_out[4]),
        .R(rst));
  FDRE \conv_out_reg[5] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[5] ),
        .Q(conv_out[5]),
        .R(rst));
  FDRE \conv_out_reg[6] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[6] ),
        .Q(conv_out[6]),
        .R(rst));
  FDRE \conv_out_reg[7] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[7] ),
        .Q(conv_out[7]),
        .R(rst));
  FDRE \conv_out_reg[8] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[8] ),
        .Q(conv_out[8]),
        .R(rst));
  FDRE \conv_out_reg[9] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(\accum_reg_n_0_[9] ),
        .Q(conv_out[9]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \cycles[0]_i_1 
       (.I0(state[0]),
        .I1(\cycles_reg_n_0_[0] ),
        .O(cycles[0]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h28)) 
    \cycles[1]_i_1 
       (.I0(state[0]),
        .I1(\cycles_reg_n_0_[0] ),
        .I2(\cycles_reg_n_0_[1] ),
        .O(cycles[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h2A80)) 
    \cycles[2]_i_1 
       (.I0(state[0]),
        .I1(\cycles_reg_n_0_[0] ),
        .I2(\cycles_reg_n_0_[1] ),
        .I3(\cycles_reg_n_0_[2] ),
        .O(cycles[2]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h2AAA8000)) 
    \cycles[3]_i_1 
       (.I0(state[0]),
        .I1(\cycles_reg_n_0_[1] ),
        .I2(\cycles_reg_n_0_[0] ),
        .I3(\cycles_reg_n_0_[2] ),
        .I4(\cycles_reg_n_0_[3] ),
        .O(cycles[3]));
  FDRE \cycles_reg[0] 
       (.C(clk),
        .CE(accum),
        .D(cycles[0]),
        .Q(\cycles_reg_n_0_[0] ),
        .R(rst));
  FDRE \cycles_reg[1] 
       (.C(clk),
        .CE(accum),
        .D(cycles[1]),
        .Q(\cycles_reg_n_0_[1] ),
        .R(rst));
  FDRE \cycles_reg[2] 
       (.C(clk),
        .CE(accum),
        .D(cycles[2]),
        .Q(\cycles_reg_n_0_[2] ),
        .R(rst));
  FDRE \cycles_reg[3] 
       (.C(clk),
        .CE(accum),
        .D(cycles[3]),
        .Q(\cycles_reg_n_0_[3] ),
        .R(rst));
  LUT3 #(
    .INIT(8'h04)) 
    done_i_1
       (.I0(state[0]),
        .I1(state[1]),
        .I2(rst),
        .O(done_i_1_n_0));
  FDRE done_reg
       (.C(clk),
        .CE(1'b1),
        .D(done_i_1_n_0),
        .Q(done),
        .R(1'b0));
  LUT5 #(
    .INIT(32'h7070FF00)) 
    \remaining[0]_i_1 
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(\remaining[4]_i_2_n_0 ),
        .I2(\remaining_reg_n_0_[0] ),
        .I3(state1__0),
        .I4(state[0]),
        .O(remaining[0]));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[0]_i_2 
       (.I0(\remaining[0]_i_3_n_0 ),
        .I1(\remaining[0]_i_2_0 [4]),
        .I2(\remaining[0]_i_2_0 [3]),
        .I3(\remaining[0]_i_2_0 [0]),
        .I4(\remaining[0]_i_2_0 [5]),
        .I5(state2__6),
        .O(state1__0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[0]_i_3 
       (.I0(\remaining[0]_i_2_0 [2]),
        .I1(\remaining[0]_i_2_0 [1]),
        .I2(\remaining[0]_i_2_0 [7]),
        .I3(\remaining[0]_i_2_0 [6]),
        .O(\remaining[0]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[0]_i_4 
       (.I0(\remaining[0]_i_4_0 [5]),
        .I1(\remaining[0]_i_4_0 [0]),
        .I2(\remaining[0]_i_4_0 [3]),
        .I3(\remaining[0]_i_4_0 [4]),
        .I4(\remaining[0]_i_5_n_0 ),
        .O(state2__6));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[0]_i_5 
       (.I0(\remaining[0]_i_4_0 [2]),
        .I1(\remaining[0]_i_4_0 [1]),
        .I2(\remaining[0]_i_4_0 [7]),
        .I3(\remaining[0]_i_4_0 [6]),
        .O(\remaining[0]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h7F007F00FFFF0000)) 
    \remaining[1]_i_1 
       (.I0(ffs_idx__30),
        .I1(\remaining[6]_i_3_n_0 ),
        .I2(\remaining[3]_i_2_n_0 ),
        .I3(\remaining_reg_n_0_[1] ),
        .I4(state123_out),
        .I5(state[0]),
        .O(remaining[1]));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[1]_i_2 
       (.I0(\remaining[1]_i_3_n_0 ),
        .I1(\remaining[1]_i_2_0 [4]),
        .I2(\remaining[1]_i_2_0 [3]),
        .I3(\remaining[1]_i_2_0 [0]),
        .I4(\remaining[1]_i_2_0 [5]),
        .I5(state221_in),
        .O(state123_out));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[1]_i_3 
       (.I0(\remaining[1]_i_2_0 [2]),
        .I1(\remaining[1]_i_2_0 [1]),
        .I2(\remaining[1]_i_2_0 [7]),
        .I3(\remaining[1]_i_2_0 [6]),
        .O(\remaining[1]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[1]_i_4 
       (.I0(\remaining[1]_i_4_0 [5]),
        .I1(\remaining[1]_i_4_0 [0]),
        .I2(\remaining[1]_i_4_0 [3]),
        .I3(\remaining[1]_i_4_0 [4]),
        .I4(\remaining[1]_i_5_n_0 ),
        .O(state221_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[1]_i_5 
       (.I0(\remaining[1]_i_4_0 [2]),
        .I1(\remaining[1]_i_4_0 [1]),
        .I2(\remaining[1]_i_4_0 [7]),
        .I3(\remaining[1]_i_4_0 [6]),
        .O(\remaining[1]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hEF00EF00FFFF0000)) 
    \remaining[2]_i_1 
       (.I0(ffs_idx__30),
        .I1(\remaining[6]_i_3_n_0 ),
        .I2(\remaining[3]_i_2_n_0 ),
        .I3(p_0_in_0),
        .I4(state126_out),
        .I5(state[0]),
        .O(remaining[2]));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[2]_i_2 
       (.I0(\remaining[2]_i_3_n_0 ),
        .I1(\remaining[2]_i_2_0 [4]),
        .I2(\remaining[2]_i_2_0 [3]),
        .I3(\remaining[2]_i_2_0 [0]),
        .I4(\remaining[2]_i_2_0 [5]),
        .I5(state224_in),
        .O(state126_out));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[2]_i_3 
       (.I0(\remaining[2]_i_2_0 [2]),
        .I1(\remaining[2]_i_2_0 [1]),
        .I2(\remaining[2]_i_2_0 [7]),
        .I3(\remaining[2]_i_2_0 [6]),
        .O(\remaining[2]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[2]_i_4 
       (.I0(\remaining[2]_i_4_0 [5]),
        .I1(\remaining[2]_i_4_0 [0]),
        .I2(\remaining[2]_i_4_0 [3]),
        .I3(\remaining[2]_i_4_0 [4]),
        .I4(\remaining[2]_i_5_n_0 ),
        .O(state224_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[2]_i_5 
       (.I0(\remaining[2]_i_4_0 [2]),
        .I1(\remaining[2]_i_4_0 [1]),
        .I2(\remaining[2]_i_4_0 [7]),
        .I3(\remaining[2]_i_4_0 [6]),
        .O(\remaining[2]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h7070FF00)) 
    \remaining[3]_i_1 
       (.I0(\remaining[3]_i_2_n_0 ),
        .I1(\remaining[7]_i_3_n_0 ),
        .I2(p_0_in3_in),
        .I3(state129_out),
        .I4(state[0]),
        .O(remaining[3]));
  LUT3 #(
    .INIT(8'h83)) 
    \remaining[3]_i_2 
       (.I0(\remaining[8]_i_8_n_0 ),
        .I1(\remaining[8]_i_7_n_0 ),
        .I2(\remaining[6]_i_3_n_0 ),
        .O(\remaining[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[3]_i_3 
       (.I0(\remaining[3]_i_4_n_0 ),
        .I1(\remaining[3]_i_3_0 [4]),
        .I2(\remaining[3]_i_3_0 [3]),
        .I3(\remaining[3]_i_3_0 [0]),
        .I4(\remaining[3]_i_3_0 [5]),
        .I5(state227_in),
        .O(state129_out));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[3]_i_4 
       (.I0(\remaining[3]_i_3_0 [2]),
        .I1(\remaining[3]_i_3_0 [1]),
        .I2(\remaining[3]_i_3_0 [7]),
        .I3(\remaining[3]_i_3_0 [6]),
        .O(\remaining[3]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[3]_i_5 
       (.I0(\remaining[3]_i_5_0 [5]),
        .I1(\remaining[3]_i_5_0 [0]),
        .I2(\remaining[3]_i_5_0 [3]),
        .I3(\remaining[3]_i_5_0 [4]),
        .I4(\remaining[3]_i_6_n_0 ),
        .O(state227_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[3]_i_6 
       (.I0(\remaining[3]_i_5_0 [2]),
        .I1(\remaining[3]_i_5_0 [1]),
        .I2(\remaining[3]_i_5_0 [7]),
        .I3(\remaining[3]_i_5_0 [6]),
        .O(\remaining[3]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'h7070FF00)) 
    \remaining[4]_i_1 
       (.I0(\remaining[7]_i_2_n_0 ),
        .I1(\remaining[4]_i_2_n_0 ),
        .I2(p_0_in6_in),
        .I3(state132_out),
        .I4(state[0]),
        .O(remaining[4]));
  LUT2 #(
    .INIT(4'h2)) 
    \remaining[4]_i_2 
       (.I0(\remaining[6]_i_3_n_0 ),
        .I1(ffs_idx__30),
        .O(\remaining[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[4]_i_3 
       (.I0(\remaining[4]_i_4_n_0 ),
        .I1(\remaining[4]_i_3_0 [4]),
        .I2(\remaining[4]_i_3_0 [3]),
        .I3(\remaining[4]_i_3_0 [0]),
        .I4(\remaining[4]_i_3_0 [5]),
        .I5(state230_in),
        .O(state132_out));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[4]_i_4 
       (.I0(\remaining[4]_i_3_0 [2]),
        .I1(\remaining[4]_i_3_0 [1]),
        .I2(\remaining[4]_i_3_0 [7]),
        .I3(\remaining[4]_i_3_0 [6]),
        .O(\remaining[4]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[4]_i_5 
       (.I0(\remaining[4]_i_5_0 [5]),
        .I1(\remaining[4]_i_5_0 [0]),
        .I2(\remaining[4]_i_5_0 [3]),
        .I3(\remaining[4]_i_5_0 [4]),
        .I4(\remaining[4]_i_6_n_0 ),
        .O(state230_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[4]_i_6 
       (.I0(\remaining[4]_i_5_0 [2]),
        .I1(\remaining[4]_i_5_0 [1]),
        .I2(\remaining[4]_i_5_0 [7]),
        .I3(\remaining[4]_i_5_0 [6]),
        .O(\remaining[4]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h7F007F00FFFF0000)) 
    \remaining[5]_i_1 
       (.I0(ffs_idx__30),
        .I1(\remaining[6]_i_3_n_0 ),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(p_0_in9_in),
        .I4(state135_out),
        .I5(state[0]),
        .O(remaining[5]));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[5]_i_2 
       (.I0(\remaining[5]_i_3_n_0 ),
        .I1(\remaining[5]_i_2_0 [4]),
        .I2(\remaining[5]_i_2_0 [3]),
        .I3(\remaining[5]_i_2_0 [0]),
        .I4(\remaining[5]_i_2_0 [5]),
        .I5(state233_in),
        .O(state135_out));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[5]_i_3 
       (.I0(\remaining[5]_i_2_0 [2]),
        .I1(\remaining[5]_i_2_0 [1]),
        .I2(\remaining[5]_i_2_0 [7]),
        .I3(\remaining[5]_i_2_0 [6]),
        .O(\remaining[5]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[5]_i_4 
       (.I0(\remaining[5]_i_4_0 [5]),
        .I1(\remaining[5]_i_4_0 [0]),
        .I2(\remaining[5]_i_4_0 [3]),
        .I3(\remaining[5]_i_4_0 [4]),
        .I4(\remaining[5]_i_5_n_0 ),
        .O(state233_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[5]_i_5 
       (.I0(\remaining[5]_i_4_0 [2]),
        .I1(\remaining[5]_i_4_0 [1]),
        .I2(\remaining[5]_i_4_0 [7]),
        .I3(\remaining[5]_i_4_0 [6]),
        .O(\remaining[5]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hEF00EF00FFFF0000)) 
    \remaining[6]_i_1 
       (.I0(ffs_idx__30),
        .I1(\remaining[6]_i_3_n_0 ),
        .I2(\remaining[7]_i_2_n_0 ),
        .I3(p_0_in12_in),
        .I4(state138_out),
        .I5(state[0]),
        .O(remaining[6]));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[6]_i_10 
       (.I0(\remaining[6]_i_4_0 [2]),
        .I1(\remaining[6]_i_4_0 [1]),
        .I2(\remaining[6]_i_4_0 [7]),
        .I3(\remaining[6]_i_4_0 [6]),
        .O(\remaining[6]_i_10_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[6]_i_11 
       (.I0(\remaining[6]_i_11_0 [5]),
        .I1(\remaining[6]_i_11_0 [0]),
        .I2(\remaining[6]_i_11_0 [3]),
        .I3(\remaining[6]_i_11_0 [4]),
        .I4(\remaining[6]_i_12_n_0 ),
        .O(state236_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[6]_i_12 
       (.I0(\remaining[6]_i_11_0 [2]),
        .I1(\remaining[6]_i_11_0 [1]),
        .I2(\remaining[6]_i_11_0 [7]),
        .I3(\remaining[6]_i_11_0 [6]),
        .O(\remaining[6]_i_12_n_0 ));
  LUT6 #(
    .INIT(64'h00E0EEEE00EEEEEE)) 
    \remaining[6]_i_2 
       (.I0(\remaining[6]_i_5_n_0 ),
        .I1(\remaining[6]_i_6_n_0 ),
        .I2(\remaining_reg_n_0_[1] ),
        .I3(\remaining_reg_n_0_[0] ),
        .I4(\remaining[8]_i_7_n_0 ),
        .I5(\remaining[6]_i_7_n_0 ),
        .O(ffs_idx__30));
  LUT6 #(
    .INIT(64'hFFFFFFFF000000FE)) 
    \remaining[6]_i_3 
       (.I0(p_0_in9_in),
        .I1(p_0_in6_in),
        .I2(\remaining[6]_i_8_n_0 ),
        .I3(p_0_in_0),
        .I4(p_0_in3_in),
        .I5(\remaining[6]_i_9_n_0 ),
        .O(\remaining[6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[6]_i_4 
       (.I0(\remaining[6]_i_10_n_0 ),
        .I1(\remaining[6]_i_4_0 [4]),
        .I2(\remaining[6]_i_4_0 [3]),
        .I3(\remaining[6]_i_4_0 [0]),
        .I4(\remaining[6]_i_4_0 [5]),
        .I5(state236_in),
        .O(state138_out));
  LUT6 #(
    .INIT(64'h1011101100001011)) 
    \remaining[6]_i_5 
       (.I0(p_0_in12_in),
        .I1(p_0_in_0),
        .I2(p_0_in3_in),
        .I3(p_0_in6_in),
        .I4(p_0_in18_in),
        .I5(p_0_in15_in),
        .O(\remaining[6]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF00BA)) 
    \remaining[6]_i_6 
       (.I0(p_0_in3_in),
        .I1(p_0_in6_in),
        .I2(p_0_in9_in),
        .I3(p_0_in_0),
        .I4(\remaining_reg_n_0_[1] ),
        .I5(\remaining_reg_n_0_[0] ),
        .O(\remaining[6]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h1111111111110001)) 
    \remaining[6]_i_7 
       (.I0(p_0_in3_in),
        .I1(p_0_in_0),
        .I2(p_0_in12_in),
        .I3(p_0_in15_in),
        .I4(p_0_in6_in),
        .I5(p_0_in9_in),
        .O(\remaining[6]_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \remaining[6]_i_8 
       (.I0(p_0_in12_in),
        .I1(p_0_in15_in),
        .O(\remaining[6]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \remaining[6]_i_9 
       (.I0(\remaining_reg_n_0_[0] ),
        .I1(\remaining_reg_n_0_[1] ),
        .O(\remaining[6]_i_9_n_0 ));
  LUT5 #(
    .INIT(32'h7070FF00)) 
    \remaining[7]_i_1 
       (.I0(\remaining[7]_i_2_n_0 ),
        .I1(\remaining[7]_i_3_n_0 ),
        .I2(p_0_in15_in),
        .I3(state141_out),
        .I4(state[0]),
        .O(remaining[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \remaining[7]_i_2 
       (.I0(\remaining[8]_i_7_n_0 ),
        .I1(\remaining[6]_i_3_n_0 ),
        .O(\remaining[7]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \remaining[7]_i_3 
       (.I0(ffs_idx__30),
        .I1(\remaining[6]_i_3_n_0 ),
        .O(\remaining[7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[7]_i_4 
       (.I0(\remaining[7]_i_5_n_0 ),
        .I1(\remaining[7]_i_4_0 [4]),
        .I2(\remaining[7]_i_4_0 [3]),
        .I3(\remaining[7]_i_4_0 [0]),
        .I4(\remaining[7]_i_4_0 [5]),
        .I5(state239_in),
        .O(state141_out));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[7]_i_5 
       (.I0(\remaining[7]_i_4_0 [2]),
        .I1(\remaining[7]_i_4_0 [1]),
        .I2(\remaining[7]_i_4_0 [7]),
        .I3(\remaining[7]_i_4_0 [6]),
        .O(\remaining[7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[7]_i_6 
       (.I0(\remaining[7]_i_6_0 [5]),
        .I1(\remaining[7]_i_6_0 [0]),
        .I2(\remaining[7]_i_6_0 [3]),
        .I3(\remaining[7]_i_6_0 [4]),
        .I4(\remaining[7]_i_7_n_0 ),
        .O(state239_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[7]_i_7 
       (.I0(\remaining[7]_i_6_0 [2]),
        .I1(\remaining[7]_i_6_0 [1]),
        .I2(\remaining[7]_i_6_0 [7]),
        .I3(\remaining[7]_i_6_0 [6]),
        .O(\remaining[7]_i_7_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \remaining[8]_i_1 
       (.I0(core_start),
        .I1(state[0]),
        .I2(ffs_valid__0),
        .I3(state[1]),
        .O(accum));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \remaining[8]_i_10 
       (.I0(Q[5]),
        .I1(Q[0]),
        .I2(Q[3]),
        .I3(Q[4]),
        .I4(\remaining[8]_i_11_n_0 ),
        .O(state242_in));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[8]_i_11 
       (.I0(Q[2]),
        .I1(Q[1]),
        .I2(Q[7]),
        .I3(Q[6]),
        .O(\remaining[8]_i_11_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h44F0)) 
    \remaining[8]_i_2 
       (.I0(\remaining[8]_i_4_n_0 ),
        .I1(p_0_in18_in),
        .I2(state144_out),
        .I3(state[0]),
        .O(remaining[8]));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[8]_i_3 
       (.I0(\remaining[8]_i_6_n_0 ),
        .I1(p_0_in12_in),
        .I2(p_0_in15_in),
        .I3(p_0_in18_in),
        .O(ffs_valid__0));
  LUT3 #(
    .INIT(8'h08)) 
    \remaining[8]_i_4 
       (.I0(\remaining[6]_i_3_n_0 ),
        .I1(\remaining[8]_i_7_n_0 ),
        .I2(\remaining[8]_i_8_n_0 ),
        .O(\remaining[8]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFE00000000)) 
    \remaining[8]_i_5 
       (.I0(\remaining[8]_i_9_n_0 ),
        .I1(\remaining[8]_i_5_0 [4]),
        .I2(\remaining[8]_i_5_0 [3]),
        .I3(\remaining[8]_i_5_0 [0]),
        .I4(\remaining[8]_i_5_0 [5]),
        .I5(state242_in),
        .O(state144_out));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \remaining[8]_i_6 
       (.I0(p_0_in3_in),
        .I1(p_0_in9_in),
        .I2(p_0_in6_in),
        .I3(\remaining_reg_n_0_[0] ),
        .I4(\remaining_reg_n_0_[1] ),
        .I5(p_0_in_0),
        .O(\remaining[8]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF0001)) 
    \remaining[8]_i_7 
       (.I0(p_0_in3_in),
        .I1(p_0_in9_in),
        .I2(p_0_in_0),
        .I3(p_0_in6_in),
        .I4(\remaining_reg_n_0_[1] ),
        .I5(\remaining_reg_n_0_[0] ),
        .O(\remaining[8]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFBBBBAABA)) 
    \remaining[8]_i_8 
       (.I0(\remaining[6]_i_9_n_0 ),
        .I1(p_0_in_0),
        .I2(p_0_in9_in),
        .I3(p_0_in6_in),
        .I4(p_0_in3_in),
        .I5(\remaining[6]_i_5_n_0 ),
        .O(\remaining[8]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \remaining[8]_i_9 
       (.I0(\remaining[8]_i_5_0 [2]),
        .I1(\remaining[8]_i_5_0 [1]),
        .I2(\remaining[8]_i_5_0 [7]),
        .I3(\remaining[8]_i_5_0 [6]),
        .O(\remaining[8]_i_9_n_0 ));
  FDRE \remaining_reg[0] 
       (.C(clk),
        .CE(accum),
        .D(remaining[0]),
        .Q(\remaining_reg_n_0_[0] ),
        .R(rst));
  FDRE \remaining_reg[1] 
       (.C(clk),
        .CE(accum),
        .D(remaining[1]),
        .Q(\remaining_reg_n_0_[1] ),
        .R(rst));
  FDRE \remaining_reg[2] 
       (.C(clk),
        .CE(accum),
        .D(remaining[2]),
        .Q(p_0_in_0),
        .R(rst));
  FDRE \remaining_reg[3] 
       (.C(clk),
        .CE(accum),
        .D(remaining[3]),
        .Q(p_0_in3_in),
        .R(rst));
  FDRE \remaining_reg[4] 
       (.C(clk),
        .CE(accum),
        .D(remaining[4]),
        .Q(p_0_in6_in),
        .R(rst));
  FDRE \remaining_reg[5] 
       (.C(clk),
        .CE(accum),
        .D(remaining[5]),
        .Q(p_0_in9_in),
        .R(rst));
  FDRE \remaining_reg[6] 
       (.C(clk),
        .CE(accum),
        .D(remaining[6]),
        .Q(p_0_in12_in),
        .R(rst));
  FDRE \remaining_reg[7] 
       (.C(clk),
        .CE(accum),
        .D(remaining[7]),
        .Q(p_0_in15_in),
        .R(rst));
  FDRE \remaining_reg[8] 
       (.C(clk),
        .CE(accum),
        .D(remaining[8]),
        .Q(p_0_in18_in),
        .R(rst));
  FDRE \skip_count_reg[0] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(skips[0]),
        .Q(skip_count[0]),
        .R(rst));
  FDRE \skip_count_reg[1] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(skips[1]),
        .Q(skip_count[1]),
        .R(rst));
  FDRE \skip_count_reg[2] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(skips[2]),
        .Q(skip_count[2]),
        .R(rst));
  FDRE \skip_count_reg[3] 
       (.C(clk),
        .CE(\conv_out[31]_i_1_n_0 ),
        .D(skips[3]),
        .Q(skip_count[3]),
        .R(rst));
  LUT5 #(
    .INIT(32'h69969669)) 
    \skips[0]_i_1 
       (.I0(state141_out),
        .I1(state1__0),
        .I2(state144_out),
        .I3(\skips[0]_i_2_n_0 ),
        .I4(\skips[0]_i_3_n_0 ),
        .O(skips0[0]));
  LUT3 #(
    .INIT(8'h69)) 
    \skips[0]_i_2 
       (.I0(state126_out),
        .I1(state123_out),
        .I2(state129_out),
        .O(\skips[0]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h69)) 
    \skips[0]_i_3 
       (.I0(state135_out),
        .I1(state132_out),
        .I2(state138_out),
        .O(\skips[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hE81717E817E8E817)) 
    \skips[1]_i_1 
       (.I0(state144_out),
        .I1(state1__0),
        .I2(state141_out),
        .I3(\skips[3]_i_4_n_0 ),
        .I4(\skips[3]_i_5_n_0 ),
        .I5(\skips[3]_i_3_n_0 ),
        .O(skips0[1]));
  LUT6 #(
    .INIT(64'hE8FFFF17FF171700)) 
    \skips[2]_i_1 
       (.I0(state144_out),
        .I1(state1__0),
        .I2(state141_out),
        .I3(\skips[3]_i_3_n_0 ),
        .I4(\skips[3]_i_5_n_0 ),
        .I5(\skips[3]_i_4_n_0 ),
        .O(skips0[2]));
  LUT3 #(
    .INIT(8'h10)) 
    \skips[3]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(core_start),
        .O(skips_1));
  LUT6 #(
    .INIT(64'h1700000000000000)) 
    \skips[3]_i_2 
       (.I0(state144_out),
        .I1(state1__0),
        .I2(state141_out),
        .I3(\skips[3]_i_3_n_0 ),
        .I4(\skips[3]_i_4_n_0 ),
        .I5(\skips[3]_i_5_n_0 ),
        .O(skips0[3]));
  LUT5 #(
    .INIT(32'hFF696900)) 
    \skips[3]_i_3 
       (.I0(state141_out),
        .I1(state1__0),
        .I2(state144_out),
        .I3(\skips[0]_i_2_n_0 ),
        .I4(\skips[0]_i_3_n_0 ),
        .O(\skips[3]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h17)) 
    \skips[3]_i_4 
       (.I0(state129_out),
        .I1(state123_out),
        .I2(state126_out),
        .O(\skips[3]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h17)) 
    \skips[3]_i_5 
       (.I0(state138_out),
        .I1(state132_out),
        .I2(state135_out),
        .O(\skips[3]_i_5_n_0 ));
  FDRE \skips_reg[0] 
       (.C(clk),
        .CE(skips_1),
        .D(skips0[0]),
        .Q(skips[0]),
        .R(rst));
  FDRE \skips_reg[1] 
       (.C(clk),
        .CE(skips_1),
        .D(skips0[1]),
        .Q(skips[1]),
        .R(rst));
  FDRE \skips_reg[2] 
       (.C(clk),
        .CE(skips_1),
        .D(skips0[2]),
        .Q(skips[2]),
        .R(rst));
  FDRE \skips_reg[3] 
       (.C(clk),
        .CE(skips_1),
        .D(skips0[3]),
        .Q(skips[3]),
        .R(rst));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
