`include "defines.v"
module ALU_Decoder(ALUOp,funct3,funct7,op,ALUControl);

    input [1:0]ALUOp;
    input [2:0]funct3;
    input [6:0]funct7,op;
    output reg [2:0]ALUControl;

    // Combinational decoder: choose ALUControl based on ALUOp and funct fields
    always @* begin
        // default
        ALUControl = `ALU_ADD;

        case (ALUOp)
            2'b00: begin
                // Load/Immediate: use ADD to compute address or add immediate
                ALUControl = `ALU_ADD;
            end
            2'b01: begin
                // Branch: use SUB for comparison (e.g., beq)
                ALUControl = `ALU_SUB;
            end
            2'b10: begin
                // R-type: decode by funct3/funct7 (and op[5] per original logic)
                case (funct3)
                    3'b000: ALUControl = ({op[5], funct7[5]} == 2'b11) ? `ALU_SUB : `ALU_ADD;
                    3'b010: ALUControl = `ALU_SLT;
                    3'b110: ALUControl = `ALU_OR;
                    3'b111: ALUControl = `ALU_AND;
                    default: ALUControl = `ALU_ADD;
                endcase
            end
            default: ALUControl = `ALU_ADD;
        endcase
    end
endmodule