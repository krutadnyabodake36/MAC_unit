`timescale 1ns / 1ps
// =============================================================================
// File: src/conv2d_engine_wrapper.sv
// Target: Invent Logics EDGE Spartan-7 (XC7S15 @ 50 MHz)
// Description: Thin wrapper for isolated SAIF power analysis of Conv2D engines.
// Decouples the compute core from UART and pin I/O switching.
// All engines instantiate identically at hierarchy: conv2d_engine_wrapper/gen_engine/u_core
// =============================================================================

module conv2d_engine_wrapper #(
    parameter int DESIGN_SELECT = 0
) (
    input  logic               clk,
    input  logic               rst,
    input  logic               start,
    input  logic signed [7:0]  weights_in [9],
    input  logic signed [7:0]  pixels_in  [9],
    output logic               done,
    output logic signed [31:0] conv_out,
    output logic [3:0]         compute_cycles,
    output logic [3:0]         skip_count
);

    // Register inputs on start to decouple from testbench stimulus transitions
    logic signed [7:0] w_reg [9];
    logic signed [7:0] p_reg [9];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 9; i++) begin
                w_reg[i] <= 8'sd0;
                p_reg[i] <= 8'sd0;
            end
        end else if (start) begin
            w_reg <= weights_in;
            p_reg <= pixels_in;
        end
    end

    // Unified hierarchy instantiation for direct SAIF power extraction
    generate
        if (DESIGN_SELECT == 0) begin : gen_engine
            conv2d_serial_baseline u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles)
            );
            assign skip_count = 4'd0;
        end else if (DESIGN_SELECT == 1) begin : gen_engine
            conv2d_serial_oi u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 2) begin : gen_engine
            conv2d_serial_cg u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 3) begin : gen_engine
            conv2d_serial_zs u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 4) begin : gen_engine
            conv2d_serial_combined u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 5) begin : gen_engine
            conv2d_serial_zs_oi u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 6) begin : gen_engine
            conv2d_serial_zs_cg u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 7) begin : gen_engine
            conv2d_serial_oi_cg u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles),
                .skip_count     (skip_count)
            );
        end else if (DESIGN_SELECT == 8) begin : gen_engine
            conv2d_serial_static_sobel u_core (
                .clk            (clk),
                .rst            (rst),
                .start          (start),
                .weights        (w_reg),
                .pixels         (p_reg),
                .done           (done),
                .conv_out       (conv_out),
                .compute_cycles (compute_cycles)
            );
            assign skip_count = 4'd0;
        end
    endgenerate

endmodule
