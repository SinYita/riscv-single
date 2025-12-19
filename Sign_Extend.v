`include "define.v"

module Sign_Extend(Ins, sel_ext, ImmExt);
    input [2:0]  sel_ext;
    input [31:0] Ins;
    output reg [31:0] ImmExt;

    always@(*) begin
        case(sel_ext)
            `Ext_ImmI: ImmExt = {{20{Ins[31]}}, Ins[31:20]};
            
            `Ext_ImmS: ImmExt = {{20{Ins[31]}}, Ins[31:25], Ins[11:7]};
            
            `Ext_ImmB: ImmExt = {{19{Ins[31]}}, Ins[31], Ins[7], Ins[30:25], Ins[11:8], 1'b0};
            
            `Ext_ImmU: ImmExt = {Ins[31:12], 12'b0};
            
            `Ext_ImmJ: ImmExt = {{11{Ins[31]}}, Ins[31], Ins[19:12], Ins[20], Ins[30:21], 1'b0};
            
            default:   ImmExt = 32'b0;
        endcase
    end
endmodule