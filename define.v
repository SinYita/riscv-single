// --- ALU Control Signals (4-bit) ---
`define ALU_NONE                4'b0000
`define ALU_SHIFTL              4'b0001
`define ALU_SHIFTR              4'b0010
`define ALU_SHIFTR_ARITH        4'b0011
`define ALU_ADD                 4'b0100
`define ALU_SUB                 4'b0110
`define ALU_AND                 4'b0111
`define ALU_OR                  4'b1000
`define ALU_XOR                 4'b1001
`define ALU_LESS_THAN           4'b1010
`define ALU_LESS_THAN_SIGNED    4'b1011
`define ALU_COPY_B              4'b1100 // lui

// --- Immediate Extension Type (3-bit) ---
`define Ext_ImmI                3'b000
`define Ext_ImmS                3'b001
`define Ext_ImmB                3'b010
`define Ext_ImmU                3'b011
`define Ext_ImmJ                3'b100

// --- ALUOp from Main Decoder to ALU Decoder (2-bit) ---
`define ALUOP_LOAD_STORE        2'b00 
`define ALUOP_BRANCH            2'b01 
`define ALUOP_ITYPE             2'b10 
`define ALUOP_LUI               2'b11 

// --- Opcode Definitions (7-bit) ---
`define OPCODE_RTP              7'b0110011 
`define OPCODE_ITP              7'b0010011 
`define OPCODE_LW               7'b0000011 
`define OPCODE_SW               7'b0100011
`define OPCODE_BEQ              7'b1100011
`define OPCODE_JAL              7'b1101111
`define OPCODE_LUI              7'b0110111 

// --- Control Signal Values ---
`define ALU_IMM                 1'b1 
`define ALU_REG                 1'b0 

`define PC4                     1'b0 
`define PCI                     1'b1 

`define YES                     1'b1
`define NO                      1'b0

// --- Register Write-Back Select (2-bit) ---
`define WB_ALU                  2'b00 // ALU
`define WB_MEM                  2'b01 // Data Memory
`define WB_PC4                  2'b10 // PC + 4