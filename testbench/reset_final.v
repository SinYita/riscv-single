`timescale 1ns / 1ps

module reset_final_tb;
    reg clk, rst, WE;
    reg [4:0] A1, A2, A3;
    reg [31:0] WD;
    wire [31:0] RD1, RD2;
    
    Register_File uut (.clk(clk), .rst(rst), .WriteEnable3(WE), .WD3(WD), 
                      .Address1(A1), .Address2(A2), .Address3(A3), .RD1(RD1), .RD2(RD2));
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; 
        
        // Start with proper reset sequence
        rst = 0; WE = 0; A1 = 0; A2 = 0; A3 = 0; WD = 0;
        @(posedge clk); // Reset on clock edge
        rst = 1; // Release reset
        #10;
        
        // Write to register 5
        WE = 1; A3 = 5; WD = 32'hAAAAAAAA;
        @(posedge clk); 
        WE = 0; A1 = 5; #1;
        $display("After write R5: RD1=%08x", RD1);
        
        // Write to register 10
        WE = 1; A3 = 10; WD = 32'hBBBBBBBB;
        @(posedge clk);
        WE = 0; A2 = 10; #1;
        $display("After write R10: RD2=%08x", RD2);
        
        // Check both registers contain data
        A1 = 5; A2 = 10; #1;
        $display("Before reset: R5=%08x, R10=%08x", RD1, RD2);
        
        // Apply reset (active low)
        $display("Applying reset...");
        rst = 0;
        @(posedge clk); // Let reset take effect
        #1;
        $display("After reset clock: R5=%08x, R10=%08x", RD1, RD2);
        
        // Release reset
        rst = 1; #1;
        $display("After releasing reset: R5=%08x, R10=%08x", RD1, RD2);
        
        $finish;
    end
endmodule
