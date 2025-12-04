`include "define.v"

module Sign_Extend(Ins,Imm_src,ImmExt);
    input [2:0] Imm_src;
    input [31:0] Ins;
    output reg [31:0] ImmExt;

    always@(*) begin
        case(Imm_src)
        `Ext_ImmI: ImmExt <= {{21{Ins[31]}}, Ins[30:25], Ins[24:21], Ins[20]};
        `Ext_ImmS: ImmExt <= {{21{Ins[31]}}, Ins[30:25], Ins[11:8], Ins[7]};
        `Ext_ImmB: ImmExt <= {{20{Ins[31]}}, Ins[7], Ins[30:25], Ins[11:8], 1'b0};
        `Ext_ImmU: ImmExt <= {Ins[31:12], 12'b000_0000_0000};
        `Ext_ImmJ: ImmExt <= {{12{Ins[31]}}, Ins[19:12], Ins[20], Ins[30:25], Ins[24:21], 1'b0};
            default: ImmExt <= {{21{Ins[31]}}, Ins[30:25], Ins[24:21], Ins[20]};
        endcase
    end

endmodule