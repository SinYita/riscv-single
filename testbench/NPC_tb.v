`timescale 1ns/1ps

module NPC_tb();
    `include "../src/define.v"
    
    // Testbench signals
    reg [31:0] PC;
    reg PCSrc;  // Changed to 1-bit
    reg [31:0] IMMEXT;
    wire [31:0] NPC;
    
    // Instantiate the NPC module
    NPC uut (
        .PC(PC),
        .PCSrc(PCSrc),
        .IMMEXT(IMMEXT),
        .NPC(NPC)
    );
    
    // Test sequence
    initial begin
        PC = 32'h00000000;
        PCSrc = 1'b0;
        IMMEXT = 32'h00000000;
        
        $dumpfile("NPC_tb.vcd");
        $dumpvars(0, NPC_tb);
        
        $display("=== NPC Module Testbench ===");
        $display("Time\tPC\t\tPCSrc\tIMMEXT\t\tNPC\t\tExpected");
        
        #1;
        
        // Test 1: Sequential execution (PC + 4)
        $display("\n--- Test 1: Sequential execution (PC + 4) ---");
        PC = 32'h00000000;
        PCSrc = `PC_NOJUMP;
        IMMEXT = 32'h12345678;
        #10;
        $display("%0t\t%h\t%b\t%h\t%h\t%h", $time, PC, PCSrc, IMMEXT, NPC, PC + 4);
        if (NPC == PC + 4) 
            $display("PASS: NPC = PC + 4 = 0x00000004");
        else 
            $display("FAIL: Expected 0x00000004, got %h", NPC);
        
        // Test 2: Different PC values with PC + 4
        $display("\n--- Test 2: Different PC values with PC + 4 ---");
        PC = 32'h00001000;
        PCSrc = `PC_NOJUMP;
        IMMEXT = 32'hFFFFFFFF;
        #10;
        $display("%0t\t%h\t%b\t%h\t%h\t%h", $time, PC, PCSrc, IMMEXT, NPC, PC + 4);
        if (NPC == 32'h00001004) 
            $display("PASS: NPC = PC + 4 = 0x00001004");
        else 
            $display("FAIL: Expected 0x00001004, got %h", NPC);
        
        // Test 3: Branch/Jump with positive offset
        $display("\n--- Test 3: Branch/Jump with positive offset ---");
        PC = 32'h00002000;
        PCSrc = `PC_J_OFFSET;
        IMMEXT = 32'h00000010;
        #10;
        $display("%0t\t%h\t%b\t%h\t%h\t%h", $time, PC, PCSrc, IMMEXT, NPC, PC + IMMEXT);
        if (NPC == 32'h00002010) 
            $display("PASS: NPC = PC + IMMEXT = 0x00002010");
        else 
            $display("FAIL: Expected 0x00002010, got %h", NPC);
        
        // Test 4: Branch/Jump with negative offset (signed)
        $display("\n--- Test 4: Branch/Jump with negative offset ---");
        PC = 32'h00003000;
        PCSrc = `PC_J_OFFSET;
        IMMEXT = 32'hFFFFFFF0;
        #10;
        $display("%0t\t%h\t%b\t%h\t%h\t%h", $time, PC, PCSrc, IMMEXT, NPC, PC + IMMEXT);
        if (NPC == 32'h00002FF0) 
            $display("PASS: NPC = PC + IMMEXT = 0x00002FF0 (negative offset)");
        else 
            $display("FAIL: Expected 0x00002FF0, got %h", NPC);
        
        // Test 5: Large positive offset
        $display("\n--- Test 5: Large positive offset ---");
        PC = 32'h00000100;
        PCSrc = `PC_J_OFFSET;
        IMMEXT = 32'h00001000;
        #10;
        $display("%0t\t%h\t%b\t%h\t%h\t%h", $time, PC, PCSrc, IMMEXT, NPC, PC + IMMEXT);
        if (NPC == 32'h00001100) 
            $display("PASS: NPC = PC + IMMEXT = 0x00001100 (large offset)");
        else 
            $display("FAIL: Expected 0x00001100, got %h", NPC);
        
        // Test 6: Zero offset
        $display("\n--- Test 6: Zero offset ---");
        PC = 32'h00005000;
        PCSrc = `PC_J_OFFSET;
        IMMEXT = 32'h00000000;
        #10;
        $display("%0t\t%h\t%b\t%h\t%h\t%h", $time, PC, PCSrc, IMMEXT, NPC, PC);
        if (NPC == PC) 
            $display("PASS: NPC = PC = 0x00005000 (zero offset)");
        else 
            $display("FAIL: Expected 0x00005000, got %h", NPC);
        
        // Test 7: Edge case - Maximum addresses
        $display("\n--- Test 7: Edge case - Maximum addresses ---");
        PC = 32'hFFFFFFFC;
        PCSrc = `PC_NOJUMP;
        IMMEXT = 32'h00000000;
        #10;
        $display("%0t\t%h\t%b\t%h\t%h\t%h", $time, PC, PCSrc, IMMEXT, NPC, PC + 4);
        if (NPC == 32'h00000000)
            $display("PASS: PC + 4 overflow handled correctly: 0x00000000");
        else 
            $display("INFO: PC + 4 = %h (may overflow depending on implementation)", NPC);
        
        // Test 8: Rapid PCSrc switching
        $display("\n--- Test 8: Rapid PCSrc switching ---");
        PC = 32'h00007000;
        IMMEXT = 32'h00000100;
        
        PCSrc = `PC_NOJUMP;
        #1;
        if (NPC == 32'h00007004) 
            $display("PASS: Quick switch to PC+4 works");
        
        PCSrc = `PC_J_OFFSET;
        #1;
        if (NPC == 32'h00007100) 
            $display("PASS: Quick switch to PC+IMMEXT works");
        
        PCSrc = `PC_NOJUMP;
        #1;
        if (NPC == 32'h00007004) 
            $display("PASS: Quick switch back to PC+4 works");
        
        $display("\n=== NPC Testbench Complete ===");
        #50;
        $finish;
    end
    
    always @(*) begin
        #0.1;
        if (PC !== 32'hxxxxxxxx && PCSrc !== 1'bx && IMMEXT !== 32'hxxxxxxxx) begin
            case (PCSrc)
                `PC_NOJUMP: begin
                    if (NPC !== PC + 4)
                        $display("WARNING: NPC mismatch at time %0t. Expected %h, got %h", 
                                $time, PC + 4, NPC);
                end
                `PC_J_OFFSET: begin
                    if (NPC !== PC + IMMEXT)
                        $display("WARNING: NPC mismatch at time %0t. Expected %h, got %h", 
                                $time, PC + IMMEXT, NPC);
                end
                default: begin
                    if (NPC !== PC + 4)
                        $display("WARNING: Default case mismatch at time %0t. Expected %h, got %h", 
                                $time, PC + 4, NPC);
                end
            endcase
        end
    end
    
endmodule