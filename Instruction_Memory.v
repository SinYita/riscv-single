module Instruction_Memory(rst,A,RD);
    input rst;
    input [31:0] A;
    output[31:0] RD;

    reg[31:0] mem[1023:0];
    assign RD = (rst == 1'b0)? 32'b0: mem[A[31:2]]; // shift by 2 to get word address
    initial begin
        $readmemh("./memfile.hex",mem);
    end

endmodule