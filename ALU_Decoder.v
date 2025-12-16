`include "define.v"
module ALU_Decoder(ALUOp,funct3,funct7,op,alu_control);

    input [2:0]ALUOp;
    input [2:0]funct3;
    input [6:0]funct7,op;
    output reg [3:0]alu_control;

    always @(*) begin
        case (ALUOp)
            `ALUOP_RTYPE: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b000_0000)
                            alu_control = `ALU_ADD; // ADD
                        else if (funct7 == 7'b010_0000)
                            alu_control = `ALU_SUB; // SUB
                        else 
                            alu_control = `ALU_ADD;
                    end
                    3'b100: alu_control = `ALU_XOR; // XOR
                    3'b110: alu_control = `ALU_OR;  // OR
                    3'b111: alu_control = `ALU_AND; // AND
                    3'b001: alu_control = `ALU_SHIFTL; // SLL
                    3'b101: begin
                        if(funct7 == 7'b000_0000)
                            alu_control = `ALU_SHIFTR; // SRL
                        else if(funct7 == 7'b010_0000)
                            alu_control = `ALU_SHIFTR_ARITH; // SRA
                        else 
                            alu_control = `ALU_SHIFTR;
                    end
                    3'b010: alu_control = `ALU_LESS_THAN_SIGNED; // SLT
                    3'b011: alu_control = `ALU_LESS_THAN; // SLTU
                    default: alu_control = `ALU_NONE; // default NOP
                endcase
            end
            `ALUOP_ITYPE: begin
                case (funct3)
                    3'b000: alu_control = `ALU_ADD; // ADDI
                    3'b100: alu_control = `ALU_XOR; // XORI
                    3'b110: alu_control = `ALU_OR;  // ORI
                    3'b111: alu_control = `ALU_AND; // ANDI
                    3'b001: alu_control = `ALU_SHIFTL; // SLLI
                    3'b101: begin
                        if(funct7 == 7'b000_0000)
                            alu_control = `ALU_SHIFTR; // SRLI
                        else if(funct7 == 7'b010_0000)
                            alu_control = `ALU_SHIFTR_ARITH; // SRAI
                        else 
                            alu_control = `ALU_SHIFTR;
                    end
                   
                    3'b010: alu_control = `ALU_LESS_THAN_SIGNED; // SLTI
                    3'b011: alu_control = `ALU_LESS_THAN; // SLTIU
                    default: alu_control = `ALU_NONE; // default NOP
                endcase
            end
            `ALUOP_LOAD_STORE: alu_control = `ALU_ADD; // for address calculation
            `ALUOP_BRANCH: alu_control = `ALU_XOR; // for branch comparison
            `ALUOP_J_UAL: alu_control = `ALU_NONE; // for jal/jalr address calculation
            default: alu_control = `ALU_NONE; // default NOP
        endcase
    end
endmodule