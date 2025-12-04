`include "define.v"
module ALU_Decoder(ALUOp,funct3,funct7,op,ALUControl);

    input [2:0]ALUOp;
    input [2:0]funct3;
    input [6:0]funct7,op;
    output reg [3:0]ALUControl;

    always @(*) begin
        case (ALUOp)
            `ALUOP_RTYPE: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b000_0000)
                            ALUControl = `ALU_ADD; // ADD
                        else if (funct7 == 7'b010_0000)
                            ALUControl = `ALU_SUB; // SUB
                        else 
                            ALUControl = `ALU_ADD;
                    end
                    3'b100: ALUControl = `ALU_XOR; // XOR
                    3'b110: ALUControl = `ALU_OR;  // OR
                    3'b111: ALUControl = `ALU_AND; // AND
                    3'b001: ALUControl = `ALU_SHIFTL; // SLL
                    3'b101: begin
                        if(funct7 == 7'b000_0000)
                            ALUControl = `ALU_SHIFTR; // SRL
                        else if(funct7 == 7'b010_0000)
                            ALUControl = `ALU_SHIFTR_ARITH; // SRA
                        else 
                            ALUControl = `ALU_SHIFTR;
                    end
                    3'b010: ALUControl = `ALU_LESS_THAN_SIGNED; // SLT
                    3'b011: ALUControl = `ALU_LESS_THAN; // SLTU
                    default: ALUControl = `ALU_NONE; // default NOP
                endcase
            end
            `ALUOP_ITYPE: begin
                case (funct3)
                    3'b000: ALUControl = `ALU_ADD; // ADDI
                    3'b100: ALUControl = `ALU_XOR; // XORI
                    3'b110: ALUControl = `ALU_OR;  // ORI
                    3'b111: ALUControl = `ALU_AND; // ANDI
                    3'b001: ALUControl = `ALU_SHIFTL; // SLLI
                    3'b101: begin
                        if(funct7 == 7'b000_0000)
                            ALUControl = `ALU_SHIFTR; // SRLI
                        else if(funct7 == 7'b010_0000)
                            ALUControl = `ALU_SHIFTR_ARITH; // SRAI
                        else 
                            ALUControl = `ALU_SHIFTR;
                    end
                   
                    3'b010: ALUControl = `ALU_LESS_THAN_SIGNED; // SLTI
                    3'b011: ALUControl = `ALU_LESS_THAN; // SLTIU
                    default: ALUControl = `ALU_NONE; // default NOP
                endcase
            end
            `ALUOP_LOAD_STORE: ALUControl = `ALU_ADD; // for address calculation
            `ALUOP_BRANCH: ALUControl = `ALU_XOR; // for branch comparison
            `ALUOP_J_UAL: ALUControl = `ALU_NONE; // for jal/jalr address calculation
            default: ALUControl = `ALU_NONE; // default NOP
        endcase
    end
endmodule