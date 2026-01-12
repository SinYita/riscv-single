`include "define.v"

module Op_Decoder(
    input      [6:0] Op,
    output reg       RegWrite,
    output reg [2:0] ImmSrc,
    output reg       ALUSrc,
    output reg       MemWrite,
    output reg [1:0] ResultSrc,
    output reg       Branch,
    output reg [1:0] ALUOp,
    output reg       Jump
);

    always @* begin
        // Default values
        RegWrite   = `NO;
        ImmSrc     = `Ext_ImmI;
        ALUSrc     = `ALU_REG;
        MemWrite   = 1'b0;
        ResultSrc  = `WB_ALU;
        ALUOp      = `ALUOP_LOAD_STORE;
        Branch     = 1'b0;
        Jump       = 1'b0;

        case (Op)
            `OPCODE_LW: begin 
                RegWrite   = `YES;
                ImmSrc     = `Ext_ImmI;
                ALUSrc     = `ALU_IMM;
                MemWrite   = 1'b0;
                ResultSrc  = `WB_MEM;
                ALUOp      = `ALUOP_LOAD_STORE;
                Branch     = 1'b0;
                Jump       = 1'b0;
            end

            `OPCODE_SW: begin
                RegWrite   = `NO;
                ImmSrc     = `Ext_ImmS;
                ALUSrc     = `ALU_IMM;
                MemWrite   = 1'b1;
                ResultSrc  = `WB_ALU;
                ALUOp      = `ALUOP_LOAD_STORE;
                Branch     = 1'b0;
                Jump       = 1'b0;
            end

            `OPCODE_RTP: begin // R-type
                RegWrite   = `YES;
                ImmSrc     = `Ext_ImmI;
                ALUSrc     = `ALU_REG;
                MemWrite   = 1'b0;
                ResultSrc  = `WB_ALU;
                ALUOp      = `ALUOP_ITYPE;
                Branch     = 1'b0;
                Jump       = 1'b0;
            end

            `OPCODE_ITP: begin // I-type Arithmetic
                RegWrite   = `YES;
                ImmSrc     = `Ext_ImmI;
                ALUSrc     = `ALU_IMM;
                MemWrite   = 1'b0;
                ResultSrc  = `WB_ALU;
                ALUOp      = `ALUOP_ITYPE;
                Branch     = 1'b0;
                Jump       = 1'b0;
            end

            `OPCODE_BEQ: begin
                RegWrite   = `NO;
                ImmSrc     = `Ext_ImmB;
                ALUSrc     = `ALU_REG;
                MemWrite   = 1'b0;
                ResultSrc  = `WB_ALU;
                ALUOp      = `ALUOP_BRANCH;
                Branch     = 1'b1;
                Jump       = 1'b0;
            end

            `OPCODE_JAL: begin 
                RegWrite   = `YES;
                ImmSrc     = `Ext_ImmJ;
                ALUSrc     = `ALU_REG;
                MemWrite   = 1'b0;
                ResultSrc  = `WB_PC4;
                ALUOp      = `ALUOP_LOAD_STORE;
                Branch     = 1'b0;
                Jump       = 1'b1;
            end

            `OPCODE_LUI: begin 
                RegWrite   = `YES;
                ImmSrc     = `Ext_ImmU;
                ALUSrc     = `ALU_IMM;
                MemWrite   = 1'b0;
                ResultSrc  = `WB_ALU;
                ALUOp      = `ALUOP_LUI;
                Branch     = 1'b0;
                Jump       = 1'b0;
            end

            default: ;
        endcase
    end
endmodule
