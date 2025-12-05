`timescale 1ns / 1ps
`include "define.v"

module Register_File_tb;


    reg clk;
    reg rst;
    reg WriteEnable3;
    reg [4:0] Address1, Address2, Address3;
    reg [31:0] WD3;
    wire [31:0] RD1, RD2;
    
    reg test_passed;
    integer test_count;

    Register_File uut (
        .clk(clk),
        .rst(rst),
        .WriteEnable3(WriteEnable3),
        .WD3(WD3),
        .Address1(Address1),
        .Address2(Address2),
        .Address3(Address3),
        .RD1(RD1),
        .RD2(RD2)
    );
    
    always begin
        clk = 0; #5;
        clk = ~clk; #5;
    end
    
    initial begin
        $dumpfile("Register_File_tb.vcd");
        $dumpvars(0, Register_File_tb);
    end
    
    initial begin
        $display("=== Register File Module Testbench ===");
        $display("Time\tRst\tWE3\tAddr1\tAddr2\tAddr3\tWD3\t\tRD1\t\tRD2\t\tTest");
        
        test_passed = 1;
        test_count = 0;
        
        // Initialize signals
        rst = 0;  // Apply active-low reset (rst=0 means reset active)
        WriteEnable3 = 0;
        Address1 = 0;
        Address2 = 0;
        Address3 = 0;
        WD3 = 0;
        
        // Test 1: Reset functionality
        $display("\n--- Test 1: Reset Functionality ---");
        rst = 0; // Apply reset
        #20;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tReset", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD1 == 32'h0 && RD2 == 32'h0) begin
            $display("PASS: Reset clears registers");
        end else begin
            $display("FAIL: Reset should clear all registers to 0");
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        rst = 1;
        #10;
        
        // Test 2: Write to register 0 should be ignored
        $display("\n--- Test 2: Register 0 Write Protection ---");
        WriteEnable3 = 1;
        Address3 = 5'd0;
        WD3 = 32'hDEADBEEF;
        Address1 = 5'd0;
        #20;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tR0 Write", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD1 == 32'h0) begin
            $display("PASS: Register 0 remains 0 (write ignored)");
        end else begin
            $display("FAIL: Register 0 should always be 0, got %08x", RD1);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 3: Write and read from various registers
        $display("\n--- Test 3: Basic Write/Read Operations ---");
        
        // Write to register 5
        WriteEnable3 = 1;
        Address3 = 5'd5;
        WD3 = 32'h12345678;
        @(posedge clk); // Wait for write to complete
        #1; // Small delay after clock edge
        Address1 = 5'd5; // Read from register 5
        #1;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tWrite R5", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD1 == 32'h12345678) begin
            $display("PASS: Write/Read register 5 works");
        end else begin
            $display("FAIL: Expected %08x, got %08x", 32'h12345678, RD1);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Write to register 10
        Address3 = 5'd10;
        WD3 = 32'hABCDEF00;
        @(posedge clk); // Wait for write to complete
        #1;
        Address2 = 5'd10; // Read from register 10
        #1;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tWrite R10", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD2 == 32'hABCDEF00) begin
            $display("PASS: Write/Read register 10 works");
        end else begin
            $display("FAIL: Expected %08x, got %08x", 32'hABCDEF00, RD2);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 4: Simultaneous dual read
        $display("\n--- Test 4: Dual Port Read ---");
        Address1 = 5'd5;  // Should read 0x12345678
        Address2 = 5'd10; // Should read 0xABCDEF00
        WriteEnable3 = 0; // Disable write
        #10;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tDual Read", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD1 == 32'h12345678 && RD2 == 32'hABCDEF00) begin
            $display("PASS: Dual port read works correctly");
        end else begin
            $display("FAIL: Dual read failed. RD1=%08x (exp:12345678), RD2=%08x (exp:ABCDEF00)", RD1, RD2);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 5: Write enable control
        $display("\n--- Test 5: Write Enable Control ---");
        WriteEnable3 = 0; // Disable write
        Address3 = 5'd15;
        WD3 = 32'hFFFFFFFF;
        @(posedge clk);
        #1;
        Address1 = 5'd15; // Read from register 15 (should be 0)
        #1;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tWE=0", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD1 == 32'h0) begin
            $display("PASS: Write disabled when WE=0");
        end else begin
            $display("FAIL: Write should be disabled when WE=0, got %08x", RD1);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 6: All registers (boundary test)
        $display("\n--- Test 6: Boundary Registers (R1 and R31) ---");
        WriteEnable3 = 1;
        
        // Test register 1
        Address3 = 5'd1;
        WD3 = 32'h11111111;
        @(posedge clk);
        #1;
        Address1 = 5'd1;
        #1;
        if (RD1 == 32'h11111111) begin
            $display("PASS: Register 1 write/read works");
        end else begin
            $display("FAIL: Register 1 failed. Expected 11111111, got %08x", RD1);
            test_passed = 0;
        end
        
        // Test register 31
        Address3 = 5'd31;
        WD3 = 32'h31313131;
        @(posedge clk);
        #1;
        Address2 = 5'd31;
        #1;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tR31 Write", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD2 == 32'h31313131) begin
            $display("PASS: Register 31 write/read works");
        end else begin
            $display("FAIL: Register 31 failed. Expected 31313131, got %08x", RD2);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 7: Overwrite existing data
        $display("\n--- Test 7: Data Overwrite ---");
        Address3 = 5'd5; // Overwrite register 5
        WD3 = 32'hCAFEBABE;
        @(posedge clk);
        #1;
        Address1 = 5'd5;
        #1;
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tOverwrite", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD1 == 32'hCAFEBABE) begin
            $display("PASS: Data overwrite works");
        end else begin
            $display("FAIL: Overwrite failed. Expected CAFEBABE, got %08x", RD1);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 8: Reset after writes
        $display("\n--- Test 8: Reset After Operations ---");
        
        // First show what we currently have
        Address1 = 5'd5; Address2 = 5'd10; WriteEnable3 = 0; #1;
        $display("Before reset: R5=%08x, R10=%08x", RD1, RD2);
        
        // Apply reset
        rst = 0; // Apply active-low reset
        @(posedge clk); // Reset happens on this clock edge
        #1;
        $display("After reset clock: R5=%08x, R10=%08x", RD1, RD2);
        
        // Release reset  
        rst = 1; // Release reset back to normal operation
        #1;
        $display("After releasing reset: R5=%08x, R10=%08x", RD1, RD2);
        
        $display("%0t\t%b\t%b\t%2d\t%2d\t%2d\t%08x\t%08x\t%08x\tPost-Reset", 
                 $time, rst, WriteEnable3, Address1, Address2, Address3, WD3, RD1, RD2);
        
        if (RD1 == 32'h0 && RD2 == 32'h0) begin
            $display("PASS: Reset clears all previous data");
        end else begin
            $display("FAIL: Reset should clear all data. RD1=%08x, RD2=%08x", RD1, RD2);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Final results
        $display("\n=== Register_File Testbench Complete ===");
        if (test_passed) begin
            $display("ALL TESTS PASSED! (%0d/%0d)", test_count, test_count);
        end else begin
            $display("SOME TESTS FAILED!");
        end
        
        #50;
        $finish;
    end

endmodule