module Sign_Extend(Ins,Imm_src,Imm_out);
    input [2:0] Imm_src;
    input [31:0] Ins;
    output [31:0] Imm_out;

    always@(*) begin
        case(Imm_src)
        `Ext_ImmI: Imm_out <= {{21{Ins[31]}}, Ins[30:25], Ins[24:21], Ins[20]};
        `Ext_ImmS: Imm_out <= {{21{Ins[31]}}, Ins[30:25], Ins[11:8], Ins[7]};
        `Ext_ImmB: Imm_out <= {{20{Ins[31]}}, Ins[7], Ins[30:25], Ins[11:8], 1'b0};
        `Ext_ImmU: Imm_out <= {Ins[31], Ins[30:20], Ins[19:12], 11'b000_0000_0000};
        `Ext_ImmJ: Imm_out <= {{12{Ins[31]}}, Ins[19:12], Ins[20], Ins[30:25], Ins[24:21], 1'b0};
            default: Imm_out <= {{21{Ins[31]}}, Ins[30:25], Ins[24:21], Ins[20]};
        endcase
    end

endmodule