module mux4 #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] d0, d1, d2, d3,
    input  [1:0]       s, 
    output [WIDTH-1:0] y
);
    assign y = (s == 2'b00) ? d0 :
               (s == 2'b01) ? d1 :
               (s == 2'b10) ? d2 : d3;
endmodule