# CPE3300-RISCV-Pipeline-CPU
RISC-V RV32I Pipeline CPU from Cal Poly CPE 3300 (Computer Architecture), designed using SystemVerilog and Vivado.
Runs TestAll.mem file designed as a comprehensive test of all instructions; debug text file provided

Data hazards currently mitigated in design:
- Read after write (RAW)
- lw dependency

Control hazards currently mitigated in design:
- Branch prediction (for jal, jalr, and branch instructions)

Currently working on:
- Direct-mapped cache for instruction memory
- Set associative cache for data memory
