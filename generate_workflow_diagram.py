"""
generate_workflow_diagram.py
Generates an ultra-clean, publication-grade academic block diagram:
"End-to-End Vision Pipeline & System Dataflow Architecture"
for the Spartan-7 Dual-Tier Zero-Skipping Edge Vision Accelerator.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np

def create_workflow_diagram():
    # 15.5 x 9.6 inches @ 300 DPI
    fig, ax = plt.subplots(figsize=(15.5, 9.6), dpi=300)
    ax.set_xlim(0, 155)
    ax.set_ylim(0, 96)
    ax.axis('off')

    # Color Palette: Clean IEEE Academic & Engineering Theme
    c_host_container_bg = '#F8FAFC'
    c_host_border = '#64748B'
    c_fpga_container_bg = '#F1F5F9'
    c_fpga_border = '#0F172A'
    
    c_card_bg = '#FFFFFF'
    c_card_border = '#334155'
    
    # Subsystem highlight accents
    c_t2_bg = '#FFFBEB'         # Warm amber/gold for Tier-2 Zero-Skipping
    c_t2_border = '#D97706'
    c_t2_txt = '#92400E'
    
    c_t1_bg = '#EFF6FF'         # Tech blue for Tier-1 MAC Engine
    c_t1_border = '#2563EB'
    c_t1_txt = '#1E40AF'
    
    c_recon_bg = '#F0FDF4'      # Emerald green for Reconstruction & Output
    c_recon_border = '#16A34A'
    c_recon_txt = '#15803D'

    c_bus_tx = '#DC2626'        # Red for Host->FPGA 18-Byte Bus
    c_bus_rx = '#16A34A'        # Green for FPGA->Host 6-Byte Bus
    c_arrow = '#334155'         # Standard flow arrow

    # Typography definitions
    font_domain = {'family': 'sans-serif', 'weight': 'bold', 'size': 10.2}
    font_title = {'family': 'sans-serif', 'weight': 'bold', 'size': 8.8}
    font_bold = {'family': 'sans-serif', 'weight': 'bold', 'size': 7.8}
    font_body = {'family': 'sans-serif', 'size': 7.3}
    font_small = {'family': 'sans-serif', 'size': 6.8}
    font_badge = {'family': 'sans-serif', 'weight': 'bold', 'size': 7.0}

    # =========================================================================
    # 1. TOP-LEVEL DOMAIN CONTAINERS
    # =========================================================================
    
    # --- DOMAIN 1: HOST PRE-PROCESSING (Top-Left) ---
    ax.add_patch(FancyBboxPatch((2, 50), 62, 40, boxstyle="round,pad=0.5,rounding_size=1.5",
                                facecolor=c_host_container_bg, edgecolor=c_host_border, linewidth=1.4, linestyle='--', zorder=1))
    ax.text(4, 87.2, "HOST SOFTWARE DOMAIN (Pre-Processing & Framing)",
            fontdict=font_domain, color='#1E293B', zorder=2)
    ax.text(4, 84.8, "Python Vision Profiler | Sliding Receptive Field Ingestion",
            fontdict=font_small, color='#64748B', style='italic', zorder=2)

    # --- DOMAIN 3: HOST POST-PROCESSING & RECONSTRUCTION (Bottom-Left) ---
    ax.add_patch(FancyBboxPatch((2, 7), 62, 41, boxstyle="round,pad=0.5,rounding_size=1.5",
                                facecolor=c_host_container_bg, edgecolor=c_host_border, linewidth=1.4, linestyle='--', zorder=1))
    ax.text(4, 45.2, "HOST SOFTWARE DOMAIN (Telemetry Ingestion & Reconstruction)",
            fontdict=font_domain, color='#1E293B', zorder=2)
    ax.text(4, 42.8, "Bit-Exact Image Synthesis | Hardware Telemetry Analytics",
            fontdict=font_small, color='#64748B', style='italic', zorder=2)

    # --- DOMAIN 2: PHYSICAL FPGA ACCELERATOR (Right Side, Full Height) ---
    ax.add_patch(FancyBboxPatch((78, 7), 75, 83, boxstyle="round,pad=0.5,rounding_size=1.5",
                                facecolor=c_fpga_container_bg, edgecolor=c_fpga_border, linewidth=2.0, zorder=1))
    ax.text(80, 87.2, "SPARTAN-7 FPGA HARDWARE ACCELERATOR (XC7S15 @ 50 MHz)",
            fontdict=font_domain, color='#0F172A', zorder=2)
    ax.text(80, 84.8, "Invent Logics EDGE Dev Board | 0 DSP48 Slices | 100% Bit-Exact Execution in Silicon",
            fontdict=font_small, color='#475569', style='italic', zorder=2)

    # =========================================================================
    # 2. HOST PRE-PROCESSING BLOCKS (Top-Left)
    # =========================================================================
    
    # Block 1: Raw Image Ingestion & Padding
    ax.add_patch(FancyBboxPatch((4, 52), 17.5, 30, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_card_bg, edgecolor=c_card_border, linewidth=1.2, zorder=2))
    ax.text(12.75, 79.5, "1. Image Ingestion &\nZero-Padding", fontdict=font_title, ha='center', va='center', zorder=3)
    
    # Visual icon: 2D matrix with padded border
    rect_img = Rectangle((6.5, 69.0), 12.5, 8.0, facecolor='#E2E8F0', edgecolor='#64748B', lw=0.9, linestyle=':', zorder=3)
    ax.add_patch(rect_img)
    rect_inner = Rectangle((7.8, 70.2), 9.9, 5.6, facecolor='#94A3B8', edgecolor='#334155', lw=0.9, zorder=4)
    ax.add_patch(rect_inner)
    ax.text(12.75, 73.0, "W × H Grayscale", fontdict=font_badge, color='#FFFFFF', ha='center', va='center', zorder=5)
    ax.text(12.75, 67.3, "1-Pixel Pad: (H+2) × (W+2)", fontdict=font_small, color='#334155', ha='center', zorder=5)

    ax.text(5.2, 59.8, 
            "• 8-bit Grayscale Pixel Input\n"
            "• Preserves Spatial Dimensions\n"
            "• Fixed Range: [0, 255]\n"
            "• Zero Boundary Border",
            fontdict=font_body, ha='left', va='center', zorder=3)

    # Arrow 1 -> 2
    ax.annotate('', xy=(24, 67), xytext=(21.5, 67),
                arrowprops=dict(facecolor=c_arrow, edgecolor=c_arrow, arrowstyle="-|>", lw=1.5), zorder=3)

    # Block 2: 3x3 Sliding Window Extraction
    ax.add_patch(FancyBboxPatch((24, 52), 19, 30, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_card_bg, edgecolor=c_card_border, linewidth=1.2, zorder=2))
    ax.text(33.5, 79.5, "2. 3×3 Receptive\nPatch Generator", fontdict=font_title, ha='center', va='center', zorder=3)
    
    # Visual icon: 3x3 kernel grid
    gx_start, gy_start = 28.0, 69.2
    for r in range(3):
        for c in range(3):
            ax.add_patch(Rectangle((gx_start + c*3.7, gy_start + (2-r)*2.6), 3.3, 2.2, 
                                   facecolor='#FEF3C7', edgecolor='#D97706', lw=0.8, zorder=3))
    ax.text(33.5, 73.0, "3×3 Patch", fontdict=font_badge, color='#92400E', ha='center', va='center', zorder=4)
    ax.text(33.5, 67.3, "P[0..8] & Filter W[0..8]", fontdict=font_small, color='#334155', ha='center', zorder=4)

    ax.text(25.2, 59.8,
            "• Stride = 1 Spatial Traversal\n"
            "• Extracts 9 Local Pixels P\n"
            "• Matches 9 Kernel Weights W\n"
            "  (Sobel Gx, Gy or CNN Kernel)\n"
            "• Coordinates: (r, c)",
            fontdict=font_body, ha='left', va='center', zorder=3)

    # Arrow 2 -> 3
    ax.annotate('', xy=(45.5, 67), xytext=(43, 67),
                arrowprops=dict(facecolor=c_arrow, edgecolor=c_arrow, arrowstyle="-|>", lw=1.5), zorder=3)

    # Block 3: Vectorization & Framing
    ax.add_patch(FancyBboxPatch((45.5, 52), 17, 30, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_card_bg, edgecolor=c_card_border, linewidth=1.2, zorder=2))
    ax.text(54.0, 79.5, "3. Vectorization &\nFrame Assembly", fontdict=font_title, ha='center', va='center', zorder=3)

    # Visual icon: 18-byte packed frame
    ax.add_patch(Rectangle((47.0, 70.8), 6.5, 5.8, facecolor='#DBEAFE', edgecolor='#2563EB', lw=0.9, zorder=3))
    ax.text(50.25, 73.7, "9× W_k\n(Weights)", fontdict=font_small, color='#1E40AF', ha='center', va='center', zorder=4)
    ax.add_patch(Rectangle((54.5, 70.8), 6.5, 5.8, facecolor='#E0E7FF', edgecolor='#4F46E5', lw=0.9, zorder=3))
    ax.text(57.75, 73.7, "9× P_k\n(Pixels)", fontdict=font_small, color='#3730A3', ha='center', va='center', zorder=4)
    ax.text(54.0, 67.3, "18-Byte Binary Payload", fontdict=font_small, color='#334155', ha='center', zorder=4)

    ax.text(46.5, 59.8,
            "• Signed INT8 Flattening\n"
            "• P = [p0, p1, ..., p8]\n"
            "• W = [w0, w1, ..., w8]\n"
            "• Binary Struct Packing\n"
            "• UART Tx Buffer Stream",
            fontdict=font_body, ha='left', va='center', zorder=3)

    # =========================================================================
    # 3. INTER-DOMAIN COMMUNICATION BUSES (UART INTERFACE IN MIDDLE CHANNEL)
    # =========================================================================
    
    # Top Bus: Host -> FPGA (Downstream 18-Byte Payload)
    ax.annotate('', xy=(80, 67), xytext=(62.5, 67),
                arrowprops=dict(facecolor=c_bus_tx, edgecolor=c_bus_tx, arrowstyle="-|>", lw=2.8), zorder=2)
    # Label Pill for 18-byte bus (zorder=4 ensures it sits cleanly ON TOP of the arrow)
    ax.add_patch(FancyBboxPatch((64.0, 69.2), 13.5, 5.8, boxstyle="round,pad=0.2,rounding_size=0.6",
                                facecolor='#FEF2F2', edgecolor='#DC2626', linewidth=1.2, zorder=4))
    ax.text(70.75, 72.1, "18-BYTE PAYLOAD\nUART @ 115.2k", fontdict=font_badge, color='#991B1B', ha='center', va='center', zorder=5)

    # Bottom Bus: FPGA -> Host (Upstream 6-Byte Telemetry)
    ax.annotate('', xy=(62.5, 25), xytext=(80, 25),
                arrowprops=dict(facecolor=c_bus_rx, edgecolor=c_bus_rx, arrowstyle="-|>", lw=2.8), zorder=2)
    # Label Pill for 6-byte bus (zorder=4 ensures it sits cleanly ON TOP of the arrow)
    ax.add_patch(FancyBboxPatch((64.0, 27.2), 13.5, 5.8, boxstyle="round,pad=0.2,rounding_size=0.6",
                                facecolor='#F0FDF4', edgecolor='#16A34A', linewidth=1.2, zorder=4))
    ax.text(70.75, 30.1, "6-BYTE TELEMETRY\nUART Rx Stream", fontdict=font_badge, color='#15803D', ha='center', va='center', zorder=5)

    # =========================================================================
    # 4. FPGA HARDWARE ACCELERATOR INTERNALS (Right Side)
    # =========================================================================

    # Sub-block 4: Ingress Latch & Parallel Zero-Detect
    ax.add_patch(FancyBboxPatch((80, 56), 33, 26, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_card_bg, edgecolor=c_card_border, linewidth=1.3, zorder=2))
    ax.text(96.5, 79.5, "4. Ingress Registers & Zero-Detect", fontdict=font_title, ha='center', zorder=3)
    
    ax.text(81.5, 67.5, 
            "• 18 × 8-bit Ingress Registers (W[0..8], P[0..8])\n"
            "• 9-Way Parallel 8-bit NOR Reduction (1 Cycle):\n"
            "    Z_w[k] = ~( | W[k] ),    Z_p[k] = ~( | P[k] )\n"
            "• Active Product Mask Generation:\n"
            "    M[k] = ~( Z_w[k]  |  Z_p[k] ),   k ∈ {0..8}\n"
            "• Output: 9-bit Active Mask M = [m8..m0]\n"
            "• Clamps zero products before multiplication",
            fontdict=font_body, ha='left', va='center', zorder=3)

    # Arrow 4 -> 5 (To Tier 2 FFS)
    ax.annotate('', xy=(118, 68.5), xytext=(113, 68.5),
                arrowprops=dict(facecolor=c_arrow, edgecolor=c_arrow, arrowstyle="-|>", lw=1.5), zorder=2)
    ax.add_patch(FancyBboxPatch((113.0, 70.2), 6.5, 3.5, boxstyle="round,pad=0.1,rounding_size=0.4",
                                facecolor='#FEF3C7', edgecolor='#D97706', lw=0.8, zorder=4))
    ax.text(116.25, 71.95, "Mask M", fontdict=font_small, color='#92400E', ha='center', va='center', weight='bold', zorder=5)

    # Sub-block 5: Tier-2 Dynamic Zero-Skipping Controller
    ax.add_patch(FancyBboxPatch((118, 56), 33, 26, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_t2_bg, edgecolor=c_t2_border, linewidth=1.5, zorder=2))
    ax.text(134.5, 79.5, "5. Tier-2 FFS Zero-Skipping FSM", fontdict=font_title, ha='center', color=c_t2_txt, zorder=3)
    ax.text(134.5, 77.0, "Dynamic Latency & Cycle Compression Engine", fontdict=font_small, ha='center', color='#B45309', style='italic', zorder=3)

    ax.text(119.5, 66.8,
            "• Find-First-Set (FFS) Priority Encoder:\n"
            "    next_k = FFS(M)  in O(1) combinational delay\n"
            "• Bypasses All Zero-Product Clock Cycles\n"
            "• Deterministic Cycle Count = Non-Zero Count (N ≤ 9)\n"
            "• 1-Cycle Fast Finish when patch is all-zero (M = 0)\n"
            "• Compresses 9-cycle baseline down to ~5.9 cycles\n"
            "• Delivers 1.53× Silicon Execution Speedup",
            fontdict=font_body, ha='left', va='center', zorder=3)

    # Arrow from Tier-2 down to Tier-1 MAC
    ax.annotate('', xy=(115.5, 49), xytext=(134.5, 56),
                arrowprops=dict(facecolor=c_arrow, edgecolor=c_arrow, arrowstyle="-|>", lw=1.8,
                                connectionstyle="arc3,rad=-0.12"), zorder=2)
    # Badge on arrow (zorder=4 ensures it sits cleanly ON TOP of the arrow)
    ax.add_patch(FancyBboxPatch((121.5, 51.0), 22, 3.8, boxstyle="round,pad=0.2,rounding_size=0.5",
                                facecolor='#DBEAFE', edgecolor='#2563EB', lw=0.9, zorder=4))
    ax.text(132.5, 52.9, "Active Non-Zero Operands (W_k, P_k)", fontdict=font_badge, color='#1E40AF', ha='center', va='center', zorder=5)

    # Sub-block 6: Tier-1 Operand-Isolated & Clock-Gated MAC Core
    ax.add_patch(FancyBboxPatch((80, 27), 71, 21.5, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_t1_bg, edgecolor=c_t1_border, linewidth=1.6, zorder=2))
    ax.text(115.5, 46.2, "6. Tier-1 Operand-Isolated & Clock-Gated MAC Core (mac_combined.sv)", 
            fontdict=font_title, ha='center', color=c_t1_txt, zorder=3)
    
    # Internal sub-boxes inside Tier-1 for clear microarchitecture
    # Box A: Operand Isolation
    ax.add_patch(FancyBboxPatch((82, 29), 21, 14.5, boxstyle="round,pad=0.3,rounding_size=0.6",
                                facecolor='#FFFFFF', edgecolor='#3B82F6', lw=1.0, zorder=3))
    ax.text(92.5, 41.5, "Operand Isolation (OI)", fontdict=font_bold, ha='center', color='#1D4ED8', zorder=4)
    ax.text(83.2, 34.8, 
            "• Clamps inputs to 0 when idle\n"
            "• Eliminates internal toggling\n"
            "• Energy: 0.80 pJ/MAC\n"
            "  (vs 1.25 pJ in un-isolated)\n"
            "• 36% dynamic switching cut",
            fontdict=font_small, ha='left', va='center', zorder=4)

    # Box B: Pure LUT Multiplier (0 DSP)
    ax.add_patch(FancyBboxPatch((105, 29), 22.5, 14.5, boxstyle="round,pad=0.3,rounding_size=0.6",
                                facecolor='#FFFFFF', edgecolor='#3B82F6', lw=1.0, zorder=3))
    ax.text(116.25, 41.5, "Distributed LUT Multiplier", fontdict=font_bold, ha='center', color='#1D4ED8', zorder=4)
    ax.text(106.2, 34.8,
            "• 8×8 Signed Multiplier Tree\n"
            "• Pure Slice Logic Implementation\n"
            "• Zero DSP48 Slices (0 DSP)\n"
            "• 16-bit Intermediate Product\n"
            "• 100% Bit-Exact Precision",
            fontdict=font_small, ha='left', va='center', zorder=4)

    # Box C: Clock-Gated Accumulator
    ax.add_patch(FancyBboxPatch((129.5, 29), 19.5, 14.5, boxstyle="round,pad=0.3,rounding_size=0.6",
                                facecolor='#FFFFFF', edgecolor='#3B82F6', lw=1.0, zorder=3))
    ax.text(139.25, 41.5, "Clock-Gated Accumulator", fontdict=font_bold, ha='center', color='#1D4ED8', zorder=4)
    ax.text(130.5, 34.8,
            "• Glitch-free clock enable gating\n"
            "• Freezes clock toggling on zero\n"
            "• 32-bit Signed Accumulator Reg\n"
            "• Computes Y = Σ (W_k · P_k)\n"
            "• Suppresses register power",
            fontdict=font_small, ha='left', va='center', zorder=4)

    # Arrow 6 -> 7 (Down to Telemetry Transmitter)
    ax.annotate('', xy=(115.5, 22), xytext=(115.5, 27),
                arrowprops=dict(facecolor=c_arrow, edgecolor=c_arrow, arrowstyle="-|>", lw=1.5), zorder=2)

    # Sub-block 7: Hardware Telemetry Transmitter
    ax.add_patch(FancyBboxPatch((80, 10), 71, 11.5, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_card_bg, edgecolor=c_card_border, linewidth=1.3, zorder=2))
    ax.text(115.5, 19.0, "7. Silicon Telemetry Packetizer & UART Transmitter (HIL Verification)", 
            fontdict=font_title, ha='center', zorder=3)
    
    # Visual depiction of 6-byte packet
    ax.add_patch(Rectangle((83, 12), 24, 4.2, facecolor='#DBEAFE', edgecolor='#2563EB', lw=0.9, zorder=3))
    ax.text(95, 14.1, "4-Byte Result Y(r, c) [31..0]", fontdict=font_small, color='#1E40AF', ha='center', va='center', zorder=4)
    
    ax.add_patch(Rectangle((110, 12), 18, 4.2, facecolor='#FEF3C7', edgecolor='#D97706', lw=0.9, zorder=3))
    ax.text(119, 14.1, "1-Byte Cycles (N_cyc)", fontdict=font_small, color='#92400E', ha='center', va='center', zorder=4)
    
    ax.add_patch(Rectangle((130.5, 12), 18, 4.2, facecolor='#DCFCE7', edgecolor='#16A34A', lw=0.9, zorder=3))
    ax.text(139.5, 14.1, "1-Byte Skips (N_skp)", fontdict=font_small, color='#15803D', ha='center', va='center', zorder=4)

    # =========================================================================
    # 5. HOST POST-PROCESSING & RECONSTRUCTION (Bottom-Left)
    # =========================================================================

    # Block 8: Telemetry De-framing & Hardware Analytics
    ax.add_patch(FancyBboxPatch((35, 10), 27.5, 30.5, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_card_bg, edgecolor=c_card_border, linewidth=1.2, zorder=2))
    ax.text(48.75, 37.5, "8. Telemetry Ingestion &\nHardware Profiling", fontdict=font_title, ha='center', va='center', zorder=3)

    ax.text(36.2, 23.5,
            "• Deserializes 6-Byte Serial Stream:\n"
            "    Y(r, c) = unpack('<i', rx[0:4])\n"
            "    Cycles  = rx[4],  Skips = rx[5]\n"
            "• Live Performance Analytics:\n"
            "    - Silicon Latency @ 50 MHz (ms)\n"
            "    - Real Throughput (76.24 MMAC/s)\n"
            "    - Dynamic Energy Dissipation (uJ)\n"
            "    - Energy-Delay Product (1.78x EDP)\n"
            "• Real-Time Spatial Matrix Assembly:\n"
            "    Out_Matrix[r, c] = Y(r, c)",
            fontdict=font_body, ha='left', va='center', zorder=3)

    # Arrow 8 -> 9
    ax.annotate('', xy=(32.5, 25), xytext=(35, 25),
                arrowprops=dict(facecolor=c_arrow, edgecolor=c_arrow, arrowstyle="-|>", lw=1.5), zorder=2)

    # Block 9: Reconstruction & Validation
    ax.add_patch(FancyBboxPatch((4, 10), 28.5, 30.5, boxstyle="round,pad=0.4,rounding_size=1.0",
                                facecolor=c_recon_bg, edgecolor=c_recon_border, linewidth=1.5, zorder=2))
    ax.text(18.25, 37.5, "9. Image Reconstruction &\nMathematical Validation", 
            fontdict=font_title, ha='center', va='center', color=c_recon_txt, zorder=3)

    # Visual icon: reconstructed edge map
    ax.add_patch(Rectangle((11.5, 26.5), 13.5, 6.5, facecolor='#1E293B', edgecolor='#16A34A', lw=1.2, zorder=3))
    # Simulated edge line inside
    ax.plot([13.5, 16.5, 19.5, 22.5], [28.0, 31.0, 29.0, 31.5], color='#4ADE80', lw=1.6, zorder=4)
    ax.text(18.25, 24.8, "Edge Feature Map", fontdict=font_small, color='#15803D', ha='center', weight='bold', zorder=4)

    ax.text(5.2, 16.8,
            "• Absolute Gradient Synthesis:\n"
            "    |G(r, c)| = |Gx(r, c)| + |Gy(r, c)|\n"
            "• Min-Max Dynamic Range Scaling:\n"
            "    I_out = (Mag - Min) / (Max - Min) × 255\n"
            "• 8-bit PNG Spatial Feature Output\n"
            "• 100% Bit-Exact Verification (PSNR = inf)\n"
            "• Zero Floating-Point Drift / 0 Mismatches",
            fontdict=font_body, ha='left', va='center', zorder=3)

    # =========================================================================
    # 6. ENGINEERING TITLE & METRIC BANNER (Bottom Footer Block)
    # =========================================================================
    # Like an authentic IEEE / Engineering drawing border & specification block
    ax.add_patch(Rectangle((2, 0.8), 151, 4.6, facecolor='#0F172A', edgecolor='#0F172A', lw=1.0, zorder=2))
    
    ax.text(4, 3.3, "SYSTEM WORKFLOW & ARCHITECTURAL DATAFLOW", fontdict={'family': 'sans-serif', 'weight': 'bold', 'size': 9.0}, color='#F8FAFC', zorder=3)
    ax.text(4, 1.8, "Ultra-Low Power Dual-Tier Zero-Skipping Edge Vision Accelerator", fontdict={'family': 'sans-serif', 'size': 7.2}, color='#94A3B8', zorder=3)

    ax.text(65, 3.3, "PLATFORM: Xilinx Spartan-7 (XC7S15-FTGB196) @ 50 MHz", fontdict={'family': 'sans-serif', 'weight': 'bold', 'size': 8.0}, color='#38BDF8', zorder=3)
    ax.text(65, 1.8, "SILICON METRICS: 1.53x Speedup | 1.78x EDP | 0 DSP Slices | 100% Bit-Exact", fontdict={'family': 'sans-serif', 'size': 7.2}, color='#CBD5E1', zorder=3)

    ax.text(130, 3.3, "STATUS: HARDWARE VERIFIED", fontdict={'family': 'sans-serif', 'weight': 'bold', 'size': 8.0}, color='#4ADE80', zorder=3)
    ax.text(130, 1.8, "HIL UART STREAMING (COM17)", fontdict={'family': 'sans-serif', 'size': 7.2}, color='#94A3B8', zorder=3)

    plt.tight_layout()
    out_path = 'docs/images/mac_vision_workflow.png'
    plt.savefig(out_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[SUCCESS] Regenerated ultra-clean workflow diagram at: {out_path}")

if __name__ == '__main__':
    create_workflow_diagram()
