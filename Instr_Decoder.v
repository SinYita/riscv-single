module Instr_Decoder(
    input [6:0] op,
    output reg [2:0] sel_ext
);
    always @(*) begin
        case (op)
            `OPCODE_LW, `OPCODE_ITP: sel_ext = `Ext_ImmI;
            `OPCODE_SW:             sel_ext = `Ext_ImmS;
            `OPCODE_BEQ:            sel_ext = `Ext_ImmB;
            `OPCODE_JAL:            sel_ext = `Ext_ImmJ;
            `OPCODE_LUI:            sel_ext = `Ext_ImmU;
            default:                sel_ext = `Ext_ImmI;
        endcase
    end
endmodule