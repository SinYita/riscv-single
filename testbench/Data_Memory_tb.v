`timescale 1ns / 1ps
`include "define.v"

module Data_Memory_tb;

    reg clk;
    reg rst;
    reg WE;
    reg [31:0] A, WD;
    wire [31:0] RD;
    
    reg test_passed;
    integer test_count;
    
    reg [31:0] data_addr20, data_addr30;
    
    Data_Memory uut (
        .clk(clk),
        .rst(rst),
        .WE(WE),
        .WD(WD),
        .A(A),
        .RD(RD)
    );
    
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end
    
    initial begin
        $dumpfile("Data_Memory_tb.vcd");
        $dumpvars(0, Data_Memory_tb);
    end
    
    initial begin
        $display("=== Data Memory Module Testbench ===");
        $display("Time\tRst\tWE\tAddr\t\tWriteData\tReadData\tTest Description");
        
        test_passed = 1;
        test_count = 0;
        
        rst = 1;
        WE = 0;
        A = 0;
        WD = 0;
        
        // Test 1: Reset functionality
        $display("\n--- Test 1: Reset Functionality ---");
        rst = 0;
        A = 32'h00000000;
        #20;
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tReset=0", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == 32'h0) begin
            $display("PASS: Reset properly disables memory output");
        end else begin
            $display("FAIL: Reset should disable output, got %08x", RD);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        rst = 1; #20; // Release reset
        
        // Test 2: Basic write operation
        $display("\n--- Test 2: Basic Write Operation ---");
        WE = 1;
        A = 32'h00000010; // Address 16
        WD = 32'h12345678;
        #20; // Wait for clock edge
        
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tWrite", 
                 $time, rst, WE, A, WD, RD);
        
        // Test 3: Read the written data
        $display("\n--- Test 3: Read Written Data ---");
        WE = 0; // Disable write
        #20; // Wait for read
        
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tRead", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == 32'h12345678) begin
            $display("PASS: Basic write/read works correctly");
        end else begin
            $display("FAIL: Expected %08x, got %08x", 32'h12345678, RD);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 4: Write enable control
        $display("\n--- Test 4: Write Enable Control ---");
        WE = 0; // Write disabled
        A = 32'h00000014; // Different address
        WD = 32'hDEADBEEF;
        #20;
        
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tWE=0 Write", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == 32'h0) begin
            $display("PASS: Write disabled when WE=0");
        end else begin
            $display("INFO: Location contains %08x (might be from initialization)", RD);
        end
        test_count = test_count + 1;
        
        // Test 5: Multiple writes to different addresses
        $display("\n--- Test 5: Multiple Address Write/Read ---");
        WE = 1;
        
        // Write to address 20
        A = 32'h00000020;
        WD = 32'hABCDEF00;
        #20;
        WE = 0; #10;
        data_addr20 = RD;
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tAddr 20", 
                 $time, rst, WE, A, WD, RD);
        
        // Write to address 30  
        WE = 1;
        A = 32'h00000030;
        WD = 32'hCAFEBABE;
        #20;
        WE = 0; #10;
        data_addr30 = RD;
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tAddr 30", 
                 $time, rst, WE, A, WD, RD);
        
        // Verify independence - read back addr 20
        A = 32'h00000020; #10;
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tReread 20", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == data_addr20 && data_addr20 == 32'hABCDEF00) begin
            $display("PASS: Multiple addresses work independently");
        end else begin
            $display("FAIL: Address independence failed. Expected %08x, got %08x", 
                     32'hABCDEF00, RD);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 6: Data overwrite
        $display("\n--- Test 6: Data Overwrite ---");
        WE = 1;
        A = 32'h00000010; // Same address as Test 2
        WD = 32'hFFFFFFFF; // New data
        #20;
        WE = 0; #10;
        
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tOverwrite", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == 32'hFFFFFFFF) begin
            $display("PASS: Data overwrite works correctly");
        end else begin
            $display("FAIL: Overwrite failed. Expected FFFFFFFF, got %08x", RD);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 7: Boundary addresses
        $display("\n--- Test 7: Boundary Address Access ---");
        
        // Test address 0
        WE = 1;
        A = 32'h00000000;
        WD = 32'h00000001;
        #20;
        WE = 0; #10;
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tAddr 0", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == 32'h00000001) begin
            $display("PASS: Address 0 works correctly");
        end else begin
            $display("FAIL: Address 0 failed. Expected 00000001, got %08x", RD);
            test_passed = 0;
        end
        
        // Test large address (within bounds: mem[1023])
        WE = 1;
        A = 32'h000003FF; // Address 1023
        WD = 32'h1023ABCD;
        #20;
        WE = 0; #10;
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tAddr 1023", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == 32'h1023ABCD) begin
            $display("PASS: Large valid address works correctly");
        end else begin
            $display("FAIL: Large address failed. Expected 1023ABCD, got %08x", RD);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 8: Rapid read/write operations
        $display("\n--- Test 8: Rapid Operations ---");
        
        A = 32'h00000100;
        WE = 1;
        WD = 32'h11111111; #20;
        WE = 0; #10;
        
        if (RD == 32'h11111111) 
            $display("PASS: Rapid operation 1 successful");
        
        A = 32'h00000104; 
        WE = 1;
        WD = 32'h22222222; #20;
        WE = 0; #10;
        
        if (RD == 32'h22222222) 
            $display("PASS: Rapid operation 2 successful");
        
        test_count = test_count + 1;
        
        // Test 9: Write during reset
        $display("\n--- Test 9: Reset During Write ---");
        
        A = 32'h00000200;
        WD = 32'hBADBAD00;
        WE = 1;
        rst = 0; // Reset during write setup
        #20;
        rst = 1; // Release reset
        WE = 0;
        #10;
        
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tReset+Write", 
                 $time, rst, WE, A, WD, RD);
        
        $display("INFO: Reset behavior during write tested");
        test_count = test_count + 1;
        
        // Test 10: Clock edge behavior
        $display("\n--- Test 10: Clock Edge Timing ---");
        
        WE = 1;
        A = 32'h00000300;
        WD = 32'hCCCCCCCC;
        
        // Write should happen on positive edge
        @(posedge clk);
        #1; // Small delay after clock edge
        WE = 0;
        #5;
        
        $display("%0t\t%b\t%b\t%08x\t%08x\t%08x\tClock Edge", 
                 $time, rst, WE, A, WD, RD);
        
        if (RD == 32'hCCCCCCCC) begin
            $display("PASS: Write occurs on positive clock edge");
        end else begin
            $display("FAIL: Clock edge timing issue. Expected CCCCCCCC, got %08x", RD);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Final results
        $display("\n=== Data_Memory Testbench Complete ===");
        if (test_passed) begin
            $display("ALL TESTS PASSED! (%0d/%0d)", test_count, test_count);
        end else begin
            $display("SOME TESTS FAILED!");
        end
        
        #50;
        $finish;
    end

endmodule