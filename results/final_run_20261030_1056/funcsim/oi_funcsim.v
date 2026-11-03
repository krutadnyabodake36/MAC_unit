// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
// Date        : Sat Oct 31 22:47:51 2026
// Host        : LAPTOP-NBHBH25N running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -force results/final_run_20261030_1056/funcsim/oi_funcsim.v
// Design      : conv2d_engine_wrapper
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s15ftgb196-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* DESIGN_SELECT = "1" *) (* ECO_CHECKSUM = "15f498d6" *) 
(* NotValidForBitStream *)
(* \DesignAttr:ENABLE_NOC_NETLIST_VIEW  *) 
(* \DesignAttr:ENABLE_AIE_NETLIST_VIEW  *) 
module conv2d_engine_wrapper
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

  conv2d_serial_oi \gen_engine.u_core 
       (.Q(\w_reg_reg[8] ),
        .accum1__0_carry__1_i_5_0(\w_reg_reg[5] ),
        .accum1__0_carry__1_i_5_1(\w_reg_reg[7] ),
        .accum1__0_carry__1_i_5_2(\w_reg_reg[4] ),
        .accum1__0_carry__1_i_5_3(\w_reg_reg[6] ),
        .accum1__0_carry__1_i_5_4(\w_reg_reg[1] ),
        .accum1__0_carry__1_i_5_5(\w_reg_reg[3] ),
        .accum1__0_carry__1_i_5_6(\w_reg_reg[0] ),
        .accum1__0_carry__1_i_5_7(\w_reg_reg[2] ),
        .accum1__59_carry_i_6_0(\p_reg_reg[8] ),
        .accum1__59_carry_i_8_0(\p_reg_reg[5] ),
        .accum1__59_carry_i_8_1(\p_reg_reg[7] ),
        .accum1__59_carry_i_8_2(\p_reg_reg[4] ),
        .accum1__59_carry_i_8_3(\p_reg_reg[6] ),
        .accum1__59_carry_i_8_4(\p_reg_reg[1] ),
        .accum1__59_carry_i_8_5(\p_reg_reg[3] ),
        .accum1__59_carry_i_8_6(\p_reg_reg[0] ),
        .accum1__59_carry_i_8_7(\p_reg_reg[2] ),
        .clk(clk),
        .compute_cycles(compute_cycles),
        .conv_out(conv_out),
        .done(done),
        .rst(rst),
        .skip_count(skip_count),
        .start(start));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [0]),
        .Q(\p_reg_reg[0] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [1]),
        .Q(\p_reg_reg[0] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [2]),
        .Q(\p_reg_reg[0] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [3]),
        .Q(\p_reg_reg[0] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [4]),
        .Q(\p_reg_reg[0] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [5]),
        .Q(\p_reg_reg[0] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [6]),
        .Q(\p_reg_reg[0] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[0][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[0] [7]),
        .Q(\p_reg_reg[0] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [0]),
        .Q(\p_reg_reg[1] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [1]),
        .Q(\p_reg_reg[1] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [2]),
        .Q(\p_reg_reg[1] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [3]),
        .Q(\p_reg_reg[1] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [4]),
        .Q(\p_reg_reg[1] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [5]),
        .Q(\p_reg_reg[1] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [6]),
        .Q(\p_reg_reg[1] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[1][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[1] [7]),
        .Q(\p_reg_reg[1] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [0]),
        .Q(\p_reg_reg[2] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [1]),
        .Q(\p_reg_reg[2] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [2]),
        .Q(\p_reg_reg[2] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [3]),
        .Q(\p_reg_reg[2] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [4]),
        .Q(\p_reg_reg[2] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [5]),
        .Q(\p_reg_reg[2] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [6]),
        .Q(\p_reg_reg[2] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[2][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[2] [7]),
        .Q(\p_reg_reg[2] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [0]),
        .Q(\p_reg_reg[3] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [1]),
        .Q(\p_reg_reg[3] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [2]),
        .Q(\p_reg_reg[3] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [3]),
        .Q(\p_reg_reg[3] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [4]),
        .Q(\p_reg_reg[3] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [5]),
        .Q(\p_reg_reg[3] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [6]),
        .Q(\p_reg_reg[3] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[3][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[3] [7]),
        .Q(\p_reg_reg[3] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [0]),
        .Q(\p_reg_reg[4] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [1]),
        .Q(\p_reg_reg[4] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [2]),
        .Q(\p_reg_reg[4] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [3]),
        .Q(\p_reg_reg[4] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [4]),
        .Q(\p_reg_reg[4] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [5]),
        .Q(\p_reg_reg[4] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [6]),
        .Q(\p_reg_reg[4] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[4][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[4] [7]),
        .Q(\p_reg_reg[4] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [0]),
        .Q(\p_reg_reg[5] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [1]),
        .Q(\p_reg_reg[5] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [2]),
        .Q(\p_reg_reg[5] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [3]),
        .Q(\p_reg_reg[5] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [4]),
        .Q(\p_reg_reg[5] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [5]),
        .Q(\p_reg_reg[5] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [6]),
        .Q(\p_reg_reg[5] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[5][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[5] [7]),
        .Q(\p_reg_reg[5] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [0]),
        .Q(\p_reg_reg[6] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [1]),
        .Q(\p_reg_reg[6] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [2]),
        .Q(\p_reg_reg[6] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [3]),
        .Q(\p_reg_reg[6] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [4]),
        .Q(\p_reg_reg[6] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [5]),
        .Q(\p_reg_reg[6] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [6]),
        .Q(\p_reg_reg[6] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[6][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[6] [7]),
        .Q(\p_reg_reg[6] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [0]),
        .Q(\p_reg_reg[7] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [1]),
        .Q(\p_reg_reg[7] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [2]),
        .Q(\p_reg_reg[7] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [3]),
        .Q(\p_reg_reg[7] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [4]),
        .Q(\p_reg_reg[7] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [5]),
        .Q(\p_reg_reg[7] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [6]),
        .Q(\p_reg_reg[7] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[7][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[7] [7]),
        .Q(\p_reg_reg[7] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][0] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [0]),
        .Q(\p_reg_reg[8] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][1] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [1]),
        .Q(\p_reg_reg[8] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][2] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [2]),
        .Q(\p_reg_reg[8] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][3] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [3]),
        .Q(\p_reg_reg[8] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][4] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [4]),
        .Q(\p_reg_reg[8] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][5] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [5]),
        .Q(\p_reg_reg[8] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][6] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [6]),
        .Q(\p_reg_reg[8] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \p_reg_reg[8][7] 
       (.C(clk),
        .CE(start),
        .D(\pixels_in[8] [7]),
        .Q(\p_reg_reg[8] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [0]),
        .Q(\w_reg_reg[0] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [1]),
        .Q(\w_reg_reg[0] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [2]),
        .Q(\w_reg_reg[0] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [3]),
        .Q(\w_reg_reg[0] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [4]),
        .Q(\w_reg_reg[0] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [5]),
        .Q(\w_reg_reg[0] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [6]),
        .Q(\w_reg_reg[0] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[0][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[0] [7]),
        .Q(\w_reg_reg[0] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [0]),
        .Q(\w_reg_reg[1] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [1]),
        .Q(\w_reg_reg[1] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [2]),
        .Q(\w_reg_reg[1] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [3]),
        .Q(\w_reg_reg[1] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [4]),
        .Q(\w_reg_reg[1] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [5]),
        .Q(\w_reg_reg[1] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [6]),
        .Q(\w_reg_reg[1] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[1][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[1] [7]),
        .Q(\w_reg_reg[1] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [0]),
        .Q(\w_reg_reg[2] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [1]),
        .Q(\w_reg_reg[2] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [2]),
        .Q(\w_reg_reg[2] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [3]),
        .Q(\w_reg_reg[2] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [4]),
        .Q(\w_reg_reg[2] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [5]),
        .Q(\w_reg_reg[2] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [6]),
        .Q(\w_reg_reg[2] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[2][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[2] [7]),
        .Q(\w_reg_reg[2] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [0]),
        .Q(\w_reg_reg[3] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [1]),
        .Q(\w_reg_reg[3] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [2]),
        .Q(\w_reg_reg[3] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [3]),
        .Q(\w_reg_reg[3] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [4]),
        .Q(\w_reg_reg[3] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [5]),
        .Q(\w_reg_reg[3] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [6]),
        .Q(\w_reg_reg[3] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[3][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[3] [7]),
        .Q(\w_reg_reg[3] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [0]),
        .Q(\w_reg_reg[4] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [1]),
        .Q(\w_reg_reg[4] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [2]),
        .Q(\w_reg_reg[4] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [3]),
        .Q(\w_reg_reg[4] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [4]),
        .Q(\w_reg_reg[4] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [5]),
        .Q(\w_reg_reg[4] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [6]),
        .Q(\w_reg_reg[4] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[4][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[4] [7]),
        .Q(\w_reg_reg[4] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [0]),
        .Q(\w_reg_reg[5] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [1]),
        .Q(\w_reg_reg[5] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [2]),
        .Q(\w_reg_reg[5] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [3]),
        .Q(\w_reg_reg[5] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [4]),
        .Q(\w_reg_reg[5] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [5]),
        .Q(\w_reg_reg[5] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [6]),
        .Q(\w_reg_reg[5] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[5][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[5] [7]),
        .Q(\w_reg_reg[5] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [0]),
        .Q(\w_reg_reg[6] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [1]),
        .Q(\w_reg_reg[6] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [2]),
        .Q(\w_reg_reg[6] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [3]),
        .Q(\w_reg_reg[6] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [4]),
        .Q(\w_reg_reg[6] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [5]),
        .Q(\w_reg_reg[6] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [6]),
        .Q(\w_reg_reg[6] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[6][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[6] [7]),
        .Q(\w_reg_reg[6] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [0]),
        .Q(\w_reg_reg[7] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [1]),
        .Q(\w_reg_reg[7] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [2]),
        .Q(\w_reg_reg[7] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [3]),
        .Q(\w_reg_reg[7] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [4]),
        .Q(\w_reg_reg[7] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [5]),
        .Q(\w_reg_reg[7] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [6]),
        .Q(\w_reg_reg[7] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[7][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[7] [7]),
        .Q(\w_reg_reg[7] [7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][0] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [0]),
        .Q(\w_reg_reg[8] [0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][1] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [1]),
        .Q(\w_reg_reg[8] [1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][2] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [2]),
        .Q(\w_reg_reg[8] [2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][3] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [3]),
        .Q(\w_reg_reg[8] [3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][4] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [4]),
        .Q(\w_reg_reg[8] [4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][5] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [5]),
        .Q(\w_reg_reg[8] [5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][6] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [6]),
        .Q(\w_reg_reg[8] [6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \w_reg_reg[8][7] 
       (.C(clk),
        .CE(start),
        .D(\weights_in[8] [7]),
        .Q(\w_reg_reg[8] [7]),
        .R(rst));
endmodule

module conv2d_serial_oi
   (done,
    conv_out,
    compute_cycles,
    skip_count,
    clk,
    rst,
    start,
    Q,
    accum1__59_carry_i_6_0,
    accum1__59_carry_i_8_0,
    accum1__59_carry_i_8_1,
    accum1__59_carry_i_8_2,
    accum1__59_carry_i_8_3,
    accum1__59_carry_i_8_4,
    accum1__59_carry_i_8_5,
    accum1__59_carry_i_8_6,
    accum1__59_carry_i_8_7,
    accum1__0_carry__1_i_5_0,
    accum1__0_carry__1_i_5_1,
    accum1__0_carry__1_i_5_2,
    accum1__0_carry__1_i_5_3,
    accum1__0_carry__1_i_5_4,
    accum1__0_carry__1_i_5_5,
    accum1__0_carry__1_i_5_6,
    accum1__0_carry__1_i_5_7);
  output done;
  output [31:0]conv_out;
  output [3:0]compute_cycles;
  output [3:0]skip_count;
  input clk;
  input rst;
  input start;
  input [7:0]Q;
  input [7:0]accum1__59_carry_i_6_0;
  input [7:0]accum1__59_carry_i_8_0;
  input [7:0]accum1__59_carry_i_8_1;
  input [7:0]accum1__59_carry_i_8_2;
  input [7:0]accum1__59_carry_i_8_3;
  input [7:0]accum1__59_carry_i_8_4;
  input [7:0]accum1__59_carry_i_8_5;
  input [7:0]accum1__59_carry_i_8_6;
  input [7:0]accum1__59_carry_i_8_7;
  input [7:0]accum1__0_carry__1_i_5_0;
  input [7:0]accum1__0_carry__1_i_5_1;
  input [7:0]accum1__0_carry__1_i_5_2;
  input [7:0]accum1__0_carry__1_i_5_3;
  input [7:0]accum1__0_carry__1_i_5_4;
  input [7:0]accum1__0_carry__1_i_5_5;
  input [7:0]accum1__0_carry__1_i_5_6;
  input [7:0]accum1__0_carry__1_i_5_7;

  wire [7:0]A;
  wire [5:0]B;
  wire \FSM_onehot_state[0]_i_1_n_0 ;
  wire \FSM_onehot_state[1]_i_1_n_0 ;
  wire \FSM_onehot_state[2]_i_1_n_0 ;
  wire \FSM_onehot_state[2]_i_2_n_0 ;
  wire \FSM_onehot_state[2]_i_3_n_0 ;
  wire \FSM_onehot_state_reg_n_0_[0] ;
  wire \FSM_onehot_state_reg_n_0_[1] ;
  wire \FSM_onehot_state_reg_n_0_[2] ;
  wire [7:0]Q;
  wire [31:0]accum;
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
  wire accum1__0_carry__0_i_10_n_0;
  wire accum1__0_carry__0_i_12_n_0;
  wire accum1__0_carry__0_i_14_n_0;
  wire accum1__0_carry__0_i_16_n_0;
  wire accum1__0_carry__0_i_18_n_0;
  wire accum1__0_carry__0_i_19_n_0;
  wire accum1__0_carry__0_i_1_n_0;
  wire accum1__0_carry__0_i_20_n_0;
  wire accum1__0_carry__0_i_21_n_0;
  wire accum1__0_carry__0_i_22_n_0;
  wire accum1__0_carry__0_i_23_n_0;
  wire accum1__0_carry__0_i_24_n_0;
  wire accum1__0_carry__0_i_25_n_0;
  wire accum1__0_carry__0_i_26_n_0;
  wire accum1__0_carry__0_i_27_n_0;
  wire accum1__0_carry__0_i_28_n_0;
  wire accum1__0_carry__0_i_29_n_0;
  wire accum1__0_carry__0_i_2_n_0;
  wire accum1__0_carry__0_i_30_n_0;
  wire accum1__0_carry__0_i_3_n_0;
  wire accum1__0_carry__0_i_4_n_0;
  wire accum1__0_carry__0_i_5_n_0;
  wire accum1__0_carry__0_i_6_n_0;
  wire accum1__0_carry__0_i_7_n_0;
  wire accum1__0_carry__0_i_8_n_0;
  wire accum1__0_carry__0_n_0;
  wire accum1__0_carry__0_n_4;
  wire accum1__0_carry__0_n_5;
  wire accum1__0_carry__0_n_6;
  wire accum1__0_carry__0_n_7;
  wire accum1__0_carry__1_i_1_n_0;
  wire accum1__0_carry__1_i_2_n_0;
  wire accum1__0_carry__1_i_3_n_0;
  wire accum1__0_carry__1_i_4_n_0;
  wire [7:0]accum1__0_carry__1_i_5_0;
  wire [7:0]accum1__0_carry__1_i_5_1;
  wire [7:0]accum1__0_carry__1_i_5_2;
  wire [7:0]accum1__0_carry__1_i_5_3;
  wire [7:0]accum1__0_carry__1_i_5_4;
  wire [7:0]accum1__0_carry__1_i_5_5;
  wire [7:0]accum1__0_carry__1_i_5_6;
  wire [7:0]accum1__0_carry__1_i_5_7;
  wire accum1__0_carry__1_i_6_n_0;
  wire accum1__0_carry__1_i_8_n_0;
  wire accum1__0_carry__1_i_9_n_0;
  wire accum1__0_carry__1_n_1;
  wire accum1__0_carry__1_n_6;
  wire accum1__0_carry__1_n_7;
  wire accum1__0_carry_i_10_n_0;
  wire accum1__0_carry_i_17_n_0;
  wire accum1__0_carry_i_1_n_0;
  wire accum1__0_carry_i_23_n_0;
  wire accum1__0_carry_i_24_n_0;
  wire accum1__0_carry_i_25_n_0;
  wire accum1__0_carry_i_26_n_0;
  wire accum1__0_carry_i_27_n_0;
  wire accum1__0_carry_i_28_n_0;
  wire accum1__0_carry_i_29_n_0;
  wire accum1__0_carry_i_2_n_0;
  wire accum1__0_carry_i_30_n_0;
  wire accum1__0_carry_i_31_n_0;
  wire accum1__0_carry_i_32_n_0;
  wire accum1__0_carry_i_33_n_0;
  wire accum1__0_carry_i_34_n_0;
  wire accum1__0_carry_i_35_n_0;
  wire accum1__0_carry_i_36_n_0;
  wire accum1__0_carry_i_3_n_0;
  wire accum1__0_carry_i_4_n_0;
  wire accum1__0_carry_i_5_n_0;
  wire accum1__0_carry_i_6_n_0;
  wire accum1__0_carry_i_7_n_0;
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
  wire accum1__30_carry__0_i_19_n_0;
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
  wire accum1__30_carry__1_i_5_n_0;
  wire accum1__30_carry__1_n_1;
  wire accum1__30_carry__1_n_6;
  wire accum1__30_carry__1_n_7;
  wire accum1__30_carry_i_12_n_0;
  wire accum1__30_carry_i_16_n_0;
  wire accum1__30_carry_i_17_n_0;
  wire accum1__30_carry_i_18_n_0;
  wire accum1__30_carry_i_19_n_0;
  wire accum1__30_carry_i_1_n_0;
  wire accum1__30_carry_i_20_n_0;
  wire accum1__30_carry_i_21_n_0;
  wire accum1__30_carry_i_2_n_0;
  wire accum1__30_carry_i_3_n_0;
  wire accum1__30_carry_i_4_n_0;
  wire accum1__30_carry_i_5_n_0;
  wire accum1__30_carry_i_6_n_0;
  wire accum1__30_carry_i_7_n_0;
  wire accum1__30_carry_i_9_n_0;
  wire accum1__30_carry_n_0;
  wire accum1__30_carry_n_4;
  wire accum1__30_carry_n_5;
  wire accum1__30_carry_n_6;
  wire accum1__30_carry_n_7;
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
  wire accum1__59_carry_i_10_n_0;
  wire accum1__59_carry_i_11_n_0;
  wire accum1__59_carry_i_12_n_0;
  wire accum1__59_carry_i_13_n_0;
  wire accum1__59_carry_i_1_n_0;
  wire accum1__59_carry_i_2_n_0;
  wire accum1__59_carry_i_3_n_0;
  wire accum1__59_carry_i_4_n_0;
  wire accum1__59_carry_i_5_n_0;
  wire [7:0]accum1__59_carry_i_6_0;
  wire accum1__59_carry_i_6_n_0;
  wire accum1__59_carry_i_7_n_0;
  wire [7:0]accum1__59_carry_i_8_0;
  wire [7:0]accum1__59_carry_i_8_1;
  wire [7:0]accum1__59_carry_i_8_2;
  wire [7:0]accum1__59_carry_i_8_3;
  wire [7:0]accum1__59_carry_i_8_4;
  wire [7:0]accum1__59_carry_i_8_5;
  wire [7:0]accum1__59_carry_i_8_6;
  wire [7:0]accum1__59_carry_i_8_7;
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
  wire \accum[0]_i_1_n_0 ;
  wire \accum[10]_i_1_n_0 ;
  wire \accum[11]_i_1_n_0 ;
  wire \accum[12]_i_1_n_0 ;
  wire \accum[13]_i_1_n_0 ;
  wire \accum[14]_i_1_n_0 ;
  wire \accum[15]_i_1_n_0 ;
  wire \accum[16]_i_1_n_0 ;
  wire \accum[17]_i_1_n_0 ;
  wire \accum[18]_i_1_n_0 ;
  wire \accum[19]_i_1_n_0 ;
  wire \accum[1]_i_1_n_0 ;
  wire \accum[20]_i_1_n_0 ;
  wire \accum[21]_i_1_n_0 ;
  wire \accum[22]_i_1_n_0 ;
  wire \accum[23]_i_1_n_0 ;
  wire \accum[24]_i_1_n_0 ;
  wire \accum[25]_i_1_n_0 ;
  wire \accum[26]_i_1_n_0 ;
  wire \accum[27]_i_1_n_0 ;
  wire \accum[28]_i_1_n_0 ;
  wire \accum[29]_i_1_n_0 ;
  wire \accum[2]_i_1_n_0 ;
  wire \accum[30]_i_1_n_0 ;
  wire \accum[31]_i_1_n_0 ;
  wire \accum[3]_i_1_n_0 ;
  wire \accum[4]_i_1_n_0 ;
  wire \accum[5]_i_1_n_0 ;
  wire \accum[6]_i_1_n_0 ;
  wire \accum[7]_i_1_n_0 ;
  wire \accum[8]_i_1_n_0 ;
  wire \accum[9]_i_1_n_0 ;
  wire clk;
  wire [3:0]compute_cycles;
  wire [31:0]conv_out;
  wire [3:0]cycles;
  wire \cycles_reg_n_0_[0] ;
  wire \cycles_reg_n_0_[1] ;
  wire \cycles_reg_n_0_[2] ;
  wire \cycles_reg_n_0_[3] ;
  wire done;
  wire done_i_1_n_0;
  wire \gen_engine.u_core/ ;
  wire [3:0]idx;
  wire \idx[3]_i_1_n_0 ;
  wire \idx[3]_i_3_n_0 ;
  wire \idx_reg_n_0_[0] ;
  wire \idx_reg_n_0_[1] ;
  wire \idx_reg_n_0_[2] ;
  wire \idx_reg_n_0_[3] ;
  wire is_zero;
  wire [3:0]isolated;
  wire \isolated[3]_i_1_n_0 ;
  wire \isolated[3]_i_4_n_0 ;
  wire \isolated[3]_i_5_n_0 ;
  wire \isolated[3]_i_6_n_0 ;
  wire \isolated[3]_i_7_n_0 ;
  wire \isolated_reg_n_0_[0] ;
  wire \isolated_reg_n_0_[1] ;
  wire \isolated_reg_n_0_[2] ;
  wire \isolated_reg_n_0_[3] ;
  wire [15:0]p_0_in;
  wire [7:0]pixels__63;
  wire rst;
  wire [3:0]skip_count;
  wire start;
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

  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'hFFE2)) 
    \FSM_onehot_state[0]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[0] ),
        .I1(\FSM_onehot_state[2]_i_2_n_0 ),
        .I2(\FSM_onehot_state_reg_n_0_[2] ),
        .I3(rst),
        .O(\FSM_onehot_state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \FSM_onehot_state[1]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(\FSM_onehot_state[2]_i_2_n_0 ),
        .I2(\FSM_onehot_state_reg_n_0_[0] ),
        .I3(rst),
        .O(\FSM_onehot_state[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \FSM_onehot_state[2]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[2] ),
        .I1(\FSM_onehot_state[2]_i_2_n_0 ),
        .I2(\FSM_onehot_state_reg_n_0_[1] ),
        .I3(rst),
        .O(\FSM_onehot_state[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEEEEEEEEEFEEEEEE)) 
    \FSM_onehot_state[2]_i_2 
       (.I0(\FSM_onehot_state[2]_i_3_n_0 ),
        .I1(\FSM_onehot_state_reg_n_0_[2] ),
        .I2(\idx[3]_i_3_n_0 ),
        .I3(\FSM_onehot_state_reg_n_0_[1] ),
        .I4(\idx_reg_n_0_[3] ),
        .I5(\idx_reg_n_0_[2] ),
        .O(\FSM_onehot_state[2]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_onehot_state[2]_i_3 
       (.I0(\FSM_onehot_state_reg_n_0_[0] ),
        .I1(start),
        .O(\FSM_onehot_state[2]_i_3_n_0 ));
  (* FSM_ENCODED_STATES = "ST_IDLE:001,ST_COMPUTE:010,ST_DONE:100," *) 
  FDRE #(
    .INIT(1'b1)) 
    \FSM_onehot_state_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_onehot_state[0]_i_1_n_0 ),
        .Q(\FSM_onehot_state_reg_n_0_[0] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "ST_IDLE:001,ST_COMPUTE:010,ST_DONE:100," *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_onehot_state[1]_i_1_n_0 ),
        .Q(\FSM_onehot_state_reg_n_0_[1] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "ST_IDLE:001,ST_COMPUTE:010,ST_DONE:100," *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_onehot_state[2]_i_1_n_0 ),
        .Q(\FSM_onehot_state_reg_n_0_[2] ),
        .R(1'b0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry
       (.CI(1'b0),
        .CO({accum0_carry_n_0,NLW_accum0_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI(accum[3:0]),
        .O(accum0[3:0]),
        .S({accum0_carry_i_1_n_0,accum0_carry_i_2_n_0,accum0_carry_i_3_n_0,accum0_carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__0
       (.CI(accum0_carry_n_0),
        .CO({accum0_carry__0_n_0,NLW_accum0_carry__0_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI(accum[7:4]),
        .O(accum0[7:4]),
        .S({accum0_carry__0_i_1_n_0,accum0_carry__0_i_2_n_0,accum0_carry__0_i_3_n_0,accum0_carry__0_i_4_n_0}));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_1
       (.I0(accum[7]),
        .I1(p_0_in[7]),
        .O(accum0_carry__0_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_2
       (.I0(accum[6]),
        .I1(p_0_in[6]),
        .O(accum0_carry__0_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_3
       (.I0(accum[5]),
        .I1(p_0_in[5]),
        .O(accum0_carry__0_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__0_i_4
       (.I0(accum[4]),
        .I1(p_0_in[4]),
        .O(accum0_carry__0_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__1
       (.CI(accum0_carry__0_n_0),
        .CO({accum0_carry__1_n_0,NLW_accum0_carry__1_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI(accum[11:8]),
        .O(accum0[11:8]),
        .S({accum0_carry__1_i_1_n_0,accum0_carry__1_i_2_n_0,accum0_carry__1_i_3_n_0,accum0_carry__1_i_4_n_0}));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_1
       (.I0(accum[11]),
        .I1(p_0_in[11]),
        .O(accum0_carry__1_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_2
       (.I0(accum[10]),
        .I1(p_0_in[10]),
        .O(accum0_carry__1_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_3
       (.I0(accum[9]),
        .I1(p_0_in[9]),
        .O(accum0_carry__1_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__1_i_4
       (.I0(accum[8]),
        .I1(p_0_in[8]),
        .O(accum0_carry__1_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__2
       (.CI(accum0_carry__1_n_0),
        .CO({accum0_carry__2_n_0,NLW_accum0_carry__2_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({p_0_in[15],accum[14:12]}),
        .O(accum0[15:12]),
        .S({accum0_carry__2_i_1_n_0,accum0_carry__2_i_2_n_0,accum0_carry__2_i_3_n_0,accum0_carry__2_i_4_n_0}));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_1
       (.I0(p_0_in[15]),
        .I1(accum[15]),
        .O(accum0_carry__2_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_2
       (.I0(accum[14]),
        .I1(p_0_in[14]),
        .O(accum0_carry__2_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_3
       (.I0(accum[13]),
        .I1(p_0_in[13]),
        .O(accum0_carry__2_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__2_i_4
       (.I0(accum[12]),
        .I1(p_0_in[12]),
        .O(accum0_carry__2_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__3
       (.CI(accum0_carry__2_n_0),
        .CO({accum0_carry__3_n_0,NLW_accum0_carry__3_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({accum[18:16],accum0_carry__3_i_1_n_0}),
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
       (.I0(accum[18]),
        .I1(accum[19]),
        .O(accum0_carry__3_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__3_i_3
       (.I0(accum[17]),
        .I1(accum[18]),
        .O(accum0_carry__3_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__3_i_4
       (.I0(accum[16]),
        .I1(accum[17]),
        .O(accum0_carry__3_i_4_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry__3_i_5
       (.I0(p_0_in[15]),
        .I1(accum[16]),
        .O(accum0_carry__3_i_5_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__4
       (.CI(accum0_carry__3_n_0),
        .CO({accum0_carry__4_n_0,NLW_accum0_carry__4_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI(accum[22:19]),
        .O(accum0[23:20]),
        .S({accum0_carry__4_i_1_n_0,accum0_carry__4_i_2_n_0,accum0_carry__4_i_3_n_0,accum0_carry__4_i_4_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_1
       (.I0(accum[22]),
        .I1(accum[23]),
        .O(accum0_carry__4_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_2
       (.I0(accum[21]),
        .I1(accum[22]),
        .O(accum0_carry__4_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_3
       (.I0(accum[20]),
        .I1(accum[21]),
        .O(accum0_carry__4_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__4_i_4
       (.I0(accum[19]),
        .I1(accum[20]),
        .O(accum0_carry__4_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__5
       (.CI(accum0_carry__4_n_0),
        .CO({accum0_carry__5_n_0,NLW_accum0_carry__5_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI(accum[26:23]),
        .O(accum0[27:24]),
        .S({accum0_carry__5_i_1_n_0,accum0_carry__5_i_2_n_0,accum0_carry__5_i_3_n_0,accum0_carry__5_i_4_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_1
       (.I0(accum[26]),
        .I1(accum[27]),
        .O(accum0_carry__5_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_2
       (.I0(accum[25]),
        .I1(accum[26]),
        .O(accum0_carry__5_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_3
       (.I0(accum[24]),
        .I1(accum[25]),
        .O(accum0_carry__5_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__5_i_4
       (.I0(accum[23]),
        .I1(accum[24]),
        .O(accum0_carry__5_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 accum0_carry__6
       (.CI(accum0_carry__5_n_0),
        .CO(NLW_accum0_carry__6_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,accum[29:27]}),
        .O(accum0[31:28]),
        .S({accum0_carry__6_i_1_n_0,accum0_carry__6_i_2_n_0,accum0_carry__6_i_3_n_0,accum0_carry__6_i_4_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_1
       (.I0(accum[30]),
        .I1(accum[31]),
        .O(accum0_carry__6_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_2
       (.I0(accum[29]),
        .I1(accum[30]),
        .O(accum0_carry__6_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_3
       (.I0(accum[28]),
        .I1(accum[29]),
        .O(accum0_carry__6_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    accum0_carry__6_i_4
       (.I0(accum[27]),
        .I1(accum[28]),
        .O(accum0_carry__6_i_4_n_0));
  LUT3 #(
    .INIT(8'h96)) 
    accum0_carry_i_1
       (.I0(accum[3]),
        .I1(accum1__30_carry_n_7),
        .I2(accum1__0_carry_n_4),
        .O(accum0_carry_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry_i_2
       (.I0(accum[2]),
        .I1(p_0_in[2]),
        .O(accum0_carry_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry_i_3
       (.I0(accum[1]),
        .I1(p_0_in[1]),
        .O(accum0_carry_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    accum0_carry_i_4
       (.I0(accum[0]),
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
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__0_carry__0_i_1
       (.I0(pixels__63[0]),
        .I1(weights__63[6]),
        .I2(accum1__0_carry__0_i_10_n_0),
        .I3(weights__63[5]),
        .I4(is_zero),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_10
       (.I0(weights__63[4]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[2]),
        .O(accum1__0_carry__0_i_10_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry__0_i_11
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry__0_i_27_n_0),
        .I2(accum1__0_carry__0_i_28_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[5]),
        .O(weights__63[5]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_12
       (.I0(weights__63[3]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[2]),
        .O(accum1__0_carry__0_i_12_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry__0_i_13
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry__0_i_29_n_0),
        .I2(accum1__0_carry__0_i_30_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[4]),
        .O(weights__63[4]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_14
       (.I0(weights__63[2]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[2]),
        .O(accum1__0_carry__0_i_14_n_0));
  LUT3 #(
    .INIT(8'h2A)) 
    accum1__0_carry__0_i_15
       (.I0(weights__63[6]),
        .I1(\isolated[3]_i_5_n_0 ),
        .I2(\isolated[3]_i_4_n_0 ),
        .O(A[6]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_16
       (.I0(weights__63[5]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[2]),
        .O(accum1__0_carry__0_i_16_n_0));
  LUT3 #(
    .INIT(8'h2A)) 
    accum1__0_carry__0_i_17
       (.I0(weights__63[7]),
        .I1(\isolated[3]_i_5_n_0 ),
        .I2(\isolated[3]_i_4_n_0 ),
        .O(A[7]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_18
       (.I0(weights__63[4]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_18_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_19
       (.I0(weights__63[5]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[0]),
        .O(accum1__0_carry__0_i_19_n_0));
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__0_carry__0_i_2
       (.I0(pixels__63[0]),
        .I1(weights__63[5]),
        .I2(accum1__0_carry__0_i_12_n_0),
        .I3(weights__63[4]),
        .I4(is_zero),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_2_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_20
       (.I0(weights__63[5]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_20_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_21
       (.I0(weights__63[6]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[0]),
        .O(accum1__0_carry__0_i_21_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_22
       (.I0(weights__63[3]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_22_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_23
       (.I0(weights__63[4]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[0]),
        .O(accum1__0_carry__0_i_23_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__0_i_24
       (.I0(weights__63[2]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_24_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__0_i_25
       (.I0(accum1__0_carry__1_i_5_4[6]),
        .I1(accum1__0_carry__1_i_5_5[6]),
        .I2(accum1__0_carry__1_i_5_6[6]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[6]),
        .O(accum1__0_carry__0_i_25_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__0_i_26
       (.I0(accum1__0_carry__1_i_5_0[6]),
        .I1(accum1__0_carry__1_i_5_1[6]),
        .I2(accum1__0_carry__1_i_5_2[6]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[6]),
        .O(accum1__0_carry__0_i_26_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__0_i_27
       (.I0(accum1__0_carry__1_i_5_4[5]),
        .I1(accum1__0_carry__1_i_5_5[5]),
        .I2(accum1__0_carry__1_i_5_6[5]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[5]),
        .O(accum1__0_carry__0_i_27_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__0_i_28
       (.I0(accum1__0_carry__1_i_5_0[5]),
        .I1(accum1__0_carry__1_i_5_1[5]),
        .I2(accum1__0_carry__1_i_5_2[5]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[5]),
        .O(accum1__0_carry__0_i_28_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__0_i_29
       (.I0(accum1__0_carry__1_i_5_4[4]),
        .I1(accum1__0_carry__1_i_5_5[4]),
        .I2(accum1__0_carry__1_i_5_6[4]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[4]),
        .O(accum1__0_carry__0_i_29_n_0));
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__0_carry__0_i_3
       (.I0(pixels__63[0]),
        .I1(weights__63[4]),
        .I2(accum1__0_carry__0_i_14_n_0),
        .I3(weights__63[3]),
        .I4(is_zero),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_3_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__0_i_30
       (.I0(accum1__0_carry__1_i_5_0[4]),
        .I1(accum1__0_carry__1_i_5_1[4]),
        .I2(accum1__0_carry__1_i_5_2[4]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[4]),
        .O(accum1__0_carry__0_i_30_n_0));
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__0_carry__0_i_4
       (.I0(pixels__63[0]),
        .I1(weights__63[3]),
        .I2(accum1__0_carry_i_10_n_0),
        .I3(weights__63[2]),
        .I4(is_zero),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__0_i_4_n_0));
  LUT6 #(
    .INIT(64'h6A95956A956A956A)) 
    accum1__0_carry__0_i_5
       (.I0(accum1__0_carry__0_i_1_n_0),
        .I1(B[1]),
        .I2(A[6]),
        .I3(accum1__0_carry__0_i_16_n_0),
        .I4(A[7]),
        .I5(B[0]),
        .O(accum1__0_carry__0_i_5_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__0_carry__0_i_6
       (.I0(accum1__0_carry__0_i_18_n_0),
        .I1(accum1__0_carry__0_i_12_n_0),
        .I2(accum1__0_carry__0_i_19_n_0),
        .I3(accum1__0_carry__0_i_20_n_0),
        .I4(accum1__0_carry__0_i_10_n_0),
        .I5(accum1__0_carry__0_i_21_n_0),
        .O(accum1__0_carry__0_i_6_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__0_carry__0_i_7
       (.I0(accum1__0_carry__0_i_22_n_0),
        .I1(accum1__0_carry__0_i_14_n_0),
        .I2(accum1__0_carry__0_i_23_n_0),
        .I3(accum1__0_carry__0_i_18_n_0),
        .I4(accum1__0_carry__0_i_12_n_0),
        .I5(accum1__0_carry__0_i_19_n_0),
        .O(accum1__0_carry__0_i_7_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__0_carry__0_i_8
       (.I0(accum1__0_carry__0_i_24_n_0),
        .I1(accum1__0_carry_i_10_n_0),
        .I2(accum1__0_carry_i_17_n_0),
        .I3(accum1__0_carry__0_i_22_n_0),
        .I4(accum1__0_carry__0_i_14_n_0),
        .I5(accum1__0_carry__0_i_23_n_0),
        .O(accum1__0_carry__0_i_8_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry__0_i_9
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry__0_i_25_n_0),
        .I2(accum1__0_carry__0_i_26_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[6]),
        .O(weights__63[6]));
  CARRY4 accum1__0_carry__1
       (.CI(accum1__0_carry__0_n_0),
        .CO({NLW_accum1__0_carry__1_CO_UNCONNECTED[3],accum1__0_carry__1_n_1,NLW_accum1__0_carry__1_CO_UNCONNECTED[1:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,accum1__0_carry__1_i_1_n_0,accum1__0_carry__1_i_2_n_0}),
        .O({NLW_accum1__0_carry__1_O_UNCONNECTED[3:2],accum1__0_carry__1_n_6,accum1__0_carry__1_n_7}),
        .S({1'b0,1'b1,accum1__0_carry__1_i_3_n_0,accum1__0_carry__1_i_4_n_0}));
  LUT5 #(
    .INIT(32'h00700000)) 
    accum1__0_carry__1_i_1
       (.I0(pixels__63[1]),
        .I1(weights__63[7]),
        .I2(pixels__63[2]),
        .I3(is_zero),
        .I4(weights__63[6]),
        .O(accum1__0_carry__1_i_1_n_0));
  LUT6 #(
    .INIT(64'h0F0F088F0F0F8F8F)) 
    accum1__0_carry__1_i_2
       (.I0(pixels__63[2]),
        .I1(weights__63[5]),
        .I2(accum1__0_carry__1_i_6_n_0),
        .I3(weights__63[7]),
        .I4(is_zero),
        .I5(pixels__63[0]),
        .O(accum1__0_carry__1_i_2_n_0));
  LUT5 #(
    .INIT(32'hFF2FFF5F)) 
    accum1__0_carry__1_i_3
       (.I0(weights__63[6]),
        .I1(pixels__63[1]),
        .I2(pixels__63[2]),
        .I3(is_zero),
        .I4(weights__63[7]),
        .O(accum1__0_carry__1_i_3_n_0));
  LUT6 #(
    .INIT(64'h2450F30F4BFFC3FF)) 
    accum1__0_carry__1_i_4
       (.I0(B[0]),
        .I1(A[5]),
        .I2(A[6]),
        .I3(B[2]),
        .I4(A[7]),
        .I5(B[1]),
        .O(accum1__0_carry__1_i_4_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry__1_i_5
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry__1_i_8_n_0),
        .I2(accum1__0_carry__1_i_9_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[7]),
        .O(weights__63[7]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry__1_i_6
       (.I0(weights__63[6]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[1]),
        .O(accum1__0_carry__1_i_6_n_0));
  LUT3 #(
    .INIT(8'h2A)) 
    accum1__0_carry__1_i_7
       (.I0(weights__63[5]),
        .I1(\isolated[3]_i_5_n_0 ),
        .I2(\isolated[3]_i_4_n_0 ),
        .O(A[5]));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__1_i_8
       (.I0(accum1__0_carry__1_i_5_4[7]),
        .I1(accum1__0_carry__1_i_5_5[7]),
        .I2(accum1__0_carry__1_i_5_6[7]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[7]),
        .O(accum1__0_carry__1_i_8_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry__1_i_9
       (.I0(accum1__0_carry__1_i_5_0[7]),
        .I1(accum1__0_carry__1_i_5_1[7]),
        .I2(accum1__0_carry__1_i_5_2[7]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[7]),
        .O(accum1__0_carry__1_i_9_n_0));
  LUT6 #(
    .INIT(64'h0F0F78870F0F8787)) 
    accum1__0_carry_i_1
       (.I0(pixels__63[0]),
        .I1(weights__63[3]),
        .I2(accum1__0_carry_i_10_n_0),
        .I3(weights__63[2]),
        .I4(is_zero),
        .I5(pixels__63[1]),
        .O(accum1__0_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry_i_10
       (.I0(weights__63[1]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[2]),
        .O(accum1__0_carry_i_10_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry_i_11
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry_i_27_n_0),
        .I2(accum1__0_carry_i_28_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[2]),
        .O(weights__63[2]));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry_i_12
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry_i_29_n_0),
        .I2(accum1__0_carry_i_30_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[1]),
        .O(pixels__63[1]));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry_i_13
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry_i_31_n_0),
        .I2(accum1__0_carry_i_32_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[1]),
        .O(weights__63[1]));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry_i_14
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry_i_33_n_0),
        .I2(accum1__0_carry_i_34_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[2]),
        .O(pixels__63[2]));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry_i_15
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry_i_35_n_0),
        .I2(accum1__0_carry_i_36_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[0]),
        .O(weights__63[0]));
  LUT3 #(
    .INIT(8'h2A)) 
    accum1__0_carry_i_16
       (.I0(weights__63[2]),
        .I1(\isolated[3]_i_5_n_0 ),
        .I2(\isolated[3]_i_4_n_0 ),
        .O(A[2]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__0_carry_i_17
       (.I0(weights__63[3]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[0]),
        .O(accum1__0_carry_i_17_n_0));
  LUT3 #(
    .INIT(8'h2A)) 
    accum1__0_carry_i_18
       (.I0(weights__63[1]),
        .I1(\isolated[3]_i_5_n_0 ),
        .I2(\isolated[3]_i_4_n_0 ),
        .O(A[1]));
  LUT3 #(
    .INIT(8'h70)) 
    accum1__0_carry_i_19
       (.I0(\isolated[3]_i_7_n_0 ),
        .I1(\isolated[3]_i_6_n_0 ),
        .I2(pixels__63[1]),
        .O(B[1]));
  LUT5 #(
    .INIT(32'h00780088)) 
    accum1__0_carry_i_2
       (.I0(pixels__63[1]),
        .I1(weights__63[1]),
        .I2(pixels__63[2]),
        .I3(is_zero),
        .I4(weights__63[0]),
        .O(accum1__0_carry_i_2_n_0));
  LUT3 #(
    .INIT(8'h2A)) 
    accum1__0_carry_i_20
       (.I0(weights__63[0]),
        .I1(\isolated[3]_i_5_n_0 ),
        .I2(\isolated[3]_i_4_n_0 ),
        .O(A[0]));
  LUT3 #(
    .INIT(8'h70)) 
    accum1__0_carry_i_21
       (.I0(\isolated[3]_i_7_n_0 ),
        .I1(\isolated[3]_i_6_n_0 ),
        .I2(pixels__63[2]),
        .O(B[2]));
  LUT3 #(
    .INIT(8'h70)) 
    accum1__0_carry_i_22
       (.I0(\isolated[3]_i_7_n_0 ),
        .I1(\isolated[3]_i_6_n_0 ),
        .I2(pixels__63[0]),
        .O(B[0]));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_23
       (.I0(accum1__59_carry_i_8_4[0]),
        .I1(accum1__59_carry_i_8_5[0]),
        .I2(accum1__59_carry_i_8_6[0]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[0]),
        .O(accum1__0_carry_i_23_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_24
       (.I0(accum1__59_carry_i_8_0[0]),
        .I1(accum1__59_carry_i_8_1[0]),
        .I2(accum1__59_carry_i_8_2[0]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[0]),
        .O(accum1__0_carry_i_24_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_25
       (.I0(accum1__0_carry__1_i_5_4[3]),
        .I1(accum1__0_carry__1_i_5_5[3]),
        .I2(accum1__0_carry__1_i_5_6[3]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[3]),
        .O(accum1__0_carry_i_25_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_26
       (.I0(accum1__0_carry__1_i_5_0[3]),
        .I1(accum1__0_carry__1_i_5_1[3]),
        .I2(accum1__0_carry__1_i_5_2[3]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[3]),
        .O(accum1__0_carry_i_26_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_27
       (.I0(accum1__0_carry__1_i_5_4[2]),
        .I1(accum1__0_carry__1_i_5_5[2]),
        .I2(accum1__0_carry__1_i_5_6[2]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[2]),
        .O(accum1__0_carry_i_27_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_28
       (.I0(accum1__0_carry__1_i_5_0[2]),
        .I1(accum1__0_carry__1_i_5_1[2]),
        .I2(accum1__0_carry__1_i_5_2[2]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[2]),
        .O(accum1__0_carry_i_28_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_29
       (.I0(accum1__59_carry_i_8_4[1]),
        .I1(accum1__59_carry_i_8_5[1]),
        .I2(accum1__59_carry_i_8_6[1]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[1]),
        .O(accum1__0_carry_i_29_n_0));
  LUT3 #(
    .INIT(8'h20)) 
    accum1__0_carry_i_3
       (.I0(weights__63[1]),
        .I1(is_zero),
        .I2(pixels__63[0]),
        .O(accum1__0_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_30
       (.I0(accum1__59_carry_i_8_0[1]),
        .I1(accum1__59_carry_i_8_1[1]),
        .I2(accum1__59_carry_i_8_2[1]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[1]),
        .O(accum1__0_carry_i_30_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_31
       (.I0(accum1__0_carry__1_i_5_4[1]),
        .I1(accum1__0_carry__1_i_5_5[1]),
        .I2(accum1__0_carry__1_i_5_6[1]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[1]),
        .O(accum1__0_carry_i_31_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_32
       (.I0(accum1__0_carry__1_i_5_0[1]),
        .I1(accum1__0_carry__1_i_5_1[1]),
        .I2(accum1__0_carry__1_i_5_2[1]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[1]),
        .O(accum1__0_carry_i_32_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_33
       (.I0(accum1__59_carry_i_8_4[2]),
        .I1(accum1__59_carry_i_8_5[2]),
        .I2(accum1__59_carry_i_8_6[2]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[2]),
        .O(accum1__0_carry_i_33_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_34
       (.I0(accum1__59_carry_i_8_0[2]),
        .I1(accum1__59_carry_i_8_1[2]),
        .I2(accum1__59_carry_i_8_2[2]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[2]),
        .O(accum1__0_carry_i_34_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_35
       (.I0(accum1__0_carry__1_i_5_4[0]),
        .I1(accum1__0_carry__1_i_5_5[0]),
        .I2(accum1__0_carry__1_i_5_6[0]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_7[0]),
        .O(accum1__0_carry_i_35_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__0_carry_i_36
       (.I0(accum1__0_carry__1_i_5_0[0]),
        .I1(accum1__0_carry__1_i_5_1[0]),
        .I2(accum1__0_carry__1_i_5_2[0]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__0_carry__1_i_5_3[0]),
        .O(accum1__0_carry_i_36_n_0));
  LUT6 #(
    .INIT(64'h99C369C399339933)) 
    accum1__0_carry_i_4
       (.I0(A[2]),
        .I1(accum1__0_carry_i_17_n_0),
        .I2(A[1]),
        .I3(B[1]),
        .I4(A[0]),
        .I5(B[2]),
        .O(accum1__0_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    accum1__0_carry_i_5
       (.I0(A[0]),
        .I1(B[2]),
        .I2(A[1]),
        .I3(B[1]),
        .I4(B[0]),
        .I5(A[2]),
        .O(accum1__0_carry_i_5_n_0));
  LUT5 #(
    .INIT(32'h00780088)) 
    accum1__0_carry_i_6
       (.I0(pixels__63[0]),
        .I1(weights__63[1]),
        .I2(pixels__63[1]),
        .I3(is_zero),
        .I4(weights__63[0]),
        .O(accum1__0_carry_i_6_n_0));
  LUT3 #(
    .INIT(8'h20)) 
    accum1__0_carry_i_7
       (.I0(weights__63[0]),
        .I1(is_zero),
        .I2(pixels__63[0]),
        .O(accum1__0_carry_i_7_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry_i_8
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry_i_23_n_0),
        .I2(accum1__0_carry_i_24_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[0]),
        .O(pixels__63[0]));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__0_carry_i_9
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__0_carry_i_25_n_0),
        .I2(accum1__0_carry_i_26_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(Q[3]),
        .O(weights__63[3]));
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
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__30_carry__0_i_1
       (.I0(pixels__63[3]),
        .I1(weights__63[6]),
        .I2(accum1__30_carry__0_i_9_n_0),
        .I3(weights__63[5]),
        .I4(is_zero),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_10
       (.I0(weights__63[3]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[5]),
        .O(accum1__30_carry__0_i_10_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_11
       (.I0(weights__63[2]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[5]),
        .O(accum1__30_carry__0_i_11_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_12
       (.I0(weights__63[7]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[3]),
        .O(accum1__30_carry__0_i_12_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_13
       (.I0(weights__63[4]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_13_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_14
       (.I0(weights__63[5]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[3]),
        .O(accum1__30_carry__0_i_14_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_15
       (.I0(weights__63[5]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_15_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_16
       (.I0(weights__63[6]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[3]),
        .O(accum1__30_carry__0_i_16_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_17
       (.I0(weights__63[3]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_17_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_18
       (.I0(weights__63[4]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[3]),
        .O(accum1__30_carry__0_i_18_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_19
       (.I0(weights__63[2]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_19_n_0));
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__30_carry__0_i_2
       (.I0(pixels__63[3]),
        .I1(weights__63[5]),
        .I2(accum1__30_carry__0_i_10_n_0),
        .I3(weights__63[4]),
        .I4(is_zero),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_2_n_0));
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__30_carry__0_i_3
       (.I0(pixels__63[3]),
        .I1(weights__63[4]),
        .I2(accum1__30_carry__0_i_11_n_0),
        .I3(weights__63[3]),
        .I4(is_zero),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_3_n_0));
  LUT6 #(
    .INIT(64'h00008F0800000808)) 
    accum1__30_carry__0_i_4
       (.I0(pixels__63[3]),
        .I1(weights__63[3]),
        .I2(accum1__30_carry_i_9_n_0),
        .I3(weights__63[2]),
        .I4(is_zero),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__0_i_4_n_0));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    accum1__30_carry__0_i_5
       (.I0(accum1__30_carry__0_i_1_n_0),
        .I1(B[4]),
        .I2(A[6]),
        .I3(B[5]),
        .I4(A[5]),
        .I5(accum1__30_carry__0_i_12_n_0),
        .O(accum1__30_carry__0_i_5_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__30_carry__0_i_6
       (.I0(accum1__30_carry__0_i_13_n_0),
        .I1(accum1__30_carry__0_i_10_n_0),
        .I2(accum1__30_carry__0_i_14_n_0),
        .I3(accum1__30_carry__0_i_15_n_0),
        .I4(accum1__30_carry__0_i_9_n_0),
        .I5(accum1__30_carry__0_i_16_n_0),
        .O(accum1__30_carry__0_i_6_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__30_carry__0_i_7
       (.I0(accum1__30_carry__0_i_17_n_0),
        .I1(accum1__30_carry__0_i_11_n_0),
        .I2(accum1__30_carry__0_i_18_n_0),
        .I3(accum1__30_carry__0_i_13_n_0),
        .I4(accum1__30_carry__0_i_10_n_0),
        .I5(accum1__30_carry__0_i_14_n_0),
        .O(accum1__30_carry__0_i_7_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    accum1__30_carry__0_i_8
       (.I0(accum1__30_carry__0_i_19_n_0),
        .I1(accum1__30_carry_i_9_n_0),
        .I2(accum1__30_carry_i_12_n_0),
        .I3(accum1__30_carry__0_i_17_n_0),
        .I4(accum1__30_carry__0_i_11_n_0),
        .I5(accum1__30_carry__0_i_18_n_0),
        .O(accum1__30_carry__0_i_8_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__0_i_9
       (.I0(weights__63[4]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[5]),
        .O(accum1__30_carry__0_i_9_n_0));
  CARRY4 accum1__30_carry__1
       (.CI(accum1__30_carry__0_n_0),
        .CO({NLW_accum1__30_carry__1_CO_UNCONNECTED[3],accum1__30_carry__1_n_1,NLW_accum1__30_carry__1_CO_UNCONNECTED[1:0]}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,accum1__30_carry__1_i_1_n_0,accum1__30_carry__1_i_2_n_0}),
        .O({NLW_accum1__30_carry__1_O_UNCONNECTED[3:2],accum1__30_carry__1_n_6,accum1__30_carry__1_n_7}),
        .S({1'b0,1'b1,accum1__30_carry__1_i_3_n_0,accum1__30_carry__1_i_4_n_0}));
  LUT5 #(
    .INIT(32'h00700000)) 
    accum1__30_carry__1_i_1
       (.I0(pixels__63[4]),
        .I1(weights__63[7]),
        .I2(pixels__63[5]),
        .I3(is_zero),
        .I4(weights__63[6]),
        .O(accum1__30_carry__1_i_1_n_0));
  LUT6 #(
    .INIT(64'h0F0F088F0F0F8F8F)) 
    accum1__30_carry__1_i_2
       (.I0(pixels__63[5]),
        .I1(weights__63[5]),
        .I2(accum1__30_carry__1_i_5_n_0),
        .I3(weights__63[7]),
        .I4(is_zero),
        .I5(pixels__63[3]),
        .O(accum1__30_carry__1_i_2_n_0));
  LUT5 #(
    .INIT(32'hFF2FFF5F)) 
    accum1__30_carry__1_i_3
       (.I0(weights__63[6]),
        .I1(pixels__63[4]),
        .I2(pixels__63[5]),
        .I3(is_zero),
        .I4(weights__63[7]),
        .O(accum1__30_carry__1_i_3_n_0));
  LUT6 #(
    .INIT(64'h2450F30F4BFFC3FF)) 
    accum1__30_carry__1_i_4
       (.I0(B[3]),
        .I1(A[5]),
        .I2(A[6]),
        .I3(B[5]),
        .I4(A[7]),
        .I5(B[4]),
        .O(accum1__30_carry__1_i_4_n_0));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry__1_i_5
       (.I0(weights__63[6]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[4]),
        .O(accum1__30_carry__1_i_5_n_0));
  LUT6 #(
    .INIT(64'h0F0F78870F0F8787)) 
    accum1__30_carry_i_1
       (.I0(pixels__63[3]),
        .I1(weights__63[3]),
        .I2(accum1__30_carry_i_9_n_0),
        .I3(weights__63[2]),
        .I4(is_zero),
        .I5(pixels__63[4]),
        .O(accum1__30_carry_i_1_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__30_carry_i_10
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__30_carry_i_18_n_0),
        .I2(accum1__30_carry_i_19_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[4]),
        .O(pixels__63[4]));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__30_carry_i_11
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__30_carry_i_20_n_0),
        .I2(accum1__30_carry_i_21_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[5]),
        .O(pixels__63[5]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry_i_12
       (.I0(weights__63[3]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[3]),
        .O(accum1__30_carry_i_12_n_0));
  LUT3 #(
    .INIT(8'h70)) 
    accum1__30_carry_i_13
       (.I0(\isolated[3]_i_7_n_0 ),
        .I1(\isolated[3]_i_6_n_0 ),
        .I2(pixels__63[5]),
        .O(B[5]));
  LUT3 #(
    .INIT(8'h70)) 
    accum1__30_carry_i_14
       (.I0(\isolated[3]_i_7_n_0 ),
        .I1(\isolated[3]_i_6_n_0 ),
        .I2(pixels__63[4]),
        .O(B[4]));
  LUT3 #(
    .INIT(8'h70)) 
    accum1__30_carry_i_15
       (.I0(\isolated[3]_i_7_n_0 ),
        .I1(\isolated[3]_i_6_n_0 ),
        .I2(pixels__63[3]),
        .O(B[3]));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__30_carry_i_16
       (.I0(accum1__59_carry_i_8_4[3]),
        .I1(accum1__59_carry_i_8_5[3]),
        .I2(accum1__59_carry_i_8_6[3]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[3]),
        .O(accum1__30_carry_i_16_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__30_carry_i_17
       (.I0(accum1__59_carry_i_8_0[3]),
        .I1(accum1__59_carry_i_8_1[3]),
        .I2(accum1__59_carry_i_8_2[3]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[3]),
        .O(accum1__30_carry_i_17_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__30_carry_i_18
       (.I0(accum1__59_carry_i_8_4[4]),
        .I1(accum1__59_carry_i_8_5[4]),
        .I2(accum1__59_carry_i_8_6[4]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[4]),
        .O(accum1__30_carry_i_18_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__30_carry_i_19
       (.I0(accum1__59_carry_i_8_0[4]),
        .I1(accum1__59_carry_i_8_1[4]),
        .I2(accum1__59_carry_i_8_2[4]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[4]),
        .O(accum1__30_carry_i_19_n_0));
  LUT5 #(
    .INIT(32'h00780088)) 
    accum1__30_carry_i_2
       (.I0(pixels__63[4]),
        .I1(weights__63[1]),
        .I2(pixels__63[5]),
        .I3(is_zero),
        .I4(weights__63[0]),
        .O(accum1__30_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__30_carry_i_20
       (.I0(accum1__59_carry_i_8_4[5]),
        .I1(accum1__59_carry_i_8_5[5]),
        .I2(accum1__59_carry_i_8_6[5]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[5]),
        .O(accum1__30_carry_i_20_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__30_carry_i_21
       (.I0(accum1__59_carry_i_8_0[5]),
        .I1(accum1__59_carry_i_8_1[5]),
        .I2(accum1__59_carry_i_8_2[5]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[5]),
        .O(accum1__30_carry_i_21_n_0));
  LUT3 #(
    .INIT(8'h20)) 
    accum1__30_carry_i_3
       (.I0(weights__63[1]),
        .I1(is_zero),
        .I2(pixels__63[3]),
        .O(accum1__30_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h96999999CC333333)) 
    accum1__30_carry_i_4
       (.I0(A[2]),
        .I1(accum1__30_carry_i_12_n_0),
        .I2(A[0]),
        .I3(A[1]),
        .I4(B[5]),
        .I5(B[4]),
        .O(accum1__30_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    accum1__30_carry_i_5
       (.I0(A[0]),
        .I1(B[5]),
        .I2(A[1]),
        .I3(B[4]),
        .I4(B[3]),
        .I5(A[2]),
        .O(accum1__30_carry_i_5_n_0));
  LUT5 #(
    .INIT(32'h00780088)) 
    accum1__30_carry_i_6
       (.I0(pixels__63[3]),
        .I1(weights__63[1]),
        .I2(pixels__63[4]),
        .I3(is_zero),
        .I4(weights__63[0]),
        .O(accum1__30_carry_i_6_n_0));
  LUT3 #(
    .INIT(8'h20)) 
    accum1__30_carry_i_7
       (.I0(weights__63[0]),
        .I1(is_zero),
        .I2(pixels__63[3]),
        .O(accum1__30_carry_i_7_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__30_carry_i_8
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__30_carry_i_16_n_0),
        .I2(accum1__30_carry_i_17_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[3]),
        .O(pixels__63[3]));
  LUT6 #(
    .INIT(64'hFFD5D5D5FFFFFFFF)) 
    accum1__30_carry_i_9
       (.I0(weights__63[1]),
        .I1(\isolated[3]_i_4_n_0 ),
        .I2(\isolated[3]_i_5_n_0 ),
        .I3(\isolated[3]_i_6_n_0 ),
        .I4(\isolated[3]_i_7_n_0 ),
        .I5(pixels__63[5]),
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
  LUT5 #(
    .INIT(32'h00700000)) 
    accum1__59_carry__0_i_1
       (.I0(pixels__63[7]),
        .I1(weights__63[5]),
        .I2(pixels__63[6]),
        .I3(is_zero),
        .I4(weights__63[6]),
        .O(accum1__59_carry__0_i_1_n_0));
  LUT5 #(
    .INIT(32'h00700000)) 
    accum1__59_carry__0_i_2
       (.I0(pixels__63[7]),
        .I1(weights__63[4]),
        .I2(pixels__63[6]),
        .I3(is_zero),
        .I4(weights__63[5]),
        .O(accum1__59_carry__0_i_2_n_0));
  LUT5 #(
    .INIT(32'h00700000)) 
    accum1__59_carry__0_i_3
       (.I0(pixels__63[7]),
        .I1(weights__63[3]),
        .I2(pixels__63[6]),
        .I3(is_zero),
        .I4(weights__63[4]),
        .O(accum1__59_carry__0_i_3_n_0));
  LUT5 #(
    .INIT(32'h00700000)) 
    accum1__59_carry__0_i_4
       (.I0(pixels__63[7]),
        .I1(weights__63[2]),
        .I2(pixels__63[6]),
        .I3(is_zero),
        .I4(weights__63[3]),
        .O(accum1__59_carry__0_i_4_n_0));
  LUT6 #(
    .INIT(64'h0703080C0C000C00)) 
    accum1__59_carry__0_i_5
       (.I0(weights__63[5]),
        .I1(weights__63[6]),
        .I2(is_zero),
        .I3(pixels__63[7]),
        .I4(weights__63[7]),
        .I5(pixels__63[6]),
        .O(accum1__59_carry__0_i_5_n_0));
  LUT6 #(
    .INIT(64'hF8FCF7F3F3FFF3FF)) 
    accum1__59_carry__0_i_6
       (.I0(weights__63[4]),
        .I1(weights__63[5]),
        .I2(is_zero),
        .I3(pixels__63[7]),
        .I4(weights__63[6]),
        .I5(pixels__63[6]),
        .O(accum1__59_carry__0_i_6_n_0));
  LUT6 #(
    .INIT(64'hF8FCF7F3F3FFF3FF)) 
    accum1__59_carry__0_i_7
       (.I0(weights__63[3]),
        .I1(weights__63[4]),
        .I2(is_zero),
        .I3(pixels__63[7]),
        .I4(weights__63[5]),
        .I5(pixels__63[6]),
        .O(accum1__59_carry__0_i_7_n_0));
  LUT6 #(
    .INIT(64'hF8FCF7F3F3FFF3FF)) 
    accum1__59_carry__0_i_8
       (.I0(weights__63[2]),
        .I1(weights__63[3]),
        .I2(is_zero),
        .I3(pixels__63[7]),
        .I4(weights__63[4]),
        .I5(pixels__63[6]),
        .O(accum1__59_carry__0_i_8_n_0));
  CARRY4 accum1__59_carry__1
       (.CI(accum1__59_carry__0_n_0),
        .CO(NLW_accum1__59_carry__1_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,accum1__59_carry__1_i_1_n_0}),
        .O({NLW_accum1__59_carry__1_O_UNCONNECTED[3:2],accum1__59_carry__1_n_6,accum1__59_carry__1_n_7}),
        .S({1'b0,1'b0,1'b1,accum1__59_carry__1_i_2_n_0}));
  LUT5 #(
    .INIT(32'hFF07FF77)) 
    accum1__59_carry__1_i_1
       (.I0(pixels__63[7]),
        .I1(weights__63[6]),
        .I2(pixels__63[6]),
        .I3(is_zero),
        .I4(weights__63[7]),
        .O(accum1__59_carry__1_i_1_n_0));
  LUT5 #(
    .INIT(32'hFFE5FF3F)) 
    accum1__59_carry__1_i_2
       (.I0(pixels__63[6]),
        .I1(weights__63[6]),
        .I2(pixels__63[7]),
        .I3(is_zero),
        .I4(weights__63[7]),
        .O(accum1__59_carry__1_i_2_n_0));
  LUT3 #(
    .INIT(8'hDF)) 
    accum1__59_carry_i_1
       (.I0(weights__63[1]),
        .I1(is_zero),
        .I2(pixels__63[7]),
        .O(accum1__59_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__59_carry_i_10
       (.I0(accum1__59_carry_i_8_4[7]),
        .I1(accum1__59_carry_i_8_5[7]),
        .I2(accum1__59_carry_i_8_6[7]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[7]),
        .O(accum1__59_carry_i_10_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__59_carry_i_11
       (.I0(accum1__59_carry_i_8_0[7]),
        .I1(accum1__59_carry_i_8_1[7]),
        .I2(accum1__59_carry_i_8_2[7]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[7]),
        .O(accum1__59_carry_i_11_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__59_carry_i_12
       (.I0(accum1__59_carry_i_8_4[6]),
        .I1(accum1__59_carry_i_8_5[6]),
        .I2(accum1__59_carry_i_8_6[6]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_7[6]),
        .O(accum1__59_carry_i_12_n_0));
  LUT6 #(
    .INIT(64'hCCFFAAF0CC00AAF0)) 
    accum1__59_carry_i_13
       (.I0(accum1__59_carry_i_8_0[6]),
        .I1(accum1__59_carry_i_8_1[6]),
        .I2(accum1__59_carry_i_8_2[6]),
        .I3(\idx_reg_n_0_[0] ),
        .I4(\idx_reg_n_0_[1] ),
        .I5(accum1__59_carry_i_8_3[6]),
        .O(accum1__59_carry_i_13_n_0));
  LUT3 #(
    .INIT(8'h20)) 
    accum1__59_carry_i_2
       (.I0(pixels__63[7]),
        .I1(is_zero),
        .I2(weights__63[1]),
        .O(accum1__59_carry_i_2_n_0));
  LUT3 #(
    .INIT(8'hDF)) 
    accum1__59_carry_i_3
       (.I0(weights__63[0]),
        .I1(is_zero),
        .I2(pixels__63[7]),
        .O(accum1__59_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h090F060006000600)) 
    accum1__59_carry_i_4
       (.I0(weights__63[1]),
        .I1(weights__63[2]),
        .I2(is_zero),
        .I3(pixels__63[7]),
        .I4(weights__63[3]),
        .I5(pixels__63[6]),
        .O(accum1__59_carry_i_4_n_0));
  LUT5 #(
    .INIT(32'h00780088)) 
    accum1__59_carry_i_5
       (.I0(pixels__63[7]),
        .I1(weights__63[1]),
        .I2(pixels__63[6]),
        .I3(is_zero),
        .I4(weights__63[2]),
        .O(accum1__59_carry_i_5_n_0));
  LUT5 #(
    .INIT(32'hFF87FF77)) 
    accum1__59_carry_i_6
       (.I0(pixels__63[7]),
        .I1(weights__63[0]),
        .I2(pixels__63[6]),
        .I3(is_zero),
        .I4(weights__63[1]),
        .O(accum1__59_carry_i_6_n_0));
  LUT3 #(
    .INIT(8'h20)) 
    accum1__59_carry_i_7
       (.I0(weights__63[0]),
        .I1(is_zero),
        .I2(pixels__63[6]),
        .O(accum1__59_carry_i_7_n_0));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__59_carry_i_8
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__59_carry_i_10_n_0),
        .I2(accum1__59_carry_i_11_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[7]),
        .O(pixels__63[7]));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    accum1__59_carry_i_9
       (.I0(\idx_reg_n_0_[2] ),
        .I1(accum1__59_carry_i_12_n_0),
        .I2(accum1__59_carry_i_13_n_0),
        .I3(\idx_reg_n_0_[3] ),
        .I4(accum1__59_carry_i_6_0[6]),
        .O(pixels__63[6]));
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
  (* HLUTNM = "lutpair2" *) 
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
  (* HLUTNM = "lutpair2" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[0]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[0]),
        .O(\accum[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[10]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[10]),
        .O(\accum[10]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[11]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[11]),
        .O(\accum[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[12]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[12]),
        .O(\accum[12]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[13]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[13]),
        .O(\accum[13]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[14]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[14]),
        .O(\accum[14]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[15]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[15]),
        .O(\accum[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[16]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[16]),
        .O(\accum[16]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[17]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[17]),
        .O(\accum[17]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[18]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[18]),
        .O(\accum[18]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[19]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[19]),
        .O(\accum[19]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[1]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[1]),
        .O(\accum[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[20]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[20]),
        .O(\accum[20]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[21]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[21]),
        .O(\accum[21]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[22]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[22]),
        .O(\accum[22]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[23]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[23]),
        .O(\accum[23]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[24]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[24]),
        .O(\accum[24]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[25]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[25]),
        .O(\accum[25]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[26]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[26]),
        .O(\accum[26]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[27]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[27]),
        .O(\accum[27]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[28]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[28]),
        .O(\accum[28]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[29]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[29]),
        .O(\accum[29]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[2]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[2]),
        .O(\accum[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[30]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[30]),
        .O(\accum[30]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[31]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[31]),
        .O(\accum[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[3]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[3]),
        .O(\accum[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[4]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[4]),
        .O(\accum[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[5]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[5]),
        .O(\accum[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[6]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[6]),
        .O(\accum[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[7]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[7]),
        .O(\accum[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[8]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[8]),
        .O(\accum[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \accum[9]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(accum0[9]),
        .O(\accum[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[0] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[0]_i_1_n_0 ),
        .Q(accum[0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[10] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[10]_i_1_n_0 ),
        .Q(accum[10]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[11] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[11]_i_1_n_0 ),
        .Q(accum[11]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[12] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[12]_i_1_n_0 ),
        .Q(accum[12]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[13] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[13]_i_1_n_0 ),
        .Q(accum[13]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[14] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[14]_i_1_n_0 ),
        .Q(accum[14]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[15] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[15]_i_1_n_0 ),
        .Q(accum[15]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[16] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[16]_i_1_n_0 ),
        .Q(accum[16]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[17] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[17]_i_1_n_0 ),
        .Q(accum[17]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[18] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[18]_i_1_n_0 ),
        .Q(accum[18]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[19] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[19]_i_1_n_0 ),
        .Q(accum[19]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[1] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[1]_i_1_n_0 ),
        .Q(accum[1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[20] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[20]_i_1_n_0 ),
        .Q(accum[20]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[21] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[21]_i_1_n_0 ),
        .Q(accum[21]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[22] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[22]_i_1_n_0 ),
        .Q(accum[22]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[23] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[23]_i_1_n_0 ),
        .Q(accum[23]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[24] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[24]_i_1_n_0 ),
        .Q(accum[24]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[25] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[25]_i_1_n_0 ),
        .Q(accum[25]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[26] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[26]_i_1_n_0 ),
        .Q(accum[26]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[27] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[27]_i_1_n_0 ),
        .Q(accum[27]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[28] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[28]_i_1_n_0 ),
        .Q(accum[28]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[29] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[29]_i_1_n_0 ),
        .Q(accum[29]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[2] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[2]_i_1_n_0 ),
        .Q(accum[2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[30] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[30]_i_1_n_0 ),
        .Q(accum[30]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[31] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[31]_i_1_n_0 ),
        .Q(accum[31]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[3] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[3]_i_1_n_0 ),
        .Q(accum[3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[4] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[4]_i_1_n_0 ),
        .Q(accum[4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[5] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[5]_i_1_n_0 ),
        .Q(accum[5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[6] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[6]_i_1_n_0 ),
        .Q(accum[6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[7] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[7]_i_1_n_0 ),
        .Q(accum[7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[8] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[8]_i_1_n_0 ),
        .Q(accum[8]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \accum_reg[9] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(\accum[9]_i_1_n_0 ),
        .Q(accum[9]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \compute_cycles_reg[0] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\cycles_reg_n_0_[0] ),
        .Q(compute_cycles[0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \compute_cycles_reg[1] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\cycles_reg_n_0_[1] ),
        .Q(compute_cycles[1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \compute_cycles_reg[2] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\cycles_reg_n_0_[2] ),
        .Q(compute_cycles[2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \compute_cycles_reg[3] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\cycles_reg_n_0_[3] ),
        .Q(compute_cycles[3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[0] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[0]),
        .Q(conv_out[0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[10] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[10]),
        .Q(conv_out[10]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[11] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[11]),
        .Q(conv_out[11]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[12] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[12]),
        .Q(conv_out[12]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[13] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[13]),
        .Q(conv_out[13]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[14] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[14]),
        .Q(conv_out[14]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[15] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[15]),
        .Q(conv_out[15]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[16] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[16]),
        .Q(conv_out[16]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[17] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[17]),
        .Q(conv_out[17]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[18] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[18]),
        .Q(conv_out[18]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[19] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[19]),
        .Q(conv_out[19]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[1] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[1]),
        .Q(conv_out[1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[20] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[20]),
        .Q(conv_out[20]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[21] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[21]),
        .Q(conv_out[21]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[22] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[22]),
        .Q(conv_out[22]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[23] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[23]),
        .Q(conv_out[23]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[24] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[24]),
        .Q(conv_out[24]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[25] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[25]),
        .Q(conv_out[25]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[26] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[26]),
        .Q(conv_out[26]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[27] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[27]),
        .Q(conv_out[27]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[28] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[28]),
        .Q(conv_out[28]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[29] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[29]),
        .Q(conv_out[29]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[2] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[2]),
        .Q(conv_out[2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[30] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[30]),
        .Q(conv_out[30]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[31] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[31]),
        .Q(conv_out[31]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[3] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[3]),
        .Q(conv_out[3]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[4] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[4]),
        .Q(conv_out[4]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[5] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[5]),
        .Q(conv_out[5]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[6] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[6]),
        .Q(conv_out[6]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[7] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[7]),
        .Q(conv_out[7]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[8] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[8]),
        .Q(conv_out[8]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \conv_out_reg[9] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(accum[9]),
        .Q(conv_out[9]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \cycles[0]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(\cycles_reg_n_0_[0] ),
        .O(cycles[0]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'h48)) 
    \cycles[1]_i_1 
       (.I0(\cycles_reg_n_0_[0] ),
        .I1(\FSM_onehot_state_reg_n_0_[1] ),
        .I2(\cycles_reg_n_0_[1] ),
        .O(cycles[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h7080)) 
    \cycles[2]_i_1 
       (.I0(\cycles_reg_n_0_[1] ),
        .I1(\cycles_reg_n_0_[0] ),
        .I2(\FSM_onehot_state_reg_n_0_[1] ),
        .I3(\cycles_reg_n_0_[2] ),
        .O(cycles[2]));
  LUT3 #(
    .INIT(8'hEA)) 
    \cycles[3]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(start),
        .I2(\FSM_onehot_state_reg_n_0_[0] ),
        .O(\gen_engine.u_core/ ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h7F008000)) 
    \cycles[3]_i_2 
       (.I0(\cycles_reg_n_0_[2] ),
        .I1(\cycles_reg_n_0_[0] ),
        .I2(\cycles_reg_n_0_[1] ),
        .I3(\FSM_onehot_state_reg_n_0_[1] ),
        .I4(\cycles_reg_n_0_[3] ),
        .O(cycles[3]));
  FDRE #(
    .INIT(1'b0)) 
    \cycles_reg[0] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(cycles[0]),
        .Q(\cycles_reg_n_0_[0] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \cycles_reg[1] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(cycles[1]),
        .Q(\cycles_reg_n_0_[1] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \cycles_reg[2] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(cycles[2]),
        .Q(\cycles_reg_n_0_[2] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \cycles_reg[3] 
       (.C(clk),
        .CE(\gen_engine.u_core/ ),
        .D(cycles[3]),
        .Q(\cycles_reg_n_0_[3] ),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h2)) 
    done_i_1
       (.I0(\FSM_onehot_state_reg_n_0_[2] ),
        .I1(rst),
        .O(done_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    done_reg
       (.C(clk),
        .CE(1'b1),
        .D(done_i_1_n_0),
        .Q(done),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \idx[0]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(\idx_reg_n_0_[0] ),
        .O(idx[0]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h28)) 
    \idx[1]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(\idx_reg_n_0_[0] ),
        .I2(\idx_reg_n_0_[1] ),
        .O(idx[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7080)) 
    \idx[2]_i_1 
       (.I0(\idx_reg_n_0_[1] ),
        .I1(\idx_reg_n_0_[0] ),
        .I2(\FSM_onehot_state_reg_n_0_[1] ),
        .I3(\idx_reg_n_0_[2] ),
        .O(idx[2]));
  LUT6 #(
    .INIT(64'hFFFFFD00FD00FD00)) 
    \idx[3]_i_1 
       (.I0(\idx_reg_n_0_[3] ),
        .I1(\idx[3]_i_3_n_0 ),
        .I2(\idx_reg_n_0_[2] ),
        .I3(\FSM_onehot_state_reg_n_0_[1] ),
        .I4(start),
        .I5(\FSM_onehot_state_reg_n_0_[0] ),
        .O(\idx[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7F008000)) 
    \idx[3]_i_2 
       (.I0(\idx_reg_n_0_[2] ),
        .I1(\idx_reg_n_0_[0] ),
        .I2(\idx_reg_n_0_[1] ),
        .I3(\FSM_onehot_state_reg_n_0_[1] ),
        .I4(\idx_reg_n_0_[3] ),
        .O(idx[3]));
  LUT2 #(
    .INIT(4'hE)) 
    \idx[3]_i_3 
       (.I0(\idx_reg_n_0_[1] ),
        .I1(\idx_reg_n_0_[0] ),
        .O(\idx[3]_i_3_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \idx_reg[0] 
       (.C(clk),
        .CE(\idx[3]_i_1_n_0 ),
        .D(idx[0]),
        .Q(\idx_reg_n_0_[0] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \idx_reg[1] 
       (.C(clk),
        .CE(\idx[3]_i_1_n_0 ),
        .D(idx[1]),
        .Q(\idx_reg_n_0_[1] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \idx_reg[2] 
       (.C(clk),
        .CE(\idx[3]_i_1_n_0 ),
        .D(idx[2]),
        .Q(\idx_reg_n_0_[2] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \idx_reg[3] 
       (.C(clk),
        .CE(\idx[3]_i_1_n_0 ),
        .D(idx[3]),
        .Q(\idx_reg_n_0_[3] ),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \isolated[0]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[1] ),
        .I1(\isolated_reg_n_0_[0] ),
        .O(isolated[0]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'h48)) 
    \isolated[1]_i_1 
       (.I0(\isolated_reg_n_0_[0] ),
        .I1(\FSM_onehot_state_reg_n_0_[1] ),
        .I2(\isolated_reg_n_0_[1] ),
        .O(isolated[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h7080)) 
    \isolated[2]_i_1 
       (.I0(\isolated_reg_n_0_[1] ),
        .I1(\isolated_reg_n_0_[0] ),
        .I2(\FSM_onehot_state_reg_n_0_[1] ),
        .I3(\isolated_reg_n_0_[2] ),
        .O(isolated[2]));
  LUT4 #(
    .INIT(16'hF888)) 
    \isolated[3]_i_1 
       (.I0(is_zero),
        .I1(\FSM_onehot_state_reg_n_0_[1] ),
        .I2(start),
        .I3(\FSM_onehot_state_reg_n_0_[0] ),
        .O(\isolated[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h7F008000)) 
    \isolated[3]_i_2 
       (.I0(\isolated_reg_n_0_[2] ),
        .I1(\isolated_reg_n_0_[0] ),
        .I2(\isolated_reg_n_0_[1] ),
        .I3(\FSM_onehot_state_reg_n_0_[1] ),
        .I4(\isolated_reg_n_0_[3] ),
        .O(isolated[3]));
  LUT4 #(
    .INIT(16'hF888)) 
    \isolated[3]_i_3 
       (.I0(\isolated[3]_i_4_n_0 ),
        .I1(\isolated[3]_i_5_n_0 ),
        .I2(\isolated[3]_i_6_n_0 ),
        .I3(\isolated[3]_i_7_n_0 ),
        .O(is_zero));
  LUT4 #(
    .INIT(16'h0001)) 
    \isolated[3]_i_4 
       (.I0(pixels__63[7]),
        .I1(pixels__63[6]),
        .I2(pixels__63[5]),
        .I3(pixels__63[4]),
        .O(\isolated[3]_i_4_n_0 ));
  LUT4 #(
    .INIT(16'h0001)) 
    \isolated[3]_i_5 
       (.I0(pixels__63[1]),
        .I1(pixels__63[0]),
        .I2(pixels__63[3]),
        .I3(pixels__63[2]),
        .O(\isolated[3]_i_5_n_0 ));
  LUT4 #(
    .INIT(16'h0001)) 
    \isolated[3]_i_6 
       (.I0(weights__63[7]),
        .I1(weights__63[6]),
        .I2(weights__63[5]),
        .I3(weights__63[4]),
        .O(\isolated[3]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'h0001)) 
    \isolated[3]_i_7 
       (.I0(weights__63[1]),
        .I1(weights__63[0]),
        .I2(weights__63[3]),
        .I3(weights__63[2]),
        .O(\isolated[3]_i_7_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \isolated_reg[0] 
       (.C(clk),
        .CE(\isolated[3]_i_1_n_0 ),
        .D(isolated[0]),
        .Q(\isolated_reg_n_0_[0] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \isolated_reg[1] 
       (.C(clk),
        .CE(\isolated[3]_i_1_n_0 ),
        .D(isolated[1]),
        .Q(\isolated_reg_n_0_[1] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \isolated_reg[2] 
       (.C(clk),
        .CE(\isolated[3]_i_1_n_0 ),
        .D(isolated[2]),
        .Q(\isolated_reg_n_0_[2] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \isolated_reg[3] 
       (.C(clk),
        .CE(\isolated[3]_i_1_n_0 ),
        .D(isolated[3]),
        .Q(\isolated_reg_n_0_[3] ),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \skip_count_reg[0] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\isolated_reg_n_0_[0] ),
        .Q(skip_count[0]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \skip_count_reg[1] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\isolated_reg_n_0_[1] ),
        .Q(skip_count[1]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \skip_count_reg[2] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\isolated_reg_n_0_[2] ),
        .Q(skip_count[2]),
        .R(rst));
  FDRE #(
    .INIT(1'b0)) 
    \skip_count_reg[3] 
       (.C(clk),
        .CE(\FSM_onehot_state_reg_n_0_[2] ),
        .D(\isolated_reg_n_0_[3] ),
        .Q(skip_count[3]),
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
