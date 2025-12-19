`include "define.v"

module ALU_Decoder(
    input  [1:0] ALUOp,   
    input  [2:0] funct3,
    input  funct7b5,
    input opb5,
    output reg [3:0] alu_control
);

    wire r_sub;
    assign r_sub = funct7b5 & opb5;
    always @(*) begin
        case (ALUOp)
            2'b00: alu_control = `ALU_ADD; 
            2'b01: alu_control = `ALU_SUB;
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if (r_sub)
                            alu_control = `ALU_SUB;
                        else
                            alu_control = `ALU_ADD;
                    end
                    3'b100: alu_control = `ALU_XOR;
                    3'b110: alu_control = `ALU_OR;
                    3'b111: alu_control = `ALU_AND;
                    3'b001: alu_control = `ALU_SHIFTL;
                    3'b101: alu_control = (funct7b5) ? `ALU_SHIFTR_ARITH : `ALU_SHIFTR;
                    3'b010: alu_control = `ALU_LESS_THAN_SIGNED;
                    3'b011: alu_control = `ALU_LESS_THAN;
                    default: alu_control = `ALU_NONE;
                endcase
            end
            2'b11: begin
                alu_control = `ALU_COPY_B; 
            end

            default: alu_control = `ALU_NONE;
        endcase
    end
endmodule