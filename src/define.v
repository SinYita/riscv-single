
// ALU_Ctrl
`define ALU_NONE                                4'b0000
`define ALU_SHIFTL                              4'b0001
`define ALU_SHIFTR                              4'b0010
`define ALU_SHIFTR_ARITH                        4'b0011
`define ALU_ADD                                 4'b0100
`define ALU_SUB                                 4'b0110
`define ALU_AND                                 4'b0111
`define ALU_OR                                  4'b1000
`define ALU_XOR                                 4'b1001
`define ALU_LESS_THAN                           4'b1010
`define ALU_LESS_THAN_SIGNED                    4'b1011


// Imm_Src
`define Ext_ImmI      3'b000 // Immediate extension for I-type instructions
`define Ext_ImmS      3'b001
`define Ext_ImmB      3'b010
`define Ext_ImmU      3'b011
`define Ext_ImmJ      3'b100


//ALUOP
`define ALUOP_LOAD_STORE                        3'b000
`define ALUOP_RTYPE                             3'b001
`define ALUOP_ITYPE                            3'b010
`define ALUOP_BRANCH                            3'b011
`define ALUOP_J_UAL                          3'b100

//ResultSrc
`define FROM_ALU                                 3'b000          // from ALU Result
`define FROM_MEM                                 3'b001          // from Memory
`define FROM_PC_                                 3'b010          // PC + 4
`define FROM_IMM                                 3'b011          // ImmExt

// Opcode definitions
`define OPCODE_RTYPE  7'b011_0011  // R-type
`define OPCODE_ITYPE  7'b001_0011  // I-type 
`define OPCODE_LOAD   7'b000_0011  // lw
`define OPCODE_STORE  7'b010_0011  // sw
`define OPCODE_BRANCH 7'b110_0011  // B-Type(beq)
`define OPCODE_JAL    7'b110_1111  // J-Type(jal)
`define OPCODE_LUI    7'b011_0111  // U-Type(lui)

// IMMSRC
`define ALU_IMM 1'b1 // the second ALU operand is immediate
`define ALU_REG 1'b0 // the second ALU operand is register


// PCSrc
`define PC_NOJUMP 1'b0 // PC + 4
`define PC_J_OFFSET 1'b1 // PC + immediate offset


//YES/NO
`define YES 1'b1
`define NO  1'b0