module Mux(in_1,in_2,sel,out);
    input[31:0] in_1,in_2;
    input sel;
    output [31:0] out;
    assign out = (~sel) ? in_1 : in_2;
    // 0 for in_1, 1 for in_2
endmodule