module mem(
    input          clk,
    input          WE,        
    input  [31:0]  A,     
    input  [31:0]  WD,
    output [31:0]  RD
);

    reg [31:0] RAM [0:1023]; 

    assign RD = RAM[A[31:2]];

    always @(posedge clk) begin
        if (WE) begin
            RAM[A[31:2]] <= WD;
        end
    end

    // initial begin
    //     $readmemh("./memfile.hex", RAM);
    // end
endmodule