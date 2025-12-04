`timescale 1ns / 1ps

module reset_debug_tb;
    reg clk, rst, WE;
    reg [4:0] A3;
    reg [31:0] WD;
    wire [31:0] RD1, RD2;
    
    Register_File uut (.clk(clk), .rst(rst), .WriteEnable3(WE), .WD3(WD), 
                      .Address1(5'd5), .Address2(5'd10), .Address3(A3), .RD1(RD1), .RD2(RD2));
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; rst = 1; WE = 0; A3 = 0; WD = 0;
        
        // Write some data first
        WE = 1; A3 = 5; WD = 32'h12345678;
        @(posedge clk); #1;
        $display("After write: RD1=%08x", RD1);
        
        // Now test reset
        $display("Applying reset (rst=0)");
        rst = 0; 
        #1;
        $display("During reset: RD1=%08x", RD1);
        
        @(posedge clk); 
        #1;
        $display("After reset clock: RD1=%08x", RD1);
        
        rst = 1;
        #1; 
        $display("After releasing reset: RD1=%08x", RD1);
        
        $finish;
    end
endmodule
