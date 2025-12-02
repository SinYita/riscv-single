`timescale 1ns/1ns

// Widths
`define ALU_CTRL_WIDTH 4

// ALU_Ctrl
`define ALU_ADD   4'b0000
`define ALU_SUB   4'b0001
`define ALU_XOR   4'b0010
`define ALU_OR    4'b0011
`define ALU_AND   4'b0100
`define ALU_SLL   4'b0101
`define ALU_SRL   4'b0110
`define ALU_SRA   4'b0111
`define ALU_SLT   4'b1000
`define ALU_SLTU  4'b1001


// ALU_Op
`define ALU_LOAD_STORE 2'b00
`define ALU_STYPE_BRANCH     2'b01
`define ALU_RTYPE      2'b10



// Reserved / default
`define ALU_NOP   4'b1111

// Opcode definitions
`define OPCODE_RTYPE  7'b011_0011  // R-type
`define OPCODE_ITYPE  7'b001_0011  // I-type 
`define OPCODE_LOAD   7'b000_0011  // lw
`define OPCODE_STORE  7'b010_0011  // sw
`define OPCODE_BRANCH 7'b110_0011  // branch (e.g., BEQ)