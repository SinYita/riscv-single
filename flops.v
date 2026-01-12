module flopr #(parameter WIDTH = 8)
              (input                  clk, rst_n,
               input  [WIDTH-1:0]     d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, negedge rst_n)
    if (!rst_n) q <= 0;
    else        q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
               (input                  clk, rst_n, en,
                input  [WIDTH-1:0]     d, 
                output reg [WIDTH-1:0] q);
    
    always @(posedge clk, negedge rst_n)
        if (!rst_n) q <= 0;
        else if (en) q <= d;
endmodule

module flopclr #(parameter WIDTH = 8)
                (input                  clk, rst_n, clr,
                 input  [WIDTH-1:0]     d, 
                 output reg [WIDTH-1:0] q);

  always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= 0;
    else if (clr) q <= 0;
    else q <= d;
endmodule

module flopenclr #(parameter WIDTH = 8)
                  (input                  clk, rst_n, clr, en, 
                   input  [WIDTH-1:0]     d, 
                   output reg [WIDTH-1:0] q);

  always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= 0;
    else if (clr) q <= 0;
    else if (en) q <= d;
endmodule
