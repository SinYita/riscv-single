`timescale 1ns / 1ps
`include "define.v"

module Instruction_Memory_tb;

    reg rst;
    reg [31:0] Address;
    wire [31:0] ReadData;
    
    reg test_passed;
    integer test_count;
    
    reg [31:0] data_0, data_1, data_2, data_3;
    reg [31:0] rapid_data_0, rapid_data_1, rapid_data_2;
    
    Instruction_Memory uut (
        .rst(rst),
        .Address(Address),
        .ReadData(ReadData)
    );
    
    function [31:0] simulate_next_pc;
        input [31:0] pc;
        input [31:0] instr;
        reg [6:0] opcode;
        reg [2:0] funct3;
        reg [4:0] rs1, rs2;
        reg [31:0] next_pc;
        reg signed [20:0] imm_j;
        reg signed [12:0] imm_b;
        reg branch_taken;
        begin
            opcode = instr[6:0];
            funct3 = instr[14:12];
            rs1 = instr[19:15];
            rs2 = instr[24:20];
            next_pc = pc + 4;  // Default: PC + 4
            branch_taken = 0;
            
            case (opcode)
                7'b1100011: begin // Branch instructions
                    imm_b = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                    
                    // Check for infinite loop first (BEQ x0, x0, 0)
                    if (instr == 32'h00000063) begin
                        $display("PC: 0x%08x | Instruction: 0x%08x | INFINITE LOOP DETECTED (BEQ x0, x0, 0)", pc, instr);
                        simulate_next_pc = 32'hFFFFFFFF; // Signal end
                    end else begin
                        // Simulate branch condition (assuming simple test case)
                        // For BEQ (funct3 = 000): assume branch taken if rs1 == rs2 (we'll simulate this)
                        case (funct3)
                            3'b000: branch_taken = (rs1 == rs2) ? 1 : 0;  // BEQ - simplified assumption
                            3'b001: branch_taken = (rs1 != rs2) ? 1 : 0;  // BNE - simplified assumption
                            default: branch_taken = 0;
                        endcase
                        
                        if (branch_taken) begin
                            next_pc = pc + imm_b;
                            $display("PC: 0x%08x | Instruction: 0x%08x | Next PC: PC+IMM (0x%08x) [BRANCH TAKEN]", pc, instr, next_pc);
                            simulate_next_pc = next_pc;
                        end else begin
                            next_pc = pc + 4;
                            $display("PC: 0x%08x | Instruction: 0x%08x | Next PC: PC+4 (0x%08x) [BRANCH NOT TAKEN]", pc, instr, next_pc);
                            simulate_next_pc = next_pc;
                        end
                    end
                end
                
                7'b1101111: begin // JAL (unconditional jump)
                    imm_j = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                    next_pc = pc + imm_j;
                    $display("PC: 0x%08x | Instruction: 0x%08x | Next PC: PC+IMM (0x%08x) [JUMP]", pc, instr, next_pc);
                    simulate_next_pc = next_pc;
                end
                
                default: begin
                    $display("PC: 0x%08x | Instruction: 0x%08x | Next PC: PC+4 (0x%08x)", pc, instr, next_pc);
                    simulate_next_pc = next_pc;
                end
            endcase
        end
    endfunction
    
    initial begin
        $dumpfile("Instruction_Memory_tb.vcd");
        $dumpvars(0, Instruction_Memory_tb);
    end
    
    initial begin
        test_passed = 1;
        test_count = 0;
        
        #10;
        
        // Test 8: Instruction execution simulation with proper PC progression
        rst = 1;
        
        // Simulate actual PC progression following branch logic
        Address = 32'h00000000;
        repeat (20) begin  // Maximum 20 instructions to prevent infinite loop
            #10;
            Address = simulate_next_pc(Address, ReadData);
            if (Address == 32'hFFFFFFFF) begin // End condition
                $display("Program execution completed or infinite loop detected");
                $finish;
            end
        end
        
        test_count = test_count + 1;
        
        #50;
        $finish;
    end

endmodule