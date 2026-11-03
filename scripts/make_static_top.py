with open('src/conv2d_benchmark_top_ablation.sv', 'rb') as f:
    content = f.read().decode('utf-8')

# 1. Update header comment and module name
content = content.replace(
    '// File: conv2d_benchmark_top_ablation.sv',
    '// File: conv2d_benchmark_top_static.sv'
)
content = content.replace(
    '//   7 = OI + CG (conv2d_serial_oi_cg, fixed 9 cycles, OI clamped + accumulator CG)',
    '//   7 = OI + CG (conv2d_serial_oi_cg, fixed 9 cycles, OI clamped + accumulator CG)\r\n//   8 = Static Sobel-X 6-Tap (conv2d_serial_static_sobel, fixed 6 cycles, no zero detection)'
)
content = content.replace(
    'module conv2d_benchmark_top_ablation #(',
    'module conv2d_benchmark_top_static #('
)
content = content.replace(
    'parameter int DESIGN_SELECT = 4,',
    'parameter int DESIGN_SELECT = 8,'
)

# 2. Add DESIGN_SELECT == 8 branch before gen_default
target = """        end else begin : gen_default"""

replacement = """        end else if (EFF_DESIGN == 8) begin : gen_static_sobel
            conv2d_serial_static_sobel u_engine (
                .clk            (clk),
                .rst            (rst),
                .start          (eng_start),
                .weights        (weights_reg),
                .pixels         (pixels_reg),
                .done           (eng_done),
                .conv_out       (eng_result),
                .compute_cycles (eng_cycles)
            );
            assign eng_skips = 4'd0;  // Static Sobel has fixed schedule, no dynamic skip logic
        end else begin : gen_default"""

if target in content:
    content = content.replace(target, replacement, 1)
else:
    print("WARNING: target not found!")

with open('src/conv2d_benchmark_top_static.sv', 'wb') as f:
    f.write(content.encode('utf-8'))

print("Updated src/conv2d_benchmark_top_static.sv")

