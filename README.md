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

### Available Modules

- `ALU` - Arithmetic Logic Unit
- `Controller` - Main Controller (Instruction Decoder)
- `Data_Memory` - Data Memory Unit
- `Instruction_Memory` - Instruction Memory Unit
- `Mux` - Multiplexer
- `NPC` - Next PC Calculator
- `PC` - Program Counter
- `Register_File` - Register File
- `Sign_Extend` - Sign Extension Unit
- `Single_Cycle_Top` - Complete Single Cycle CPU

## Running Individual Tests Manually

If you prefer to compile and run tests manually:

```bash
cd testbench

# Compile a specific module
iverilog -I ../src -o alu_test ALU_tb.v ../src/ALU.v

# Run simulation
vvp alu_test

# View waveform (requires GTKWave)
gtkwave ALU_tb.vcd
```

## CPU Architecture

The single-cycle CPU follows a classic datapath design:

1. **Fetch**: PC → Instruction Memory → Instruction
2. **Decode**: Instruction → Controller → Control Signals
3. **Execute**: ALU performs operation
4. **Memory**: Load/Store access Data Memory
5. **Write Back**: Result written to Register File

All operations complete in one clock cycle.

## Design Features

- **32-bit Architecture**: Full RV32I support
- **Harvard Architecture**: Separate instruction and data memory
- **Single Cycle**: Each instruction completes in one clock cycle
- **Comprehensive Testing**: Individual testbenches for each module
- **Modular Design**: Clean separation of concerns

## Reset Behavior

- **Reset Signal**: Active-low (`rst = 0` activates reset)
- **PC Reset**: Clears to `0x00000000`
- **Registers**: All cleared to zero
- **Memory**: Instruction memory loaded from `memfile.hex`

## Memory Map

- **Instruction Memory**: 0x00000000 - 0x00000FFF (4KB, 1024 words)
- **Data Memory**: 0x00000000 - 0x00000FFF (4KB, 1024 words)

Note: Instruction and data memories are separate (Harvard architecture).

## Adding New Instructions

To add support for new instructions:

1. Update `define.v` with new opcodes and control signals
2. Modify `Op_Decoder.v` to handle new instruction types
3. Update `ALU_Decoder.v` if new ALU operations are needed
4. Implement ALU operations in `ALU.v`
5. Add test cases to appropriate testbenches

## Troubleshooting

### Compilation Errors

If you encounter "module already declared" errors:
- Ensure modules are not listed in `compiler_helper.py` if they're already included via Verilog `include` directives
- Check for duplicate `include` statements in source files

### Simulation Issues

- Verify `memfile.hex` exists in the `assembly/` directory
- Check that all control signals are properly defined in `define.v`
- Use `--verbose` flag to see detailed compilation commands

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is open source and available under the MIT License.

## Author

SinYita

## Acknowledgments

Based on the RISC-V ISA specification and standard single-cycle CPU design patterns.
