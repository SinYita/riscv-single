module Instruction_Memory(rst,Address,ReadData);
    input rst;
    input [31:0] Address;
    output[31:0] ReadData;

    reg[31:0] mem[1023:0];
    assign ReadData = (rst == 1'b0)? 32'b0: mem[Address[31:2]]; // shift by 2 to get word address
    initial begin
        $readmemh("../assembly/memfile.hex",mem);
    end

endmodule