module PC(clk,rst, NPC,PC);
    input clk;
    input rst;
    input [31:0] NPC;
    output reg [31:0] PC;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'h0000_3000;
        end
        else begin
            PC <= NPC;
            $write("PC: %h\n", PC);
        end
    end
endmodules