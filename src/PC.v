module PC(clk,rst,PC,NPC);
    input clk;
    input rst;
    input [31:0] NPC; // Next Instruction Address
    output reg [31:0] PC; // current Instrcution Address

    always @(posedge clk) begin
        if (~rst) begin
            PC <= 32'h0000_0000;
        end
        else begin
            PC <= NPC;
            $write("PC: %h\n", NPC);
        end
    end
endmodule