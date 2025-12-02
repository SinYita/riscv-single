module PC(clk,rst,PC,NPC);
    input clk;
    input rst;
    input [31:0] NPC; // Next Instruction Address
    output reg [31:0] PC; // current Instrcution Address

    always @(posedge clk or posedge rst) begin
        if (~rst) begin
            PC <= {32{1'b0}};
        end
        else begin
            PC <= NPC;
            $write("PC: %h\n", NPC);
        end
    end
endmodule