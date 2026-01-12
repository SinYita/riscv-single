module Data_Memory #(
    parameter MEM_DEPTH = 1024
)(
    input clk,
    input rst_n,
    input WE,
    input [31:0] A,
    input [31:0] WD,
    output [31:0] RD
);

    reg [31:0] RAM [MEM_DEPTH-1:0];

    always @ (posedge clk)
    begin
        if(WE)
            RAM[A[31:2]] <= WD;
    end

    assign RD = (~rst_n) ? 32'd0 : RAM[A[31:2]];

    // integer i;
    // initial begin
    //     for(i = 0; i < 1024; i = i + 1) RAM[i] = 32'b0;
    // end


endmodule