`timescale 1ns/1ps

module Sign_Extend_tb();
    `include "../src/define.v"
    
    reg [31:0] Ins;
    reg [2:0] Imm_src;
    wire [31:0] ImmExt;
    
    Sign_Extend uut (
        .Ins(Ins),
        .Imm_src(Imm_src),
        .ImmExt(ImmExt)
    );
    
    reg [31:0] expected;
    
    initial begin
        Ins = 32'h00000000;
        Imm_src = 3'b000;
        
        $dumpfile("Sign_Extend_tb.vcd");
        $dumpvars(0, Sign_Extend_tb);
        
        $display("=== Sign_Extend Module Testbench ===");
        $display("Time\tImm_src\tInstruction\t\tImmExt\t\t\tExpected\tType");
        
        #1;
        
        $display("\n--- Test 1: I-type Immediate ---");
        Ins = 32'h00C00093;
        Imm_src = `Ext_ImmI;
        expected = 32'h0000000C;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: I-type positive immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        Ins = 32'hFFF00093;
        Imm_src = `Ext_ImmI;
        expected = 32'hFFFFFFFF;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: I-type negative immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 2: S-type Immediate ---");
        Ins = 32'h00812423;
        Imm_src = `Ext_ImmS;
        expected = 32'h00000008;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tS-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: S-type positive immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        Ins = 32'hFE812E23;
        Imm_src = `Ext_ImmS;
        expected = 32'hFFFFFFFC;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tS-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: S-type negative immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 3: B-type Immediate ---");
        Ins = 32'h00208463;
        Imm_src = `Ext_ImmB;
        expected = 32'h00000008;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tB-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: B-type positive immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        Ins = 32'hFE208EE3;
        Imm_src = `Ext_ImmB;
        expected = 32'hFFFFFFFC;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tB-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: B-type negative immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 4: U-type Immediate ---");
        Ins = 32'h12345137;
        Imm_src = `Ext_ImmU;
        expected = 32'h12345000;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tU-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: U-type immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        Ins = 32'hFFFFF137;
        Imm_src = `Ext_ImmU;
        expected = 32'hFFFFF000;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tU-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: U-type immediate with high bits");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 5: J-type Immediate ---");
        Ins = 32'h008000EF;
        Imm_src = `Ext_ImmJ;
        expected = 32'h00000008;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tJ-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: J-type positive immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        Ins = 32'hFF8000EF;
        Imm_src = `Ext_ImmJ;
        expected = 32'hFFF007F8;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tJ-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: J-type negative immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 6: Zero immediate values ---");
        Ins = 32'h00000013;
        Imm_src = `Ext_ImmI;
        expected = 32'h00000000;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: Zero I-type immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 7: Maximum values ---");
        Ins = 32'h7FF00013;
        Imm_src = `Ext_ImmI;
        expected = 32'h000007FF;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: Maximum positive I-type immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        Ins = 32'h80000013;
        Imm_src = `Ext_ImmI;
        expected = 32'hFFFFF800;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tI-type", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: Maximum negative I-type immediate");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 8: Default case ---");
        Ins = 32'h12345678;
        Imm_src = 3'b111;
        expected = 32'h00000123;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\tDefault", $time, Imm_src, Ins, ImmExt, expected);
        if (ImmExt == expected) 
            $display("PASS: Default case works like I-type");
        else 
            $display("FAIL: Expected %h, got %h", expected, ImmExt);
        
        $display("\n--- Test 9: Rapid type switching ---");
        Ins = 32'hFFF00093;
        
        Imm_src = `Ext_ImmI;
        #1;
        if (ImmExt == 32'hFFFFFFFF) 
            $display("PASS: Quick switch to I-type works");
        
        Imm_src = `Ext_ImmS;
        #1;
        if (ImmExt[11:0] == 12'h093) 
            $display("PASS: Quick switch to S-type works");
        
        Imm_src = `Ext_ImmI;
        #1;
        if (ImmExt == 32'hFFFFFFFF) 
            $display("PASS: Quick switch back to I-type works");
        
        $display("\n=== Sign_Extend Testbench Complete ===");
        #50;
        $finish;
    end
    
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
                $display("PASS: %s", test_name);
            else
                $display("FAIL: %s - Expected %h, got %h", test_name, expected_result, ImmExt);
        end
    endtask
    
    always @(*) begin
        #0.1;
        if (Ins !== 32'hxxxxxxxx && Imm_src !== 3'bxxx) begin
            case (Imm_src)
                `Ext_ImmI: begin
                    if (ImmExt !== {{20{Ins[31]}}, Ins[31:20]})
                        $display("WARNING: I-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmS: begin
                    if (ImmExt !== {{20{Ins[31]}}, Ins[31:25], Ins[11:7]})
                        $display("WARNING: S-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmB: begin
                    if (ImmExt !== {{19{Ins[31]}}, Ins[31], Ins[7], Ins[30:25], Ins[11:8], 1'b0})
                        $display("WARNING: B-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmU: begin
                    if (ImmExt !== {Ins[31:12], 12'b0})
                        $display("WARNING: U-type extraction mismatch at time %0t", $time);
                end
                `Ext_ImmJ: begin
                    if (ImmExt !== {{11{Ins[31]}}, Ins[31], Ins[19:12], Ins[20], Ins[30:21], 1'b0})
                        $display("WARNING: J-type extraction mismatch at time %0t", $time);
                end
            endcase
        end
    end
    
endmodule