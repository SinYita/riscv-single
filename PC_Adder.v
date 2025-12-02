module PC_Adder(a,b,c);
    input[31:0] a,b;
    output[31:0] c;

    assign c = a + b; // this could be extend to support jump address calculation
endmodule