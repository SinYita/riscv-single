module Instruction_Memory#(parameter MEM_DEPTH = 1024)(
    input rst_n,
    input [31:0] A,
    output[31:0] RD
);
    reg[31:0] RAM[MEM_DEPTH-1:0];
    assign RD = RAM[A[31:2]]; // shift by 2 to get word address
    // initial begin
    //     $readmemh("./memfile.hex",RAM);
    // end

endmodule