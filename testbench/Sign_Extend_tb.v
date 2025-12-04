`timescale 1ns/1ps

module Sign_Extend_tb();
    // Include define file for immediate type constants
    `include "../src/define.v"
    
    // Testbench signals
    reg [31:0] Ins;
    reg [2:0] Imm_src;
    wire [31:0] ImmExt;
    
    // Instantiate the Sign_Extend module
    Sign_Extend uut (
        .Ins(Ins),
        .Imm_src(Imm_src),
        .ImmExt(ImmExt)
    );
    
    // Test vectors and expected results
    reg [31:0] expected;
    
    // Test sequence
    initial begin
        // Initialize signals
        Ins = 32'h00000000;
        Imm_src = 3'b000;
        
        // Create VCD file for waveform viewing
        $dumpfile("Sign_Extend_tb.vcd");
        $dumpvars(0, Sign_Extend_tb);
        
        $display("=== Sign_Extend Module Testbench ===");
        $display("Time\tImm_src\tInstruction\t\tImmExt\t\t\tExpected\tType");
        
        #1; // Small delay for signal propagation
        
        // Test 1: I-type immediate (12-bit sign extended)
        $display("\n--- Test 1: I-type Immediate ---");
        Ins = 32'h00C00093;  // ADDI x1, x0, 12 (positive immediate)
        Imm_src = `Ext_ImmI;
        expected = 32'h0000000C;  // +12 sign extended
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: I-type positive immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 2: I-type negative immediate
        Ins = 32'hFFF00093;  // ADDI x1, x0, -1 (negative immediate)
        Imm_src = `Ext_ImmI;
        expected = 32'hFFFFFFFF;  // -1 sign extended
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: I-type negative immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 3: S-type immediate (store instruction)
        $display("\n--- Test 2: S-type Immediate ---");
        Ins = 32'h00812423;  // SW x8, 8(x2) - store with offset 8
        Imm_src = `Ext_ImmS;
        expected = 32'h00000008;  // +8 sign extended
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tS-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: S-type positive immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 4: S-type negative immediate
        Ins = 32'hFE812E23;  // SW with negative offset
        Imm_src = `Ext_ImmS;
        expected = 32'hFFFFFFFC;  // -4 sign extended  
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tS-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: S-type negative immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 5: B-type immediate (branch instruction)
        $display("\n--- Test 3: B-type Immediate ---");
        Ins = 32'h00208463;  // BEQ x1, x2, 8 - branch with offset 8
        Imm_src = `Ext_ImmB;
        expected = 32'h00000008;  // +8 sign extended (LSB always 0)
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tB-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: B-type positive immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 6: B-type negative immediate
        Ins = 32'hFE208EE3;  // BEQ with negative offset
        Imm_src = `Ext_ImmB;
        expected = 32'hFFFFFFFC;  // -4 sign extended
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tB-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: B-type negative immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 7: U-type immediate (LUI instruction)
        $display("\n--- Test 4: U-type Immediate ---");
        Ins = 32'h12345137;  // LUI x2, 0x12345
        Imm_src = `Ext_ImmU;
        expected = 32'h12345000;  // Upper 20 bits, lower 12 bits zero
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tU-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: U-type immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 8: U-type with sign bit set
        Ins = 32'hFFFFF137;  // LUI with upper bits set
        Imm_src = `Ext_ImmU;
        expected = 32'hFFFFF000;  // Upper 20 bits, lower 12 bits zero
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tU-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: U-type immediate with high bits");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 9: J-type immediate (JAL instruction)
        $display("\n--- Test 5: J-type Immediate ---");
        Ins = 32'h008000EF;  // JAL x1, 8 - jump with offset 8
        Imm_src = `Ext_ImmJ;
        expected = 32'h00000008;  // +8 sign extended (LSB always 0)
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tJ-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: J-type positive immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 10: J-type negative immediate
        Ins = 32'hFF8000EF;  // JAL with negative offset
        Imm_src = `Ext_ImmJ;
        expected = 32'hFFF007F8;  // Correct J-type immediate extraction
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tJ-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: J-type negative immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 11: Zero immediate values
        $display("\n--- Test 6: Zero immediate values ---");
        Ins = 32'h00000013;  // ADDI x0, x0, 0 (NOP)
        Imm_src = `Ext_ImmI;
        expected = 32'h00000000;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: Zero I-type immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 12: Maximum positive I-type immediate
        $display("\n--- Test 7: Maximum values ---");
        Ins = 32'h7FF00013;  // ADDI with max positive immediate (2047)
        Imm_src = `Ext_ImmI;
        expected = 32'h000007FF;  // +2047 sign extended
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: Maximum positive I-type immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 13: Maximum negative I-type immediate  
        Ins = 32'h80000013;  // ADDI with max negative immediate (-2048)
        Imm_src = `Ext_ImmI;
        expected = 32'hFFFFF800;  // -2048 sign extended
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: Maximum negative I-type immediate");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 14: Default case (should behave like I-type)
        $display("\n--- Test 8: Default case ---");
        Ins = 32'h12345678;
        Imm_src = 3'b111;  // Invalid selector (should default to I-type)
        expected = 32'h00000123;  // Should extract like I-type: bits [31:20] = 0x123
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tDefault", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("✓ PASS: Default case works like I-type");
        else 
            $display("✗ FAIL: Expected %h, got %h", expected, ImmExt);
        
        // Test 15: Rapid switching between types
        $display("\n--- Test 9: Rapid type switching ---");
        Ins = 32'hFFF00093;  // Instruction with negative immediate
        
        Imm_src = `Ext_ImmI;
        #1;
        if (ImmExt == 32'hFFFFFFFF) 
            $display("✓ PASS: Quick switch to I-type works");
        
        Imm_src = `Ext_ImmS;
        #1;
        if (ImmExt[11:0] == 12'h093) 
            $display("✓ PASS: Quick switch to S-type works");
        
        Imm_src = `Ext_ImmI;
        #1;
        if (ImmExt == 32'hFFFFFFFF) 
            $display("✓ PASS: Quick switch back to I-type works");
        
        $display("\n=== Sign_Extend Testbench Complete ===");
        #50;
        $finish;
    end
    
    // Helper task to check bit extraction
    task check_bits;
        input [31:0] instruction;
        input [2:0] imm_type;
        input [31:0] expected_result;
        input [50*8:1] test_name;
        begin
            Ins = instruction;
            Imm_src = imm_type;
            #1;
            if (ImmExt == expected_result)
                $display("✓ PASS: %s", test_name);
            else
                $display("✗ FAIL: %s - Expected %h, got %h", test_name, expected_result, ImmExt);
        end
    endtask
    
    // Monitor for debugging
    always @(*) begin
        #0.1; // Small delay to avoid race conditions
        if (Ins !== 32'hxxxxxxxx && Imm_src !== 3'bxxx) begin
            case (Imm_src)
                `Ext_ImmI: begin
                    // I-type: sign extend bits [31:20]
                    if (ImmExt !== {{21{Ins[31]}}, Ins[30:25], Ins[24:21], Ins[20]})
                        $display("WARNING: I-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmS: begin
                    // S-type: sign extend {bits[31:25], bits[11:7]}
                    if (ImmExt !== {{21{Ins[31]}}, Ins[30:25], Ins[11:8], Ins[7]})
                        $display("WARNING: S-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmB: begin
                    // B-type: sign extend {bit[31], bit[7], bits[30:25], bits[11:8], 1'b0}
                    if (ImmExt !== {{20{Ins[31]}}, Ins[7], Ins[30:25], Ins[11:8], 1'b0})
                        $display("WARNING: B-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmU: begin
                    // U-type: {bits[31:12], 12'b0}
                    if (ImmExt !== {Ins[31], Ins[30:20], Ins[19:12], 12'b0})
                        $display("WARNING: U-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmJ: begin
                    // J-type: sign extend {bit[31], bits[19:12], bit[20], bits[30:25], bits[24:21], 1'b0}
                    if (ImmExt !== {{12{Ins[31]}}, Ins[19:12], Ins[20], Ins[30:25], Ins[24:21], 1'b0})
                        $display("WARNING: J-type extraction mismatch at time %0t", $time);
                end
            endcase
        end
    end
    
endmodule