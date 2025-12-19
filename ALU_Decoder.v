`include "define.v"

module ALU_Decoder(
    input  [1:0] ALUOp,   
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] alu_control
);

    always @(*) begin
        case (ALUOp)
            `ALUOP_LOAD_STORE: alu_control = `ALU_ADD; 

            `ALUOP_RTYPE_BRANCH: begin
                case (funct3)
                    3'b000: begin
                        if (funct7[5])
                            alu_control = `ALU_SUB;
                        else
                            alu_control = `ALU_ADD;
                    end
                    3'b100: alu_control = `ALU_XOR;
                    3'b110: alu_control = `ALU_OR;
                    3'b111: alu_control = `ALU_AND;
                    3'b001: alu_control = `ALU_SHIFTL;
                    3'b101: alu_control = (funct7[5]) ? `ALU_SHIFTR_ARITH : `ALU_SHIFTR;
                    3'b010: alu_control = `ALU_LESS_THAN_SIGNED;
                    3'b011: alu_control = `ALU_LESS_THAN;
                    default: alu_control = `ALU_NONE;
                endcase
            end

            // 10: I-type Arithmetic
            `ALUOP_ITYPE: begin
                case (funct3)
                    3'b000: alu_control = `ALU_ADD;
                    3'b100: alu_control = `ALU_XOR;
                    3'b110: alu_control = `ALU_OR;
                    3'b111: alu_control = `ALU_AND;
                    3'b001: alu_control = `ALU_SHIFTL;
                    3'b101: alu_control = (funct7[5]) ? `ALU_SHIFTR_ARITH : `ALU_SHIFTR;
                    3'b010: alu_control = `ALU_LESS_THAN_SIGNED;
                    3'b011: alu_control = `ALU_LESS_THAN;
                    default: alu_control = `ALU_NONE;
                endcase
            end

            `ALUOP_LUI: begin
                alu_control = `ALU_COPY_B; 
            end

            default: alu_control = `ALU_NONE;
        endcase
    end
endmodule