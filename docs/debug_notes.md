# Debug Notes – RISC-V CPU (TL-Verilog)

This document records concrete debugging issues encountered during development
and how they were resolved, based on simulation behavior and Verilator output.

---

## 1. JAL writing to register x0

### Problem
JAL instructions were incorrectly writing a return address into register x0.

This caused:
- x0 no longer remaining constant zero
- Simulation failure despite correct program flow

### Root Cause
The register file macro allows writes whenever `wr_en` is asserted.
RISC-V requires x0 to be hard-wired to zero.

### Fix
Explicitly gate the write enable:

```verilog
($rd_valid && $rd[4:0] != 5'b0)