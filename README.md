# 32 bit Radix-4 Booth - Wallace Tree Multiplier

This repository contains the hardware implementation (RTL) of a high-performance multiplier. The design is based on two fundamental techniques for area and latency optimization: Modified Booth encoding (Radix-4) for partial product reduction and the **Wallace Tree** for their parallel compression.

---

## 1. The Standard Multiplication Problem

In traditional binary multiplication, the number of generated partial products is exactly equal to the number of bits in the multiplier.

![Standard Multiplication](img/image_bff6a4.png)

*(Representation of partial product generation in a standard multiplication)*


---

## 2. From Booth to "Modified Booth" Encoding (Radix-4)

### The Original Booth Transform
The Booth transform leverages a mathematical property of binary numbers: sequences of consecutive 1s can be rewritten as a subtraction. For example:

**01111110 = 10000000 - 10**

The greater the number of consecutive 1s, the better the simplification. However, this basic transformation does not truly optimize the hardware circuit. The actual number of required adders remains unchanged relative to the number of bits in the original multiplier, as the hardware structure must be sized for the worst-case scenario.

### The Improved Booth Encoding Method (Radix-4)
To physically reduce the number of partial products and therefore the number of accumulators, **Modified Booth Encoding (Radix-4)** is used.

The binary number of the multiplier $X$ is grouped into 3-bit sets starting from the least significant bit (LSB). Grouping rules:
* The least significant bit of the first group is integrated with a dummy bit $x_{-1}$ is set to **0**.
* Adjacent groups overlap by one bit (the most significant bit of the previous group becomes the least significant bit of the next group).

This method **halves** the number of partial products. For example, in a 32-bit multiplication, instead of generating 32 partial products to sum, only 16 are generated (or 17 in the case of compatible unsigned numbers). 

---

## 3. Partial Product Generation

The relationship between each group of 3 consecutive bits determines the operation to be performed on the multiplicand $Y$. Let $x_{2i+1}$, $x_{2i}$, and $x_{2i-1}$ be the three consecutive bits of the multiplier $X$, and let $PP_i$ be the partial product generated at the i-th step. 

The following truth table shows the required operations:

![Radix-4 Booth Encoding Truth Table](img/image_bffb00.png)
*(Look-up table for Radix-4 Booth encoding)*

Based on these combinations, the partial product can take only 5 possible values: 0, $Y$, $2Y$, $-Y$, $-2Y$.

**Hardware advantages of this implementation:**
* $Y$ and $0$: Direct pass or zeroing.
* $2Y$: In binary, multiplication by 2 is achieved at zero hardware cost with a simple **1-bit left shift (left shift)**.
* Negative values ($-Y$, $-2Y$): These are obtained by calculating the two's complement (bit inversion + adding 1 in the LSB of the subsequent adder).

The most elementary type of improved Booth encoding is precisely this Radix-4, as it does not require any extra adders to generate the partial products (which would happen in a higher-order Booth to generate, for example, a multiple like $3Y$). This makes it the optimal choice for balancing partial product reduction and the simplicity of the generator circuit.

---

## 4. The Wallace Tree (Wallace Tree Compression)

Booth encoding addresses the first aspect of optimization: reducing the number of partial products. However, the carry propagation delay of the accumulators still significantly impacts performance. Here we see the scheme using simple adders for partial sums:

![Radix-4 Booth Multiplier](img/image_bffb0020.png)
*(Multiplier Booth Radix-4 with RCA)*

If direct summation is used, the result of the current bit depends on the carry from the previous bit. This makes the entire process serial and, the wider the bus, the greater the delay will be. The key to optimization is **eliminating carry chains and parallelizing the operation**.

### The Carry-Save Adder (CSA)

The standard technique for parallel accumulation is the use of Carry-Save Adders (CSA). At a logical level, a CSA is essentially a 1-bit **Full Adder** (complete adder), whose logical equations are:

![Carry-Save Adder equations](img/image_c04d3c.png)
$$S_i = A_i \oplus B_i \oplus C_{i-1}$$
$$C_i = A_i B_i + C_{i-1}(A_i + B_i)$$

The real advantage of the CSA does not lie in its internal logic, but in how it is interconnected in the circuit. To understand this, let's suppose we need to sum three 4-bit numbers: $A[3:0]$, $B[3:0]$, and $C[3:0]$.

#### Serial Approach (Inefficient)
In traditional Ripple Carry addition, the first-level addition presents a delay caused by the carry chain.

![Ripple Carry Adder Chain](img/image_c05400.png)
*(Carry chain in a serial adder: the delay increases linearly with the number of bits)*

#### Carry-Save Approach / 3-2 Compression (Efficient)
Using the same CSA hardware, we can reorganize the architecture. Instead of propagating the carry horizontally to the adjacent stage, the CSA accepts three bits from the same column as input and generates two bits as output (a Sum and a Carry for the next column).

![Carry-Save Adder 3-2 Compression](img/image_c054ba.png)

*(Carry-Save Architecture: parallel execution without horizontal carry chains)*

As shown in the diagram, the first stage of the four CSAs is completely parallel. It consumes only a single logic delay (gate delay) that does not increase with bit width. Since this block accepts three inputs and generates two outputs, it is known in RTL literature as a **3-2 Compressor (3-2 compressor**).

### Tree Architecture 

Applied to our multiplier, the Carry-Save method is used to group the partial products generated by Booth into sets of three. The outputs (Sum and Carry vectors) of each stage are in turn compressed in cascade, forming a **tree structure: the Wallace Tree**.

### The Final Addition Stage
The compression process in the Wallace Tree continues in a purely combinatorial and parallel way until exactly **two final rows** are reached **(a Sum vector and a Carry vector)**. Here we can see the dot example of a 8 bit wallace tree reduction:

![dot reduction](img/wallace_tree_mul.png)

*(Dot diagram showing the level-by-level compression of partial products until only two rows remain)*

Since Wallace compression cannot reduce 2 rows into 1 single row without propagating carries, these last two rows are summed using a traditional but extremely fast Fast Carry Propagation Adder (e.g., Carry Look-Ahead Adder or Kogge-Stone Adder) to obtain the final 64-bit product.



# 📂 Project Structure & Workflow
The repository is structured following industrial best practices, separating hardware sources, automation scripts, verification, and synthesis environments:

```text
Booth-Wallace_Multiplier/
├── src/
│   └── rtl/          # VHDL sources (Multiplier, Booth Encoders, CSAs, P4 Adder)
├── sw/               # Python script for automated hardware generation
├── sim/              # Simulation environment (Testbench & Waveforms)
└── syn/              # Logic Synthesis environment (Tcl scripts, Netlists, Reports)
```

##  src/rtl/ & sw/ | Automated Hardware Generation
The src/rtl folder contains all the logic blocks written in VHDL.
Manually wiring a 32-bit Wallace Tree (which requires instantiating and connecting hundreds of Half Adders and Full Adders across 6 compression stages) is highly difficult and inefficient. Therefore, the sw/ folder contains a custom Python scripti made that is designed to automatically generate the structural VHDL code of the compression tree.
Why this approach is a game-changer:

### Algorithmic & Zero-Bug Wiring:
The script tracks the exact "height" of each partial product column. At every stage, it algorithmically groups bits into sets of 3 (instantiating a Full Adder) or 2 (instantiating a Half Adder), calculates the new sum and carry wires, and outputs perfectly mapped VHDL code.

### Instant Scalability:
If the specification suddenly changed from a 32-bit to a 64-bit multiplier, it would take weeks to manually rewiring the tree. With this script, scaling the hardware takes milliseconds — simply update the N parameter and run the script.

### Modern HDL Philosophy: 
This "software-generating-hardware" approach mirrors the philosophy behind next-generation hardware construction languages (like UC Berkeley's Chisel or SpinalHDL). It demonstrates that high-level digital design is no longer just about placing logic gates, but about automating the generation of complex hardware structures.

##  sim/ | Procedural Verification (Testbench)
Verification is not based on simple manual stimuli, but on an advanced procedural testbench (MULTIPLIER_tb.vhd).

Automated Checking: The testbench features a check_mul procedure that dynamically calculates the 64-bit Gold Reference internally in VHDL. Using assert statements, it compares this reference against the hardware output at every delta-cycle.

Corner Cases: The module is stressed with targeted vectors (zeros, identity, negative/positive combinations, and the maximum 32-bit signed limits).

![waveform](Booth-wallace_Multiplier/sim/sim.png)

Waveforms: The provided screenshot in the sim/ folder visually demonstrates the simulation's success. The waveforms confirm that the 64-bit hardware signal Y perfectly matches the software reference expected_out even for boundary operations, consistently yielding mathematically accurate results in the billions.


## ⚙️ syn/ | Tcl Automation & Extreme Performance
Logic synthesis (performed via Synopsys Design Compiler) is fully automated using a Tcl script (mul.tcl).
This script implements a standard industrial "dual-pass synthesis" flow:

A first unconstrained compilation to evaluate the base area and the natural latency of the architecture.

A second high-effort compilation forcing an aggressive timing constraint (max_delay) to push the synthesizer to optimize the critical path.

## Results & Area-Speed Tradeoff:
The 6 generated reports (Area, Power, and Timing for both passes) and the final optimized netlist are available in the syn/ directory. They showcase the raw power of this architecture.

By replacing the standard Ripple Carry Adder array with the parallel compression of the Wallace Tree and the P4 Sparse Tree Adder, the synthesizer successfully mapped the entire 32-bit multiplier achieving a Data Arrival Time of exactly 2.00 ns (Slack: 0.00).
This translates to completing a purely combinatorial 32x32-bit multiplication at an equivalent frequency of 500 MHz. To achieve this, the tool strategically traded area for speed, utilizing higher drive-strength standard cells to entirely eliminate the latency bottleneck typical of traditional carry-propagation chains.

