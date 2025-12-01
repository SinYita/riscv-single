module PC(clk,rst,PC,NPC);
    input clk;
    input rst;
    input [31:0] NPC;
    output reg [31:0] PC;

    always @(posedge clk or posedge rst) begin
        if (~rst) begin
            PC <= {32{1'b0}};
        end
        else begin
            PC <= NPC;
            $write("PC: %h\n", PC);
        end
    end
endmodules