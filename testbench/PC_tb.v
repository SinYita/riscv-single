`timescale 1ns/1ps

module PC_tb();
    reg clk;
    reg rst;
    reg [31:0] NPC;
    wire [31:0] PC;
    
    PC uut (
        .clk(clk),
        .rst(rst),
        .PC(PC),
        .NPC(NPC)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst = 0;
        NPC = 32'h00000000;
        $dumpfile("PC_tb.vcd");
        $dumpvars(0, PC_tb);        
        $display("=== PC Module Testbench ===");
        $display("Time\tRST\tNPC\t\tPC");
        $monitor("%0t\t%b\t%h\t%h", $time, rst, NPC, PC);
        
        #10;
        $display("\n--- Test 1: Reset functionality ---");
        rst = 0;
        #20;
        if (PC == 32'h00000000) 
            $display("PASS: Reset sets PC to 0x00000000");
        else 
            $display("FAIL: Reset should set PC to 0x00000000, got %h", PC);
        
        $display("\n--- Test 2: Normal PC update ---");
        rst = 1;
        NPC = 32'h00000004;
        #10;
        if (PC == 32'h00000004) 
            $display("PASS: PC correctly updates to 0x00000004");
        else 
            $display("FAIL: PC should be 0x00000004, got %h", PC);
        
        $display("\n--- Test 3: Sequential PC updates ---");
        NPC = 32'h00000008;
        #10;
        if (PC == 32'h00000008) 
            $display("PASS: PC correctly updates to 0x00000008");
        else 
            $display("FAIL: PC should be 0x00000008, got %h", PC);
            
        NPC = 32'h0000000C;
        #10;
        if (PC == 32'h0000000C) 
            $display("PASS: PC correctly updates to 0x0000000C");
        else 
            $display("FAIL: PC should be 0x0000000C, got %h", PC);
        
        $display("\n--- Test 4: Large address values ---");
        NPC = 32'hFFFFFFFC;
        #10;
        if (PC == 32'hFFFFFFFC) 
            $display("PASS: PC correctly handles large address 0xFFFFFFFC");
        else 
            $display("FAIL: PC should be 0xFFFFFFFC, got %h", PC);
        
        $display("\n--- Test 5: Reset during operation ---");
        NPC = 32'h12345678;
        #5;
        rst = 0;
        #10;
        if (PC == 32'h00000000) 
            $display("PASS: Reset works correctly during operation");
        else 
            $display("FAIL: Reset should set PC to 0x00000000, got %h", PC);
            
        rst = 1;
        #10;
        
        $display("\n--- Test 6: Zero address ---");
        NPC = 32'h00000000;
        #10;
        if (PC == 32'h00000000) 
            $display("PASS: PC correctly handles zero address");
        else 
            $display("FAIL: PC should be 0x00000000, got %h", PC);
        
        $display("\n=== PC Testbench Complete ===");
        #50;
        $finish;
    end
    
    always @(PC) begin
        if (PC === 32'hxxxxxxxx) begin
            $display("ERROR: PC is in undefined state at time %0t", $time);
        end
    end
    
endmodule