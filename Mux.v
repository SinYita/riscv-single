module Mux(in_1,in_2,sel,out);
    input[31:0] in_1,in_2;
    input sel;
    output [31:0] out;

    
//  when sel==0, out=in_1; when sel==1, out=in_2
    assign out = (~sel) ? in_1 : in_2;
endmodule