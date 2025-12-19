module flopenr #(parameter WIDTH = 8) (
    input clk, 
    input rst,
    input en, 
    input [WIDTH-1:0] d, 
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or negedge rst) begin
        if (!rst)  q <= {WIDTH{1'b0}};
        else if (en) q <= d;
    end
endmodule