`timescale 1ns / 1ps

module debug_regfile_tb;
    reg clk, rst, WE;
    reg [4:0] A1, A2, A3;
    reg [31:0] WD;
    wire [31:0] RD1, RD2;
    
    Register_File uut (.clk(clk), .rst(rst), .WriteEnable3(WE), .WD3(WD), 
                      .Address1(A1), .Address2(A2), .Address3(A3), .RD1(RD1), .RD2(RD2));
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; rst = 1; WE = 0; A1 = 0; A2 = 0; A3 = 0; WD = 0;
        
        #10; rst = 0; #10; rst = 1; #10; // Reset sequence
        
        $display("After reset: RD1=%08x, RD2=%08x", RD1, RD2);
        
        // Try to write to register 5
        WE = 1; A3 = 5; WD = 32'h12345678;
        $display("Setup write: WE=%b, A3=%d, WD=%08x", WE, A3, WD);
        
        @(posedge clk);
        $display("After posedge: RD1=%08x, RD2=%08x", RD1, RD2);
        
        #1;
        A1 = 5; // Read from register 5
        #1;
        $display("Reading R5: A1=%d, RD1=%08x", A1, RD1);
        
        $finish;
    end
endmodule
