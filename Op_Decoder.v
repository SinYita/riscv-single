`include "defines.v"
module Op_Decoder(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp);
    input  [6:0] Op;
    output reg   RegWrite, ALUSrc, MemWrite, ResultSrc, Branch;
    output reg [1:0] ImmSrc, ALUOp;

    always @* begin
        // defaults
        RegWrite  = 1'b0;
        ImmSrc    = 2'b00;
        ALUSrc    = 1'b0;
        MemWrite  = 1'b0;
        ResultSrc = 1'b0;
        Branch    = 1'b0;
        ALUOp     = 2'b00;

        case (Op)
            OPCODE_LOAD: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ResultSrc = 1'b1; // load reads from memory
                ALUOp     = 2'b00;
                ImmSrc    = 2'b00; // I-type (load)
            end
            OPCODE_STORE: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ImmSrc   = 2'b01; // S-type (store)
            end
            OPCODE_BRANCH: begin
                Branch = 1'b1;
                ALUOp  = 2'b01;
                ImmSrc = 2'b10; // B-type (branch)
            end
            OPCODE_RTYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;
            end
            default: begin
                // keep defaults (easy to extend for JAL/JALR/LUI etc.)
            end
        endcase
    end
endmodule