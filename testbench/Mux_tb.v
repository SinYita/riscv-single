`timescale 1ns/1ps

module Mux_tb();
    reg [31:0] in_1, in_2;
    reg sel;
    wire [31:0] out;
    
    Mux uut (
        .in_1(in_1),
        .in_2(in_2),
        .sel(sel),
        .out(out)
    );
    
    initial begin
        in_1 = 32'h00000000;
        in_2 = 32'h00000000;
        sel = 1'b0;
        
        $dumpfile("Mux_tb.vcd");
        $dumpvars(0, Mux_tb);
        
        $display("=== Mux Module Testbench ===");
        $display("Time\tSEL\tIN_1\t\tIN_2\t\tOUT\t\tExpected");
        
        #1; // Small delay for signal propagation
        
        // Test 1: sel = 0, should output in_1
        $display("\n--- Test 1: Select input 1 (sel = 0) ---");
        in_1 = 32'h12345678;
        in_2 = 32'hABCDEF00;
        sel = 1'b0;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\t%h", $time, sel, in_1, in_2, out, in_1);
        if (out == in_1) 
            $display("PASS: sel=0 correctly selects in_1");
        else 
            $display("FAIL: Expected %h, got %h", in_1, out);
        
        // Test 2: sel = 1, should output in_2
        $display("\n--- Test 2: Select input 2 (sel = 1) ---");
        in_1 = 32'h12345678;
        in_2 = 32'hABCDEF00;
        sel = 1'b1;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\t%h", $time, sel, in_1, in_2, out, in_2);
        if (out == in_2) 
            $display("PASS: sel=1 correctly selects in_2");
        else 
            $display("FAIL: Expected %h, got %h", in_2, out);
        
        // Test 3: Different values with sel = 0
        $display("\n--- Test 3: Different values with sel = 0 ---");
        in_1 = 32'hFFFFFFFF;
        in_2 = 32'h00000001;
        sel = 1'b0;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\t%h", $time, sel, in_1, in_2, out, in_1);
        if (out == in_1) 
            $display("PASS: sel=0 correctly selects in_1 (all 1s)");
        else 
            $display("FAIL: Expected %h, got %h", in_1, out);
        
        // Test 4: Different values with sel = 1
        $display("\n--- Test 4: Different values with sel = 1 ---");
        in_1 = 32'hFFFFFFFF;
        in_2 = 32'h00000001;
        sel = 1'b1;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\t%h", $time, sel, in_1, in_2, out, in_2);
        if (out == in_2) 
            $display("PASS: sel=1 correctly selects in_2 (small value)");
        else 
            $display("FAIL: Expected %h, got %h", in_2, out);
        
        // Test 5: Zero inputs
        $display("\n--- Test 5: Zero inputs ---");
        in_1 = 32'h00000000;
        in_2 = 32'h00000000;
        sel = 1'b0;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\t%h", $time, sel, in_1, in_2, out, in_1);
        if (out == 32'h00000000) 
            $display("PASS: Zero inputs work correctly");
        else 
            $display("FAIL: Expected 00000000, got %h", out);
        
        sel = 1'b1;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h\t%h", $time, sel, in_1, in_2, out, in_2);
        if (out == 32'h00000000) 
            $display("PASS: Zero inputs work correctly with sel=1");
        else 
            $display("FAIL: Expected 00000000, got %h", out);
        
        // Test 6: Maximum values
        $display("\n--- Test 6: Maximum values ---");
        in_1 = 32'hFFFFFFFF;
        in_2 = 32'hFFFFFFFF;
        sel = 1'b0;
        #10;
        if (out == 32'hFFFFFFFF) 
            $display("PASS: Maximum values work correctly with sel=0");
        else 
            $display("FAIL: Expected FFFFFFFF, got %h", out);
        
        sel = 1'b1;
        #10;
        if (out == 32'hFFFFFFFF) 
            $display("PASS: Maximum values work correctly with sel=1");
        else 
            $display("FAIL: Expected FFFFFFFF, got %h", out);
        
        // Test 7: Rapid switching
        $display("\n--- Test 7: Rapid switching ---");
        in_1 = 32'hAAAAAAAA;
        in_2 = 32'h55555555;
        
        sel = 1'b0;
        #1;
        if (out == in_1) 
            $display("PASS: Quick switch to in_1 works");
        
        sel = 1'b1;
        #1;
        if (out == in_2) 
            $display("PASS: Quick switch to in_2 works");
        
        sel = 1'b0;
        #1;
        if (out == in_1) 
            $display("PASS: Quick switch back to in_1 works");
        
        // Test 8: Pattern test
        $display("\n--- Test 8: Pattern test ---");
        in_1 = 32'h0F0F0F0F;
        in_2 = 32'hF0F0F0F0;
        
        sel = 1'b0;
        #5;
        $display("Pattern test: sel=0, out=%h (expected %h)", out, in_1);
        if (out == in_1) $display("PASS: Pattern test sel=0");
        
        sel = 1'b1;
        #5;
        $display("Pattern test: sel=1, out=%h (expected %h)", out, in_2);
        if (out == in_2) $display("PASS: Pattern test sel=1");
        
        $display("\n=== Mux Testbench Complete ===");
        #50;
        $finish;
    end
    
    // Monitor for real-time checking
    always @(*) begin
        #0.1; // Small delay to avoid race conditions
        if (sel !== 1'bx && in_1 !== 32'hxxxxxxxx && in_2 !== 32'hxxxxxxxx) begin
            case (sel)
                1'b0: begin
                    if (out !== in_1)
                        $display("WARNING: Mux output mismatch at time %0t. sel=0 but out=%h, in_1=%h", 
                                $time, out, in_1);
                end
                1'b1: begin
                    if (out !== in_2)
                        $display("WARNING: Mux output mismatch at time %0t. sel=1 but out=%h, in_2=%h", 
                                $time, out, in_2);
                end
            endcase
        end
    end
    
endmodule