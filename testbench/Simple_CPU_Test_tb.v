`timescale 1ns / 1ps
`include "define.v"

module Simple_CPU_Test_tb;

    // Clock and reset
    reg clk, rst;
    integer cycle_count;
    
    // CPU Top-level signals
    wire [31:0] PC_current;
    wire [31:0] instruction;
    wire [31:0] ALU_result;
    wire [31:0] reg_write_data;
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] immediate;
    wire [31:0] memory_read_data;
    wire RegWrite, MemWrite, ALUSrc, ResultSrc, PCSrc;
    wire [2:0] ImmSrc;
    wire [3:0] ALUControl;
    wire Zero;
    
    // Internal CPU signals
    wire [31:0] PC_next;
    wire [31:0] ALU_srcB;
    
    // Instantiate CPU modules
    
    // Program Counter
    PC pc_inst (
        .clk(clk),
        .rst(rst),
        .NPC(PC_next),
        .PC(PC_current)
    );
    
    // Next PC calculation  
    NPC npc_inst (
        .PC(PC_current),
        .PCSrc(PCSrc),
        .IMMEXT(immediate),
        .NPC(PC_next)
    );
    
    // Instruction Memory
    Instruction_Memory imem_inst (
        .rst(rst),
        .Address(PC_current),
        .ReadData(instruction)
    );
    
    // Register File
    Register_File rf_inst (
        .clk(clk),
        .rst(rst),
        .WriteEnable3(RegWrite),
        .WD3(reg_write_data),
        .Address1(instruction[19:15]),  // rs1
        .Address2(instruction[24:20]),  // rs2  
        .Address3(instruction[11:7]),   // rd
        .RD1(reg_data1),
        .RD2(reg_data2)
    );
    
    // Sign Extend
    Sign_Extend sext_inst (
        .Ins(instruction),
        .Imm_src(ImmSrc),
        .ImmExt(immediate)
    );
    
    // ALU Source B Multiplexer
    Mux alu_srcb_mux (
        .in_1(reg_data2),
        .in_2(immediate),
        .sel(ALUSrc),
        .out(ALU_srcB)
    );
    
    // ALU
    ALU alu_inst (
        .A(reg_data1),
        .B(ALU_srcB),
        .ALUControl(ALUControl),
        .Result(ALU_result),
        .Zero(Zero)
    );
    
    // Controller  
    Controller ctrl_inst (
        .Zero(Zero),
        .inst(instruction),
        .RegWrite_E(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite_E(MemWrite),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .ALUControl(ALUControl)
    );
    
    // Data Memory
    Data_Memory dmem_inst (
        .clk(clk),
        .rst(rst),
        .WE(MemWrite),
        .WD(reg_data2),
        .A(ALU_result),
        .RD(memory_read_data)
    );
    
    // Result Multiplexer (ALU result vs Memory data)
    Mux result_mux (
        .in_1(ALU_result),
        .in_2(memory_read_data), 
        .sel(ResultSrc),
        .out(reg_write_data)
    );
    
    // Clock generation
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end
    
    // VCD dump
    initial begin
        $dumpfile("Simple_CPU_Test_tb.vcd");
        $dumpvars(0, Simple_CPU_Test_tb);
    end
    
    // Main test sequence
    initial begin
        $display("=== Simple CPU Test ===");
        
        cycle_count = 0;
        
        // Initialize CPU
        rst = 0;  // Apply reset (active low)
        #15;      // Hold reset for a while
        
        $display("During reset - PC: 0x%08x, Instr: 0x%08x", PC_current, instruction);
        
        rst = 1;  // Release reset
        #5;       // Small delay
        
        $display("After reset - PC: 0x%08x, Instr: 0x%08x", PC_current, instruction);
        
        // Show what instruction is at address 0
        $display("Checking instruction at address 0:");
        $display("Mem[0] = 0x%08x", imem_inst.mem[0]);
        $display("Mem[1] = 0x%08x", imem_inst.mem[1]); 
        $display("Mem[2] = 0x%08x", imem_inst.mem[2]);
        
        // Execute several cycles
        repeat(10) begin
            $display("\n--- Cycle %0d ---", cycle_count);
            $display("Before clk - PC: 0x%08x, Instr: 0x%08x", PC_current, instruction);
            $display("RegWrite: %b, ALU_result: 0x%08x, reg_write_data: 0x%08x", RegWrite, ALU_result, reg_write_data);
            
            @(posedge clk);
            #1; // Small delay for signals to settle
            cycle_count = cycle_count + 1;
            
            $display("After clk - PC: 0x%08x, Instr: 0x%08x", PC_current, instruction);
            
            // Show register values for x1, x2, x3, x4
            force rf_inst.Address1 = 5'd1;
            #1;
            $display("x1 = 0x%08x", rf_inst.RD1);
            force rf_inst.Address1 = 5'd2;
            #1;
            $display("x2 = 0x%08x", rf_inst.RD1);
            force rf_inst.Address1 = 5'd3;
            #1;
            $display("x3 = 0x%08x", rf_inst.RD1);
            force rf_inst.Address1 = 5'd4;
            #1;
            $display("x4 = 0x%08x", rf_inst.RD1);
            release rf_inst.Address1;
        end
        
        $display("\n=== Test Complete ===");
        #50;
        $finish;
    end

endmodule