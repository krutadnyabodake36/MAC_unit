#!/usr/bin/env python3
"""
Generate publication-quality diagrams for the Zero-Skipping MAC research paper:
1. End-to-End Workflow & Pipeline Architecture
2. Baseline Conventional Serial MAC Architecture
3. Proposed Combined Zero-Skipping + Operand Isolation + Clock-Enable Gating MAC Architecture
4. Sparsity vs. Speedup Sweep Plot
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ArrowStyle

os.makedirs("results/paper_assets", exist_ok=True)
os.makedirs("fig", exist_ok=True)
os.makedirs("docs/images", exist_ok=True)

plt.rcParams['font.sans-serif'] = 'DejaVu Sans'
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['mathtext.fontset'] = 'cm'

# =============================================================================
# 1. END-TO-END WORKFLOW & PIPELINE ARCHITECTURE
# =============================================================================
def generate_end_to_end_pipeline():
    fig, ax = plt.subplots(figsize=(14, 7), dpi=300)
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 7)
    ax.axis('off')

    # Background zones
    # Host PC Zone
    host_zone = FancyBboxPatch((0.3, 0.4), 3.8, 6.2, boxstyle="round,pad=0.1,rounding_size=0.2",
                               fc="#F0F4F8", ec="#94A3B8", lw=1.5, ls="--")
    ax.add_patch(host_zone)
    ax.text(2.2, 6.35, "HOST SYSTEM (Python 3.10 / PC)", ha='center', va='center',
            fontsize=11, fontweight='bold', color="#1E293B")

    # USB-UART Channel Zone
    uart_zone = FancyBboxPatch((4.5, 0.4), 2.2, 6.2, boxstyle="round,pad=0.1,rounding_size=0.2",
                               fc="#FFFBEB", ec="#F59E0B", lw=1.5, ls=":")
    ax.add_patch(uart_zone)
    ax.text(5.6, 6.35, "PHYSICAL CHANNEL", ha='center', va='center',
            fontsize=10, fontweight='bold', color="#92400E")
    ax.text(5.6, 6.05, "FTDI FT2232H USB-UART\n115,200 Baud (8-N-1)", ha='center', va='center',
            fontsize=8.5, color="#78350F")

    # FPGA Target Zone
    fpga_zone = FancyBboxPatch((7.1, 0.4), 6.6, 6.2, boxstyle="round,pad=0.1,rounding_size=0.2",
                               fc="#EFF6FF", ec="#3B82F6", lw=1.5, ls="--")
    ax.add_patch(fpga_zone)
    ax.text(10.4, 6.35, "FPGA HARDWARE TARGET (Xilinx Spartan-7 XC7S15 @ 50 MHz)", ha='center', va='center',
            fontsize=11, fontweight='bold', color="#1E3A8A")

    # Host Steps
    boxes_host = [
        (0.6, 4.8, 3.2, 0.9, "1. Grayscale Image Input\n(PIL Bilinear, Max Dim 128)", "#E2E8F0", "#475569"),
        (0.6, 3.5, 3.2, 0.9, "2. Signed Domain Shift\nint8 = uint8 - 128 (Pad=0)", "#E2E8F0", "#475569"),
        (0.6, 2.2, 3.2, 0.9, "3. 3x3 Sliding Window\n9 Weights + 9 Pixels Serialized", "#E2E8F0", "#475569"),
        (0.6, 0.8, 3.2, 1.0, "4. Telemetry Log & Edge Map\nReconstruction / Verification", "#DCFCE7", "#16A34A")
    ]
    for x, y, w, h, text, fc, ec in boxes_host:
        p = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.08,rounding_size=0.1", fc=fc, ec=ec, lw=1.2)
        ax.add_patch(p)
        ax.text(x + w/2, y + h/2, text, ha='center', va='center', fontsize=8.5, fontweight='bold', color="#0F172A")

    # Downward arrows on host
    ax.annotate('', xy=(2.2, 4.45), xytext=(2.2, 4.8), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#475569"))
    ax.annotate('', xy=(2.2, 3.15), xytext=(2.2, 3.5), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#475569"))

    # Forward UART Request: Host to FPGA
    req_box = FancyBboxPatch((4.7, 3.7), 1.8, 1.2, boxstyle="round,pad=0.06,rounding_size=0.08",
                             fc="#FEF3C7", ec="#D97706", lw=1.2)
    ax.add_patch(req_box)
    ax.text(5.6, 4.45, "18-Byte Frame", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#92400E")
    ax.text(5.6, 4.0, "9x W [int8]\n+ 9x P [int8]", ha='center', va='center', fontsize=7.5, color="#78350F")

    ax.annotate('', xy=(4.7, 4.3), xytext=(3.8, 2.65),
                arrowprops=dict(arrowstyle="-|>", lw=1.8, color="#D97706", connectionstyle="arc3,rad=-0.15"))
    ax.annotate('', xy=(7.4, 4.3), xytext=(6.5, 4.3),
                arrowprops=dict(arrowstyle="-|>", lw=1.8, color="#D97706"))

    # Return UART Reply: FPGA to Host
    reply_box = FancyBboxPatch((4.7, 1.3), 1.8, 1.4, boxstyle="round,pad=0.06,rounding_size=0.08",
                              fc="#DCFCE7", ec="#16A34A", lw=1.2)
    ax.add_patch(reply_box)
    ax.text(5.6, 2.2, "6-Byte Reply", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#166534")
    ax.text(5.6, 1.7, "4B: 32-bit Sum\n1B: Compute Cyc\n1B: Skip Count", ha='center', va='center', fontsize=7.5, color="#14532D")

    ax.annotate('', xy=(3.8, 1.3), xytext=(4.7, 2.0),
                arrowprops=dict(arrowstyle="-|>", lw=1.8, color="#16A34A", connectionstyle="arc3,rad=0.1"))
    ax.annotate('', xy=(6.5, 2.0), xytext=(7.4, 2.0),
                arrowprops=dict(arrowstyle="<-", lw=1.8, color="#16A34A"))

    # FPGA Internal Blocks
    # UART RX Deserializer
    rx_box = FancyBboxPatch((7.4, 3.7), 1.8, 1.2, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#DBEAFE", ec="#2563EB", lw=1.2)
    ax.add_patch(rx_box)
    ax.text(8.3, 4.4, "UART RX Core", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#1E40AF")
    ax.text(8.3, 3.95, "Deserializer (18B)\n434 clks/bit", ha='center', va='center', fontsize=7.5, color="#1E3A8A")

    # Operand Storage Registers
    reg_box = FancyBboxPatch((9.6, 3.7), 1.6, 1.2, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#DBEAFE", ec="#2563EB", lw=1.2)
    ax.add_patch(reg_box)
    ax.text(10.4, 4.4, "Register Bank", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#1E40AF")
    ax.text(10.4, 3.95, "Weights [9x8b]\nPixels [9x8b]", ha='center', va='center', fontsize=7.5, color="#1E3A8A")

    ax.annotate('', xy=(9.6, 4.3), xytext=(9.2, 4.3), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#2563EB"))

    # Engine Core
    eng_box = FancyBboxPatch((11.6, 2.2), 1.9, 2.7, boxstyle="round,pad=0.1,rounding_size=0.12", fc="#C7D2FE", ec="#4338CA", lw=1.8)
    ax.add_patch(eng_box)
    ax.text(12.55, 4.4, "CONV2D CORE", ha='center', va='center', fontsize=9, fontweight='bold', color="#312E81")
    ax.text(12.55, 3.9, "Priority Zero-Skip\nOperand Isolation\nCE Clock Gating", ha='center', va='center', fontsize=7.5, color="#3730A3")
    ax.text(12.55, 3.1, "8x8 Multiplier\n32-bit Accumulator\n2-6 Cycles/Patch", ha='center', va='center', fontsize=7.5, color="#312E81")
    ax.text(12.55, 2.45, "0 DSP, 0 BRAM", ha='center', va='center', fontsize=7.5, fontweight='bold', color="#4338CA")

    ax.annotate('', xy=(11.6, 4.3), xytext=(11.2, 4.3), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#2563EB"))
    ax.text(11.4, 4.5, "eng_start", fontsize=7, color="#1E40AF")

    # Output Latches & UART TX Core
    tx_box = FancyBboxPatch((7.4, 1.4), 1.8, 1.2, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#DBEAFE", ec="#2563EB", lw=1.2)
    ax.add_patch(tx_box)
    ax.text(8.3, 2.1, "UART TX Core", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#1E40AF")
    ax.text(8.3, 1.65, "Serializer (6B)\nSum+Cyc+Skip", ha='center', va='center', fontsize=7.5, color="#1E3A8A")

    # Return connection from engine to TX
    ax.annotate('', xy=(9.2, 2.0), xytext=(11.6, 2.5),
                arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#4338CA", connectionstyle="arc3,rad=0.15"))
    ax.text(10.4, 2.4, "32b Sum + Telemetry", fontsize=7.5, color="#312E81", ha='center')

    plt.tight_layout()
    plt.savefig("results/paper_assets/end_to_end_pipeline.png", dpi=300, bbox_inches='tight')
    plt.savefig("fig/pipeline.png", dpi=300, bbox_inches='tight')
    plt.savefig("docs/images/end_to_end_pipeline.png", dpi=300, bbox_inches='tight')
    plt.close()
    print("Generated end_to_end_pipeline.png")

# =============================================================================
# 2. BASELINE CONVENTIONAL SERIAL MAC HARDWARE ARCHITECTURE
# =============================================================================
def generate_baseline_mac():
    fig, ax = plt.subplots(figsize=(12, 6.5), dpi=300)
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 6.5)
    ax.axis('off')

    # Border frame
    frame = FancyBboxPatch((0.2, 0.2), 11.6, 6.1, boxstyle="round,pad=0.1,rounding_size=0.2",
                           fc="#F8FAFC", ec="#64748B", lw=1.5)
    ax.add_patch(frame)
    ax.text(6.0, 6.0, "Conventional Baseline Serial 3x3 Convolution MAC Unit (conv2d_serial_baseline.sv)",
            ha='center', va='center', fontsize=11, fontweight='bold', color="#0F172A")
    ax.text(6.0, 5.7, "Fixed 9 Compute Cycles/Patch | Clocks Free-Running | Multiplier Continuously Toggling",
            ha='center', va='center', fontsize=8.5, color="#475569")

    # Input registers
    w_reg = FancyBboxPatch((0.6, 3.8), 1.8, 1.4, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#E2E8F0", ec="#475569", lw=1.2)
    p_reg = FancyBboxPatch((0.6, 1.6), 1.8, 1.4, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#E2E8F0", ec="#475569", lw=1.2)
    ax.add_patch(w_reg)
    ax.add_patch(p_reg)
    ax.text(1.5, 4.65, "Weight Registers", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#1E293B")
    ax.text(1.5, 4.15, "W[0] .. W[8]\n9x 8-bit Signed", ha='center', va='center', fontsize=7.5, color="#334155")
    ax.text(1.5, 2.45, "Pixel Registers", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#1E293B")
    ax.text(1.5, 1.95, "P[0] .. P[8]\n9x 8-bit Signed", ha='center', va='center', fontsize=7.5, color="#334155")

    # Selection Muxes
    w_mux = FancyBboxPatch((3.2, 3.8), 1.2, 1.4, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#FED7AA", ec="#EA580C", lw=1.2)
    p_mux = FancyBboxPatch((3.2, 1.6), 1.2, 1.4, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#FED7AA", ec="#EA580C", lw=1.2)
    ax.add_patch(w_mux)
    ax.add_patch(p_mux)
    ax.text(3.8, 4.5, "9:1 Mux", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#9A3412")
    ax.text(3.8, 4.05, "Weights", ha='center', va='center', fontsize=7.5, color="#C2410C")
    ax.text(3.8, 2.3, "9:1 Mux", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#9A3412")
    ax.text(3.8, 1.85, "Pixels", ha='center', va='center', fontsize=7.5, color="#C2410C")

    ax.annotate('', xy=(3.2, 4.5), xytext=(2.4, 4.5), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#334155"))
    ax.annotate('', xy=(3.2, 2.3), xytext=(2.4, 2.3), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#334155"))

    # Sequential Counter (0..8)
    counter_box = FancyBboxPatch((1.8, 0.45), 2.6, 0.8, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#E0E7FF", ec="#4338CA", lw=1.2)
    ax.add_patch(counter_box)
    ax.text(3.1, 0.85, "Sequential Counter (idx: 0..8)", ha='center', va='center', fontsize=8, fontweight='bold', color="#312E81")

    # Counter lines to muxes
    ax.annotate('', xy=(3.8, 1.6), xytext=(3.8, 1.25), arrowprops=dict(arrowstyle="-|>", lw=1.2, color="#4338CA", ls="-"))
    ax.annotate('', xy=(3.8, 3.8), xytext=(3.8, 3.0), arrowprops=dict(arrowstyle="-|>", lw=1.2, color="#4338CA", ls="-"))
    ax.text(4.0, 3.4, "idx [3:0]", fontsize=7, color="#4338CA")

    # 8x8 Multiplier
    mult_box = FancyBboxPatch((5.4, 2.4), 1.8, 1.8, boxstyle="round,pad=0.08,rounding_size=0.12", fc="#FEE2E2", ec="#DC2626", lw=1.5)
    ax.add_patch(mult_box)
    ax.text(6.3, 3.6, "8x8 Signed", ha='center', va='center', fontsize=9, fontweight='bold', color="#991B1B")
    ax.text(6.3, 3.2, "Multiplier", ha='center', va='center', fontsize=10, fontweight='bold', color="#991B1B")
    ax.text(6.3, 2.7, "LUT/Fabric Logic\n(0 DSP)", ha='center', va='center', fontsize=7.5, color="#7F1D1D")

    ax.annotate('', xy=(5.4, 3.6), xytext=(4.4, 4.5), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#9A3412"))
    ax.text(4.8, 4.25, "sel_w [7:0]", fontsize=7, color="#9A3412")
    ax.annotate('', xy=(5.4, 3.0), xytext=(4.4, 2.3), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#9A3412"))
    ax.text(4.8, 2.5, "sel_p [7:0]", fontsize=7, color="#9A3412")

    # 32-bit Adder
    adder_box = FancyBboxPatch((8.0, 2.7), 1.3, 1.2, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#FEF3C7", ec="#D97706", lw=1.2)
    ax.add_patch(adder_box)
    ax.text(8.65, 3.4, "32-bit Adder", ha='center', va='center', fontsize=8, fontweight='bold', color="#92400E")
    ax.text(8.65, 3.0, "+ Sign Ext.", ha='center', va='center', fontsize=7.5, color="#78350F")

    ax.annotate('', xy=(8.0, 3.3), xytext=(7.2, 3.3), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#DC2626"))
    ax.text(7.6, 3.5, "prod [15:0]", fontsize=7, color="#DC2626")

    # 32-bit Accumulator Register
    accum_box = FancyBboxPatch((9.9, 2.5), 1.5, 1.6, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#DCFCE7", ec="#16A34A", lw=1.5)
    ax.add_patch(accum_box)
    ax.text(10.65, 3.6, "Accumulator", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#166534")
    ax.text(10.65, 3.15, "Register (FFs)\n32-bit Signed", ha='center', va='center', fontsize=7.5, color="#14532D")
    ax.text(10.65, 2.7, "Free-Running clk", ha='center', va='center', fontsize=7, color="#16A34A")

    ax.annotate('', xy=(9.9, 3.3), xytext=(9.3, 3.3), arrowprops=dict(arrowstyle="-|>", lw=1.5, color="#D97706"))

    # Accumulator Feedback loop
    ax.annotate('', xy=(8.65, 2.7), xytext=(10.65, 2.5),
                arrowprops=dict(arrowstyle="-|>", lw=1.2, color="#16A34A", connectionstyle="arc3,rad=-0.4"))
    ax.text(9.65, 1.75, "accum [31:0]", fontsize=7, color="#166534")

    # Output port
    ax.annotate('', xy=(11.8, 3.3), xytext=(11.4, 3.3), arrowprops=dict(arrowstyle="-|>", lw=1.8, color="#0F172A"))
    ax.text(11.6, 3.55, "conv_out [31:0]", fontsize=7.5, fontweight='bold', color="#0F172A")

    plt.tight_layout()
    plt.savefig("results/paper_assets/baseline_mac_architecture.png", dpi=300, bbox_inches='tight')
    plt.savefig("fig/baseline_mac.png", dpi=300, bbox_inches='tight')
    plt.savefig("docs/images/baseline_mac_architecture.png", dpi=300, bbox_inches='tight')
    plt.close()
    print("Generated baseline_mac_architecture.png")

# =============================================================================
# 3. PROPOSED COMBINED ZERO-SKIPPING MAC HARDWARE ARCHITECTURE
# =============================================================================
def generate_proposed_mac():
    fig, ax = plt.subplots(figsize=(13.5, 7.2), dpi=300)
    ax.set_xlim(0, 13.5)
    ax.set_ylim(0, 7.2)
    ax.axis('off')

    # Border frame
    frame = FancyBboxPatch((0.2, 0.2), 13.1, 6.8, boxstyle="round,pad=0.1,rounding_size=0.2",
                           fc="#F8FAFC", ec="#2563EB", lw=1.8)
    ax.add_patch(frame)
    ax.text(6.75, 6.75, "Proposed Tri-Optimization 3x3 Convolution Engine (conv2d_serial_combined.sv)",
            ha='center', va='center', fontsize=11, fontweight='bold', color="#1E3A8A")
    ax.text(6.75, 6.45, "Tier 2: Priority Zero-Skipping (2-6 Cyc) | Tier 1: Operand Clamping (OI) | Tier 1: Clock-Enable Gating (CG)",
            ha='center', va='center', fontsize=8.5, color="#1D4ED8")

    # Inputs
    w_reg = FancyBboxPatch((0.5, 4.4), 1.6, 1.2, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#E2E8F0", ec="#475569", lw=1.2)
    p_reg = FancyBboxPatch((0.5, 2.6), 1.6, 1.2, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#E2E8F0", ec="#475569", lw=1.2)
    ax.add_patch(w_reg)
    ax.add_patch(p_reg)
    ax.text(1.3, 5.1, "Weights [9x8b]", ha='center', va='center', fontsize=8, fontweight='bold', color="#1E293B")
    ax.text(1.3, 4.65, "W[0] .. W[8]\nSigned int8", ha='center', va='center', fontsize=7, color="#334155")
    ax.text(1.3, 3.3, "Pixels [9x8b]", ha='center', va='center', fontsize=8, fontweight='bold', color="#1E293B")
    ax.text(1.3, 2.85, "P[0] .. P[8]\nSigned int8", ha='center', va='center', fontsize=7, color="#334155")

    # Step 1: Parallel Non-Zero Mask Generator
    mask_box = FancyBboxPatch((2.6, 3.2), 1.8, 2.0, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#FEF3C7", ec="#D97706", lw=1.4)
    ax.add_patch(mask_box)
    ax.text(3.5, 4.8, "Parallel Non-Zero", ha='center', va='center', fontsize=8, fontweight='bold', color="#92400E")
    ax.text(3.5, 4.45, "Mask Generator", ha='center', va='center', fontsize=8, fontweight='bold', color="#92400E")
    ax.text(3.5, 3.9, "nz_mask[i] =\n(W[i]!=0) && (P[i]!=0)", ha='center', va='center', fontsize=6.8, color="#78350F")
    ax.text(3.5, 3.4, "9 Parallel Detectors", ha='center', va='center', fontsize=7, color="#B45309")

    ax.annotate('', xy=(2.6, 4.6), xytext=(2.1, 4.8), arrowprops=dict(arrowstyle="-|>", lw=1.2, color="#475569"))
    ax.annotate('', xy=(2.6, 3.8), xytext=(2.1, 3.2), arrowprops=dict(arrowstyle="-|>", lw=1.2, color="#475569"))

    # Step 2: FFS Priority Encoder
    ffs_box = FancyBboxPatch((4.9, 3.2), 1.8, 2.0, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#FFEDD5", ec="#EA580C", lw=1.4)
    ax.add_patch(ffs_box)
    ax.text(5.8, 4.8, "Find-First-Set", ha='center', va='center', fontsize=8, fontweight='bold', color="#9A3412")
    ax.text(5.8, 4.45, "Priority Encoder", ha='center', va='center', fontsize=8, fontweight='bold', color="#9A3412")
    ax.text(5.8, 3.9, "Scans remaining[8:0]\nOutputs lowest set bit\nffs_idx [3:0]", ha='center', va='center', fontsize=6.8, color="#9A3412")
    ax.text(5.8, 3.4, "Sets ffs_valid flag", ha='center', va='center', fontsize=7, fontweight='bold', color="#C2410C")

    ax.annotate('', xy=(4.9, 4.2), xytext=(4.4, 4.2), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#D97706"))
    ax.text(4.65, 4.4, "9b", fontsize=6.5, color="#D97706")

    # Step 3: Remaining Mask & Bit-Clear Decoder
    clear_box = FancyBboxPatch((3.5, 0.9), 2.8, 1.5, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#E0E7FF", ec="#4338CA", lw=1.2)
    ax.add_patch(clear_box)
    ax.text(4.9, 2.05, "Remaining Mask & Bit-Clear Decoder", ha='center', va='center', fontsize=7.5, fontweight='bold', color="#312E81")
    ax.text(4.9, 1.6, "remaining <= remaining & ~bit_clear\nInitial: remaining <= nz_mask", ha='center', va='center', fontsize=7, color="#3730A3")
    ax.text(4.9, 1.15, "Dynamic Skip Controller (bypasses null taps)", ha='center', va='center', fontsize=6.8, color="#4338CA")

    # Feedback from FFS to Bit-Clear and back to FFS
    ax.annotate('', xy=(4.9, 2.4), xytext=(5.8, 3.2),
                arrowprops=dict(arrowstyle="-|>", lw=1.2, color="#EA580C", connectionstyle="arc3,rad=0.2"))
    ax.annotate('', xy=(5.2, 3.2), xytext=(4.9, 2.4),
                arrowprops=dict(arrowstyle="-|>", lw=1.2, color="#4338CA", connectionstyle="arc3,rad=0.2"))

    # Step 4: Operand Isolation Clamping Muxes
    iso_box = FancyBboxPatch((7.2, 3.4), 1.7, 1.6, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#CFFAFE", ec="#0891B2", lw=1.4)
    ax.add_patch(iso_box)
    ax.text(8.05, 4.6, "Operand Isolation", ha='center', va='center', fontsize=8, fontweight='bold', color="#155E75")
    ax.text(8.05, 4.2, "Clamping Logic", ha='center', va='center', fontsize=8, fontweight='bold', color="#155E75")
    ax.text(8.05, 3.75, "Clamps to 0 if not\nCOMPUTE or !ffs_valid", ha='center', va='center', fontsize=6.8, color="#0E7490")

    ax.annotate('', xy=(7.2, 4.2), xytext=(6.7, 4.2), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#EA580C"))
    ax.text(6.95, 4.4, "idx", fontsize=7, color="#EA580C")

    # Step 5: Multiplier
    mult_box = FancyBboxPatch((9.3, 3.4), 1.6, 1.6, boxstyle="round,pad=0.08,rounding_size=0.1", fc="#FEE2E2", ec="#DC2626", lw=1.5)
    ax.add_patch(mult_box)
    ax.text(10.1, 4.5, "8x8 Signed", ha='center', va='center', fontsize=8.5, fontweight='bold', color="#991B1B")
    ax.text(10.1, 4.15, "Multiplier", ha='center', va='center', fontsize=9, fontweight='bold', color="#991B1B")
    ax.text(10.1, 3.7, "Pure Fabric\n(0 DSP)", ha='center', va='center', fontsize=7.5, color="#7F1D1D")

    ax.annotate('', xy=(9.3, 4.3), xytext=(8.9, 4.3), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#0891B2"))
    ax.annotate('', xy=(9.3, 3.8), xytext=(8.9, 3.8), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#0891B2"))
    ax.text(9.1, 4.5, "iso_w", fontsize=6.5, color="#0891B2")
    ax.text(9.1, 3.6, "iso_p", fontsize=6.5, color="#0891B2")

    # Step 6: 32-bit Adder
    adder_box = FancyBboxPatch((10.1, 1.7), 1.2, 1.0, boxstyle="round,pad=0.06,rounding_size=0.08", fc="#FEF3C7", ec="#D97706", lw=1.2)
    ax.add_patch(adder_box)
    ax.text(10.7, 2.3, "32-bit Adder", ha='center', va='center', fontsize=7.5, fontweight='bold', color="#92400E")
    ax.text(10.7, 1.95, "+ Sign Ext.", ha='center', va='center', fontsize=7, color="#78350F")

    ax.annotate('', xy=(10.7, 2.7), xytext=(10.1, 3.4), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#DC2626"))
    ax.text(10.6, 3.1, "prod [15:0]", fontsize=6.5, color="#DC2626")

    # Step 7: Clock-Gated Accumulator Register
    accum_box = FancyBboxPatch((11.6, 1.4), 1.5, 1.7, boxstyle="round,pad=0.08,rounding_size=0.12", fc="#DCFCE7", ec="#16A34A", lw=1.6)
    ax.add_patch(accum_box)
    ax.text(12.35, 2.7, "Accumulator", ha='center', va='center', fontsize=8, fontweight='bold', color="#166534")
    ax.text(12.35, 2.3, "Register (32b)", ha='center', va='center', fontsize=7.5, fontweight='bold', color="#166534")
    ax.text(12.35, 1.85, "CE Clock-Gated\nBUFGCE Control", ha='center', va='center', fontsize=6.8, color="#15803D")

    ax.annotate('', xy=(11.6, 2.2), xytext=(11.3, 2.2), arrowprops=dict(arrowstyle="-|>", lw=1.4, color="#D97706"))

    # Clock enable line from FFS
    ax.annotate('', xy=(12.35, 3.1), xytext=(6.7, 4.8),
                arrowprops=dict(arrowstyle="-|>", lw=1.3, color="#15803D", ls="--", connectionstyle="arc3,rad=-0.25"))
    ax.text(9.5, 5.6, "accum_ce = (COMPUTE && ffs_valid)", fontsize=7, color="#15803D", fontweight='bold')

    # Output port
    ax.annotate('', xy=(13.3, 2.2), xytext=(13.1, 2.2), arrowprops=dict(arrowstyle="-|>", lw=1.8, color="#0F172A"))
    ax.text(12.8, 1.0, "Telemetry:\ncompute_cycles (0..9)\nskip_count (0..9)", fontsize=7, color="#1E293B", ha='center')

    plt.tight_layout()
    plt.savefig("results/paper_assets/proposed_mac_architecture.png", dpi=300, bbox_inches='tight')
    plt.savefig("fig/proposed_mac.png", dpi=300, bbox_inches='tight')
    plt.savefig("docs/images/proposed_mac_architecture.png", dpi=300, bbox_inches='tight')
    plt.close()
    print("Generated proposed_mac_architecture.png")

# =============================================================================
# 4. SPARSITY VS SPEEDUP SWEEP PLOT (FIG 2)
# =============================================================================
def generate_sparsity_plot():
    achieved = [0.00, 9.62, 21.14, 30.39, 40.08, 49.55, 59.79, 70.06, 79.38, 90.37]
    dense_speedup = [1.000, 1.085, 1.209, 1.331, 1.488, 1.682, 1.958, 2.343, 2.853, 3.837]
    sobel_speedup = [1.375, 1.480, 1.633, 1.776, 1.965, 2.185, 2.511, 2.891, 3.390, 4.274]

    fig, ax = plt.subplots(figsize=(7, 4.5), dpi=300)
    ax.plot(achieved, dense_speedup, marker='s', markersize=6, color='#2563EB', linewidth=2.0, label='Dense Kernel (Gaussian/Random)')
    ax.plot(achieved, sobel_speedup, marker='^', markersize=6, color='#DC2626', linewidth=2.0, linestyle='--', label='Sobel-X Kernel (3 Structural Zeros)')

    ax.set_xlabel('Achieved Pixel Sparsity (%)', fontsize=10, fontweight='bold')
    ax.set_ylabel('Measured Wall-Clock Speedup vs. Baseline', fontsize=10, fontweight='bold')
    ax.set_title('Zero-Skipping Engine Speedup vs. Workload Sparsity (2,000 Patches/Level)', fontsize=10.5, fontweight='bold')
    ax.grid(True, linestyle=':', alpha=0.6)
    ax.legend(frameon=True, fontsize=9, loc='upper left')
    ax.set_ylim(0.8, 4.6)
    ax.set_xlim(-2, 95)

    plt.tight_layout()
    plt.savefig("results/paper_assets/sparsity_sweep_plot.png", dpi=300, bbox_inches='tight')
    plt.savefig("fig/sweep.png", dpi=300, bbox_inches='tight')
    plt.savefig("docs/images/sparsity_sweep_plot.png", dpi=300, bbox_inches='tight')
    plt.close()
    print("Generated sparsity_sweep_plot.png")

if __name__ == "__main__":
    generate_end_to_end_pipeline()
    generate_baseline_mac()
    generate_proposed_mac()
    generate_sparsity_plot()
    print("All paper diagrams successfully generated in results/paper_assets, fig, and docs/images!")

