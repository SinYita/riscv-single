`include "define.v"
module Op_Decoder(Zero,inst,rf_we,sel_ext,alu_control,dmem_we,ResultSrc,PCSrc,ALUOp);
    input  Zero;
    input  [31:0] inst;
    output reg rf_we;
    output reg [2:0] sel_ext; // which type of immediate extension
    output reg alu_control; // the second operand
    output reg dmem_we;
    output reg [2:0] ResultSrc; // ? -> register
    output reg PCSrc; // Branch or not
    output reg [2:0] ALUOp; // ALU operation

    wire [6:0] Op = inst[6:0];
    wire [2:0] Funct3 = inst[14:12];
    wire [6:0] Funct7 = inst[31:25];

    always @* begin
        case (Op)
            `OPCODE_LOAD: begin // lw
                rf_we <= `YES;
                sel_ext   <= `Ext_ImmI;
                alu_control   <= `ALU_IMM;
                dmem_we <= `NO;
                ResultSrc<= `FROM_MEM;
                ALUOp    <= `ALUOP_LOAD_STORE;

                PCSrc <= `PC_NOJUMP;
            end
            `OPCODE_STORE: begin
                rf_we <= `NO;
                sel_ext   <= `Ext_ImmS;
                alu_control   <= `ALU_IMM;
                dmem_we <= `YES;
                ResultSrc<= `FROM_MEM;
                ALUOp    <= `ALUOP_LOAD_STORE;

                PCSrc <= `PC_NOJUMP;
                
            end
            `OPCODE_RTYPE: begin
                rf_we <= `YES;
                sel_ext   <= `Ext_ImmI;
                alu_control   <= `ALU_REG;
                dmem_we <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_RTYPE;

                PCSrc   <= `PC_NOJUMP;
            end
            `OPCODE_ITYPE: begin
                rf_we <= `YES;
                sel_ext   <= `Ext_ImmI;
                alu_control   <= `ALU_IMM;
                dmem_we <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_ITYPE;

                PCSrc   <= `PC_NOJUMP;
            end
            `OPCODE_BRANCH: begin
                rf_we <= `NO;
                sel_ext   <= `Ext_ImmB;
                alu_control   <= `ALU_REG;
                dmem_we <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_BRANCH;
                if (Zero)
                    PCSrc   <= `PC_J_OFFSET;
                else
                    PCSrc   <= `PC_NOJUMP;
            end
            `OPCODE_JAL: begin // jal
                rf_we <= `YES;
                sel_ext   <= `Ext_ImmJ;
                alu_control   <= `ALU_IMM;
                dmem_we <= `NO;
                ResultSrc<= `FROM_PC_;

                ALUOp    <= `ALUOP_J_UAL;
                PCSrc   <= `PC_J_OFFSET;
            end
            `OPCODE_LUI: begin // lui
                rf_we <= `YES;
                sel_ext   <= `Ext_ImmU;
                alu_control   <= `ALU_IMM;
                dmem_we <= `NO;
                ResultSrc<= `FROM_IMM;
                ALUOp    <= `ALUOP_J_UAL;

                
                 PCSrc   <= `PC_NOJUMP;
            end
            default: begin // nop
                rf_we <= `NO;
                sel_ext   <= `Ext_ImmI;
                alu_control   <= `ALU_REG;
                dmem_we <= `NO;
                ResultSrc<= `FROM_ALU;
                ALUOp    <= `ALUOP_ITYPE;

                PCSrc   <= `PC_NOJUMP;
            end
        endcase
    end
endmodule