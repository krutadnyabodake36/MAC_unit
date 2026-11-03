# Complete Project Viva Guide: Dual-Tier Zero-Skipping Edge Vision MAC Accelerator

---

## Table of Contents
1. [Core Principles of the Multiply-Accumulate (MAC) Unit](#1-core-principles-of-the-multiply-accumulate-mac-unit)
2. [Why Edge Vision Accelerators Need Zero-Skipping](#2-why-edge-vision-accelerators-need-zero-skipping)
3. [Architectural Deep-Dive: Baseline vs. Proposed MAC Unit](#3-architectural-deep-dive-baseline-vs-proposed-mac-unit)
4. [From Single MAC to 2D Convolution Engines](#4-from-single-mac-to-2d-convolution-engines)
5. [End-to-End Image Processing & Mathematical Vectorization](#5-end-to-end-image-processing--mathematical-vectorization)
6. [Hardware Communication & FPGA Silicon Execution](#6-hardware-communication--fpga-silicon-execution)
7. [Host Image Reconstruction & Bit-Exact Verification](#7-host-image-reconstruction--bit-exact-verification)
8. [Comprehensive Mathematical Foundations](#8-comprehensive-mathematical-foundations)
9. [Synthesis, Implementation, & Silicon Resource Profile](#9-synthesis-implementation--silicon-resource-profile)
10. [Workload Benchmark Suite & Comparative Analysis](#10-workload-benchmark-suite--comparative-analysis)
11. [Master Viva Questions & Model Answers](#11-master-viva-questions--model-answers)

---

## 1. Core Principles of the Multiply-Accumulate (MAC) Unit

### 1.1 What is a MAC Unit?
A **Multiply-Accumulate (MAC)** unit is a dedicated digital arithmetic circuit that computes the product of two numbers and adds that product to an internal accumulating register in a continuous loop.

$$\text{Accumulator}[n] = \text{Accumulator}[n-1] + (A[n] \times B[n])$$

```
                     Input A [8-bit signed] ────┐
                                                ├────> [ Signed Multiplier (8x8) ]
                     Input B [8-bit signed] ────┘                   │
                                                                    ▼
                                                            Product [16-bit signed]
                                                                    │
                                                                    ▼
   Clock / Reset ──> [ Accumulator Register (32-bit) ] ─────> [ Adder (32-bit) ]
                              ▲                                     │
                              └─────────────────────────────────────┘
```

### 1.2 The Three Hardware Stages of a Synchronous MAC
1. **Multiplication Stage**: Computes the intermediate 16-bit signed product of two 8-bit two's complement inputs ($A \times B$).
2. **Sign-Extension & Addition Stage**: Sign-extends the 16-bit product to 32 bits and adds it to the current 32-bit accumulator register contents.
3. **Accumulator Storage Stage**: A 32-bit register with synchronous active-low reset (`rst_n`) and clock enable (`en`) that latches the new sum on the rising clock edge.

### 1.3 Why is the MAC Unit Ubiquitous in Modern Computing?
- **Convolutional Neural Networks (CNNs)**: Fully-connected and convolutional layers are composed almost entirely of inner vector products ($\mathbf{w} \cdot \mathbf{x}$).
- **Digital Image Filtering (Sobel, Gaussian, Laplacian)**: Spatial convolution slides a $3 \times 3$ or $5 \times 5$ weight kernel over pixels, requiring 9 to 25 MAC operations per output pixel.
- **Digital Signal Processing (FIR/IIR Filters, FFT, Matrix Multiplication)**: All linear transformations decompose into repetitive Multiply-Accumulate sequences.
- **The Computational Bottleneck**: In modern vision and deep learning workloads, **over 90% of dynamic energy and execution time** is consumed inside MAC arrays. Multipliers feature deep combinational logic trees with high internal parasitic capacitance, making them the primary source of dynamic switching power.

---

## 2. Why Edge Vision Accelerators Need Zero-Skipping

### 2.1 The Problem: Ineffectual Computations
In computer vision, images contain massive structural and natural **sparsity** (zeros):
1. **Structural Filter Sparsity**: Classical vision filters natively contain zeros. For example, the standard horizontal Sobel gradient filter ($G_x$) and vertical Sobel filter ($G_y$) contain **33.3% zeros** by mathematical definition:

$$G_x = \begin{bmatrix} -1 & 0 & +1 \\ -2 & 0 & +2 \\ -1 & 0 & +1 \end{bmatrix}, \quad G_y = \begin{bmatrix} +1 & +2 & +1 \\ 0 & 0 & 0 \\ -1 & -2 & -1 \end{bmatrix}$$

2. **Activation Sparsity**: Real-world images feature dark backgrounds, uniform shadows, saturated bright skies, and zero-padded boundaries. In deep learning, activation functions like **ReLU** ($\max(0, x)$) forcefully zero out 40% to 80% of feature map activations.

### 2.2 The Physics of Wasted Dynamic Switching Power
In CMOS digital integrated circuits, dynamic power dissipation is governed by the charging and discharging of internal logic node capacitances:

$$P_{\text{dynamic}} = \alpha \cdot C_{\text{load}} \cdot V_{DD}^2 \cdot f_{\text{clk}}$$

Where:
- $\alpha$ is the **switching activity factor** (the probability that a logic net toggles from $0 \to 1$ or $1 \to 0$ in a clock cycle).
- $C_{\text{load}}$ is the total parasitic capacitance of the logic gates and interconnect wires.
- $V_{DD}$ is the operating supply voltage ($1.0\text{ V}$ for Spartan-7 core logic).
- $f_{\text{clk}}$ is the system operating clock frequency ($50\text{ MHz}$).

In a conventional baseline MAC, even when $A = 0$ or $B = 0$:
- Multiplier logic gates toggle redundantly, consuming dynamic energy to produce an output of $0$.
- The 32-bit accumulator register clock toggles, burning clock-tree charging energy to compute $\text{Accumulator} + 0 = \text{Accumulator}$.
- The processor spends a full clock cycle computing an ineffectual zero, degrading throughput.

---

## 3. Architectural Deep-Dive: Baseline vs. Proposed MAC Unit

### 3.1 Baseline MAC Architecture (`src/mac_baseline.sv`)
- **Structure**: A standard unconstrained synchronous MAC.
- **Inputs**: `clk`, `rst_n`, `valid_in`, `a[7:0]`, `b[7:0]`.
- **Operation**: On every rising clock edge where `valid_in = 1`:
  $$\text{product} = a \times b$$
  $$\text{accum} \le \text{accum} + \text{sign\_extended}(\text{product})$$
- **Synthesis Profile**: Uses unconstrained combinational logic. Toggles continuously regardless of operand values.

---

### 3.2 Proposed Dual-Tier Low-Power MAC Architecture (`src/mac_combined.sv`)

Our proposed architecture integrates two complementary tiers of zero-skipping:
- **Tier 1 (Intra-Cycle Power Gating)**: Suppresses dynamic switching power when zeros occur.
- **Tier 2 (Inter-Cycle Latency Compression)**: Bypasses clock cycles entirely using priority encoding.

```
                              PROPOSED TIER-1 MAC ARCHITECTURE
                              
  Operand A [8-bit] ───> [ Parallel 8-input NOR ] ──> Z_a ──┐
                                                             ├──> [ OR Gate ] ──> Zero_Det
  Operand B [8-bit] ───> [ Parallel 8-input NOR ] ──> Z_b ──┘                         │
                                                                                       │
                         ┌─────────────────────────────────────────────────────────────┘
                         │
                         ├────────────────────────┐
                         ▼                        ▼
  Operand A ───> [ Isolation MUX / AND ]     CLK ─> [ Glitch-Free CG Latch ]
                     │ (Clamp to 0 on Zero)                     │
                     ▼                                          ▼
                [ A_clamped ]                               Gated_CLK
                     │                                          │
                     ▼                                          │
  Operand B ───> [ Isolation MUX / AND ]                        │
                     │ (Clamp to 0 on Zero)                     │
                     ▼                                          │
                [ B_clamped ]                                   │
                     │                                          │
                     ▼                                          │
        [ 8x8 Distributed Multiplier ]                          │
                     │                                          │
                     ▼                                          │
           Product [16-bit signed]                              │
                     │                                          │
                     ▼                                          │
        [ 32-bit Sign-Extended Adder ]                          │
                     │                                          │
                     ▼                                          ▼
        [ 32-bit Accumulator Register ] <───────────────────────┘
```

#### Technique 1: Operand Isolation (OI)
- **Concept**: Before operands reach the multiplier tree, combinational clamping gates force the multiplier inputs to constant `8'h00` whenever either operand is zero:
  ```systemverilog
  wire is_zero = (a == 8'sd0) || (b == 8'sd0);
  wire signed [7:0] a_clamped = is_zero ? 8'sd0 : a;
  wire signed [7:0] b_clamped = is_zero ? 8'sd0 : b;
  ```
- **Physical Silicon Impact**: Because inputs to the multiplier are clamped to zero, internal nets inside the logic tree never transition. Parasitic capacitors are neither charged nor discharged.
- **Energy Metric**: Drops dynamic energy per zero-MAC from **$1.25\text{ pJ}$** down to **$0.80\text{ pJ}$** (a **$36.0\%$ dynamic energy reduction**).

#### Technique 2: Glitch-Free Clock Gating (CG)
- **Concept**: If `is_zero == 1`, the accumulator register contents will not change ($\text{Accum} + 0 = \text{Accum}$). The clock feeding the 32-bit accumulator flip-flops is gated:
  ```systemverilog
  wire accum_clk_en = valid_in && !is_zero;
  ```
- **Physical Silicon Impact**: Eliminates capacitive charging across the 32 clock-pin inputs of the accumulator flip-flops and freezes register updates.

---

## 4. From Single MAC to 2D Convolution Engines

To perform a spatial convolution across an image, a $3 \times 3$ sliding filter requires 9 distinct Multiply-Accumulate operations per output pixel:

$$Y(r, c) = \sum_{k=0}^{8} W_k \cdot P_k$$

### 4.1 Baseline Convolution Engine (`src/conv2d_serial_baseline.sv`)
- **Control Logic**: Uses a rigid modulo-9 state machine (`counter = 0, 1, 2, ..., 8`).
- **Timing**: Consumes **strictly 9 clock cycles** for every receptive patch.
- **Drawback**: Even if 7 out of the 9 incoming pixels are zero, it takes 9 full clock cycles, wasting 7 clock cycles performing redundant additions of zero.

---

### 4.2 Proposed Zero-Skipping Engine (`src/conv2d_serial_proposed.sv`)

Our proposed engine introduces **Tier-2 Dynamic Latency Compression**:

```
                       PROPOSED CONVOLUTION ENGINE DATAFLOW
                       
   18 Ingress Registers: 9 Weights W[0..8] and 9 Pixels P[0..8]
                          │
                          ▼
   [ 9-Way Parallel 8-bit NOR Zero Detection ]  (Executes in 1 Combinational Cycle)
   Z_w[k] = ~( | W[k] ),   Z_p[k] = ~( | P[k] )
                          │
                          ▼
   [ 9-Bit Active Product Mask Generator ]
   M[k] = ~( Z_w[k] | Z_p[k] ),   k in {0..8}
                          │
         ┌────────────────┴────────────────┐
         ▼                                 ▼
   Case 1: M == 9'b0                 Case 2: M != 9'b0
   (All-Zero Patch)                  (Contains Active Products)
         │                                 │
         ▼                                 ▼
   1-Cycle Fast Finish               [ Find-First-Set (FFS) Priority Encoder ]
   * Skip all 9 MAC cycles           * Select next active index: k = FFS(M)
   * Set result Y = 0                * Dispatch (W_k, P_k) to Tier-1 MAC
   * Cycles taken = 1 cycle          * Clear bit k: M <= M & ~(1 << k)
                                     * Repeat until M == 0
                                           │
                                           ▼
                                     Total Cycles = Non-Zero Count (N <= 9)
```

#### Step 1: Parallel Zero-Detection Logic
In a single combinational cycle, the engine reduces all 18 input bytes using wide parallel NOR reduction:
```systemverilog
genvar i;
generate
    for (i = 0; i < 9; i = i + 1) begin : gen_zero_detect
        assign zero_w[i] = (weights[i] == 8'sd0);
        assign zero_p[i] = (pixels[i]  == 8'sd0);
        assign active_mask[i] = ~(zero_w[i] | zero_p[i]);
    end
endgenerate
```

#### Step 2: Priority-Encoded Find-First-Set (FFS) Dispatcher
The FSM examines `active_mask[8:0]`. A combinational priority encoder identifies the lowest set bit in $\mathcal{O}(1)$ time:
```systemverilog
always_comb begin
    casez (active_mask_reg)
        9'b???????1: next_idx = 4'd0;
        9'b??????10: next_idx = 4'd1;
        9'b?????100: next_idx = 4'd2;
        9'b????1000: next_idx = 4'd3;
        9'b???10000: next_idx = 4'd4;
        9'b??100000: next_idx = 4'd5;
        9'b?1000000: next_idx = 4'd6;
        9'b10000000: next_idx = 4'd7;
        default:     next_idx = 4'd8;
    endcase
end
```
- In each cycle, the selected operand pair $(W_{\text{next\_idx}}, P_{\text{next\_idx}})$ is dispatched to the MAC.
- The corresponding bit in `active_mask_reg` is cleared.
- Zero-product clock cycles are **physically bypassed**; the engine never spends a cycle on them.

#### Step 3: Fast-Finish on Full-Zero Patches
If `active_mask == 9'b000000000`, the engine transitions directly to the `DONE` state in **exactly 1 clock cycle**, outputting $Y = 0$, cycles elapsed = 1, and skips = 9.

---

## 5. End-to-End Image Processing & Mathematical Vectorization

The end-to-end framework bridges a software host workstation (Python) with the physical Spartan-7 FPGA development board.

```
+-----------------------------------------------------------------------------------------+
|                                    HOST WORKSTATION                                     |
|                                                                                         |
|  [ Raw Grayscale Image (W x H) ]                                                        |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ 1-Pixel Border Zero-Padding ] ──> Dimensions: (W+2) x (H+2)                          |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ 3x3 Sliding Window Extraction ] (Row-by-Row, Stride = 1)                             |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Flatten to 1D Vectors ] ──> P = [p0..p8] (8-bit signed), W = [w0..w8] (8-bit signed) |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Pack 18-Byte Binary Frame ] ──> struct.pack('9b9b', *W, *P)                          |
+-----------------------------------------------------------------------------------------+
                                              │
                                              ▼ Downstream UART Stream (115,200 Baud)
+-----------------------------------------------------------------------------------------+
|                                  SPARTAN-7 FPGA SILICON                                 |
|                                                                                         |
|  [ 18-Byte Ingress Holding Register File ]                                              |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Parallel 9-Way NOR Zero Detection ] ──> Generates 9-bit Mask M[8..0]                 |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Tier-2 FFS Priority Encoder ] ──> Bypasses ineffectual cycles (1 to 9 cycles)        |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Tier-1 Low-Power MAC Core ] ──> Operand Isolation + Distributed Multiplier + CG      |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ 6-Byte Telemetry Packetizer ] ──> [ 4B Result Y | 1B Cycle Count | 1B Skip Count ]   |
+-----------------------------------------------------------------------------------------+
                                              │
                                              ▼ Upstream UART Stream (115,200 Baud)
+-----------------------------------------------------------------------------------------+
|                                    HOST WORKSTATION                                     |
|                                                                                         |
|  [ Deserialization ] ──> struct.unpack('<iBB', rx_bytes)                                |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Dual-Gradient Fusion ] ──> |G(r, c)| = |Gx(r, c)| + |Gy(r, c)|                       |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Min-Max Scaling to [0, 255] ] ──> I_out = ((|G| - Min) / (Max - Min)) * 255          |
|                 │                                                                       |
|                 ▼                                                                       |
|  [ Reconstructed Edge Feature Map ] ──> Saved as 8-bit PNG (100% Bit-Exact, PSNR = inf)  |
+-----------------------------------------------------------------------------------------+
```

### Detailed Vectorization Steps
1. **Grayscale Conversion**: Image is ingested as a 2D matrix of 8-bit intensity pixels $I(y, x) \in [0, 255]$.
2. **Symmetric Zero-Padding**: To maintain spatial resolution after $3 \times 3$ filtering, a 1-pixel boundary of zeros is added:
   $$I_{\text{pad}}(y, x) = \begin{cases} I(y-1, x-1) & \text{if } 1 \le y \le H \text{ and } 1 \le x \le W \\ 0 & \text{otherwise} \end{cases}$$
   The padded image size is $(H+2) \times (W+2)$.
3. **Sliding Receptive Window (Stride = 1)**:
   For every coordinate $(r, c)$ where $0 \le r < H$ and $0 \le c < W$, a $3 \times 3$ window extracts:
   $$P_{\text{patch}} = \begin{bmatrix} I_{\text{pad}}(r, c) & I_{\text{pad}}(r, c+1) & I_{\text{pad}}(r, c+2) \\ I_{\text{pad}}(r+1, c) & I_{\text{pad}}(r+1, c+1) & I_{\text{pad}}(r+1, c+2) \\ I_{\text{pad}}(r+2, c) & I_{\text{pad}}(r+2, c+1) & I_{\text{pad}}(r+2, c+2) \end{bmatrix}$$
4. **Vector Flattening**:
   $P_{\text{patch}}$ is flattened row-major into a 9-element signed 8-bit array:
   $$P = [p_0, p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8]$$
   Paired with the corresponding 9-element filter kernel vector (e.g., Sobel $G_x$):
   $$W = [-1, 0, +1, -2, 0, +2, -1, 0, +1]$$
5. **Frame Packing**:
   Combined into an 18-byte binary frame containing 9 weight bytes followed by 9 pixel bytes:
   ```python
   payload = struct.pack('9b9b', *weights, *pixels)
   ```

---

## 6. Hardware Communication & FPGA Silicon Execution

### 6.1 The Physical Interface
- **Board**: Invent Logics EDGE Spartan-7 Development Board.
- **FPGA Chip**: Xilinx Spartan-7 `XC7S15-FTGB196` (28nm architecture).
- **Physical Link**: Full-duplex asynchronous UART over USB (Silicon Labs CP2102 bridge).
- **Port Settings**: `COM17`, Baud Rate = **115,200 bps**, 8 Data Bits, No Parity, 1 Stop Bit (8-N-1).
- **Core Clock**: $50.00\text{ MHz}$ onboard oscillator ($20.00\text{ ns}$ period).

### 6.2 Top-Level Hardware Wrapper (`src/conv2d_benchmark_top.sv`)
The top-level FPGA design wraps the UART transceiver and convolution engine:
1. **UART Receiver FSM**:
   - Oversamples the RX line by $16\times$ at $115,200\text{ baud}$.
   - Assembles 18 incoming serial bytes into an 18-entry, 8-bit register file.
   - Asserts an internal `start` pulse once byte 17 is latched.
2. **Convolution Engine Core**:
   - Runs at $50\text{ MHz}$.
   - Generates the 9-bit mask, encodes active indices via FFS, and processes active terms through the Tier-1 MAC.
   - An internal 8-bit counter tracks clock cycles spent; another tracks skipped zero-MAC operations.
3. **UART Transmitter FSM**:
   - Triggered upon receiving the engine's `done` strobe.
   - Serializes a **6-byte binary telemetry frame** back to the laptop:
     - `Byte 0`: Output Result $Y[7:0]$ (LSB)
     - `Byte 1`: Output Result $Y[15:8]$
     - `Byte 2`: Output Result $Y[23:16]$
     - `Byte 3`: Output Result $Y[31:24]$ (MSB)
     - `Byte 4`: Measured Silicon Execution Cycles ($N_{\text{cyc}}$)
     - `Byte 5`: Skipped Ineffectual MAC Operations ($N_{\text{skip}}$)

---

## 7. Host Image Reconstruction & Bit-Exact Verification

### 7.1 Telemetry Parsing
When the host laptop receives the 6-byte response packet over COM17, it deserializes it:
```python
rx_bytes = ser.read(6)
result_y, cycles, skips = struct.unpack('<iBB', rx_bytes)
```
- `<i`: 32-bit signed integer in Little-Endian format ($Y(r, c)$).
- `BB`: Two 8-bit unsigned bytes (Execution Cycles and Zero Skips).

### 7.2 Spatial Accumulation & Gradient Magnitude
To produce a complete gradient edge map, the vision pipeline performs two convolution passes over the image:
1. Pass 1 with horizontal Sobel kernel $G_x \implies$ Yields matrix $Y_x(r, c)$.
2. Pass 2 with vertical Sobel kernel $G_y \implies$ Yields matrix $Y_y(r, c)$.

The gradient magnitude $|G(r, c)|$ is calculated using the Manhattan approximation:
$$|G(r, c)| = |Y_x(r, c)| + |Y_y(r, c)|$$

### 7.3 Min-Max Dynamic Range Scaling to 8-Bit Grayscale
Because convolution responses can exceed $[0, 255]$ (Sobel outputs range from $-1020$ to $+1020$), the host scales values into an 8-bit displayable image:

$$I_{\text{out}}(r, c) = \text{round}\left( \frac{|G(r, c)| - |G|_{\min}}{|G|_{\max} - |G|_{\min}} \times 255 \right)$$

The normalized matrix is saved as an 8-bit grayscale PNG image.

### 7.4 Bit-Exact Verification
The profiler independently calculates the identical convolution using floating-point/INT32 arithmetic in software on the CPU (the golden model). It computes the Peak Signal-to-Noise Ratio (PSNR):

$$\text{MSE} = \frac{1}{H \times W} \sum_{r=0}^{H-1} \sum_{c=0}^{W-1} \left( Y_{\text{hardware}}(r, c) - Y_{\text{golden}}(r, c) \right)^2$$

$$\text{PSNR} = 10 \cdot \log_{10} \left( \frac{255^2}{\text{MSE}} \right)$$

Across all tested workloads:
- $\text{Total Mismatches} = \mathbf{0}$
- $\text{MSE} = \mathbf{0.000000}$
- $\text{PSNR} = \mathbf{\infty\text{ dB}}$

This demonstrates that our zero-skipping architecture achieves **100% bit-exact mathematical fidelity**.

---

## 8. Comprehensive Mathematical Foundations

### 8.1 2D Spatial Discrete Convolution
$$Y(r, c) = \sum_{u=-1}^{1} \sum_{v=-1}^{1} I(r+u, c+v) \cdot K(u+1, v+1)$$

Flattened to 1D dot product:
$$Y = \sum_{k=0}^{8} W_k \cdot P_k$$

### 8.2 Parallel Zero Detection (Boolean Formulation)
For 8-bit two's complement vectors $W_k, P_k \in [-128, +127]$:
$$Z_w[k] = \overline{\bigvee_{b=0}^{7} W_k[b]} = \begin{cases} 1 & \text{if } W_k = 0 \\ 0 & \text{if } W_k \ne 0 \end{cases}$$

$$Z_p[k] = \overline{\bigvee_{b=0}^{7} P_k[b]} = \begin{cases} 1 & \text{if } P_k = 0 \\ 0 & \text{if } P_k \ne 0 \end{cases}$$

The active product mask bit $M[k]$ is defined as:
$$M[k] = \overline{Z_w[k] \lor Z_p[k]} = \begin{cases} 1 & \text{if } (W_k \ne 0) \land (P_k \ne 0) \\ 0 & \text{if } (W_k = 0) \lor (P_k = 0) \end{cases}$$

### 8.3 Workload Sparsity Metrics
1. **Global Zero Sparsity ($S_{\text{global}}$)**:
   $$S_{\text{global}} = \frac{\sum_{k=0}^{N_{\text{total}}-1} \mathbb{I}(M_k == 0)}{N_{\text{total}}} \times 100\%$$
   *(Baseline Sobel structural sparsity is $33.33\%$. Across our real-world image benchmarks, total sparsity is $\sim 34.4\%$.)*

2. **Theoretical Minimum Execution Latency ($L_{\text{optimal}}$)**:
   $$L_{\text{optimal}} = \sum_{k=0}^{8} M[k] \quad \text{cycles (subject to } L \ge 1\text{)}$$

### 8.4 Hardware Throughput & Speedup Formulation
- **Baseline Engine Throughput**:
  $$\Theta_{\text{baseline}} = \frac{9 \text{ MAC ops}}{9 \text{ cycles} \times 20\text{ ns}} = 50.00\text{ MMAC/s}$$
- **Proposed Engine Throughput**:
  $$\Theta_{\text{proposed}} = \frac{9 \text{ MAC ops}}{\bar{N}_{\text{cycles}} \times 20\text{ ns}} = \frac{9}{5.898 \times 20\text{ ns}} = \mathbf{76.24\text{ MMAC/s}}$$
- **Hardware Speedup**:
  $$S = \frac{\Theta_{\text{proposed}}}{\Theta_{\text{baseline}}} = \frac{76.24}{50.00} = \mathbf{1.525\times \approx 1.53\times}$$

### 8.5 Dynamic Energy & Energy-Delay Product (EDP)
- **Silicon Execution Time**:
  $$t_{\text{latency}} = N_{\text{cycles}} \times T_{\text{clk}} = N_{\text{cycles}} \times 20\text{ ns}$$
- **Total Dynamic Energy Dissipation**:
  $$E_{\text{dynamic}} = P_{\text{active}} \times t_{\text{latency}}$$
- **Energy-Delay Product (EDP)**:
  $$\text{EDP} = E_{\text{dynamic}} \times t_{\text{latency}} = P_{\text{active}} \times (t_{\text{latency}})^2$$

Because latency is reduced by **$34.47\%$** ($1.659\text{ ms} \to 1.087\text{ ms}$), even with active core power slightly higher due to higher functional throughput ($0.550\text{ mW} \to 0.721\text{ mW}$), the quadratic latency reduction dominates:
$$\text{EDP Improvement} = \frac{\text{EDP}_{\text{baseline}}}{\text{EDP}_{\text{proposed}}} = \frac{1.51 \times 10^{-9}\text{ J}\cdot\text{s}}{8.52 \times 10^{-10}\text{ J}\cdot\text{s}} = \mathbf{1.78\times}$$

---

## 9. Synthesis, Implementation, & Silicon Resource Profile

Synthesis and implementation were executed in **Xilinx Vivado 2023.2** targeting the **XC7S15-FTGB196-1** FPGA.

| Physical Resource | Available on Chip | Baseline Conv2D Engine | Proposed Zero-Skipping Engine | Net Overhead | Utilization % |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **LUT Elements** | 8,000 | 182 | 238 | **+56 LUTs** | **2.98%** (+0.70%) |
| **Flip-Flops (FF)** | 16,000 | 224 | 241 | **+17 FFs** | **1.51%** (+0.11%) |
| **DSP48E1 Slices** | 20 | **0** | **0** | **0 DSP** | **0.00%** |
| **Block RAM (BRAM)**| 10 | **0** | **0** | **0 BRAM** | **0.00%** |
| **Maximum Frequency**| — | 94.34 MHz | 80.64 MHz | -13.7 MHz | Fmax > 50 MHz |
| **Operating Frequency**| — | 50.00 MHz | 50.00 MHz | 0.00 MHz | Safe Slack |

### Why 0 DSP Slices is a Major Advantage
On small edge FPGAs (Spartan-7 XC7S15), there are only **20 total DSP slices**. Prior accelerators consume dozens to hundreds of DSPs (e.g., Véstias et al. consumes **192 DSPs**). By mapping our 8-bit multiplier tree into **distributed Slice LUT logic**, our design consumes **0 DSP slices**, freeing up all DSP blocks for other processing pipelines.

---

## 10. Workload Benchmark Suite & Comparative Analysis

### 10.1 Workload Characterization
To validate the architecture, three distinct visual regimes were benchmarked:

1. **High-Density Edge Workload** ($91 \times 128$, 11,648 patches):
   - High spatial entropy ($7.33\text{ bits/pixel}$), dense multi-angle edges ($18.91\%$ Canny edge density).
   - **Purpose**: Stress test under high visual activity.
2. **Natural Scene Workload** ($128 \times 72$, 9,216 patches):
   - Bimodal contrast ($125.0 \pm 118.4$, dark foreground and bright sky, $6.14\%$ edge density).
   - **Purpose**: Real-world contrast adaptation and variable-latency testing.
3. **Uniform Surface Workload** ($85 \times 128$, 10,880 patches):
   - Uniform bright planar surfaces with sparse boundaries ($1.79\%$ edge density, $77.8\%$ peak localized patch sparsity).
   - **Purpose**: Validates 1-cycle fast finish and maximum clock gating efficiency.

### 10.2 Silicon Performance Summary Across Workloads

| Parameter | High-Density Edge Workload | Natural Scene Workload | Uniform Surface Workload | Comparative Synthesis |
| :--- | :---: | :---: | :---: | :--- |
| **Workload Purpose** | Stress test under high visual activity | Dynamic contrast adaptation test | Clock gating & fast-finish test | Covers diverse contrast regimes |
| **Image Resolution (H x W)** | $91 \times 128$ | $128 \times 72$ | $85 \times 128$ | Real-world aspect ratios |
| **Receptive Patches ($N_{\text{pat}}$)** | 11,648 patches | 9,216 patches | 10,880 patches | 82k to 104k total MAC ops |
| **Workload Sparsity (% Zeros)** | 34.42% | 34.47% | 34.46% | Invariant baseline set by Sobel |
| **Baseline Cycles (9 cyc/patch)** | 104,832 cycles | 82,944 cycles | 97,920 cycles | Fixed 9-cycle baseline per patch |
| **Proposed Engine Cycles** | **68,748 cycles** | **54,356 cycles** | **64,176 cycles** | **34.4% cycle compression** |
| **Silicon Latency @ 50 MHz** | $2.097\text{ ms} \to \mathbf{1.375\text{ ms}}$ | $1.659\text{ ms} \to \mathbf{1.087\text{ ms}}$ | $1.958\text{ ms} \to \mathbf{1.284\text{ ms}}$ | Direct temporal execution reduction |
| **Effective Throughput** | **76.24 MMAC/s (1.52x)** | **76.24 MMAC/s (1.53x)** | **76.24 MMAC/s (1.53x)** | Over 50.00 MMAC/s baseline |
| **Total Dynamic Energy** | $1.153\text{ }\mu\text{J} \to \mathbf{0.991\text{ }\mu\text{J}}$ | $0.912\text{ }\mu\text{J} \to \mathbf{0.784\text{ }\mu\text{J}}$ | $1.077\text{ }\mu\text{J} \to \mathbf{0.926\text{ }\mu\text{J}}$ | **14.05% energy reduction** |
| **Energy-Delay Product (EDP)** | $2.42\text{e-}9 \to \mathbf{1.36\text{e-}9\text{ J}\cdot\text{s}}$ | $1.51\text{e-}9 \to \mathbf{8.52\text{e-}10\text{ J}\cdot\text{s}}$ | $2.11\text{e-}9 \to \mathbf{1.19\text{e-}9\text{ J}\cdot\text{s}}$ | **1.78x EDP improvement** |
| **Numerical Output Fidelity** | **100.0% Bit-Exact (PSNR = $\infty$)** | **100.0% Bit-Exact (PSNR = $\infty$)** | **100.0% Bit-Exact (PSNR = $\infty$)** | Zero arithmetic approximation error |
| **Verification Platform** | **Physical Spartan-7 FPGA** | **Physical Spartan-7 FPGA** | **Physical Spartan-7 FPGA** | Real-time hardware telemetry |

---

## 11. Master Viva Questions & Model Answers

### Category 1: Digital VLSI Design & Microarchitecture

#### Q1: What is operand isolation and how is it implemented in your RTL?
> **Answer**: Operand isolation is an architectural low-power technique where combinational clamping gates (such as AND or MUX gates) placed immediately before a functional block force its input signals to zero whenever the block is idle or its inputs are ineffectual. In our `mac_combined.sv`, we detect if either input operand is zero. If so, both inputs entering the multiplier tree are clamped to `8'sd0`. This stops internal logic nets inside the multiplier from switching, reducing dynamic power consumption by **$36\%$** (from $1.25\text{ pJ}$ to $0.80\text{ pJ/MAC}$).

#### Q2: What is the difference between clock gating and operand isolation?
> **Answer**: 
> - **Operand Isolation** operates on **data datapaths**: It clamps combinational inputs to silence internal logic node transitions within functional modules (like multipliers).
> - **Clock Gating** operates on the **clock distribution network**: It disables the clock signal entering flip-flop clock pins (using an integrated clock gating cell or latch), stopping the clock-tree charging and register state updates.
> - In our design, Tier-1 applies **both**: Operand isolation protects the multiplier tree, while clock gating freezes the 32-bit accumulator register.

#### Q3: Why did you use a Find-First-Set (FFS) priority encoder in Tier-2 instead of a simple counter?
> **Answer**: A counter must step through all indices sequentially ($0, 1, 2, \dots, 8$), which takes 9 full clock cycles regardless of how many values are zero. The Find-First-Set (FFS) encoder examines all 9 bits of the active product mask $M[8..0]$ simultaneously and identifies the next active index in $\mathcal{O}(1)$ combinational time. This allows the state machine to skip over zero indices in zero cycles, compressing patch execution latency down to only the non-zero count ($N \le 9$).

---

### Category 2: FPGA Implementation & Vivado Toolchain

#### Q4: Why is a "DSP-Free" architecture significant on FPGAs?
> **Answer**: Dedicated DSP48 slices on low-cost edge FPGAs (like the Spartan-7 XC7S15) are limited to only 20 blocks. If a vision accelerator consumes all DSP slices for spatial convolution, none remain for audio processing, control loops, or communications. Our design synthesizes the $8 \times 8$ signed multiplier into **distributed Slice LUTs**, consuming **0 DSP slices** and requiring only 56 additional LUTs ($+0.70\%$ overhead). This leaves 100% of the FPGA's DSP48 slices available for other subsystems.

#### Q5: Did adding zero-skipping logic hurt your maximum operating frequency ($F_{\max}$)?
> **Answer**: The baseline engine achieved an $F_{\max}$ of $94.34\text{ MHz}$, while our proposed engine achieved $80.64\text{ MHz}$. The minor reduction is due to the combinational path through the 9-way NOR gate reduction and FFS priority encoder. However, because our target operational frequency is **$50.00\text{ MHz}$**, the critical path has positive timing slack ($+7.60\text{ ns}$ setup slack), running with zero timing violations.

---

### Category 3: System-Level & Hardware-in-the-Loop (HIL) Execution

#### Q6: How does the laptop communicate with the FPGA, and how are results verified?
> **Answer**: We built a complete Hardware-in-the-Loop (HIL) execution framework over USB-UART running at $115,200\text{ baud}$ on `COM17`. The laptop streams 18-byte frames ($9\text{ weights} + 9\text{ pixels}$) to the FPGA. The FPGA processes the convolution in silicon, measures the exact execution clock cycles and skipped operations with on-chip counters, and returns a 6-byte telemetry frame ($4\text{B result} + 1\text{B cycles} + 1\text{B skips}$). The host deserializes the result, reconstructs the 2D gradient image, and validates every output against a golden software model, achieving **$100\%$ bit-exact match with $\text{PSNR} = \infty$**.

#### Q7: Does zero-skipping cause any loss in image quality or accuracy?
> **Answer**: **None.** Approximate computing architectures often drop small weights or round activation values, which degrades accuracy by $0.29\%$ to $1.0\%$. Our architecture is **100% bit-exact** because it only skips terms that are **identically zero** ($0 \times X = 0$). Mathematically, adding zero does not alter the accumulator sum:
> $$\sum W_k \cdot P_k \equiv \sum_{k \in \text{active}} W_k \cdot P_k$$
> Across thousands of benchmark patches, there are **0 pixel errors** and the Peak Signal-to-Noise Ratio is infinite ($\text{PSNR} = \infty$).

#### Q8: If active power increases from 0.550 mW to 0.721 mW, why is your proposed engine considered lower power?
> **Answer**: Active power ($P_{\text{active}}$) is the instantaneous power during computation. Because our proposed engine computes at a higher throughput ($1.53\times$ faster), it performs more operations per unit time, resulting in higher instantaneous power. However, **dynamic energy** is power integrated over execution time:
> $$E_{\text{dynamic}} = P_{\text{active}} \times t_{\text{latency}}$$
> Because latency is reduced by $34.47\%$, total dynamic energy drops by **$14.05\%$** (from $1.153\text{ }\mu\text{J}$ to $0.991\text{ }\mu\text{J}$), and the Energy-Delay Product (EDP) improves by **$1.78\times$**.

---

### Quick Recall Summary for Viva Day

- **Project Title**: Ultra-Low Power Dual-Tier Zero-Skipping Edge Vision Accelerator
- **Target FPGA**: Xilinx Spartan-7 `XC7S15-FTGB196` (28nm) @ $50.00\text{ MHz}$
- **Core Multiplier**: $8\text{-bit} \times 8\text{-bit}$ Signed Multiplier $\implies$ 16-bit Product $\implies$ 32-bit Accumulator
- **Tier 1 Innovation**: Intra-cycle Operand Isolation ($0.80\text{ pJ/MAC}$) + Glitch-Free Clock Gating
- **Tier 2 Innovation**: Inter-cycle 9-bit Parallel Zero-Detect + Find-First-Set (FFS) Priority Encoder
- **DSP Slices Consumed**: **0 DSP Slices** (Pure Distributed Slice LUT logic)
- **Logic Overhead**: **56 LUTs** ($+0.70\%$ fabric utilization)
- **Throughput Speedup**: **$1.53\times$** ($76.24\text{ MMAC/s}$ vs. $50.00\text{ MMAC/s}$)
- **Dynamic Energy Reduction**: **$14.05\%$** energy savings
- **Energy-Delay Product (EDP)**: **$1.78\times$** improvement
- **Mathematical Accuracy**: **$100.0\%$ Bit-Exact ($\text{PSNR} = \infty$, 0 mismatches)**
- **Hardware Interface**: HIL UART @ 115,200 Baud on `COM17` (18-Byte TX Frame, 6-Byte RX Telemetry)
