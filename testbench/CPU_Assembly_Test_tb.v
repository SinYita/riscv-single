`timescale 1ns / 1ps
`include "define.v"

module CPU_Assembly_Test_tb;

    // Clock and reset
    reg clk, rst;
    
    // Test tracking
    reg test_passed;
    integer test_count;
    integer cycle_count;
    integer max_cycles = 30; // Prevent infinite loops
    
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
        $dumpfile("CPU_Assembly_Test_tb.vcd");
        $dumpvars(0, CPU_Assembly_Test_tb);
    end
    
    // Helper task to read register value
    task read_register;
        input [4:0] reg_addr;
        output [31:0] reg_value;
        begin
            // Force the register file to output the desired register
            force rf_inst.Address1 = reg_addr;
            #1;
            reg_value = rf_inst.RD1;
            release rf_inst.Address1;
        end
    endtask
    
    // Helper task to display instruction info
    task display_instruction;
        input [31:0] pc;
        input [31:0] instr;
        begin
            $display("PC: 0x%08x, Instruction: 0x%08x", pc, instr);
            case (instr[6:0])
                `OPCODE_RTYPE: begin
                    case ({instr[31:25], instr[14:12]})
                        {7'b0000000, 3'b000}: $display("  ADD x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0100000, 3'b000}: $display("  SUB x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0000000, 3'b100}: $display("  XOR x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0000000, 3'b110}: $display("  OR x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0000000, 3'b111}: $display("  AND x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0000000, 3'b001}: $display("  SLL x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0000000, 3'b101}: $display("  SRL x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0100000, 3'b101}: $display("  SRA x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0000000, 3'b010}: $display("  SLT x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        {7'b0000000, 3'b011}: $display("  SLTU x%0d, x%0d, x%0d", instr[11:7], instr[19:15], instr[24:20]);
                        default: $display("  Unknown R-type");
                    endcase
                end
                `OPCODE_ITYPE: begin
                    case (instr[14:12])
                        3'b000: $display("  ADDI x%0d, x%0d, %0d", instr[11:7], instr[19:15], $signed(instr[31:20]));
                        3'b100: $display("  XORI x%0d, x%0d, %0d", instr[11:7], instr[19:15], $signed(instr[31:20]));
                        3'b110: $display("  ORI x%0d, x%0d, %0d", instr[11:7], instr[19:15], $signed(instr[31:20]));
                        3'b111: $display("  ANDI x%0d, x%0d, %0d", instr[11:7], instr[19:15], $signed(instr[31:20]));
                        3'b001: $display("  SLLI x%0d, x%0d, %0d", instr[11:7], instr[19:15], instr[24:20]);
                        3'b101: begin
                            if (instr[30] == 0)
                                $display("  SRLI x%0d, x%0d, %0d", instr[11:7], instr[19:15], instr[24:20]);
                            else
                                $display("  SRAI x%0d, x%0d, %0d", instr[11:7], instr[19:15], instr[24:20]);
                        end
                        default: $display("  Unknown I-type");
                    endcase
                end
                `OPCODE_LOAD: $display("  LW x%0d, %0d(x%0d)", instr[11:7], $signed(instr[31:20]), instr[19:15]);
                `OPCODE_STORE: $display("  SW x%0d, %0d(x%0d)", instr[24:20], $signed({instr[31:25], instr[11:7]}), instr[19:15]);
                `OPCODE_BRANCH: begin
                    case (instr[14:12])
                        3'b000: $display("  BEQ x%0d, x%0d, %0d", instr[19:15], instr[24:20], $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
                        3'b001: $display("  BNE x%0d, x%0d, %0d", instr[19:15], instr[24:20], $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
                        default: $display("  Unknown Branch");
                    endcase
                end
                `OPCODE_LUI: $display("  LUI x%0d, 0x%05x", instr[11:7], instr[31:12]);
                default: $display("  Unknown opcode: 0x%02x", instr[6:0]);
            endcase
        end
    endtask
    
    // Helper task to check register values
    task check_register;
        input [4:0] reg_addr;
        input [31:0] expected_value;
        input [255:0] test_name;
        reg [31:0] actual_value;
        begin
            read_register(reg_addr, actual_value);
            if (actual_value == expected_value) begin
                $display("✓ PASS: %s - x%0d = 0x%08x", test_name, reg_addr, actual_value);
            end else begin
                $display("✗ FAIL: %s - x%0d expected 0x%08x, got 0x%08x", 
                         test_name, reg_addr, expected_value, actual_value);
                test_passed = 0;
            end
            test_count = test_count + 1;
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("=== RISC-V Single Cycle CPU Assembly Test ===");
        $display("Testing CPU with simple_test.s assembly program");
        
        test_passed = 1;
        test_count = 0;
        cycle_count = 0;
        
        // Initialize CPU
        rst = 0;  // Apply reset (active low)
        #20;
        rst = 1;  // Release reset
        #5;     // Short delay for reset to take effect
        
        $display("\n=== CPU初始化完成，开始执行汇编程序 ===");
        $display("复位后PC值: 0x%08x, 指令: 0x%08x", PC_current, instruction);
        
        // Execute program step by step
        while (cycle_count < max_cycles) begin
            // Display current instruction before execution
            display_instruction(PC_current, instruction);
            
            // Execute one clock cycle
            @(posedge clk);
            #1; // Allow signals to settle
            cycle_count = cycle_count + 1;
            
            // Display register changes (we'll just show PC for now to avoid complexity)
            
            // Check if we hit the infinite loop at the end
            if (PC_current == 32'h54 && instruction == 32'h00000063) begin
                $display("  程序结束：到达无限循环");
                cycle_count = max_cycles; // Exit loop
            end
        end
        
        $display("\n=== 程序执行完成，开始验证结果 ===");
        
        // Test the expected results based on our assembly program
        
        // After "addi x1, x0, 10" and "addi x2, x0, 20"
        check_register(1, 32'd10, "立即数加载测试：x1 = 10");
        check_register(2, 32'd20, "立即数加载测试：x2 = 20");
        
        // After "add x3, x1, x2" -> x3 should be 30
        check_register(3, 32'd30, "R型加法测试：x3 = x1 + x2 = 30");
        
        // After "sub x4, x2, x1" -> x4 should be 10  
        check_register(4, 32'd10, "R型减法测试：x4 = x2 - x1 = 10");
        
        // After "xor x5, x1, x2" -> x5 should be 10 XOR 20 = 30
        check_register(5, 32'd30, "XOR测试：x5 = x1 XOR x2 = 30");
        
        // After "or x6, x1, x2" -> x6 should be 10 OR 20 = 30
        check_register(6, 32'd30, "OR测试：x6 = x1 OR x2 = 30");
        
        // After "and x7, x1, x2" -> x7 should be 10 AND 20 = 0
        check_register(7, 32'd0, "AND测试：x7 = x1 AND x2 = 0");
        
        // After "xori x8, x1, 15" -> x8 should be 10 XOR 15 = 5
        check_register(8, 32'd5, "立即数XOR测试：x8 = x1 XOR 15 = 5");
        
        // After "ori x9, x1, 7" -> x9 should be 10 OR 7 = 15
        check_register(9, 32'd15, "立即数OR测试：x9 = x1 OR 7 = 15");
        
        // After "andi x10, x1, 14" -> x10 should be 10 AND 14 = 10
        check_register(10, 32'd10, "立即数AND测试：x10 = x1 AND 14 = 10");
        
        // After "slli x11, x1, 2" -> x11 should be 10 << 2 = 40
        check_register(11, 32'd40, "左移测试：x11 = x1 << 2 = 40");
        
        // After "srli x12, x3, 1" -> x12 should be 30 >> 1 = 15
        check_register(12, 32'd15, "右移测试：x12 = x3 >> 1 = 15");
        
        // After "slt x13, x1, x2" -> x13 should be 1 (10 < 20)
        check_register(13, 32'd1, "小于比较测试：x13 = (x1 < x2) = 1");
        
        // After "sltu x14, x1, x2" -> x14 should be 1 (10 < 20 unsigned)
        check_register(14, 32'd1, "无符号小于比较测试：x14 = (x1 < x2) = 1");
        
        // After "addi x15, x0, 100" -> x15 should be 100
        check_register(15, 32'd100, "内存地址设置：x15 = 100");
        
        // After load/store operations and branch, x16 should equal x3 (30)
        check_register(16, 32'd30, "内存加载测试：x16 = 从内存加载的x3值 = 30");
        
        // After "lui x17, 0x1234" -> x17 should be 0x12340000
        check_register(17, 32'h12340000, "上位立即数测试：x17 = 0x12340000");
        
        // After successful branch, x18 should be 100 (not 999)
        check_register(18, 32'd100, "分支测试：x18 = 100（跳转成功）");
        
        $display("\n=== 测试摘要 ===");
        if (test_passed) begin
            $display("🎉 所有测试通过！(%0d/%0d)", test_count, test_count);
            $display("✅ RISC-V单周期CPU成功执行了汇编程序！");
            $display("✅ 所有指令类型都工作正常：");
            $display("   - I型指令（立即数操作）✓");
            $display("   - R型指令（寄存器操作）✓");  
            $display("   - 内存操作（加载/存储）✓");
            $display("   - 分支指令 ✓");
            $display("   - 上位立即数指令 ✓");
        end else begin
            $display("❌ 部分测试失败！请检查CPU实现。");
        end
        
        $display("\n执行统计：");
        $display("  执行的时钟周期数：%0d", cycle_count);
        $display("  执行的指令数：~%0d", cycle_count - 2);
        $display("  最终PC值：0x%08x", PC_current);
        
        #50;
        $finish;
    end

endmodule