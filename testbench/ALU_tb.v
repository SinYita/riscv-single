`timescale 1ns / 1ps
`include "define.v"

module ALU_tb;

    reg signed [31:0] A, B;
    reg [3:0] ALUControl;
    wire [31:0] Result;
    wire Zero;
    
    reg test_passed;
    integer test_count;
    
    reg [31:0] expected_result;
    reg expected_zero;
    
    ALU uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .Zero(Zero)
    );
    
    initial begin
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0, ALU_tb);
    end
    
    initial begin
        $display("=== ALU Module Testbench ===");
        $display("Time\tALUCtrl\tA\t\tB\t\tResult\t\tZero\tExpected\tTest Description");
        
        test_passed = 1;
        test_count = 0;
        
        A = 0;
        B = 0;
        ALUControl = `ALU_NONE;
        #10;
        
        $display("\n--- Test 1: ALU_ADD (Addition) ---");
        
        // Test 1.1: Positive + Positive
        A = 32'h12345678; B = 32'h87654321; ALUControl = `ALU_ADD;
        expected_result = A + B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "ADD: pos+pos");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Addition positive numbers");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 1.2: Addition resulting in zero
        A = 32'hFFFFFFFF; B = 32'h00000001; ALUControl = `ALU_ADD;
        expected_result = A + B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "ADD: -1+1=0");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Addition zero result");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 2: ALU_SUB (Subtraction) ---");
        
        // Test 2.1: Basic subtraction
        A = 32'h87654321; B = 32'h12345678; ALUControl = `ALU_SUB;
        expected_result = A - B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SUB: basic");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Subtraction basic");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test 2.2: Subtraction resulting in zero
        A = 32'h12345678; B = 32'h12345678; ALUControl = `ALU_SUB;
        expected_result = A - B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SUB: same=0");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Subtraction zero result");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 3: ALU_AND (Bitwise AND) ---");
        
        A = 32'hF0F0F0F0; B = 32'h0F0F0F0F; ALUControl = `ALU_AND;
        expected_result = A & B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "AND: no overlap");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: AND no overlap");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // AND with all ones
        A = 32'hFFFFFFFF; B = 32'h12345678; ALUControl = `ALU_AND;
        expected_result = A & B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "AND: all 1s");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: AND with all 1s");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 4: ALU_OR (Bitwise OR) ---");
        
        A = 32'hF0F0F0F0; B = 32'h0F0F0F0F; ALUControl = `ALU_OR;
        expected_result = A | B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "OR: complement");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: OR complement patterns");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // OR with zero
        A = 32'h00000000; B = 32'h00000000; ALUControl = `ALU_OR;
        expected_result = A | B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "OR: zero");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: OR with zeros");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 5: ALU_XOR (Bitwise XOR) ---");
        
        A = 32'hAAAAAAAA; B = 32'h55555555; ALUControl = `ALU_XOR;
        expected_result = A ^ B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "XOR: invert");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: XOR inverting pattern");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // XOR same values (should be zero)
        A = 32'h12345678; B = 32'h12345678; ALUControl = `ALU_XOR;
        expected_result = A ^ B;
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "XOR: same=0");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("✓ PASS: XOR same values");
        end else begin
            $display("✗ FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 6: ALU_SHIFTL (Shift Left) ---");
        
        A = 32'h00000001; B = 32'h00000004; ALUControl = `ALU_SHIFTL;
        expected_result = A << B[4:0];
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SLL: 1<<4");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Shift left basic");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Shift left with overflow
        A = 32'hF0000000; B = 32'h00000040; ALUControl = `ALU_SHIFTL;
        expected_result = A << B[4:0];
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SLL: overflow");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Shift left overflow");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 7: ALU_SHIFTR (Shift Right Logical) ---");
        
        A = 32'h80000000; B = 32'h00000004; ALUControl = `ALU_SHIFTR;
        expected_result = A >> B[4:0];
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SRL: logical");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Shift right logical");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 8: ALU_SHIFTR_ARITH (Shift Right Arithmetic) ---");
        
        A = 32'h80000000; B = 32'h00000004; ALUControl = `ALU_SHIFTR_ARITH;
        expected_result = A >>> B[4:0]; // Sign extension
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SRA: negative");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Shift right arithmetic negative");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Positive number arithmetic shift
        A = 32'h70000000; B = 32'h00000004; ALUControl = `ALU_SHIFTR_ARITH;
        expected_result = A >>> B[4:0];
        expected_zero = (expected_result == 0);
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SRA: positive");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Shift right arithmetic positive");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 9: ALU_LESS_THAN_SIGNED (SLT) ---");
        
        // Test signed comparison: -1 < 1
        A = 32'hFFFFFFFF; B = 32'h00000001; ALUControl = `ALU_LESS_THAN_SIGNED;
        expected_result = 32'h00000001;
        expected_zero = 0;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SLT: -1<1");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: SLT negative less than positive");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test signed comparison: 1 < -1 (false)
        A = 32'h00000001; B = 32'hFFFFFFFF; ALUControl = `ALU_LESS_THAN_SIGNED;
        expected_result = 32'h00000000;
        expected_zero = 1;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SLT: 1<-1");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: SLT positive not less than negative");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 10: ALU_LESS_THAN (SLTU) ---");
        
        // Test unsigned comparison: 0xFFFFFFFF > 0x00000001 
        A = 32'hFFFFFFFF; B = 32'h00000001; ALUControl = `ALU_LESS_THAN;
        expected_result = 32'h00000000;
        expected_zero = 1;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SLTU: large>small");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: SLTU large unsigned not less than small");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test unsigned comparison: 0x00000001 < 0xFFFFFFFF
        A = 32'h00000001; B = 32'hFFFFFFFF; ALUControl = `ALU_LESS_THAN;
        expected_result = 32'h00000001;
        expected_zero = 0;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SLTU: small<large");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: SLTU small unsigned less than large");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 11: ALU_NONE (Pass Through) ---");
        
        A = 32'h12345678; B = 32'h87654321; ALUControl = `ALU_NONE;
        expected_result = 32'h12345678; // Should pass A through
        expected_zero = 0;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "NONE: pass A");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: ALU_NONE passes A through");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test ALU_NONE with zero
        A = 32'h00000000; B = 32'h12345678; ALUControl = `ALU_NONE;
        expected_result = 32'h00000000;
        expected_zero = 1;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "NONE: pass 0");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: ALU_NONE passes zero through");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 12: Invalid ALU Control (Default Case) ---");
        
        A = 32'h12345678; B = 32'h87654321; ALUControl = 4'b1111; // Invalid control
        expected_result = 32'h12345678; // Should default to passing A
        expected_zero = 0;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "Invalid: default");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Invalid control defaults to pass A");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        $display("\n--- Test 13: Edge Cases ---");
        
        // Test maximum positive + 1 (overflow)
        A = 32'h7FFFFFFF; B = 32'h00000001; ALUControl = `ALU_ADD;
        expected_result = 32'h80000000; // Overflow to negative
        expected_zero = 0;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "ADD: overflow");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Addition overflow behavior");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Test shift by 0
        A = 32'h12345678; B = 32'h00000000; ALUControl = `ALU_SHIFTL;
        expected_result = 32'h12345678; // No shift
        expected_zero = 0;
        #10;
        $display("%0t\t%b\t%08x\t%08x\t%08x\t%b\t%08x\t%s", 
                 $time, ALUControl, A, B, Result, Zero, expected_result, "SLL: shift 0");
        
        if (Result == expected_result && Zero == expected_zero) begin
            $display("PASS: Shift by zero");
        end else begin
            $display("FAIL: Expected Result=%08x Zero=%b, got Result=%08x Zero=%b", 
                     expected_result, expected_zero, Result, Zero);
            test_passed = 0;
        end
        test_count = test_count + 1;
        
        // Final results
        $display("\n=== ALU Testbench Complete ===");
        if (test_passed) begin
            $display("ALL TESTS PASSED! (%0d/%0d)", test_count, test_count);
        end else begin
            $display("SOME TESTS FAILED!");
        end
        
        #50;
        $finish;
    end

endmodule