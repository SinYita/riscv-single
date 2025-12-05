`include "define.v"
module Op_Decoder(Zero,inst,RegWrite_E,ImmSrc,ALUSrc,MemWrite_E,ResultSrc,PCSrc,ALUOp);
    input  Zero;
    input  [31:0] inst;
    output reg RegWrite_E;
    output reg [2:0] ImmSrc; // which type of immediate extension
    output reg ALUSrc; // the second operand
    output reg MemWrite_E;
    output reg [2:0] ResultSrc; // ? -> register
    output reg PCSrc; // Branch or not
    output reg [2:0] ALUOp; // ALU operation

    wire [6:0] Op = inst[6:0];
    wire [2:0] Funct3 = inst[14:12];
    wire [6:0] Funct7 = inst[31:25];

    always @* begin
        case (Op)
            `OPCODE_LOAD: begin // lw
                RegWrite_E <= `YES;
                ImmSrc   <= `Ext_ImmI;
                ALUSrc   <= `ALU_IMM;
                MemWrite_E <= `NO;
                ResultSrc<= `FROM_MEM;
                ALUOp    <= `ALUOP_LOAD_STORE;

                PCSrc <= `PC_NOJUMP;
            end
            `OPCODE_STORE: begin
                RegWrite_E <= `NO;
                ImmSrc   <= `Ext_ImmS;
                ALUSrc   <= `ALU_IMM;
                MemWrite_E <= `YES;
                ResultSrc<= `FROM_MEM;
                ALUOp    <= `ALUOP_LOAD_STORE;

                PCSrc <= `PC_NOJUMP;
                
            end
            `OPCODE_RTYPE: begin
                RegWrite_E <= `YES;
                ImmSrc   <= `Ext_ImmI;
                ALUSrc   <= `ALU_REG;
                MemWrite_E <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_RTYPE;

                PCSrc   <= `PC_NOJUMP;
            end
            `OPCODE_ITYPE: begin
                RegWrite_E <= `YES;
                ImmSrc   <= `Ext_ImmI;
                ALUSrc   <= `ALU_IMM;
                MemWrite_E <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_ITYPE;

                PCSrc   <= `PC_NOJUMP;
            end
            `OPCODE_BRANCH: begin
                RegWrite_E <= `NO;
                ImmSrc   <= `Ext_ImmB;
                ALUSrc   <= `ALU_REG;
                MemWrite_E <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_BRANCH;
                if (Zero)
                    PCSrc   <= `PC_J_OFFSET;
                else
                    PCSrc   <= `PC_NOJUMP;
            end
            `OPCODE_JAL: begin // jal
                RegWrite_E <= `YES;
                ImmSrc   <= `Ext_ImmJ;
                ALUSrc   <= `ALU_IMM;
                MemWrite_E <= `NO;
                ResultSrc<= `FROM_PC_;

                ALUOp    <= `ALUOP_J_UAL;
                PCSrc   <= `PC_J_OFFSET;
            end
            `OPCODE_LUI: begin // lui
                RegWrite_E <= `YES;
                ImmSrc   <= `Ext_ImmU;
                ALUSrc   <= `ALU_IMM;
                MemWrite_E <= `NO;
                ResultSrc<= `FROM_IMM;
                ALUOp    <= `ALUOP_J_UAL;

                
                 PCSrc   <= `PC_NOJUMP;
            end
            default: begin // nop
                RegWrite_E <= `NO;
                ImmSrc   <= `Ext_ImmI;
                ALUSrc   <= `ALU_REG;
                MemWrite_E <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_ITYPE;

                PCSrc   <= `PC_NOJUMP;
            end
        endcase
    end
endmodule