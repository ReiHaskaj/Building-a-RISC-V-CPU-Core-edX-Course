# Building-a-RISC-V-CPU-Core-edX-Course

This repository contains my Verilog implementations developed while completing the
**edX / Linux Foundation course “Building a RISC-V CPU Core”**, taught by **Steve Hoover**. The work in this repository follows the structure of the course and builds up from basic digital design components to a simple RISC-V CPU core. All code here represents my own coursework solutions created while following the instructional material.

This repository is shared as a **learning portfolio** to demonstrate my understanding
of digital design and hardware description using TL-Verilog.

---

## Features

- Single-core, single-cycle CPU
- RV32I base ISA (partial)
- Program counter and next-PC logic
- Instruction fetch from instruction memory (IMEM)
- Instruction decode and immediate generation
- ALU with arithmetic, logical, and shift operations
- Branch and jump support (BEQ, BNE, BLT, BGE, JAL, JALR)
- Register file read/write integration
- Load/store effective address computation
- Writes to register x0 explicitly disabled
- Verified using Verilator simulation

---

## Notes

- Instruction memory, data memory, and register file are provided as framework macros
- Load instructions are grouped (no byte/halfword differentiation)
- Design focuses on datapath and control correctness
- No pipelining, hazards, or interrupts

---

## Tools

- TL-Verilog (Makerchip)
- Verilator
