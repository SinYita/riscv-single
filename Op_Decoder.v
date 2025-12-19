`include "define.v"

module Op_Decoder(
    input            Zero,
    input      [6:0] Op,
    output reg       rf_we,          
    output reg [2:0] sel_ext,       
    output reg       sel_alu_src_b, 
    output reg       dmem_we,        
    output reg [1:0] sel_result,    
    output reg       PCSrc,          
    output reg [1:0] ALUOp         
);

    always @* begin

        rf_we         = `NO;
        sel_ext       = `Ext_ImmI;
        sel_alu_src_b = `ALU_REG;
        dmem_we       = 1'b0;
        sel_result    = `WB_ALU;  
        ALUOp         = `ALUOP_LOAD_STORE;
        PCSrc         = `PC4;

        case (Op)
            `OPCODE_LW: begin 
                rf_we         = `YES;
                sel_ext       = `Ext_ImmI;
                sel_alu_src_b = `ALU_IMM;
                dmem_we       = 1'b0;
                sel_result    = `WB_MEM;  
                ALUOp         = `ALUOP_LOAD_STORE; 
                PCSrc         = `PC4;
            end

            `OPCODE_SW: begin
                rf_we         = `NO;
                sel_ext       = `Ext_ImmS;
                sel_alu_src_b = `ALU_IMM;
                dmem_we       = 1'b1;
                sel_result    = `WB_ALU; 
                ALUOp         = `ALUOP_LOAD_STORE;
                PCSrc         = `PC4;
            end

            `OPCODE_RTP: begin // R-type
                rf_we         = `YES;
                sel_ext       = `Ext_ImmI; 
                sel_alu_src_b = `ALU_REG;
                dmem_we       = 1'b0;
                sel_result    = `WB_ALU;  
                ALUOp         = `ALUOP_RTYPE_BRANCH; 
                PCSrc         = `PC4;
            end

            `OPCODE_ITP: begin // I-type Arithmetic
                rf_we         = `YES;
                sel_ext       = `Ext_ImmI;
                sel_alu_src_b = `ALU_IMM;
                dmem_we       = 1'b0;
                sel_result    = `WB_ALU;  
                ALUOp         = `ALUOP_ITYPE;
                PCSrc         = `PC4;
            end

            `OPCODE_BEQ: begin
                rf_we         = `NO;
                sel_ext       = `Ext_ImmB;
                sel_alu_src_b = `ALU_REG;
                dmem_we       = 1'b0;
                sel_result    = `WB_ALU;
                ALUOp         = `ALUOP_RTYPE_BRANCH;
                PCSrc         = Zero ? `PCI : `PC4;
            end

            `OPCODE_JAL: begin 
                rf_we         = `YES;
                sel_ext       = `Ext_ImmJ;
                sel_alu_src_b = `ALU_REG;
                dmem_we       = 1'b0;
                sel_result    = `WB_PC4; 
                ALUOp         = `ALUOP_LOAD_STORE;
                PCSrc         = `PCI;  
            end

            `OPCODE_LUI: begin 
                rf_we         = `YES;
                sel_ext       = `Ext_ImmU;
                sel_alu_src_b = `ALU_IMM;
                dmem_we       = 1'b0;
                sel_result    = `WB_ALU;  
                ALUOp         = `ALUOP_LUI; 
                PCSrc         = `PC4;
            end

            default: ;
        endcase
    end
endmodule