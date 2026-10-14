# RISC_V
# RISC-V Processor Design Using Verilog HDL

## Overview

This project implements a modular RISC-V processor datapath using Verilog HDL. The design includes a program counter, instruction memory, register file, control unit, ALU, immediate generator, data memory, and branch address calculation logic.

The project explores processor datapath design, instruction execution, control signal generation, and RTL simulation.

**Note:** Although the project report describes a five-stage pipelined processor, the supplied RTL does not show explicit pipeline registers for all five stages. The implementation should not be described as a verified five-stage pipeline without further development and verification.

## Repository Structure

```text
riscv-processor/
├── riscv_top.v
├── program_counter.v
├── instr_mem.v
├── reg_file.v
├── main_control_unit.v
├── Alu.v
├── immediate_gen.v
├── data_mem.v
├── branch_addr.v
├── test_bench.v
└── README.md
```

## Design Modules

| File | Description |
|---|---|
| `riscv_top.v` | Top-level module connecting the processor datapath components. |
| `program_counter.v` | Contains the program counter and PC adder modules. |
| `instr_mem.v` | Instruction memory containing example instructions. |
| `reg_file.v` | Register file with read and write functionality. |
| `main_control_unit.v` | Generates control signals based on instruction opcodes. |
| `Alu.v` | Contains the ALU, ALU control, and a multiplexer module. |
| `immediate_gen.v` | Extracts and sign-extends instruction immediate values. |
| `data_mem.v` | Data memory and associated multiplexer logic. |
| `branch_addr.v` | Calculates branch target addresses. |
| `test_bench.v` | Top-level testbench for processor simulation. |

## Instruction Classes

The supplied source code includes examples associated with:

- Arithmetic and logical operations
- Immediate arithmetic and logical operations
- Shift operations
- Load and store instructions
- Conditional branches
- LUI, AUIPC, and JAL

Complete instruction-set support and correctness have not been independently verified.

## Verification

The testbench, `RISCV_Top_tb`, generates a clock, applies reset, checks selected register values, displays PASS/FAIL messages, and generates a VCD waveform file named `riscv_wave.vcd`.

The RTL and testbench should be compiled and simulated before treating the design as verified.

## Tools and Technologies

- Verilog HDL
- AMD Xilinx Vivado
- RTL simulation
- Waveform analysis

## Simulation Using Vivado

1. Open Vivado and create a new RTL project.
2. Add all required design files as **Design Sources**.
3. Add `test_bench.v` as a **Simulation Source**.
4. Set `RISCV_Top_tb` as the simulation top module.
5. Select **Run Simulation → Run Behavioral Simulation**.
6. Inspect the simulation console and waveform window for results.

Ensure that every module is included only once, especially if multiple files contain duplicate module definitions.

## Known Limitations

- The supplied top-level RTL does not show explicit IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers.
- Hazard detection and forwarding logic are not clearly implemented in the supplied source.
- Instruction memory indexing and array bounds require review.
- Instruction encodings, control signals, branch behavior, and load/store operations require verification.
- Expected testbench results should be checked against actual RTL behavior.

## Future Improvements

- Correct instruction-memory addressing and array bounds.
- Resolve compilation and module-connection issues.
- Verify supported instructions using self-checking testbenches.
- Add tests for arithmetic, memory access, branches, jumps, and reset behavior.
- Implement and verify pipeline registers and hazard handling if a five-stage pipelined architecture is intended.

## Project Summary

**Project:** RISC-V Processor Design Using Verilog HDL

**Primary focus:** Modular RTL design, processor datapath components, instruction control, and simulation-based verification.

This README documents the supplied implementation and its limitations without claiming unverified functionality.
