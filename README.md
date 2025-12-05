# RISC-V Single Cycle CPU

A complete implementation of a single-cycle RISC-V processor in Verilog, supporting the RV32I base instruction set.

## Project Structure

```
riscv-single/
├── src/                          # Source files
│   ├── define.v                  # Global definitions and constants
│   ├── PC.v                      # Program Counter
│   ├── NPC.v                     # Next PC Calculator
│   ├── Instruction_Memory.v      # Instruction Memory (ROM)
│   ├── Register_File.v           # 32×32 Register File
│   ├── Sign_Extend.v             # Immediate Extension Unit
│   ├── ALU.v                     # Arithmetic Logic Unit
│   ├── ALU_Decoder.v             # ALU Control Decoder
│   ├── Op_Decoder.v              # Main Instruction Decoder
│   ├── Controller.v              # Main Controller
│   ├── Data_Memory.v             # Data Memory (RAM)
│   ├── Mux.v                     # Multiplexer
│   └── Single_Cycle_Top.v        # Top-level CPU module
│
├── testbench/                    # Testbench files
│   ├── ALU_tb.v                  # ALU testbench
│   ├── Controller_tb.v           # Controller testbench
│   ├── Data_Memory_tb.v          # Data Memory testbench
│   ├── Instruction_Memory_tb.v   # Instruction Memory testbench
│   ├── Mux_tb.v                  # Multiplexer testbench
│   ├── NPC_tb.v                  # NPC testbench
│   ├── PC_tb.v                   # PC testbench
│   ├── Register_File_tb.v        # Register File testbench
│   ├── Sign_Extend_tb.v          # Sign Extend testbench
│   └── Single_Cycle_Top_tb.v     # Complete CPU testbench
│
├── assembly/                     # Assembly programs
│   ├── test.s                    # Assembly test program
│   └── memfile.hex               # Machine code (hex format)
│
├── assets/                       # Documentation assets
├── compiler_helper.py            # Automated compilation tool
└── README.md                     # This file
```

## Supported Instructions

The CPU implements the following RV32I instructions:

### Arithmetic & Logic
- **R-type**: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`
- **I-type**: `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU`

### Memory Access
- **Load**: `LW` (Load Word)
- **Store**: `SW` (Store Word)

### Control Flow
- **Branch**: `BEQ` (Branch if Equal)
- **Jump**: `JAL` (Jump and Link)

### Upper Immediate
- **U-type**: `LUI` (Load Upper Immediate)

## Getting Started

### Prerequisites

- **Icarus Verilog** (iverilog): For compilation
- **VVP**: Verilog simulation runtime
- **Python 3**: For the compilation helper script

Install on Ubuntu/Debian:
```bash
sudo apt-get install iverilog python3
```

### Quick Start

1. **Clone the repository**:
```bash
git clone https://github.com/SinYita/riscv-single.git
cd riscv-single
```

2. **Make the compiler helper executable**:
```bash
chmod +x compiler_helper.py
```

3. **Run all tests**:
```bash
./compiler_helper.py --all
```

## Using compiler_helper.py

The `compiler_helper.py` script provides an easy way to compile and test individual modules or the entire CPU.

### Basic Usage

```bash
./compiler_helper.py [options] [module_names...]
```

### Options

- `--all` or `-a`: Compile and run all testbenches
- `--compile-only` or `-c`: Only compile, don't run simulation
- `--clean`: Remove all compiled executables and VCD files
- `--list` or `-l`: List all available modules
- `--verbose` or `-v`: Show detailed compilation commands
- `--help` or `-h`: Show help message

### Examples

**Run all testbenches:**
```bash
./compiler_helper.py --all
```

**Test specific modules:**
```bash
./compiler_helper.py ALU PC Register_File
```

**Only compile without running:**
```bash
./compiler_helper.py --compile-only Controller
```

**Clean build artifacts:**
```bash
./compiler_helper.py --clean
```

**List available modules:**
```bash
./compiler_helper.py --list
```

**Run with verbose output:**
```bash
./compiler_helper.py --verbose Single_Cycle_Top
```

