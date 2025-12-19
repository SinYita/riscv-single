# RISC-V CPU (FSM / Multi-Cycle style)

A Verilog implementation of a 32-bit RISC-V processor (subset of RV32I) that uses a finite-state machine (FSM) based controller to sequence multi-cycle instruction execution. The design separates fetch/decode/execute/memory/write-back into controllable steps rather than executing every instruction in a single clock cycle.


## Project Structure
## CPU Architecture

The project uses a datapath controlled by a single finite-state machine (`main_fsm`) located in the `controller` hierarchy. Instructions are executed across a small sequence of micro-steps (fetch → decode → execute → memory → write-back) when necessary; the FSM drives multiplexors and enables for the datapath rather than performing all work in one cycle.

### Top-level and overview

![Overall Design](assets/overall%20design.svg)

- Top-level module: `Single_Cycle_Top.v` / `rv_mc` — instantiates `controller`, `datapath`, and `mem`.
- Instruction and data memory: `mem.v` (RAM[0:1023], 32-bit words).

### Datapath components (files)

- PC register: `flopenr.v` (write enabled by `we_pc`).
- Instruction register / OldPC / ALUOut / MDR: `flopenr.v` and `flopr.v` instances in `datapath.v` (`instr`, `old_pc`, `alu_out_reg`, `data_out`).
- Register file: `Register_File.v` (32 × 32-bit registers, write on `WE` with write-back index `instr[11:7]`).
- Immediate extension: `Sign_Extend.v` (`imm_ext` based on `sel_ext`).
- ALU and ALU result registers: `ALU.v` + `flopr` for `alu_out_reg`.
- Muxes for ALU sources and result selection: `mux2.v`, `mux3.v`, `mux4.v` used by `datapath.v`.

Datapath control signals from the FSM/controller: `sel_alu_src_a`, `sel_alu_src_b`, `alu_op`, `sel_result`, `sel_mem_addr`, `we_mem`, `we_ir`, `we_rf`, `pc_update`.

### FSM (controller)

![FSM](assets/fsm.svg)

- `main_fsm.v` implements the microstate machine (states include `S0_FETCH`, `S1_DECODE`, `S2_EXE_ADDR`, `S3_MEM_RD`, `S4_WB_MEM`, `S5_MEM_WR`, `S6_EXE_R`, `S7_WB_ALU`, `S8_BEQ`, `S9_EXE_I`, `S10_JAL`, `S11_LUI`).
- The `controller` module connects `main_fsm` to the datapath and to the ALU decoder logic.

### ALU decoding

- The design no longer uses a separate two-level decoder UI; instead the FSM sets `alu_op` and the ALU decoder logic in the code uses `funct3`/`funct7` as needed to derive `alu_control` for `ALU.v`.

### Defines and constants

- All opcodes, ALU ops, immediate types and write-back selectors live in `define.v` (e.g. `OPCODE_JAL`, `ALUOP_LOAD_STORE`, `WB_PC4`).

This layout mirrors the RTL: the FSM in `main_fsm.v` sequences micro-operations and produces a small set of control signals that the datapath uses to compute results, access memory, and perform register write-backs over multiple cycles when required.
## CPU Architecture

The CPU follows a classic datapath design controlled by an FSM-based controller; instructions may take multiple micro-steps (cycles) to complete when required.


## Reset behavior and common pitfalls

- **Reset** is active-low in this implementation: `rst = 0` asserts reset, `rst = 1` releases it. Top-level testbenches in this repo follow that convention.
- **PC** and register file are cleared on reset.
- **Instruction memory** is loaded in the testbench via `$readmemh("memfile.hex", dut.MEM.RAM)` by default.

Common pitfall: `mem.v` allocates `RAM[0:1023]` but your `memfile.hex` may contain far fewer words. If the CPU fetches past the initialized words you will see X-valued instructions and unpredictable writes (registers becoming `xxxxxxxx`). Fixes:
- Pad `memfile.hex` with NOPs (`00000013`) to the range you will execute, or
- Use `$readmemh("memfile.hex", dut.MEM.RAM, 0, LAST_INDEX)` to limit the load range, or
- Initialize RAM in `mem.v` to a safe default (e.g., 0).

## Memory map

- **Instruction Memory**: 0x00000000 - 0x00000FFF (4KB, 1024 words)
- **Data Memory**: 0x00000000 - 0x00000FFF (4KB, 1024 words)

Instruction and data memories are separate (Harvard-like layout for this simple model).

## License

This project is open source and available under the MIT License.

## Author

**Weiyuan Du (SinYita)**

## Acknowledgments

This project is based on the RISC-V ISA specification. The implementation follows educational CPU design principles and uses an FSM/multi-cycle approach to sequence instruction execution while maintaining compatibility with RISC-V instruction encodings.

## Additional Resources

- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- Detailed design report with architecture diagrams available in the repository
- Comprehensive testbenches for all modules
- Automated testing framework via `compiler_helper.py`
